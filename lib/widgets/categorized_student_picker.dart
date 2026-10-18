import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../models/admission_model.dart';
import '../models/student_model.dart';

class CategorizedStudentPicker extends StatefulWidget {
  final List<AdmissionModel> students;
  final AdmissionModel? selectedStudent;
  final ValueChanged<AdmissionModel> onSelected;

  const CategorizedStudentPicker({
    super.key,
    required this.students,
    this.selectedStudent,
    required this.onSelected,
  });

  @override
  State<CategorizedStudentPicker> createState() => _CategorizedStudentPickerState();
}

class _CategorizedStudentPickerState extends State<CategorizedStudentPicker> {
  void _openPickerModal() {
    showDialog(
      context: context,
      builder: (ctx) => _StudentPickerModal(
        students: widget.students,
        selectedStudent: widget.selectedStudent,
        onSelected: (student) {
          widget.onSelected(student);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.selectedStudent;

    return InkWell(
      onTap: _openPickerModal,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: s != null && s.branchName.contains('Gaming')
                    ? Colors.purple.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                s != null && s.branchName.contains('Gaming')
                    ? Icons.sports_esports_rounded
                    : Icons.person_rounded,
                color: s != null && s.branchName.contains('Gaming')
                    ? Colors.purple
                    : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: s == null
                  ? const Text('Click to Select Student (Sectioned by Branch & Type)',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13.5))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(s.fullName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: s.branchName.contains('Gaming')
                                    ? Colors.purple.withOpacity(0.1)
                                    : AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                s.branchName.toUpperCase(),
                                style: TextStyle(
                                  color: s.branchName.contains('Gaming')
                                      ? Colors.purple
                                      : AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${AppConstants.formatCourseName(s.selectedCourse)} • ${s.phone}',
                          style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                        ),
                      ],
                    ),
            ),
            const Icon(Icons.unfold_more_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _StudentPickerModal extends StatefulWidget {
  final List<AdmissionModel> students;
  final AdmissionModel? selectedStudent;
  final ValueChanged<AdmissionModel> onSelected;

  const _StudentPickerModal({
    required this.students,
    this.selectedStudent,
    required this.onSelected,
  });

  @override
  State<_StudentPickerModal> createState() => _StudentPickerModalState();
}

class _StudentPickerModalState extends State<_StudentPickerModal> {
  String _search = '';
  String _categoryFilter = 'All'; // 'All', 'Gaming', 'Charbagh', 'Course', 'Tuition', 'New'

  List<AdmissionModel> get _filteredStudents {
    final now = DateTime.now();
    return widget.students.where((s) {
      // 1. Category Filter
      if (_categoryFilter == 'Gaming' && !s.branchName.contains('Gaming') && s.branchId != 'manglor') {
        return false;
      }
      if (_categoryFilter == 'Charbagh' && (s.branchName.contains('Gaming') || s.branchId == 'manglor')) {
        return false;
      }
      if (_categoryFilter == 'Course' && s.studentType != StudentType.course) {
        return false;
      }
      if (_categoryFilter == 'Tuition' && s.studentType != StudentType.tuition) {
        return false;
      }
      if (_categoryFilter == 'New') {
        final diff = now.difference(s.createdAt).inDays;
        if (diff > 30) return false;
      }

      // 2. Search Query Filter
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final match = s.fullName.toLowerCase().contains(q) ||
            s.fatherName.toLowerCase().contains(q) ||
            s.phone.toLowerCase().contains(q) ||
            s.selectedCourse.toLowerCase().contains(q) ||
            s.branchName.toLowerCase().contains(q);
        if (!match) return false;
      }

      return true;
    }).toList();
  }

  // Group filtered students by branch / section
  Map<String, List<AdmissionModel>> get _groupedStudents {
    final map = <String, List<AdmissionModel>>{};
    for (final s in _filteredStudents) {
      String sectionName = s.branchName;
      if (sectionName.isEmpty) sectionName = 'General Branch';
      if (s.branchId == 'manglor' || s.branchName.contains('Gaming')) {
        sectionName = '🎮 MAI Gaming Studio';
      } else {
        sectionName = '🏫 ${s.branchName} Branch';
      }

      map.putIfAbsent(sectionName, () => []).add(s);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth < 650 ? screenWidth * 0.95 : 600,
          maxHeight: 650,
        ),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.groups_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Select Student by Section / Category',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by student name, phone, course...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) => setState(() => _search = v.trim()),
              ),
            ),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  _filterChip('All', 'All Students (${widget.students.length})'),
                  _filterChip('Gaming', '🎮 Gaming Studio'),
                  _filterChip('Charbagh', '🏫 Charbagh Branch'),
                  _filterChip('Course', '📚 Course Students'),
                  _filterChip('Tuition', '✏️ Tuition Students'),
                  _filterChip('New', '🆕 New Admissions'),
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),

            // Sectioned List
            Expanded(
              child: _groupedStudents.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('No students found in this section.',
                            style: TextStyle(color: AppColors.textLight)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _groupedStudents.keys.length,
                      itemBuilder: (context, sectionIndex) {
                        final sectionTitle = _groupedStudents.keys.elementAt(sectionIndex);
                        final sectionList = _groupedStudents[sectionTitle]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Header Banner
                            Container(
                              margin: EdgeInsets.only(top: sectionIndex == 0 ? 0 : 16, bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: sectionTitle.contains('Gaming')
                                    ? Colors.purple.withOpacity(0.1)
                                    : AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    sectionTitle,
                                    style: TextStyle(
                                      color: sectionTitle.contains('Gaming')
                                          ? Colors.purple
                                          : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${sectionList.length}',
                                      style: const TextStyle(
                                          fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.text),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Student Cards in Section
                            ...sectionList.map((s) {
                              final isSelected = widget.selectedStudent?.id == s.id;
                              final dateFmt = DateFormat('MMM d, yyyy').format(s.createdAt);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Material(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.05)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isSelected ? AppColors.primary : AppColors.border,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    leading: CircleAvatar(
                                      backgroundColor: s.branchName.contains('Gaming')
                                          ? Colors.purple.withOpacity(0.1)
                                          : AppColors.primary.withOpacity(0.1),
                                      child: Text(
                                        s.fullName[0].toUpperCase(),
                                        style: TextStyle(
                                          color: s.branchName.contains('Gaming')
                                              ? Colors.purple
                                              : AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(s.fullName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w800, fontSize: 14)),
                                        ),
                                        Text(s.studentType.label,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textMuted)),
                                      ],
                                    ),
                                    subtitle: Text(
                                      '${AppConstants.formatCourseName(s.selectedCourse)} • ${s.phone} • Admitted: $dateFmt',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                                        : const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                                    onTap: () => widget.onSelected(s),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    final isSelected = _categoryFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.text,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.sectionBg,
        onSelected: (_) => setState(() => _categoryFilter = key),
      ),
    );
  }
}
