import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/teacher_model.dart';
import '../../services/firestore_service.dart';

class AdminTeachersPage extends ConsumerWidget {
  const AdminTeachersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersStream = ref.watch(firestoreServiceProvider).getTeachers();

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
                  Text('Teacher Management', 
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: -0.5)),
                  SizedBox(height: 6),
                  Text('Manage academic staff and faculty members.',
                    style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(context, ref),
                icon: const Icon(Icons.add), label: const Text('Add Teacher'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          StreamBuilder<List<TeacherModel>>(
            stream: teachersStream,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final list = snap.data ?? [];
              if (list.isEmpty) return const Center(child: Text('No teachers added yet.'));
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, i) => _TeacherCard(teacher: list[i]),
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
      builder: (context) => _TeacherFormDialog(),
    );
  }
}

class _TeacherFormDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_TeacherFormDialog> createState() => _TeacherFormDialogState();
}

class _TeacherFormDialogState extends ConsumerState<_TeacherFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _address = TextEditingController();
  final _exp = TextEditingController();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Teacher', style: TextStyle(fontWeight: FontWeight.w900)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField('Full Name', _name, Icons.person),
              const SizedBox(height: 16),
              _buildField('Contact / Phone', _contact, Icons.phone),
              const SizedBox(height: 16),
              _buildField('Address', _address, Icons.location_on),
              const SizedBox(height: 16),
              _buildField('Experience (Years)', _exp, Icons.history, isNumber: true),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save Teacher'),
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
      final teacher = TeacherModel(
        name: _name.text.trim(),
        contact: _contact.text.trim(),
        address: _address.text.trim(),
        experienceYears: int.tryParse(_exp.text.trim()) ?? 0,
      );
      
      await ref.read(firestoreServiceProvider).addTeacher(teacher);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class _TeacherCard extends StatelessWidget {
  final TeacherModel teacher;
  const _TeacherCard({required this.teacher});

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
        leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.person, color: AppColors.primary)),
        title: Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${teacher.experienceYears} Years Experience • ${teacher.contact}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
