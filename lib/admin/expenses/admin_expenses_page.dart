import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/expense_model.dart';
import '../../services/firestore_service.dart';

class AdminExpensesPage extends ConsumerWidget {
  const AdminExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesStream = ref.watch(firestoreServiceProvider).getExpenses();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Expense Management', 
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: -0.5)),
                  SizedBox(height: 6),
                  Text('Track institute utilities, salaries, and operational costs.',
                    style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(context, ref),
                icon: const Icon(Icons.add), label: const Text('Add Expense'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          StreamBuilder<List<ExpenseModel>>(
            stream: expensesStream,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final list = snap.data ?? [];
              if (list.isEmpty) return const Center(child: Text('No expenses recorded.'));
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, i) => _ExpenseCard(expense: list[i]),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _ExpenseFormDialog(),
    );
  }
}

class _ExpenseFormDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends ConsumerState<_ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _particulars = TextEditingController();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  String _category = 'Utility';
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Expense', style: TextStyle(fontWeight: FontWeight.w900)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField('Particulars / Description', _particulars, Icons.description),
              const SizedBox(height: 16),
              _buildField('Amount (PKR)', _amount, Icons.payments, isNumber: true),
              const SizedBox(height: 16),
              _buildField('Reference #', _reference, Icons.tag),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Utility', 'Salary', 'Rent', 'Marketing', 'Maintenance', 'Other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save Expense'),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    
    try {
      final expense = ExpenseModel(
        reference: _reference.text.trim(),
        particulars: _particulars.text.trim(),
        category: _category,
        amount: double.tryParse(_amount.text.trim()) ?? 0,
        date: DateTime.now(),
        branchId: 'all',
        adminName: 'Mister MJ',
      );
      
      await ref.read(firestoreServiceProvider).addExpense(expense);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  const _ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.money_off, color: AppColors.error, size: 20),
        ),
        title: Text(expense.particulars, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${expense.reference} • ${DateFormat('dd MMM yyyy').format(expense.date)} • ${expense.category}'),
        trailing: Text('- PKR ${NumberFormat('#,##0').format(expense.amount)}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.error, fontSize: 15)),
      ),
    );
  }
}
