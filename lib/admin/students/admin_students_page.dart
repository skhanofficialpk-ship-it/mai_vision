import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/admission_model.dart';
import '../../services/firestore_service.dart';
import '../../services/fee_service.dart';

class AdminStudentsPage extends ConsumerStatefulWidget {
  const AdminStudentsPage({super.key});

  @override
  ConsumerState<AdminStudentsPage> createState() => _AdminStudentsPageState();
}

class _AdminStudentsPageState extends ConsumerState<AdminStudentsPage> {
  String _search = '';

  void _openEditDialog(AdmissionModel s) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _EditStudentDialog(student: s),
    );
  }

  Future<void> _deleteStudent(AdmissionModel s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student?'),
        content: Text('Are you sure you want to permanently delete ${s.fullName}? This will remove their record from Student Registry and Fee Management.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && s.id != null) {
      try {
        // 1. Delete admission document
        await ref.read(firestoreServiceProvider).deleteAdmission(s.id!);

        // 2. Delete matching fee student document(s) in 'students' collection
        final feeSvc = ref.read(feeServiceProvider);
        final feeStudents = await feeSvc.getStudentsOnce();
        final sPhoneClean = s.phone.replaceAll(RegExp(r'\D'), '');
        final sNameClean = s.fullName.trim().toLowerCase();

        for (final fs in feeStudents) {
          final fsPhoneClean = fs.phone.replaceAll(RegExp(r'\D'), '');
          final fsNameClean = fs.fullName.trim().toLowerCase();

          final isMatch = (sNameClean.isNotEmpty && fsNameClean == sNameClean) ||
              (sPhoneClean.isNotEmpty && fsPhoneClean.isNotEmpty && fsPhoneClean == sPhoneClean);

          if (isMatch && fs.id != null) {
            await feeSvc.deleteStudent(fs.id!);
          }
        }

        Fluttertoast.showToast(msg: 'Student deleted from Registry and Fee Management');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Failed to delete: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 700 ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student Registry',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: -0.5)),
          const SizedBox(height: 6),
          const Text('Approved applications successfully enrolled in the system.',
              style: TextStyle(color: AppColors.textLight, fontSize: 14)),
          const SizedBox(height: 32),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name, email, or course...',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
          ),
          
          const SizedBox(height: 32),
          StreamBuilder<List<AdmissionModel>>(
            stream: firestoreService.getAdmissions(status: 'approved'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(100),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              var students = snapshot.data ?? [];
              if (_search.isNotEmpty) {
                students = students
                    .where((s) =>
                        s.fullName.toLowerCase().contains(_search) ||
                        s.email.toLowerCase().contains(_search) ||
                        s.selectedCourse.toLowerCase().contains(_search))
                    .toList();
              }

              if (students.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(60),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('No enrolled students found.', style: TextStyle(color: AppColors.textLight)),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final s = students[index];
                  return _StudentListRow(
                    student: s, 
                    onEdit: () => _openEditDialog(s),
                    onDelete: () => _deleteStudent(s),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StudentListRow extends StatelessWidget {
  final AdmissionModel student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StudentListRow({
    required this.student,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : 'S', 
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
          ),
          title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.text)),
          subtitle: Text('${AppConstants.formatCourseName(student.selectedCourse)} • ${student.phone}', 
              style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w500, fontSize: 13)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                onPressed: onEdit,
                tooltip: 'Edit Student Details',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                onPressed: onDelete,
                tooltip: 'Delete Student Record',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditStudentDialog extends ConsumerStatefulWidget {
  final AdmissionModel student;
  const _EditStudentDialog({required this.student});

  @override
  ConsumerState<_EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends ConsumerState<_EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _fatherNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _courseController;
  late TextEditingController _feeController;
  late TextEditingController _cnicController;
  late TextEditingController _addressController;
  late TextEditingController _qualificationController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _fullNameController = TextEditingController(text: s.fullName);
    _fatherNameController = TextEditingController(text: s.fatherName);
    _phoneController = TextEditingController(text: s.phone);
    _emailController = TextEditingController(text: s.email);
    _courseController = TextEditingController(text: s.selectedCourse);
    _feeController = TextEditingController(text: s.monthlyFee.toStringAsFixed(0));
    _cnicController = TextEditingController(text: s.cnicBForm ?? '');
    _addressController = TextEditingController(text: s.address);
    _qualificationController = TextEditingController(text: s.qualification);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _fatherNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _courseController.dispose();
    _feeController.dispose();
    _cnicController.dispose();
    _addressController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final updatedCourse = _courseController.text.trim();
      final updatedData = {
        'fullName': _fullNameController.text.trim(),
        'fatherName': _fatherNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'selectedCourse': updatedCourse,
        'monthlyFee': double.tryParse(_feeController.text.trim()) ?? widget.student.monthlyFee,
        'cnicBForm': _cnicController.text.trim(),
        'address': _addressController.text.trim(),
        'qualification': _qualificationController.text.trim(),
      };

      // 1. Update Admission Document
      await ref.read(firestoreServiceProvider).updateAdmission(widget.student.id!, updatedData);

      // 2. Update matching Fee Student Document in 'students' collection
      final feeSvc = ref.read(feeServiceProvider);
      final feeStudents = await feeSvc.getStudentsOnce();
      final oldPhoneClean = widget.student.phone.replaceAll(RegExp(r'\D'), '');
      final oldNameClean = widget.student.fullName.trim().toLowerCase();

      for (final fs in feeStudents) {
        final fsPhoneClean = fs.phone.replaceAll(RegExp(r'\D'), '');
        final fsNameClean = fs.fullName.trim().toLowerCase();

        final isMatch = (oldNameClean.isNotEmpty && fsNameClean == oldNameClean) ||
            (oldPhoneClean.isNotEmpty && fsPhoneClean.isNotEmpty && fsPhoneClean == oldPhoneClean);

        if (isMatch && fs.id != null) {
          final newFee = double.tryParse(_feeController.text.trim()) ?? fs.totalFee;
          final feeUpdateData = {
            'fullName': _fullNameController.text.trim(),
            'fatherName': _fatherNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'course': AppConstants.formatCourseName(updatedCourse),
            'totalFee': newFee,
            'effectiveFee': newFee - fs.discount,
          };
          await feeSvc.updateStudent(fs.id!, feeUpdateData);
        }
      }

      Fluttertoast.showToast(msg: 'Student information updated successfully!');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 28),
          SizedBox(width: 10),
          Text('Edit Student Details', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                _field('Full Name', _fullNameController, required: true),
                const SizedBox(height: 12),
                _field('Father Name', _fatherNameController, required: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _field('Phone/WhatsApp', _phoneController, required: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Email Address', _emailController)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _field('Course Name', _courseController, required: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Monthly Fee (PKR)', _feeController, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _field('CNIC / B-Form', _cnicController)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Qualification', _qualificationController)),
                  ],
                ),
                const SizedBox(height: 12),
                _field('Address', _addressController, maxLines: 2),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _saving ? null : _saveChanges,
          icon: _saving 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : const Icon(Icons.check_rounded, size: 18),
          label: Text(_saving ? 'Saving...' : 'Save Changes'),
        ),
      ],
    );
  }

  Widget _field(
    String label, 
    TextEditingController controller, {
    bool required = false, 
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
          : null,
    );
  }
}
