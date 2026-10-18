import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/excel_export_helper.dart';
import '../../core/utils/report_export_helper.dart';
import '../../core/theme/app_theme.dart';
import '../../models/student_model.dart';
import '../../models/payment_model.dart';
import '../../services/fee_service.dart';

class AdminFeesPage extends ConsumerStatefulWidget {
  const AdminFeesPage({super.key});

  @override
  ConsumerState<AdminFeesPage> createState() => _AdminFeesPageState();
}

class _AdminFeesPageState extends ConsumerState<AdminFeesPage> {
  // Filters
  String _searchQuery = '';
  String? _selectedCourse;
  String? _selectedBatch;
  String? _selectedStatus;
  bool _outstandingOnly = false;

  // 1. DONT CALL API IN BUILD. Variables declare karein:
  late Future<Map<String, dynamic>> _dashboardStatsFuture;
  late Stream<List<StudentModel>> _studentsStream;

  @override
  void initState() {
    super.initState();
    // 2. InitState mein inko initialize karein (Use ref.read here)
    final feeService = ref.read(feeServiceProvider);
    _dashboardStatsFuture = feeService.getDashboardStats();
    _studentsStream = feeService.getStudents();
  }


  @override
  Widget build(BuildContext context) {
    final feeService = ref.watch(feeServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fee Management ERP',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 24),

            // 3. Variable use karein, direct function call nahi
            FutureBuilder<Map<String, dynamic>>(
              future: _dashboardStatsFuture,
              builder: (context, snapshot) {
                // ADDED ERROR CHECK: Taa ke Firestore Rules ka error hide na ho
                if (snapshot.hasError) {
                  return Center(child: Text('Dashboard Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final stats = snapshot.data ?? {};
                return _buildDashboardCards(stats);
              },
            ),
            const SizedBox(height: 24),

            _buildFilters(),
            const SizedBox(height: 16),

            // 4. Stream variable use karein
            Expanded(
              child: StreamBuilder<List<StudentModel>>(
                stream: _studentsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Agar required ho to yahan initial load spinner lagayein
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<StudentModel> students = snapshot.data ?? [];

                  // Apply client-side filters
                  students = students.where((s) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        s.fullName.toLowerCase().contains(_searchQuery) ||
                        s.studentId.toLowerCase().contains(_searchQuery) ||
                        s.phone.contains(_searchQuery) ||
                        s.course.toLowerCase().contains(_searchQuery) ||
                        s.batch.toLowerCase().contains(_searchQuery);

                    final matchesCourse = _selectedCourse == null || _selectedCourse == 'All' || s.course == _selectedCourse;
                    final matchesBatch = _selectedBatch == null || _selectedBatch == 'All' || s.batch == _selectedBatch;
                    final matchesStatus = _selectedStatus == null || _selectedStatus == 'All' || s.status.value == _selectedStatus?.toLowerCase();
                    final matchesOutstanding = !_outstandingOnly || s.outstanding > 0;

                    return matchesSearch && matchesCourse && matchesBatch && matchesStatus && matchesOutstanding;
                  }).toList();

                  return Card(
                    elevation: 0,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Student Fee Records (${students.length})',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => ExcelExportHelper.exportStudentFeeList(students),
                                    icon: const Icon(Icons.table_view),
                                    label: const Text('Export Excel'),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: () => ReportExportHelper.generateOutstandingReport(students),
                                    icon: const Icon(Icons.picture_as_pdf),
                                    label: const Text('Outstanding PDF'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const Divider(),
                        Expanded(child: _buildResponsiveTable(students, feeService)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCards(Map<String, dynamic> stats) {
    final currencyFmt = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

    return LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 1200 ? 6 : (constraints.maxWidth > 800 ? 3 : 2);

          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: [
              _StatCard(title: 'Total Students', value: '${stats['totalStudents'] ?? 0}', icon: Icons.people, color: AppColors.primary),
              _StatCard(title: 'Active Students', value: '${stats['activeStudents'] ?? 0}', icon: Icons.person_add_alt_1, color: AppColors.success),
              _StatCard(title: 'Inactive Students', value: '${stats['inactiveStudents'] ?? 0}', icon: Icons.person_off, color: AppColors.textMuted),
              _StatCard(title: 'Pending Payments', value: '${stats['pendingFees'] ?? 0}', icon: Icons.warning_amber_rounded, color: AppColors.warning),
              _StatCard(title: 'Collection (Month)', value: currencyFmt.format(stats['monthlyCollection'] ?? 0), icon: Icons.payments, color: AppColors.success),
              _StatCard(title: 'Total Outstanding', value: currencyFmt.format(stats['totalOutstanding'] ?? 0), icon: Icons.money_off, color: AppColors.error),
            ],
          );
        }
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by Name, ID, Phone, Course...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),
            _buildDropdown('Course', ['All', 'Advance Computer Course', 'AI & Smart Digital Skills', 'Flutter Development'], _selectedCourse, (v) => setState(() => _selectedCourse = v)),
            _buildDropdown('Batch', ['All', 'Batch 1', 'Batch 2', 'Batch 3', 'Jan 2025'], _selectedBatch, (v) => setState(() => _selectedBatch = v)),
            _buildDropdown('Status', ['All', 'Active', 'Inactive'], _selectedStatus, (v) => setState(() => _selectedStatus = v)),
            FilterChip(
              label: const Text('Outstanding Only'),
              selected: _outstandingOnly,
              onSelected: (val) => setState(() => _outstandingOnly = val),
              selectedColor: AppColors.warning.withOpacity(0.2),
              checkmarkColor: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildResponsiveTable(List<StudentModel> students, FeeService feeService) {
    final currencyFmt = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy');

    return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                columns: const [
                  DataColumn(label: Text('Student ID')),
                  DataColumn(label: Text('Name & Info')),
                  DataColumn(label: Text('Course & Batch')),
                  DataColumn(label: Text('Fee Details')),
                  DataColumn(label: Text('Outstanding')),
                  DataColumn(label: Text('Last Payment')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: students.map((student) {
                  return DataRow(
                    cells: [
                      DataCell(Text(student.studentId, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(student.phone, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                        ],
                      )),
                      DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(student.course, style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text(student.batch, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                        ],
                      )),
                      DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Total: ${currencyFmt.format(student.totalFee)}', style: const TextStyle(fontSize: 13)),
                          if (student.discount > 0)
                            Text('Disc: -${currencyFmt.format(student.discount)}', style: const TextStyle(fontSize: 12, color: AppColors.success)),
                        ],
                      )),
                      DataCell(Text(
                        currencyFmt.format(student.outstanding),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: student.outstanding > 0 ? AppColors.error : AppColors.success
                        ),
                      )),
                      DataCell(Text(
                        student.lastPaymentDate != null ? dateFmt.format(student.lastPaymentDate!) : 'Never',
                        style: const TextStyle(color: AppColors.textLight),
                      )),
                      DataCell(_buildStatusChip(student.status.value)),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: 'Receive Fee',
                            child: IconButton(
                              icon: const Icon(Icons.payments, color: AppColors.success),
                              onPressed: () => _showReceiveFeeDialog(context, student, feeService),
                            ),
                          ),
                          Tooltip(
                            message: 'Payment History',
                            child: IconButton(
                              icon: const Icon(Icons.history, color: AppColors.primary),
                              onPressed: () => _showPaymentHistoryDialog(context, student, feeService),
                            ),
                          ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        }
    );
  }

  Widget _buildStatusChip(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.success.withOpacity(0.1) : AppColors.textMuted.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? AppColors.success : AppColors.textMuted),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? AppColors.success : AppColors.textMuted),
      ),
    );
  }

  void _showReceiveFeeDialog(BuildContext context, StudentModel student, FeeService feeService) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ReceiveFeeDialog(student: student, feeService: feeService),
    );
  }

  void _showPaymentHistoryDialog(BuildContext context, StudentModel student, FeeService feeService) {
    showDialog(
      context: context,
      builder: (context) => _PaymentHistoryDialog(student: student, feeService: feeService),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 24,
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textLight, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text), overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// RECEIVE FEE DIALOG
// ────────────────────────────────────────────────────────────────────────────
class _ReceiveFeeDialog extends StatefulWidget {
  final StudentModel student;
  final FeeService feeService;

  const _ReceiveFeeDialog({required this.student, required this.feeService});

  @override
  State<_ReceiveFeeDialog> createState() => _ReceiveFeeDialogState();
}

class _ReceiveFeeDialogState extends State<_ReceiveFeeDialog> {
  final _formKey = GlobalKey<FormState>();

  late double _previousDue;
  double _fine = 0.0;
  double _extraDiscount = 0.0;
  double _amountReceived = 0.0;

  PaymentType _selectedPaymentType = PaymentType.monthly;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  final TextEditingController _fineController = TextEditingController(text: '0');
  final TextEditingController _discountController = TextEditingController(text: '0');
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedFeeMonth = DateFormat('yyyy-MM').format(DateTime.now());
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _previousDue = widget.student.outstanding;
// Total Fee system
    _amountController.addListener(_recalculate);
    _fineController.addListener(_recalculate);
    _discountController.addListener(_recalculate);
    
    // Auto-fill amount received with outstanding balance
    _amountController.text = _previousDue.toInt().toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _fineController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _recalculate() {
    setState(() {
      _fine = double.tryParse(_fineController.text) ?? 0.0;
      _extraDiscount = double.tryParse(_discountController.text) ?? 0.0;
      _amountReceived = double.tryParse(_amountController.text) ?? 0.0;
    });
  }

  double get _totalDue => (_previousDue + _fine) - _extraDiscount;
  double get _remainingBalance => _totalDue - _amountReceived;

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final receiptNo = await widget.feeService.generateReceiptNumber();

      final payment = PaymentModel(
        receiptNumber: receiptNo,
        studentId: widget.student.id!,
        studentUid: widget.student.studentId,
        studentName: widget.student.fullName,
        course: widget.student.course,
        batch: widget.student.batch,
        feeMonth: _selectedFeeMonth,
        paymentDate: DateTime.now(),
        amountPaid: _amountReceived,
        discount: _extraDiscount,
        fine: _fine,
        previousDue: _previousDue,
        totalDue: _totalDue,
        remainingBalance: _remainingBalance,
        paymentType: _selectedPaymentType,
        paymentMethod: _selectedPaymentMethod,
        notes: _notesController.text.trim(),
        adminName: 'System Admin',
        status: _remainingBalance <= 0 ? PaymentStatus.paid : (_amountReceived > 0 ? PaymentStatus.partiallyPaid : PaymentStatus.pending),
      );

      await widget.feeService.recordPayment(payment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successfully recorded.'), backgroundColor: AppColors.success));
        Navigator.pop(context);

        // Auto Generate Receipt
        ReportExportHelper.generatePaymentReceipt(payment, widget.student);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

    return AlertDialog(
      title: Text('Receive Fee - ${widget.student.fullName}', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Info
                Container(
                  padding: const EdgeInsets.all(12),
                  color: AppColors.sectionBg,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ID: ${widget.student.studentId}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Course: ${widget.student.course}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Batch: ${widget.student.batch}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<PaymentType>(
                        decoration: const InputDecoration(labelText: 'Payment Type'),
                        value: _selectedPaymentType,
                        items: PaymentType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedPaymentType = v!;
                            if (v == PaymentType.previousDue) {
                            } else {
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _selectedFeeMonth,
                        decoration: const InputDecoration(labelText: 'Fee Month (YYYY-MM)'),
                        onChanged: (v) => _selectedFeeMonth = v,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Calculations
                Card(
                  elevation: 0,
                  color: AppColors.background,
                  shape: RoundedRectangleBorder(side: const BorderSide(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildCalcRow('Current Balance:', currencyFmt.format(_previousDue)),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _fineController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Fine / Penalty (PKR)'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _discountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Extra Discount (PKR)'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCalcRow('TOTAL DUE:', currencyFmt.format(_totalDue), isBold: true, color: AppColors.error),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Receive Input
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount Received (PKR) *',
                          filled: true,
                          fillColor: AppColors.white,
                        ),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.success),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<PaymentMethod>(
                        decoration: const InputDecoration(labelText: 'Method'),
                        value: _selectedPaymentMethod,
                        items: PaymentMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label))).toList(),
                        onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildCalcRow('REMAINING BALANCE:', currencyFmt.format(_remainingBalance), isBold: true, color: _remainingBalance > 0 ? AppColors.warning : AppColors.success),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Remarks / Notes (Optional)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitPayment,
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Record Payment'),
        ),
      ],
    );
  }

  Widget _buildCalcRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontSize: isBold ? 16 : 14, color: color ?? AppColors.text)),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// PAYMENT HISTORY DIALOG
// ────────────────────────────────────────────────────────────────────────────
class _PaymentHistoryDialog extends StatelessWidget {
  final StudentModel student;
  final FeeService feeService;

  const _PaymentHistoryDialog({required this.student, required this.feeService});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
    final currencyFmt = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Payment History - ${student.fullName}'),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
      content: SizedBox(
        width: 800,
        height: 500,
        child: StreamBuilder<List<PaymentModel>>(
          stream: feeService.getPayments(student.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

            final payments = snapshot.data ?? [];
            if (payments.isEmpty) return const Center(child: Text('No payment records found.'));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: () => ExcelExportHelper.exportPaymentHistory(payments, student.fullName),
                  icon: const Icon(Icons.download),
                  label: const Text('Export Excel'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Receipt No')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Month')),
                        DataColumn(label: Text('Amount Paid')),
                        DataColumn(label: Text('Method')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: payments.map((p) {
                        return DataRow(
                          cells: [
                            DataCell(Text(p.receiptNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(dateFmt.format(p.paymentDate))),
                            DataCell(Text(p.feeMonth)),
                            DataCell(Text(currencyFmt.format(p.amountPaid), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
                            DataCell(Text(p.paymentMethod.label)),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.print, color: AppColors.primary),
                                  tooltip: 'Print Receipt',
                                  onPressed: () => ReportExportHelper.generatePaymentReceipt(p, student),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppColors.error),
                                  tooltip: 'Delete & Reverse',
                                  onPressed: () => _confirmDelete(context, p),
                                ),
                              ],
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PaymentModel payment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reverse Payment?'),
        content: Text('Are you sure you want to delete receipt ${payment.receiptNumber}?\nThis will revert the student\'s outstanding balance.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await feeService.deletePayment(student.id!, payment.id!);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}