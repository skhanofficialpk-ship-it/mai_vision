import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  static const _stats = [
    ('3+', 'Certified Courses'),
    ('2', 'Months to Certify'),
    ('100%', 'Hands-On Training'),
    ('1', 'Institute, One Mission'),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w < 700 ? 2 : 4;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: ResponsivePadding(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 1.6,
          ),
          itemBuilder: (context, i) {
            final s = _stats[i];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s.$1,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(s.$2,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CtaSection extends StatelessWidget {
  const CtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;

    return Section(
      backgroundColor: AppColors.sectionBg,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 56, vertical: isMobile ? 40 : 56),
        decoration: BoxDecoration(
          color: AppColors.text,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Text(
              'Ready to Build Your Future with modern AI?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: const Text(
                'Join MAI Coaching Academy today and take the first step towards a certified, in-demand skill set.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 15, height: 1.6),
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/admissions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.text,
                  ),
                  child: const Text('Apply Now'),
                ),
                OutlinedButton(
                  onPressed: () => context.go('/contact'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                  ),
                  child: const Text('Contact Us'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
