import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

import '../../../core/constants/app_constants.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;
    final isTablet = w >= 768 && w < 1200;

    final content = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const SectionEyebrow(text: '${AppConstants.admissionsOpenText} • ${AppConstants.classesStartText}'),
        const SizedBox(height: 20),
        Text(
          'Learn AI & Computer Skills',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: isMobile ? 36 : (isTablet ? 44 : 56),
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            letterSpacing: -1,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Professional certification in AI tools, digital skills and computer sciences.',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
              fontSize: 17,
              color: AppColors.textLight,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          spacing: 16,
          runSpacing: 16,
          children: [
            AppButton(
              label: 'Apply Now',
              icon: Icons.arrow_forward,
              onPressed: () => context.go('/admissions'),
            ),
            AppButton(
              label: 'View Courses & Fees',
              outlined: true,
              onPressed: () => context.go('/courses'),
            ),
          ],
        ),
        const SizedBox(height: 48),
        Wrap(
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          spacing: 28,
          runSpacing: 16,
          children: const [
            _FeaturePill(icon: Icons.school, label: 'Expert Instructors'),
            _FeaturePill(icon: Icons.verified, label: 'Certificate Awarded'),
            _FeaturePill(icon: Icons.touch_app, label: 'Hands-On Training'),
            _FeaturePill(icon: Icons.auto_awesome, label: 'Modern Curriculum'),
          ],
        ),
      ],
    );

    final visual = _HeroVisual(isMobile: isMobile);

    return Container(
      width: double.infinity,
      color: AppColors.sectionBg,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 0,
        vertical: isMobile ? 56 : 100,
      ),
      child: ResponsivePadding(
        child: isMobile
            ? Column(
                children: [
                  content,
                  const SizedBox(height: 40),
                  visual,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 6, child: content),
                  const SizedBox(width: 48),
                  Expanded(flex: 5, child: visual),
                ],
              ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  final bool isMobile;
  const _HeroVisual({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 280 : 420,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.18),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.school, color: Colors.white, size: 44),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'MAI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'COACHING ACADEMY',
                  style: TextStyle(
                    color: Color(0xFFFDE68A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Build your future with Modern AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
