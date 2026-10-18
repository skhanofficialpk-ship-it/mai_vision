import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/course_model.dart';
import '../../models/teacher_model.dart';
import '../../services/firestore_service.dart';

class AdminCoursesPage extends ConsumerWidget {
  const AdminCoursesPage({super.key});

  void _openForm(BuildContext context, WidgetRef ref, {CourseModel? course}) {
    showDialog(
      context: context,
      builder: (_) => _CourseFormDialog(
        course: course,
        onSave: (saved) async {
          await ref.read(firestoreServiceProvider).saveCourse(saved);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, CourseModel course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Permanently delete "${course.name}" from Firestore?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (course.id != null) {
                await ref.read(firestoreServiceProvider).deleteCourse(course.id!);
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Text('Courses Management',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                        letterSpacing: -0.5)),
                SizedBox(height: 6),
                Text('Manage institute curriculum and pricing.',
                    style: TextStyle(fontSize: 14, color: AppColors.textLight)),
              ],
            );
            
            final action = ElevatedButton.icon(
              onPressed: () => _openForm(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Course'),
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerInfo,
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, child: action),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: headerInfo),
                const SizedBox(width: 16),
                action,
              ],
            );
          }),
          const SizedBox(height: 32),
            StreamBuilder<List<CourseModel>>(
              stream: firestoreService.getCourses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text('Error loading courses: ${snapshot.error}',
                                style: const TextStyle(color: AppColors.error))),
                      ],
                    ),
                  );
                }

                final courses = snapshot.data ?? [];

                if (courses.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.menu_book_outlined,
                              size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          const Text('No courses yet.',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text)),
                          const SizedBox(height: 4),
                          const Text('Tap "Add Course" to create the first one.',
                              style: TextStyle(
                                  color: AppColors.textLight, fontSize: 13.5)),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _openForm(context, ref),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Course'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: courses
                      .map((c) => _CourseRow(
                            course: c,
                            onEdit: () => _openForm(context, ref, course: c),
                            onDelete: () => _confirmDelete(context, ref, c),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      );
  }
}

class _CourseRow extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _CourseRow(
      {required this.course, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(course.icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(AppConstants.formatCourseName(course.name),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (course.admissionOpen
                                ? AppColors.success
                                : AppColors.accent)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        course.admissionOpen ? 'Admissions Open' : 'Next Batch',
                        style: TextStyle(
                          color: course.admissionOpen
                              ? AppColors.success
                              : AppColors.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.duration} • ${course.modules.length} modules',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textLight),
                ),
                if (!course.teacher.isEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 14, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${course.teacher.name} • ${course.teacher.experienceYears} yrs experience',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textLight),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Fee: PKR ${course.totalFee.toInt()}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.textLight),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon:
                        const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseFormDialog extends StatefulWidget {
  final CourseModel? course;
  final Future<void> Function(CourseModel) onSave;
  const _CourseFormDialog({required this.course, required this.onSave});

  @override
  State<_CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<_CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _description;
  late TextEditingController _fee;
  late TextEditingController _duration;
  late TextEditingController _category;
  late TextEditingController _newModule;
  late bool _admissionOpen;
  late List<String> _modules;

  // Teacher
  late TextEditingController _teacherName;
  late TextEditingController _teacherAddress;
  late TextEditingController _teacherContact;
  late TextEditingController _teacherExperience;

  bool _saving = false;
  bool get _isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _name = TextEditingController(text: c?.name ?? '');
    _description = TextEditingController(text: c?.description ?? '');
    _fee = TextEditingController(
        text: c != null ? c.totalFee.toInt().toString() : '');
    _duration = TextEditingController(text: c?.duration ?? '3 Months');
    _category = TextEditingController(text: c?.category ?? '');
    _newModule = TextEditingController();
    _admissionOpen = c?.admissionOpen ?? true;
    _modules = List.from(c?.modules ?? <String>[]);

    final t = c?.teacher ?? const TeacherModel.empty();
    _teacherName = TextEditingController(text: t.name);
    _teacherAddress = TextEditingController(text: t.address);
    _teacherContact = TextEditingController(text: t.contact);
    _teacherExperience = TextEditingController(
        text: t.experienceYears > 0 ? t.experienceYears.toString() : '');
  }

  @override
  void dispose() {
    for (final c in [
      _name, _description, _fee, _duration, _category, _newModule,
      _teacherName, _teacherAddress, _teacherContact, _teacherExperience,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _addModule() {
    final text = _newModule.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _modules.add(text);
      _newModule.clear();
    });
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_modules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one module.')),
      );
      return;
    }

    final tName = _teacherName.text.trim();
    final teacherFilled = tName.isNotEmpty ||
        _teacherAddress.text.trim().isNotEmpty ||
        _teacherContact.text.trim().isNotEmpty ||
        _teacherExperience.text.trim().isNotEmpty;
    if (teacherFilled && tName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Enter teacher name, or leave all teacher fields blank.')),
      );
      return;
    }

    final teacher = teacherFilled
        ? TeacherModel(
            name: tName,
            address: _teacherAddress.text.trim(),
            contact: _teacherContact.text.trim(),
            experienceYears:
                int.tryParse(_teacherExperience.text.trim()) ?? 0,
          )
        : const TeacherModel.empty();

    final base = widget.course ??
        CourseModel(
          name: '',
          description: '',
          duration: '3 Months',
          totalFee: 0,
          modules: const [],
          category: '',
        );

    final saved = base.copyWith(
      id: widget.course?.id ?? _slugify(_name.text.trim()),
      name: _name.text.trim(),
      description: _description.text.trim(),
      duration: _duration.text.trim(),
      totalFee:
          double.tryParse(_fee.text.trim()) ?? base.totalFee,
      category: _category.text.trim(),
      modules: _modules,
      admissionOpen: _admissionOpen,
      teacher: teacher,
    );

    setState(() => _saving = true);
    try {
      await widget.onSave(saved);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  String _slugify(String input) {
    final base = input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return base.isEmpty ? 'course_$suffix' : '${base}_$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: sw < 560 ? sw * 0.92 : 560,
          maxHeight: sh * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isEditing ? 'Edit Course' : 'Add New Course',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _name,
                    decoration:
                        const InputDecoration(labelText: 'Course Name *'),
                    validator: _req,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _description,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(labelText: 'Description *'),
                    validator: _req,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _fee,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Total Course Fee (PKR) *'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (double.tryParse(v.trim()) == null) {
                              return 'Enter a number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _duration,
                          decoration:
                              const InputDecoration(labelText: 'Duration *'),
                          validator: _req,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _category,
                    decoration:
                        const InputDecoration(labelText: 'Category *'),
                    validator: _req,
                  ),
                  const SizedBox(height: 20),
                  const Text('Modules',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.text)),
                  const SizedBox(height: 8),
                  if (_modules.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_modules.length, (i) {
                        return Chip(
                          label: Text(_modules[i],
                              style: const TextStyle(fontSize: 12.5)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () =>
                              setState(() => _modules.removeAt(i)),
                          backgroundColor: AppColors.sectionBg,
                          side: const BorderSide(color: AppColors.border),
                        );
                      }),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newModule,
                          decoration: const InputDecoration(
                              hintText: 'Add module, e.g. "MS Excel"'),
                          onSubmitted: (_) => _addModule(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: _addModule,
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.sectionBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Admissions Open',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5)),
                              Text(
                                _admissionOpen
                                    ? 'Students can apply now.'
                                    : 'Shown as "Next Batch" — applications blocked.',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _admissionOpen,
                          activeColor: AppColors.primary,
                          onChanged: (v) =>
                              setState(() => _admissionOpen = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.school_outlined,
                          size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Teacher Details (optional)',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.text)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Leave blank if no teacher assigned yet.',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _teacherName,
                    decoration:
                        const InputDecoration(labelText: 'Teacher Name'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _teacherAddress,
                    decoration:
                        const InputDecoration(labelText: 'Teacher Address'),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _teacherContact,
                          keyboardType: TextInputType.phone,
                          decoration:
                              const InputDecoration(labelText: 'Contact'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _teacherExperience,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Experience (years)'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            if (int.tryParse(v.trim()) == null)
                              return 'Whole number';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(_isEditing ? 'Save Changes' : 'Add Course'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
