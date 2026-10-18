import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/public_shell.dart';
import '../../models/course_model.dart';
import '../../models/teacher_model.dart';
import '../../providers/courses_provider.dart';

class CourseDetailPage extends ConsumerWidget {
  final String courseId;
  const CourseDetailPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseByIdProvider(courseId));
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;

    return courseAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text('Course not found.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/courses'),
                child: const Text('Back to Courses'),
              ),
            ],
          ),
        ),
      ),
      data: (course) {
        if (course == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text('Course not found.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/courses'),
                    child: const Text('View All Courses'),
                  ),
                ],
              ),
            ),
          );
        }
        return _CourseDetailView(course: course, isMobile: isMobile);
      },
    );
  }
}

class _CourseDetailView extends StatelessWidget {
  final CourseModel course;
  final bool isMobile;
  const _CourseDetailView({required this.course, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 80, vertical: isMobile ? 48 : 72),
                child: ResponsivePadding(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/courses'),
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_back, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text('Back to Courses',
                                style: TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(course.icon, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Text(
                              course.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 26 : 36,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(
                          course.description,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.9), fontSize: 15, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Section(
                child: isMobile
                    ? Column(
                        children: [
                          _ModulesList(course: course),
                          const SizedBox(height: 32),
                          _SidebarCard(course: course),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _ModulesList(course: course)),
                          const SizedBox(width: 40),
                          Expanded(flex: 1, child: _SidebarCard(course: course)),
                        ],
                      ),
              ),
              if (!course.teacher.isEmpty)
                Section(
                  backgroundColor: AppColors.sectionBg,
                  verticalPadding: 56,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: _TeacherCard(teacher: course.teacher),
                    ),
                  ),
                ),
              const AppFooter(),
            ],
          ),
        ),
        const WhatsAppFab(),
      ],
    );
  }
}

class _ModulesList extends StatelessWidget {
  final CourseModel course;
  const _ModulesList({required this.course});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Curriculum',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 8),
        const Text(
          'A structured curriculum covering everything you need to know, taught step by step.',
          style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 24),
        ...course.modules.asMap().entries.map((entry) {
          final i = entry.key;
          final m = entry.value;
          return RevealOnScroll(
            delayMs: i * 60,
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.sectionBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(m,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14.5, color: AppColors.text)),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SidebarCard extends StatelessWidget {
  final CourseModel course;
  const _SidebarCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final isClosed = !course.admissionOpen;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isClosed ? AppColors.accent.withOpacity(0.5) : AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isClosed) ...[
            const NextBatchBadge(),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Text('PKR ${course.totalFee.toInt()}',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary)),
              const Text(' total fee', style: TextStyle(color: AppColors.textLight)),
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow(icon: Icons.schedule, label: 'Duration', value: course.duration),
          const SizedBox(height: 14),
          _DetailRow(icon: Icons.category, label: 'Category', value: course.category),
          const SizedBox(height: 14),
          _DetailRow(icon: Icons.verified, label: 'Certificate', value: 'Awarded on completion'),
          const SizedBox(height: 14),
          _DetailRow(icon: Icons.groups, label: 'Format', value: 'In-person, hands-on'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Apply for This Course',
              onPressed: () => context.go('/admissions?course=${course.id}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(color: AppColors.textLight, fontSize: 13.5)),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.text)),
        ),
      ],
    );
  }
}

/// Public-facing teacher summary shown on the course detail page.
///
/// Only displays the teacher's name and years of experience — their address
/// and contact details (collected by the admin via Courses Management) are
/// kept private and are never rendered on the public website.
class _TeacherCard extends StatelessWidget {
  final TeacherModel teacher;
  const _TeacherCard({required this.teacher});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;

    final avatar = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: AppColors.primary, size: 28),
    );

    final info = _TeacherInfo(teacher: teacher);

    return RevealOnScroll(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatar,
                  const SizedBox(height: 16),
                  info,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  avatar,
                  const SizedBox(width: 16),
                  Expanded(child: info),
                ],
              ),
      ),
    );
  }
}

class _TeacherInfo extends StatelessWidget {
  final TeacherModel teacher;
  const _TeacherInfo({required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Course Instructor',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(teacher.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 4),
        Text(
          '${teacher.experienceYears} ${teacher.experienceYears == 1 ? 'year' : 'years'} of teaching experience',
          style: const TextStyle(fontSize: 13.5, color: AppColors.textLight),
        ),
      ],
    );
  }
}
