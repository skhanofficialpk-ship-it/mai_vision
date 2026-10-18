import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/file_download_helper.dart';
import '../../models/admission_model.dart';
import '../../models/student_model.dart';
import '../../services/firestore_service.dart';
import '../../services/fee_service.dart';
import '../../widgets/admission_form_widget.dart';

// StreamProvider to prevent redundant stream re-creation on re-builds
final admissionsStreamProvider = StreamProvider<List<AdmissionModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getAdmissions();
});

class AdminAdmissionsPage extends ConsumerStatefulWidget {
  const AdminAdmissionsPage({super.key});

  @override
  ConsumerState<AdminAdmissionsPage> createState() => _AdminAdmissionsPageState();
}

class _AdminAdmissionsPageState extends ConsumerState<AdminAdmissionsPage> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  void _exportCsv(List<AdmissionModel> admissions) {
    if (admissions.isEmpty) {
      Fluttertoast.showToast(msg: 'No records to export');
      return;
    }

    final rows = <List<String>>[
      [
        'Full Name',
        'Father Name',
        'Phone/WhatsApp',
        'Email',
        'Address',
        'Qualification',
        'Selected Course',
        'CNIC/B-Form',
        'Status',
        'Applied On'
      ],
      ...admissions.map((a) => [
        a.fullName,
        a.fatherName,
        a.phone,
        a.email,
        a.address,
        a.qualification,
        a.selectedCourse,
        a.cnicBForm ?? '',
        a.status,
        DateFormat('yyyy-MM-dd').format(a.createdAt),
      ]),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final bytes = Uint8List.fromList(utf8.encode(csv));
    final fileName = 'admissions_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.csv';
    downloadFile(bytes, fileName);
    Fluttertoast.showToast(msg: 'CSV downloaded (${admissions.length} records)');
  }

  List<AdmissionModel> _filterAdmissions(List<AdmissionModel> originalList) {
    var filtered = originalList;
    if (_statusFilter != 'all') {
      filtered = filtered.where((a) => a.status == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((a) {
        return a.fullName.toLowerCase().contains(_searchQuery) ||
            a.email.toLowerCase().contains(_searchQuery) ||
            a.phone.contains(_searchQuery);
      }).toList();
    }
    return filtered;
  }

  void _openAddAdmission() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Manual Admission Entry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                AdmissionFormWidget(
                  isAdmin: true,
                  onSuccess: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admissionsAsync = ref.watch(admissionsStreamProvider);

    return admissionsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text('Error loading admissions: $err'),
        ),
      ),
      data: (allAdmissions) {
        final filteredAdmissions = _filterAdmissions(allAdmissions);

        return SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width < 700 ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 650;
                final headerInfo = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Admissions Management',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: -0.5),
                    ),
                    SizedBox(height: 6),
                    Text('Review and approve new student applications.',
                        style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                  ],
                );
                
                final actions = Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: filteredAdmissions.isEmpty
                          ? null
                          : () => _exportCsv(filteredAdmissions),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Export CSV'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _openAddAdmission,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('New Admission'),
                    ),
                  ],
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      headerInfo,
                      const SizedBox(height: 20),
                      actions,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: headerInfo),
                    const SizedBox(width: 16),
                    actions,
                  ],
                );
              }),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 600;
                  final searchField = Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by name, email, or phone...',
                        prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    ),
                  );
                  final filterDropdown = Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _statusFilter,
                      decoration: const InputDecoration(
                        filled: true, 
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Status')),
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'approved', child: Text('Approved')),
                        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                      ],
                      onChanged: (v) => setState(() => _statusFilter = v ?? 'all'),
                    ),
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        searchField,
                        const SizedBox(height: 16),
                        filterDropdown,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(flex: 2, child: searchField),
                      const SizedBox(width: 16),
                      Expanded(child: filterDropdown),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              if (filteredAdmissions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(48),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('No admissions found', style: TextStyle(color: AppColors.textLight)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredAdmissions.length,
                  itemBuilder: (context, index) {
                    final admission = filteredAdmissions[index];
                    return _AdmissionCard(
                      key: ValueKey(admission.id),
                      admission: admission,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AdmissionCard extends ConsumerStatefulWidget {
  final AdmissionModel admission;
  const _AdmissionCard({super.key, required this.admission});

  @override
  ConsumerState<_AdmissionCard> createState() => _AdmissionCardState();
}

class _AdmissionCardState extends ConsumerState<_AdmissionCard> {
  bool _expanded = false;
  bool _updating = false;

  Future<void> _updateStatus(String status) async {
    final id = widget.admission.id;
    if (id == null) {
      Fluttertoast.showToast(msg: 'Error: Admission ID is missing');
      return;
    }

    final a = widget.admission;
    setState(() => _updating = true);
    try {
      if (status == 'rejected') {
        // Direct permanent deletion of application form on Reject
        await ref.read(firestoreServiceProvider).deleteAdmission(id);

        // Clean up matching fee student record if present
        final feeSvc = ref.read(feeServiceProvider);
        final feeStudents = await feeSvc.getStudentsOnce();
        final sPhoneClean = a.phone.replaceAll(RegExp(r'\D'), '');
        final sNameClean = a.fullName.trim().toLowerCase();

        for (final fs in feeStudents) {
          final fsPhoneClean = fs.phone.replaceAll(RegExp(r'\D'), '');
          final fsNameClean = fs.fullName.trim().toLowerCase();

          final isMatch = (sNameClean.isNotEmpty && fsNameClean == sNameClean) ||
              (sPhoneClean.isNotEmpty && fsPhoneClean.isNotEmpty && fsPhoneClean == sPhoneClean);

          if (isMatch && fs.id != null) {
            await feeSvc.deleteStudent(fs.id!);
          }
        }

        Fluttertoast.showToast(msg: 'Application rejected and form deleted permanently');
        return;
      }

      await ref.read(firestoreServiceProvider).updateAdmissionStatus(id, status);

      // If approved, automatically create a record in the Fee Management (students) collection
      if (status == 'approved') {
        final feeSvc = ref.read(feeServiceProvider);
        final studentId = await feeSvc.generateStudentId();
        final student = StudentModel(
          studentId: studentId,
          fullName: a.fullName,
          fatherName: a.fatherName,
          phone: a.phone,
          parentPhone: a.parentPhone,
          address: a.address,
          course: AppConstants.formatCourseName(a.selectedCourse),
          courseId: a.selectedCourse,
          studentType: a.studentType,
          selectedSubjects: a.selectedSubjects,
          branchId: a.branchId,
          branchName: a.branchName,
          batch: 'MAI-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}',
          totalFee: a.monthlyFee, 
          effectiveFee: a.monthlyFee,
          admissionDate: DateTime.now(),
          status: StudentStatus.active,
          outstanding: a.monthlyFee,
        );

        await feeSvc.addStudent(student);
        Fluttertoast.showToast(msg: 'Admission approved and student record created');
      } else {
        Fluttertoast.showToast(msg: 'Application status updated to $status');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update status: $e');
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.admission;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        a.fullName.isNotEmpty ? a.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(a.fullName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.text)),
                        Text(AppConstants.formatCourseName(a.selectedCourse),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: AppColors.textLight, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _statusColor(a.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      a.status.toUpperCase(),
                      style: TextStyle(
                          color: _statusColor(a.status), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 12),
                  _detailRow('Father Name', a.fatherName),
                _detailRow('Branch', a.branchName),
                _detailRow('Student Type', a.studentType.label), // New
                _detailRow('Phone / WhatsApp', a.phone),
                  if (a.parentPhone != null && a.parentPhone != 'N/A') _detailRow('Parent Phone', a.parentPhone!),
                  if (a.email != 'N/A') _detailRow('Email', a.email),
                  _detailRow('Address', a.address),
                  if (a.qualification != 'N/A') _detailRow('Qualification', a.qualification),
                  if (a.selectedSubjects.isNotEmpty) _detailRow('Subjects', a.selectedSubjects.join(', ')),
                  if (a.monthlyFee > 0) _detailRow('Monthly Fee', 'PKR ${a.monthlyFee.toInt()}'),
                  if (a.cnicBForm != null && a.cnicBForm != 'N/A') _detailRow('CNIC/B-Form', a.cnicBForm!),
                  _detailRow('Applied', DateFormat('MMM d, yyyy • h:mm a').format(a.createdAt)),
                  const SizedBox(height: 16),
                  if (a.status == 'pending')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _updating ? null : () => _updateStatus('approved'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Approve'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _updating ? null : () => _updateStatus('rejected'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Reject'),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _updating ? null : () => _updateStatus('pending'),
                        child: const Text('Reset to Pending'),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textLight)),
                Text(value,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text)),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 120,
                  child: Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textLight))),
              Expanded(
                  child: Text(value,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text))),
            ],
          );
        },
      ),
    );
  }
}
