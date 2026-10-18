import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../core/constants/app_constants.dart';
import '../models/student_model.dart';
import '../models/admission_model.dart';
import '../models/course_model.dart';
import '../models/branch_model.dart';
import '../providers/courses_provider.dart';
import '../services/firestore_service.dart';
import '../services/branch_service.dart';

class AdmissionFormWidget extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;
  final bool isAdmin;

  const AdmissionFormWidget({super.key, this.onSuccess, this.isAdmin = false});

  @override
  ConsumerState<AdmissionFormWidget> createState() => _AdmissionFormWidgetState();
}

class _AdmissionFormWidgetState extends ConsumerState<AdmissionFormWidget> {
  final _formKey = GlobalKey<FormState>();
  
  final _fullName = TextEditingController();
  final _fatherName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _monthlyFee = TextEditingController();
  final _tuitionClass = TextEditingController();

  StudentType _studentType = StudentType.course; 
  String? _selectedCourse;
  String? _selectedBranchId;
  bool _submitting = false;

  @override
  void dispose() {
    _fullName.dispose(); _fatherName.dispose(); _phone.dispose();
    _address.dispose(); _monthlyFee.dispose(); _tuitionClass.dispose();
    super.dispose();
  }

  void _onBranchSelected(String branchId, List<BranchModel> branches, List<CourseModel> courses) {
    setState(() {
      _selectedBranchId = branchId;
      final selectedBranch = branches.firstWhere(
        (b) => b.id == branchId,
        orElse: () => branches.first,
      );

      // If MAI Gaming Studio branch is selected:
      // Auto-set Admission Type = Course Admission, Course = Flutter Game Development & Fee
      if (selectedBranch.isGamingStudio ||
          selectedBranch.id == 'manglor' ||
          selectedBranch.name.toLowerCase().contains('gaming')) {
        _studentType = StudentType.course;
        
        final flutterCourse = courses.firstWhere(
          (c) => c.id == 'flutter_game_dev' || c.id == 'flutter_development' || c.name.toLowerCase().contains('flutter'),
          orElse: () => courses.isNotEmpty ? courses.first : defaultCourses[0],
        );
        _selectedCourse = flutterCourse.id;
        _monthlyFee.text = flutterCourse.totalFee.toInt().toString();
      }
    });
  }

  void _updateFee(List<CourseModel> courses) {
    if (_studentType == StudentType.course && _selectedCourse != null) {
      final c = courses.firstWhere(
        (c) => c.id == _selectedCourse,
        orElse: () => courses.isNotEmpty ? courses.first : defaultCourses[0],
      );
      _monthlyFee.text = c.totalFee.toInt().toString();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_studentType == StudentType.course && _selectedCourse == null) {
      Fluttertoast.showToast(msg: 'Please select a course');
      return;
    }
    
    if (_selectedBranchId == null) {
      Fluttertoast.showToast(msg: 'Please select branch');
      return;
    }

    setState(() => _submitting = true);
    try {
      final branches = await ref.read(branchServiceProvider).getBranches().first;
      final branch = branches.firstWhere((b) => b.id == _selectedBranchId);
      final courses = await ref.read(coursesProvider.future);

      final finalCourseName = _studentType == StudentType.course
          ? courses.firstWhere((c) => c.id == _selectedCourse, orElse: () => defaultCourses[0]).name
          : 'Tuition: ${_tuitionClass.text.trim()}';

      final admission = AdmissionModel(
        fullName: _fullName.text.trim(),
        fatherName: _fatherName.text.trim(),
        phone: _phone.text.trim(),
        email: 'N/A', 
        address: _address.text.trim(),
        qualification: 'N/A', 
        selectedCourse: finalCourseName,
        studentType: _studentType,
        branchId: _selectedBranchId!,
        branchName: branch.name,
        monthlyFee: double.tryParse(_monthlyFee.text) ?? 0,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      await ref.read(firestoreServiceProvider).submitAdmission(admission);
      if (mounted) {
        Fluttertoast.showToast(msg: 'Admission submitted successfully');
        widget.onSuccess?.call();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Submission failed: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final branchesStream = ref.watch(branchServiceProvider).getBranches();
    final loadedCourses = coursesAsync.valueOrNull ?? defaultCourses;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField('Student Full Name *', _fullName),
          const SizedBox(height: 16),
          _buildField('Father Name *', _fatherName),
          const SizedBox(height: 16),
          _buildField('Phone / WhatsApp *', _phone, keyboard: TextInputType.phone),
          const SizedBox(height: 16),
          _buildField('Residential Address *', _address),
          const SizedBox(height: 16),

          DropdownButtonFormField<StudentType>(
            value: _studentType,
            decoration: const InputDecoration(labelText: 'Admission Type *'),
            items: StudentType.values.map((t) => DropdownMenuItem(value: t, child: Text('${t.label} Admission'))).toList(),
            onChanged: (v) {
              setState(() {
                _studentType = v!;
                if (_studentType == StudentType.tuition) {
                  _selectedCourse = null;
                  _monthlyFee.text = '';
                } else if (_selectedCourse != null) {
                  _updateFee(loadedCourses);
                }
              });
            },
          ),
          const SizedBox(height: 16),

          StreamBuilder<List<BranchModel>>(
            stream: branchesStream,
            builder: (context, snap) {
              final branches = (snap.data ?? []).where((b) => b.isActive).toList();
              return DropdownButtonFormField<String>(
                value: _selectedBranchId,
                decoration: const InputDecoration(labelText: 'Select Branch *'),
                items: branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                onChanged: (v) {
                  if (v != null) {
                    _onBranchSelected(v, branches, loadedCourses);
                  }
                },
                validator: (v) => v == null ? 'Required' : null,
              );
            },
          ),
          const SizedBox(height: 16),

          // Conditional Fields: Course for Academy, Class for Tuition
          if (_studentType == StudentType.course)
            coursesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading courses'),
              data: (courses) {
                final validCourse = courses.any((c) => c.id == _selectedCourse)
                    ? _selectedCourse
                    : (courses.any((c) => c.name == _selectedCourse)
                        ? courses.firstWhere((c) => c.name == _selectedCourse).id
                        : null);

                // Auto populate fee if missing
                if (validCourse != null && _monthlyFee.text.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _monthlyFee.text.isEmpty) {
                      _updateFee(courses);
                    }
                  });
                }

                return DropdownButtonFormField<String>(
                  value: validCourse,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Select Course *'),
                  items: courses.map((c) => DropdownMenuItem(value: c.id, child: Text(AppConstants.formatCourseName(c.name)))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedCourse = v;
                      _updateFee(courses);
                    });
                  },
                  validator: (v) => v == null ? 'Required' : null,
                );
              },
            )
          else
            _buildField('Enter Class Name * (e.g. 9th Science, 2nd Year)', _tuitionClass),
          
          const SizedBox(height: 16),
          
          _buildField(
            'Calculated Fee (PKR) *', 
            _monthlyFee, 
            keyboard: TextInputType.number,
            readOnly: !widget.isAdmin && _studentType == StudentType.course,
            suffix: (widget.isAdmin || _studentType == StudentType.tuition) ? null : const Icon(Icons.lock_outline, size: 16),
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
              child: _submitting
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text(widget.isAdmin ? 'Add Admission' : 'Submit Application'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {TextInputType? keyboard, bool readOnly = false, Widget? suffix}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffix,
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }
}
