import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/public_shell.dart';
import '../../models/course_model.dart';
import '../../providers/courses_provider.dart';

class CoursesPage extends ConsumerWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.of(context).size.width;
    final cols = w < 768 ? 1 : (w < 1200 ? 2 : 3);
    final coursesAsync = ref.watch(coursesProvider);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const PageHero(
                title: 'Our Courses',
                subtitle:
                    'Practical, certificate-awarded programs. Pick the one that matches your goals.',
              ),
              Section(
                child: coursesAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => const _EmptyCourses(),
                  data: (courses) {
                    if (courses.isEmpty) return const _EmptyCourses();
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 28.0;
                        final cardWidth = cols == 1
                            ? constraints.maxWidth
                            : (constraints.maxWidth - spacing * (cols - 1)) / cols;
                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: courses.asMap().entries.map((entry) {
                            return SizedBox(
                              width: cardWidth,
                              child: RevealOnScroll(
                                delayMs: entry.key * 100,
                                child: _FullCourseCard(course: entry.value),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
              ),
              const _PaymentNoteSection(),
              const AppFooter(),
            ],
          ),
        ),
        const WhatsAppFab(),
      ],
    );
  }
}

class _EmptyCourses extends StatelessWidget {
  const _EmptyCourses();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Center(
        child: Text('No courses available at the moment. Check back soon.',
            style: TextStyle(color: AppColors.textLight, fontSize: 15)),
      ),
    );
  }
}

class _FullCourseCard extends StatelessWidget {
  final CourseModel course;
  const _FullCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final isClosed = !course.admissionOpen;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isClosed ? AppColors.accent.withOpacity(0.5) : AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(course.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppConstants.formatCourseName(course.name),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(course.duration,
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isClosed) ...[
                  const NextBatchBadge(),
                  const SizedBox(height: 16),
                ],
                Text(course.description,
                    style: const TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.7)),
                const SizedBox(height: 20),
                const Text('Modules Covered',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text, fontSize: 14)),
                const SizedBox(height: 12),
                ...course.modules.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(m,
                                  style: const TextStyle(fontSize: 13.5, color: AppColors.text))),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('PKR ${course.totalFee.toInt()}',
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    const Text(' total fee', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Apply Now',
                        onPressed: () => context.go('/admissions?course=${course.id}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Details',
                        outlined: true,
                        onPressed: () => context.go('/courses/${course.id}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentNoteSection extends StatelessWidget {
  const _PaymentNoteSection();

  @override
  Widget build(BuildContext context) {
    return Section(
      backgroundColor: AppColors.sectionBg,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Good to Know',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.text)),
                  SizedBox(height: 6),
                  Text(
                    'Course fees are typically for the entire duration mentioned above. A professional certificate is issued through our portal upon successful completion. Seats are limited — apply early.',
                    style: TextStyle(color: AppColors.textLight, fontSize: 13.5, height: 1.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
