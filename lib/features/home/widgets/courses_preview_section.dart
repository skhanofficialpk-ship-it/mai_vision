import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../models/course_model.dart';
import '../../../providers/courses_provider.dart';

class CoursesPreviewSection extends ConsumerWidget {
  const CoursesPreviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final cols = MediaQuery.of(context).size.width < 768
        ? 1
        : (MediaQuery.of(context).size.width < 1200 ? 2 : 3);

    return Section(
      child: Column(
        children: [
          const SectionEyebrow(text: 'Our Courses'),
          const SizedBox(height: 16),
          Text(
            'Choose Your Learning Path',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 560),
            child: Text(
              'Focused, hands-on programs designed to take you from beginner to job-ready, fast.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, fontSize: 15, height: 1.6),
            ),
          ),
          const SizedBox(height: 48),
          coursesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (courses) => LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 24.0;
                final cardWidth = cols == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - spacing * (cols - 1)) / cols;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: courses.asMap().entries.map((entry) {
                    final i = entry.key;
                    final course = entry.value;
                    return SizedBox(
                      width: cardWidth,
                      child: RevealOnScroll(
                        delayMs: i * 100,
                        child: _CourseCard(course: course),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'View All Courses',
            icon: Icons.arrow_forward,
            onPressed: () => context.go('/courses'),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final isClosed = !course.admissionOpen;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isClosed ? AppColors.accent.withOpacity(0.4) : AppColors.border),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              if (!isClosed) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    course.duration,
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
          if (isClosed) ...[
            const SizedBox(height: 14),
            const NextBatchBadge(),
          ],
          const SizedBox(height: 20),
          Text(AppConstants.formatCourseName(course.name),
              style: const TextStyle(
                  fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 10),
          Text(
            course.description,
            style: const TextStyle(color: AppColors.textLight, fontSize: 13.5, height: 1.6),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: course.modules
                .take(4)
                .map((m) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.sectionBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(m,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.text)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'PKR ${course.totalFee.toInt()}',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const Text(' total',
                  style: TextStyle(fontSize: 13, color: AppColors.textLight)),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/courses/${course.id}'),
                child: const Row(
                  children: [
                    Text('Details', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
