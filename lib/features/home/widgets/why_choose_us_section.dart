import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class WhyChooseUsSection extends StatelessWidget {
  const WhyChooseUsSection({super.key});

  static const _items = [
    (Icons.workspace_premium, 'Expert Instructors',
        'Learn from instructors with real-world experience in software development and digital tools.'),
    (Icons.verified_user, 'Certified Courses',
        'Receive an institute certificate recognized for your portfolio and job applications.'),
    (Icons.build_circle, 'Practical Training',
        'Hands-on lab sessions, real exercises, and project-based learning, not just theory.'),
    (Icons.work, 'Career Ready Skills',
        'Curriculum built around what employers and freelance clients actually look for.'),
    (Icons.handshake, 'Internship & Job Opportunities',
        'Top-performing students get access to future internship placements and job referrals.'),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w < 700 ? 1 : (w < 1100 ? 2 : 3);

    return Section(
      child: Column(
        children: [
          const SectionEyebrow(text: 'Why Choose Us'),
          const SizedBox(height: 16),
          Text(
            'A Learning Experience That Works',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: cols == 1 ? 1.6 : 0.85,
            ),
            itemBuilder: (context, i) {
              final item = _items[i];
              return RevealOnScroll(
                delayMs: i * 80,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.$1, color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(height: 18),
                      Text(item.$2,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(item.$3,
                            overflow: TextOverflow.ellipsis,
                            maxLines: cols == 1 ? 2 : 4,
                            style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textLight,
                                height: 1.6)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
