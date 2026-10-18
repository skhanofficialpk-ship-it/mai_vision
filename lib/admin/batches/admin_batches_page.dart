import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/batch_model.dart';
import '../../models/course_model.dart';
import '../../models/branch_model.dart';
import '../../services/batch_service.dart';
import '../../services/branch_service.dart';
import '../../providers/courses_provider.dart';

class AdminBatchesPage extends ConsumerStatefulWidget {
  const AdminBatchesPage({super.key});

  @override
  ConsumerState<AdminBatchesPage> createState() => _AdminBatchesPageState();
}

class _AdminBatchesPageState extends ConsumerState<AdminBatchesPage> {
  String _branchFilter = 'all';
  String _courseFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final batchesStream = ref.watch(batchServiceProvider).getBatches(
      branchId: _branchFilter,
      courseId: _courseFilter,
    );
    final branchesStream = ref.watch(branchServiceProvider).getBranches();
    final coursesAsync = ref.watch(coursesProvider);

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
                Text('Batch Management',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: -0.5)),
                SizedBox(height: 6),
                Text('Organize students and courses into teaching cycles.',
                    style: TextStyle(color: AppColors.textLight, fontSize: 14)),
              ],
            );
            
            final action = ElevatedButton.icon(
              onPressed: () => _showAddBatchDialog(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Batch'),
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
          
          // Filters integrated
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StreamBuilder<List<BranchModel>>(
                  stream: branchesStream,
                  builder: (context, snap) {
                    final branches = snap.data ?? [];
                    final validValue = branches.any((b) => b.id == _branchFilter) ? _branchFilter : 'all';
                    return SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<String>(
                        value: validValue,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Filter Branch', filled: true, fillColor: AppColors.sectionBg, border: InputBorder.none),
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('All Branches')),
                          ...branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, overflow: TextOverflow.ellipsis))),
                        ],
                        onChanged: (v) => setState(() => _branchFilter = v ?? 'all'),
                      ),
                    );
                  },
                ),
                coursesAsync.when(
                  data: (courses) {
                    final validCourse = courses.any((c) => c.id == _courseFilter)
                        ? _courseFilter
                        : (courses.any((c) => c.name == _courseFilter)
                            ? courses.firstWhere((c) => c.name == _courseFilter).id
                            : 'all');

                    return SizedBox(
                      width: 240,
                      child: DropdownButtonFormField<String>(
                        value: validCourse,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Filter Course', filled: true, fillColor: AppColors.sectionBg, border: InputBorder.none),
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('All Courses')),
                          ...courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))),
                        ],
                        onChanged: (v) => setState(() => _courseFilter = v ?? 'all'),
                      ),
                    );
                  },
                  loading: () => const SizedBox(width: 240, child: LinearProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          StreamBuilder<List<BatchModel>>(
            stream: batchesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(100), child: CircularProgressIndicator()));
              }
              final batches = snapshot.data ?? [];
              if (batches.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(60),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('No batches found for selected filters.', style: TextStyle(color: AppColors.textLight)),
                  ),
                );
              }
              return Column(
                children: batches.map((batch) => _BatchCard(batch: batch)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddBatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _AddBatchDialog(),
    );
  }
}

class _AddBatchDialog extends ConsumerStatefulWidget {
  const _AddBatchDialog();
  @override
  ConsumerState<_AddBatchDialog> createState() => _AddBatchDialogState();
}

class _AddBatchDialogState extends ConsumerState<_AddBatchDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBranchId = 'charbagh';
  final List<String> _selectedCourseIds = [];
  DateTime _startDate = DateTime.now();
  final _teacherController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _teacherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branchesStream = ref.watch(branchServiceProvider).getBranches();
    final coursesAsync = ref.watch(coursesProvider);

    return AlertDialog(
      title: const Text('Add New Batch'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Branch
                StreamBuilder<List<BranchModel>>(
                  stream: branchesStream,
                  builder: (context, snap) {
                    final branches = snap.data ?? [];
                    final activeBranches = branches.where((b) => b.isActive).toList();
                    final validValue = activeBranches.any((b) => b.id == _selectedBranchId) ? _selectedBranchId : (activeBranches.isNotEmpty ? activeBranches.first.id : null);
                    
                    return DropdownButtonFormField<String>(
                      value: validValue,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Branch *'),
                      items: activeBranches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _selectedBranchId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Multi-Course Selection with Durations
                coursesAsync.when(
                  data: (courses) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Courses *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: courses.map((c) {
                          final isSelected = _selectedCourseIds.contains(c.id);
                          return FilterChip(
                            label: Text('${c.name} (${c.duration})', style: const TextStyle(fontSize: 11)),
                            selected: isSelected,
                            onSelected: (val) {
                              setState(() {
                                if (val) _selectedCourseIds.add(c.id!);
                                else _selectedCourseIds.remove(c.id);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (_selectedCourseIds.isEmpty)
                        const Padding(padding: EdgeInsets.only(top: 4), child: Text('Select at least one course', style: TextStyle(color: Colors.red, fontSize: 11))),
                    ],
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error loading courses'),
                ),
                const SizedBox(height: 16),
                
                // Start Date
                InkWell(
                  onTap: () async {
                    final p = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime(2024), lastDate: DateTime(2030));
                    if (p != null) setState(() => _startDate = p);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Start Date'),
                    child: Text(DateFormat('MMMM dd, yyyy').format(_startDate)),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _teacherController,
                  decoration: const InputDecoration(labelText: 'Instructor / Teacher (Optional)'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Auto-Generate & Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedCourseIds.isEmpty) return;
    setState(() => _saving = true);
    
    try {
      final branches = await ref.read(branchServiceProvider).getBranches().first;
      final branch = branches.firstWhere((b) => b.id == _selectedBranchId);
      final allCourses = ref.read(coursesProvider).value ?? [];
      final selectedCourses = allCourses.where((c) => _selectedCourseIds.contains(c.id)).toList();
      
      // Auto-generate name
      final monthYear = DateFormat('MMM yyyy').format(_startDate);
      final courseNames = selectedCourses.map((c) => c.name.split(' ').first).join(', ');
      final batchName = "$monthYear — ${branch.name} ($courseNames)";
      
      Map<String, String> courseDurations = {};
      Map<String, DateTime> courseEndDates = {};

      for (var c in selectedCourses) {
        courseDurations[c.id!] = c.duration;
        
        // Calculate End Date for each course
        DateTime? endDate;
        final dur = c.duration.toLowerCase();
        if (dur.contains('month')) {
          int months = int.tryParse(dur.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
          endDate = DateTime(_startDate.year, _startDate.month + months, _startDate.day);
        } else if (dur.contains('day')) {
          int days = int.tryParse(dur.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
          endDate = _startDate.add(Duration(days: days));
        } else {
          endDate = _startDate.add(const Duration(days: 90)); // Default 3 months
        }
        courseEndDates[c.id!] = endDate;
      }
      
      // Batch Status based on earliest start vs earliest end? 
      // User requested Status: Upcoming, Active, Completed.
      String status = 'upcoming';
      final now = DateTime.now();
      if (now.isAfter(_startDate)) status = 'active';
      
      // Find the furthest end date to mark batch as completed
      DateTime? finalEnd;
      for (var d in courseEndDates.values) {
        if (finalEnd == null || d.isAfter(finalEnd)) finalEnd = d;
      }
      if (finalEnd != null && now.isAfter(finalEnd)) status = 'completed';

      final batch = BatchModel(
        name: batchName,
        branchId: _selectedBranchId!,
        courseIds: _selectedCourseIds,
        courseDurations: courseDurations,
        courseEndDates: courseEndDates,
        startDate: _startDate,
        status: status,
        teacher: _teacherController.text.trim(),
        createdAt: DateTime.now(),
      );
      
      await ref.read(batchServiceProvider).addBatch(batch);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _BatchCard extends ConsumerWidget {
  final BatchModel batch;
  const _BatchCard({required this.batch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(batch.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.text)),
                ),
                _StatusBadge(status: batch.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textLight),
                const SizedBox(width: 8),
                Text(
                  'Started: ${DateFormat('MMM d, yyyy').format(batch.startDate)}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 24),
                const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textLight),
                const SizedBox(width: 8),
                Text(batch.teacher.isEmpty ? 'No Instructor Assigned' : batch.teacher, style: const TextStyle(fontSize: 14, color: AppColors.text, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Enrolled Programs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            coursesAsync.when(
              data: (all) {
                return Column(
                  children: batch.courseIds.map((cid) {
                    final course = all.firstWhere((c) => c.id == cid, orElse: () => CourseModel(name: 'Unknown Course', description: '', duration: '', totalFee: 0, modules: [], category: ''));
                    final duration = batch.courseDurations[cid] ?? course.duration;
                    final endDate = batch.courseEndDates[cid];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded, size: 12, color: AppColors.success),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${course.name} ($duration)',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (endDate != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.sectionBg, borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                'Ends: ${DateFormat('MMM d, yyyy').format(endDate)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (status == 'active') color = AppColors.success;
    if (status == 'upcoming') color = AppColors.warning;
    if (status == 'completed') color = AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.4))),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
