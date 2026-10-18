import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/student_model.dart';
import '../../models/admission_model.dart';
import '../../models/certificate_model.dart';
import '../../services/firestore_service.dart';
import '../../core/utils/certificate_helper.dart';
import '../../widgets/categorized_student_picker.dart';
import 'package:go_router/go_router.dart'; // New

class AdminCertificatesPage extends ConsumerStatefulWidget {
  const AdminCertificatesPage({super.key});

  @override
  ConsumerState<AdminCertificatesPage> createState() => _AdminCertificatesPageState();
}

class _AdminCertificatesPageState extends ConsumerState<AdminCertificatesPage> {
  String _searchQuery = '';

  void _openIssueDialog() async {
    final firestoreService = ref.read(firestoreServiceProvider);
    // 1. Fetch approved admissions
    final approvedAdmissions = await firestoreService.getAdmissions(status: 'approved').first;
    
    // 2. Filter out Tuition students
    final eligibleStudents = approvedAdmissions.where((a) => a.studentType == StudentType.course).toList();

    if (!mounted) return;
    if (eligibleStudents.isEmpty) {
      Fluttertoast.showToast(msg: 'No eligible course students available');
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => _IssueCertificateDialog(students: eligibleStudents),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);

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
                Text('Certificates Management',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: -0.5)),
                SizedBox(height: 6),
                Text('Manage and verify issued student certificates.',
                    style: TextStyle(color: AppColors.textLight, fontSize: 14)),
              ],
            );

            final actions = Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => showDialog(context: context, builder: (_) => const _VerifyManualDialog()),
                  icon: const Icon(Icons.qr_code_scanner, size: 18),
                  label: const Text('Verify Manually'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                ),
                ElevatedButton.icon(
                  onPressed: _openIssueDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Issue Certificate'),
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

          // Search Bar integrated with style
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
                hintText: 'Search by Student Name or Certificate ID...',
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
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),

          const SizedBox(height: 32),

          StreamBuilder<List<CertificateModel>>(
            stream: firestoreService.getCertificates(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              var certs = snapshot.data ?? [];
              if (_searchQuery.isNotEmpty) {
                certs = certs.where((c) => 
                  c.studentName.toLowerCase().contains(_searchQuery) ||
                  c.certificateId.toLowerCase().contains(_searchQuery)
                ).toList();
              }

              if (certs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(48),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('No certificates found', style: TextStyle(color: AppColors.textLight)),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: certs.length,
                itemBuilder: (context, index) {
                  final cert = certs[index];
                  return _CertificateRow(
                    cert: cert,
                    onPrint: () => CertificateHelper.generateAndPrint(cert),
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Certificate?'),
                          content: const Text('This will permanently remove the certificate record. This action cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: TextButton.styleFrom(foregroundColor: AppColors.error),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await firestoreService.deleteCertificate(cert.id!);
                        Fluttertoast.showToast(msg: 'Certificate deleted');
                      }
                    },
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

class _VerifyManualDialog extends StatefulWidget {
  const _VerifyManualDialog();
  @override
  State<_VerifyManualDialog> createState() => _VerifyManualDialogState();
}

class _VerifyManualDialogState extends State<_VerifyManualDialog> {
  final _idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manual Verification', style: TextStyle(fontWeight: FontWeight.w900)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter the Certificate ID to verify its authenticity.', style: TextStyle(fontSize: 13, color: AppColors.textLight)),
          const SizedBox(height: 20),
          TextField(
            controller: _idController,
            decoration: InputDecoration(
              labelText: 'Certificate ID (e.g. MVC-2025-001)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final id = _idController.text.trim();
            if (id.isNotEmpty) {
              Navigator.pop(context);
              context.push('/verify/$id');
            }
          },
          child: const Text('Verify Now'),
        ),
      ],
    );
  }
}

class _IssueCertificateDialog extends ConsumerStatefulWidget {
  final List<AdmissionModel> students;
  const _IssueCertificateDialog({required this.students});

  @override
  ConsumerState<_IssueCertificateDialog> createState() => _IssueCertificateDialogState();
}

class _IssueCertificateDialogState extends ConsumerState<_IssueCertificateDialog> {
  AdmissionModel? _selectedStudent;
  DateTime _completionDate = DateTime.now();
  final _instructorController = TextEditingController(text: 'Muzammil Khan');
  final _projectTitleController = TextEditingController(text: 'Flutter Game Development Project');
  final _roleController = TextEditingController(text: 'Flutter Game Developer');
  final _periodController = TextEditingController(text: '2 Months');
  final _organizationController = TextEditingController(text: 'MAI Gaming Studio');

  String _certificateType = 'training'; // 'training' or 'experience'
  bool _issuing = false;

  @override
  void dispose() {
    _instructorController.dispose();
    _projectTitleController.dispose();
    _roleController.dispose();
    _periodController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  Future<void> _issue() async {
    if (_selectedStudent == null) return;
    setState(() => _issuing = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final isExp = _certificateType == 'experience';
      final certId = await firestoreService.generateCertificateId(isExperience: isExp);

      final cert = CertificateModel(
        certificateId: certId,
        studentId: _selectedStudent!.id ?? '',
        studentName: _selectedStudent!.fullName,
        courseName: AppConstants.formatCourseName(_selectedStudent!.selectedCourse),
        courseId: _selectedStudent!.selectedCourse,
        completionDate: _completionDate,
        issuedDate: DateTime.now(),
        instructorName: _instructorController.text.trim(),
        createdAt: DateTime.now(),
        certificateType: _certificateType,
        projectTitle: isExp ? _projectTitleController.text.trim() : null,
        role: isExp ? _roleController.text.trim() : null,
        experiencePeriod: isExp ? _periodController.text.trim() : null,
        organizationName: isExp ? _organizationController.text.trim() : (_selectedStudent!.branchName.contains('Gaming') ? 'MAI Gaming Studio' : 'MAI Coaching Academy'),
      );

      await firestoreService.issueCertificate(cert);
      
      if (mounted) {
        setState(() => _issuing = false);
        Navigator.pop(context);
        Fluttertoast.showToast(msg: '${isExp ? "Experience" : "Training"} Certificate issued successfully');
      }

      Future.microtask(() => CertificateHelper.generateAndPrint(cert));
    } catch (e) {
      if (mounted) setState(() => _issuing = false);
      Fluttertoast.showToast(msg: 'Error issuing certificate: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isExp = _certificateType == 'experience';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: screenWidth < 500 ? screenWidth * 0.95 : 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Issue New Certificate',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _certificateType,
                decoration: const InputDecoration(labelText: 'Certificate Type *'),
                items: const [
                  DropdownMenuItem(value: 'training', child: Text('Training / Course Certificate')),
                  DropdownMenuItem(value: 'experience', child: Text('Experience Certificate')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _certificateType = v);
                },
              ),
              const SizedBox(height: 16),
              
              CategorizedStudentPicker(
                students: widget.students,
                selectedStudent: _selectedStudent,
                onSelected: (v) {
                  setState(() {
                    _selectedStudent = v;
                    if (v.branchName.contains('Gaming')) {
                      _organizationController.text = 'MAI Gaming Studio';
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              if (isExp) ...[
                TextFormField(
                  controller: _projectTitleController,
                  decoration: const InputDecoration(labelText: 'Game / Project Title *', hintText: 'e.g. 2D Action Platformer Game'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _roleController,
                  decoration: const InputDecoration(labelText: 'Role *', hintText: 'e.g. Flutter Game Developer'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _periodController,
                  decoration: const InputDecoration(labelText: 'Experience / Training Period', hintText: 'e.g. 2 Months'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _organizationController,
                  decoration: const InputDecoration(labelText: 'Issuing Organization', hintText: 'e.g. MAI Gaming Studio'),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _instructorController,
                decoration: const InputDecoration(labelText: 'Instructor / Lead Name'),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _completionDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _completionDate = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Completion / Issue Date'),
                  child: Text(DateFormat('MMM d, yyyy').format(_completionDate)),
                ),
              ),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: (_selectedStudent == null || _issuing) ? null : _issue,
                    child: _issuing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Generate & Export QR'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CertificateRow extends StatelessWidget {
  final CertificateModel cert;
  final VoidCallback onPrint;
  final VoidCallback onDelete;
  const _CertificateRow({required this.cert, required this.onPrint, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isExp = cert.isExperience;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isExp ? Colors.purple.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isExp ? Icons.verified_user_rounded : Icons.workspace_premium,
              color: isExp ? Colors.purple : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(cert.studentName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isExp ? Colors.purple.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isExp ? 'EXPERIENCE' : 'TRAINING',
                        style: TextStyle(
                          color: isExp ? Colors.purple : AppColors.primary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isExp
                      ? '${cert.role ?? "Developer"} (${cert.projectTitle ?? "Game Project"}) • ${cert.certificateId}'
                      : '${AppConstants.formatCourseName(cert.courseName)} • ${cert.certificateId}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.print_outlined, color: AppColors.textLight, size: 20),
            onPressed: onPrint,
            tooltip: 'Print/Download QR',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: onDelete,
            tooltip: 'Delete Record',
          ),
        ],
      ),
    );
  }
}
