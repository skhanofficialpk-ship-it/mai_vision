import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/student_model.dart';
import '../../models/payment_model.dart';
import '../../services/fee_service.dart';
import '../../services/firestore_service.dart';
import '../../providers/courses_provider.dart';
import '../../core/utils/report_export_helper.dart';

class AdminFeesPage extends ConsumerStatefulWidget {
  const AdminFeesPage({super.key});
  @override
  ConsumerState<AdminFeesPage> createState() => _AdminFeesPageState();
}

class _AdminFeesPageState extends ConsumerState<AdminFeesPage> {
  String _searchQuery = '';
  String _statusFilter = 'all'; // Enrollment status: 'all', 'active', 'inactive', 'graduated'
  String _feeStatusFilter = 'all'; // Payment status: 'all', 'paid', 'unpaid', 'overdue'
  String _selectedBranch = 'all';
  String _typeFilter = 'all';

  @override
  Widget build(BuildContext context) {
    // 1. Fetch ALL students
    final studentsAsync = ref.watch(_studentsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.sectionBg,
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allStudents) {
          // 2. Client-side Filter
          final filtered = allStudents.where((s) {
            final rem = (s.effectiveFee - s.totalPaid).clamp(0.0, double.infinity);
            final isPaid = rem <= 0;
            final isUnpaid = rem > 0;
            final isOverdue = rem > 0 && DateTime.now().day > s.feeDueDay;

            final matchesBranch = _selectedBranch == 'all' || s.branchId == _selectedBranch;
            final matchesStatus = _statusFilter == 'all' || s.status.value == _statusFilter;
            final matchesType = _typeFilter == 'all' || s.studentType.value == _typeFilter;

            bool matchesFeeStatus = true;
            if (_feeStatusFilter == 'paid') {
              matchesFeeStatus = isPaid;
            } else if (_feeStatusFilter == 'unpaid') {
              matchesFeeStatus = isUnpaid;
            } else if (_feeStatusFilter == 'overdue') {
              matchesFeeStatus = isOverdue;
            }

            final matchesSearch = _searchQuery.isEmpty || 
                s.fullName.toLowerCase().contains(_searchQuery) || 
                s.studentId.toLowerCase().contains(_searchQuery);

            return matchesBranch && matchesStatus && matchesType && matchesFeeStatus && matchesSearch;
          }).toList();

          // 3. Client-side Stats
          final totalOutstanding = filtered.fold(0.0, (prev, s) => prev + s.outstanding);
          final totalReceived = filtered.fold(0.0, (prev, s) => prev + s.totalPaid);
          final activeCount = filtered.where((s) => s.status == StudentStatus.active).length;

          final screenWidth = MediaQuery.of(context).size.width;
          final paddingVal = screenWidth < 600 ? 16.0 : 32.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(paddingVal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Responsive Header Bar
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fee Management', 
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: -0.5)),
                          const SizedBox(height: 4),
                          const Text('Monitor and record student fee payments.',
                              style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _openStudentForm(null),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('New Student'),
                            ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fee Management', 
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: -0.5)),
                            SizedBox(height: 6),
                            Text('Monitor and record student fee payments.',
                                style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _openStudentForm(null),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('New Student'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Stats Cards
                LayoutBuilder(builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 900;
                  if (isCompact) {
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: constraints.maxWidth < 500 ? 1 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: constraints.maxWidth < 500 ? 2.8 : 2.5,
                      children: [
                        _StatBox(label: 'Total Students', value: '${filtered.length}', color: AppColors.primary, icon: Icons.people_outline_rounded),
                        _StatBox(label: 'Active Enrolled', value: '$activeCount', color: AppColors.success, icon: Icons.check_circle_outline_rounded),
                        _StatBox(label: 'Total Received', value: 'PKR ${NumberFormat('#,##0').format(totalReceived)}', color: Colors.teal, icon: Icons.account_balance_wallet_outlined),
                        _StatBox(label: 'Total Receivables', value: 'PKR ${NumberFormat('#,##0').format(totalOutstanding)}', color: AppColors.error, icon: Icons.money_off_rounded),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: _StatBox(label: 'Total Students', value: '${filtered.length}', color: AppColors.primary, icon: Icons.people_outline_rounded)),
                      const SizedBox(width: 16),
                      Expanded(child: _StatBox(label: 'Active Enrolled', value: '$activeCount', color: AppColors.success, icon: Icons.check_circle_outline_rounded)),
                      const SizedBox(width: 16),
                      Expanded(child: _StatBox(label: 'Total Received', value: 'PKR ${NumberFormat('#,##0').format(totalReceived)}', color: Colors.teal, icon: Icons.account_balance_wallet_outlined)),
                      const SizedBox(width: 16),
                      Expanded(child: _StatBox(label: 'Total Receivables', value: 'PKR ${NumberFormat('#,##0').format(totalOutstanding)}', color: AppColors.error, icon: Icons.money_off_rounded)),
                    ],
                  );
                }),
                const SizedBox(height: 24),

                // Filters
                _buildFilterBar(),
                const SizedBox(height: 24),

                // Optimized List
                if (filtered.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                          SizedBox(height: 16),
                          Text('No matching student fee records found', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _StudentCard(
                      student: filtered[i],
                      onCollect: () => _openCollectFee(filtered[i]),
                      onHistory: () => _openHistory(filtered[i]),
                      onEdit: () => _openStudentForm(filtered[i]),
                      onDelete: () => _deleteStudentFeeRecord(filtered[i]),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 650;
          return Wrap(
            spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: isSmall ? double.infinity : 260, 
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by name or ID...', 
                    prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20), 
                    filled: true, 
                    fillColor: AppColors.sectionBg,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                ),
              ),
              _dropdown('Fee Payment', _feeStatusFilter, ['all', 'paid', 'unpaid', 'overdue']),
              _dropdown('Enroll Status', _statusFilter, ['all', 'active', 'inactive', 'graduated']),
              _dropdown('Type', _typeFilter, ['all', 'course', 'tuition']),
              _dropdown('Branch', _selectedBranch, ['all', 'charbagh', 'manglor']),
            ],
          );
        },
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items) {
    return SizedBox(
      width: 140, 
      child: DropdownButtonFormField<String>(
        value: value, 
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          filled: true,
          fillColor: AppColors.sectionBg,
          border: InputBorder.none,
        ),
        items: items.map((i) => DropdownMenuItem(
          value: i, 
          child: Text(
            i.toUpperCase(), 
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.text),
          ),
        )).toList(),
        onChanged: (v) => setState(() {
          if (label == 'Fee Payment') _feeStatusFilter = v!;
          else if (label == 'Enroll Status') _statusFilter = v!; 
          else if (label == 'Type') _typeFilter = v!;
          else _selectedBranch = v!;
        }),
      ),
    );
  }

  // ─── DIALOGS ───

  void _openStudentForm(StudentModel? s) {
    showDialog(context: context, builder: (_) => _StudentFormDialog(student: s));
  }

  void _openCollectFee(StudentModel s) {
    showDialog(context: context, builder: (_) => _CollectFeeDialog(student: s));
  }

  void _openHistory(StudentModel s) {
    showDialog(context: context, builder: (_) => _HistoryDialog(student: s));
  }

  Future<void> _deleteStudentFeeRecord(StudentModel student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student Record?'),
        content: Text(
          'Are you sure you want to permanently delete ${student.fullName} from Fee Management? This will also remove their payment history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && student.id != null) {
      try {
        final feeSvc = ref.read(feeServiceProvider);
        await feeSvc.deleteStudent(student.id!);

        // Also delete matching admission/registry record if present
        final firestoreService = ref.read(firestoreServiceProvider);
        final admissions = await firestoreService.getAdmissionsOnce();
        final sPhoneClean = student.phone.replaceAll(RegExp(r'\D'), '');
        final sNameClean = student.fullName.trim().toLowerCase();

        for (final a in admissions) {
          final aPhoneClean = a.phone.replaceAll(RegExp(r'\D'), '');
          final aNameClean = a.fullName.trim().toLowerCase();

          final isMatch = (sNameClean.isNotEmpty && aNameClean == sNameClean) ||
              (sPhoneClean.isNotEmpty && aPhoneClean.isNotEmpty && aPhoneClean == sPhoneClean);

          if (isMatch && a.id != null) {
            await firestoreService.deleteAdmission(a.id!);
          }
        }

        Fluttertoast.showToast(msg: 'Student deleted permanently');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Failed to delete: $e');
      }
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────
// SUB-WIDGETS
// ────────────────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label, value; 
  final Color color; 
  final IconData icon;

  const _StatBox({
    required this.label, 
    required this.value, 
    required this.color, 
    required this.icon,
  });

  @override 
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18), 
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(18), 
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textLight, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                const SizedBox(height: 3),
                Text(
                  value, 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StudentModel student; 
  final VoidCallback onCollect, onHistory, onEdit, onDelete;

  const _StudentCard({
    required this.student, 
    required this.onCollect, 
    required this.onHistory, 
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final rem = (student.effectiveFee - student.totalPaid).clamp(0.0, double.infinity);
    final isOverdue = rem > 0 && DateTime.now().day > student.feeDueDay;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final avatarAndName = Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : 'S', 
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 17),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.text)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: student.studentType == StudentType.course ? Colors.blue.withOpacity(0.1) : Colors.purple.withOpacity(0.1), 
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          student.studentType.label.toUpperCase(), 
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: student.studentType == StudentType.course ? Colors.blue : Colors.purple),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${student.studentId} • ${AppConstants.formatCourseName(student.course)}', style: const TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        );

        final balanceAndStatus = Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end, 
          children: [
            Text('PKR ${NumberFormat('#,##0').format(rem)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: rem > 0 ? AppColors.error : AppColors.success)),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: (rem > 0 ? (isOverdue ? Colors.red : Colors.orange) : Colors.green).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(rem > 0 ? (isOverdue ? 'OVERDUE' : 'PENDING') : 'PAID', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: rem > 0 ? (isOverdue ? Colors.red : Colors.orange) : Colors.green)),
            ),
          ],
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            _actionBtn(Icons.payments_outlined, AppColors.success, 'Collect', onCollect),
            const SizedBox(width: 6),
            _actionBtn(Icons.history_rounded, AppColors.primary, 'History', onHistory),
            const SizedBox(width: 6),
            _actionBtn(Icons.edit_outlined, AppColors.textMuted, 'Edit', onEdit),
            const SizedBox(width: 6),
            _actionBtn(Icons.delete_outline_rounded, AppColors.error, 'Delete', onDelete),
          ],
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatarAndName,
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  balanceAndStatus,
                  const SizedBox(width: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: actions,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: avatarAndName),
            const SizedBox(width: 16),
            balanceAndStatus,
            const SizedBox(width: 24),
            actions,
          ],
        );
      }),
    );
  }

  Widget _actionBtn(IconData icon, Color color, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// DIALOGS
// ────────────────────────────────────────────────────────────────────────────

class _StudentFormDialog extends ConsumerStatefulWidget {
  final StudentModel? student; const _StudentFormDialog({this.student});
  @override ConsumerState<_StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends ConsumerState<_StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _father, _phone, _address, _fee, _discount;
  String? _courseId; bool _saving = false;

  @override void initState() {
    super.initState(); final s = widget.student;
    _name = TextEditingController(text: s?.fullName); _father = TextEditingController(text: s?.fatherName);
    _phone = TextEditingController(text: s?.phone); _address = TextEditingController(text: s?.address);
    _fee = TextEditingController(text: s?.totalFee.toInt().toString()); _discount = TextEditingController(text: s?.discount.toInt().toString() ?? '0');
    _courseId = s?.courseId;
  }

  @override Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    return AlertDialog(
      title: Text(widget.student == null ? 'New Student' : 'Edit Student', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
          _field('Full Name', _name), _field('Father Name', _father), _field('Phone', _phone), _field('Address', _address),
          const SizedBox(height: 12),
          coursesAsync.when(
            loading: () => const LinearProgressIndicator(), 
            error: (_, __) => const Text('Error'), 
            data: (list) {
              final validValue = list.any((c) => c.id == _courseId)
                  ? _courseId
                  : (list.any((c) => c.name == _courseId)
                      ? list.firstWhere((c) => c.name == _courseId).id
                      : (list.isNotEmpty ? list.first.id : null));

              return DropdownButtonFormField<String>(
                value: validValue, 
                decoration: const InputDecoration(labelText: 'Course'), 
                items: list.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _courseId = v),
              );
            },
          ),
          Row(children: [Expanded(child: _field('Total Fee', _fee)), const SizedBox(width: 12), Expanded(child: _field('Discount', _discount))]),
        ])),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _saving ? null : _save, child: _saving ? const CircularProgressIndicator() : const Text('Save')),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl) => TextFormField(controller: ctrl, decoration: InputDecoration(labelText: label), validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null);

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final svc = ref.read(feeServiceProvider);
    final courses = await ref.read(coursesProvider.future);
    final course = courses.firstWhere((c) => c.id == _courseId);
    
    final student = StudentModel(
      id: widget.student?.id,
      studentId: widget.student?.studentId ?? await svc.generateStudentId(),
      fullName: _name.text.trim(), fatherName: _father.text.trim(), phone: _phone.text.trim(), address: _address.text.trim(),
      course: course.name, courseId: course.id!, batch: 'MAI-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}',
      totalFee: double.parse(_fee.text), discount: double.parse(_discount.text),
      effectiveFee: double.parse(_fee.text) - double.parse(_discount.text),
      admissionDate: widget.student?.admissionDate ?? DateTime.now(),
      status: widget.student?.status ?? StudentStatus.active,
      totalPaid: widget.student?.totalPaid ?? 0,
      outstanding: (double.parse(_fee.text) - double.parse(_discount.text)) - (widget.student?.totalPaid ?? 0),
    );

    if (widget.student == null) await svc.addStudent(student); else await svc.updateStudent(student.id!, student.toMap());
    if (mounted) Navigator.pop(context);
  }
}

class _CollectFeeDialog extends ConsumerStatefulWidget {
  final StudentModel student; const _CollectFeeDialog({required this.student});
  @override ConsumerState<_CollectFeeDialog> createState() => _CollectFeeDialogState();
}

class _CollectFeeDialogState extends ConsumerState<_CollectFeeDialog> {
  final _amount = TextEditingController(); bool _saving = false;
  @override void initState() { super.initState(); _amount.text = student.outstanding.toInt().toString(); }
  StudentModel get student => widget.student;

  @override Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Receive Fee: ${student.fullName}', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Remaining Balance: PKR ${student.outstanding}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount Paid (PKR)')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _saving ? null : _submit, child: const Text('Record Payment')),
      ],
    );
  }

  void _submit() async {
    setState(() => _saving = true);
    final svc = ref.read(feeServiceProvider);
    final p = PaymentModel(
      receiptNumber: await svc.generateReceiptNumber(), studentId: student.id!, studentUid: student.studentId, studentName: student.fullName,
      course: student.course, batch: student.batch, feeMonth: DateFormat('MMMM yyyy').format(DateTime.now()),
      paymentDate: DateTime.now(), amountPaid: double.parse(_amount.text), discount: 0, fine: 0,
      previousDue: student.outstanding, totalDue: student.outstanding, remainingBalance: student.outstanding - double.parse(_amount.text),
      paymentType: PaymentType.monthly, paymentMethod: PaymentMethod.cash, adminName: 'Admin', status: PaymentStatus.paid,
    );
    await svc.recordPayment(p);
    if (mounted) {
      Navigator.pop(context);
      ReportExportHelper.generatePaymentReceipt(p, student);
    }
  }
}

class _HistoryDialog extends ConsumerWidget {
  final StudentModel student; const _HistoryDialog({required this.student});
  @override Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('Payment History: ${student.fullName}'),
      content: SizedBox(width: 500, height: 400, child: StreamBuilder<List<PaymentModel>>(
        stream: ref.read(feeServiceProvider).getPayments(student.id!),
        builder: (context, snap) {
          final list = snap.data ?? [];
          if (list.isEmpty) return const Center(child: Text('No records.'));
          return ListView.builder(itemCount: list.length, itemBuilder: (_, i) => ListTile(
            title: Text(list[i].feeMonth, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('PKR ${list[i].amountPaid} on ${DateFormat('dd MMM').format(list[i].paymentDate)}'),
            trailing: IconButton(icon: const Icon(Icons.print), onPressed: () => ReportExportHelper.generatePaymentReceipt(list[i], student)),
          ));
        },
      )),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    );
  }
}

final _studentsStreamProvider = StreamProvider<List<StudentModel>>((ref) {
  return ref.watch(feeServiceProvider).getStudents();
});
