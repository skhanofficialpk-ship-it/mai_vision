import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../models/game_project_model.dart';
import '../../models/admission_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/public_shell.dart';

class GamingStudioPage extends ConsumerWidget {
  const GamingStudioPage({super.key});

  void _launchUrl(String? urlStr) async {
    if (urlStr == null || urlStr.trim().isEmpty) return;
    final uri = Uri.parse(urlStr.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              // Gaming Studio Hero Banner (Light, Bright Theme)
              const _GamingHeroSection(),

              // Studio Statistics Counter
              const _StudioStatsSection(),

              // Program Overview & Detailed Curriculum
              const _ProgramOverviewSection(),

              // Public Student Game Showcase
              _GamePortfolioSection(
                firestoreService: firestoreService,
                onLaunchUrl: _launchUrl,
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

// ─────────────────────────────────────────────────────────────────────────────
// HERO SECTION (Bright Light Theme with Soft Colorful Gradients)
// ─────────────────────────────────────────────────────────────────────────────

class _GamingHeroSection extends StatelessWidget {
  const _GamingHeroSection();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;
    final isDesktop = w >= 1100;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Stack(
        children: [
          // Ambient soft background gradients (Cyan, Violet, Emerald, Blue)
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF06B6D4).withOpacity(0.12),
                    const Color(0xFF3B82F6).withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -60,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withOpacity(0.12),
                    const Color(0xFFEC4899).withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: w * 0.25,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Hero Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : (isDesktop ? 80 : 40),
              vertical: isMobile ? 48 : 80,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Text & CTA Column
                          Expanded(
                            flex: 6,
                            child: _buildHeroLeftColumn(context, isMobile: false),
                          ),
                          const SizedBox(width: 50),
                          // Visual Gaming Feature Card Column
                          const Expanded(
                            flex: 5,
                            child: _HeroVisualCard(),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildHeroLeftColumn(context, isMobile: isMobile),
                          if (!isMobile) ...[
                            const SizedBox(height: 48),
                            const _HeroVisualCard(),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroLeftColumn(BuildContext context, {required bool isMobile}) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Studio Location Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEFF6FF), Color(0xFFF3E8FF)],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFC084FC).withOpacity(0.4)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F0F172A),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sports_esports, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 10),
              const Text(
                'SPECIALIZED BRANCH • MANGLOR, SWAT',
                style: TextStyle(
                  color: Color(0xFF6B21A8),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Main Studio Title
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF2563EB), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'MAI GAMING STUDIO',
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 32 : 46,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Catchy Headline
        Text(
          'Craft, Play & Publish Next-Gen 2D Games',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            color: const Color(0xFF1E293B),
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),

        // Subtitle / Intro Text
        Text(
          'Swat\'s premier Flutter & Flame Game Development Studio. We empower creative students to design, code, physics-wire, and deploy original games directly to Google Play Store.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 16,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),

        // Quick Highlights Bar
        Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: const [
            _HeroChip(icon: Icons.schedule_rounded, label: '2 Months Course', color: Color(0xFF2563EB)),
            _HeroChip(icon: Icons.code_rounded, label: 'Flutter & Flame 2D', color: Color(0xFF06B6D4)),
            _HeroChip(icon: Icons.shop_rounded, label: 'Play Store Launch', color: Color(0xFFD97706)),
            _HeroChip(icon: Icons.verified_rounded, label: 'Dual Certificate', color: Color(0xFF059669)),
          ],
        ),
        const SizedBox(height: 32),

        // Call-to-action buttons
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _GradientButton(
              onPressed: () => context.go('/admissions'),
              icon: Icons.rocket_launch_rounded,
              label: 'Apply For Game Dev Training',
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/contact'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E293B),
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              icon: const Icon(Icons.location_on_rounded, size: 20, color: Color(0xFF7C3AED)),
              label: const Text('Visit Manglor Studio'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HeroChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const _GradientButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(_isHovered ? 0.4 : 0.25),
              blurRadius: _isHovered ? 20 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          icon: Icon(widget.icon, size: 20),
          label: Text(widget.label),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO VISUAL GAMING CONSOLE / FEATURE CARD GRAPHIC
// ─────────────────────────────────────────────────────────────────────────────

class _HeroVisualCard extends StatelessWidget {
  const _HeroVisualCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar of Mock Console
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.videogame_asset_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flame Game Engine Lab',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Live 2D Physics & Sprite Studio',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                    SizedBox(width: 6),
                    Text(
                      'ACTIVE',
                      style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Code + Physics Visual Showcase Container
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _dot(const Color(0xFFEF4444)),
                        const SizedBox(width: 6),
                        _dot(const Color(0xFFF59E0B)),
                        const SizedBox(width: 6),
                        _dot(const Color(0xFF10B981)),
                        const SizedBox(width: 12),
                        const Text(
                          'game_controller.dart',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    const Icon(Icons.code_rounded, color: Color(0xFF38BDF8), size: 16),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'class PlayerGameLoop extends FlameGame with HasCollisionDetection {\n'
                  '  late PlayerSprite player;\n'
                  '  @override\n'
                  '  Future<void> onLoad() async {\n'
                  '    add(player = PlayerSprite(position: Vector2(100, 200)));\n'
                  '    add(PhysicsWorld(gravity: Vector2(0, 9.8)));\n'
                  '  }\n'
                  '}',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 11.5,
                    height: 1.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Feature Highlights Cards Row inside Hero Graphic
          Row(
            children: [
              Expanded(
                child: _miniMetricTile(
                  icon: Icons.emoji_events_rounded,
                  color: const Color(0xFFF59E0B),
                  title: '100% Original',
                  subtitle: 'Student Projects',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniMetricTile(
                  icon: Icons.phone_android_rounded,
                  color: const Color(0xFF3B82F6),
                  title: 'Google Play',
                  subtitle: 'Direct Deployment',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _miniMetricTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STUDIO STATISTICS COUNTER SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _StudioStatsSection extends ConsumerWidget {
  const _StudioStatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;

    return StreamBuilder<List<GameProjectModel>>(
      stream: firestoreService.getGameProjects(onlyPublished: true),
      builder: (context, gameSnapshot) {
        final publishedCount = gameSnapshot.data?.length ?? 0;

        return StreamBuilder<List<AdmissionModel>>(
          stream: firestoreService.getAdmissions(status: 'approved'),
          builder: (context, studentSnapshot) {
            final studentsCount = studentSnapshot.data?.length ?? 0;

            return Container(
              width: double.infinity,
              color: const Color(0xFFF8FAFC),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 60,
                vertical: 40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1150),
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 20 : 32),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFEFF6FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFDBEAFE)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C0F172A),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: isMobile
                        ? GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.4,
                            children: [
                              _StatCounterTile(
                                icon: Icons.sports_esports_rounded,
                                color: const Color(0xFF2563EB),
                                value: '$publishedCount',
                                label: 'Total Games Published',
                              ),
                              _StatCounterTile(
                                icon: Icons.groups_rounded,
                                color: const Color(0xFF7C3AED),
                                value: '$studentsCount',
                                label: 'Students Enrolled',
                              ),
                              const _StatCounterTile(
                                icon: Icons.shop_rounded,
                                color: Color(0xFFD97706),
                                value: '100%',
                                label: 'Play Store Launches',
                              ),
                              const _StatCounterTile(
                                icon: Icons.workspace_premium_rounded,
                                color: Color(0xFF059669),
                                value: 'Dual',
                                label: 'Certificates Offered',
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _StatCounterTile(
                                  icon: Icons.sports_esports_rounded,
                                  color: const Color(0xFF2563EB),
                                  value: '$publishedCount',
                                  label: 'Total Games Published',
                                ),
                              ),
                              _statDivider(),
                              Expanded(
                                child: _StatCounterTile(
                                  icon: Icons.groups_rounded,
                                  color: const Color(0xFF7C3AED),
                                  value: '$studentsCount',
                                  label: 'Students Enrolled',
                                ),
                              ),
                              _statDivider(),
                              const Expanded(
                                child: _StatCounterTile(
                                  icon: Icons.shop_rounded,
                                  color: Color(0xFFD97706),
                                  value: '100%',
                                  label: 'Play Store Launches',
                                ),
                              ),
                              _statDivider(),
                              const Expanded(
                                child: _StatCounterTile(
                                  icon: Icons.workspace_premium_rounded,
                                  color: Color(0xFF059669),
                                  value: 'Dual',
                                  label: 'Certificates Offered',
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _statDivider() {
    return Container(
      height: 48,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFCBD5E1),
    );
  }
}

class _StatCounterTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCounterTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROGRAM OVERVIEW & CURRICULUM SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeText;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (badgeText != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
            ),
            child: Text(
              badgeText!.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textLight,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgramOverviewSection extends StatelessWidget {
  const _ProgramOverviewSection();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;

    return Section(
      child: Column(
        children: [
          const _SectionHeader(
            badgeText: 'Curriculum Highlights',
            title: '2-Month Flutter Game Development Program',
            subtitle:
                'An intensive, practical, project-based program where every student builds and publishes their own original 2D game.',
          ),
          const SizedBox(height: 48),

          // Key Feature Cards Grid with State Hovering
          GridView.count(
            crossAxisCount: isMobile ? 1 : (w < 1000 ? 2 : 4),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: isMobile ? 2.4 : (w < 1200 ? 1.15 : 1.25),
            children: const [
              _HoverableFeatureCard(
                icon: Icons.schedule_rounded,
                title: '2 Months Duration',
                subtitle: 'Intensive practical training & individual game project phase.',
                accentColor: Color(0xFF2563EB), // Royal Blue
                gradientColors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
              ),
              _HoverableFeatureCard(
                icon: Icons.sentiment_very_satisfied_rounded,
                title: 'Beginner-Friendly',
                subtitle: 'No prior game development experience required to enroll!',
                accentColor: Color(0xFF059669), // Emerald
                gradientColors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
              ),
              _HoverableFeatureCard(
                icon: Icons.terminal_rounded,
                title: 'Flutter & Flame Engine',
                subtitle: 'Cross-platform 2D game loops, physics & sprite animations.',
                accentColor: Color(0xFF7C3AED), // Violet
                gradientColors: [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
              ),
              _HoverableFeatureCard(
                icon: Icons.shop_rounded,
                title: 'Play Store Launch',
                subtitle: 'Publish student games directly to Google Play Store.',
                accentColor: Color(0xFFD97706), // Amber
                gradientColors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Detailed Curriculum Roadmap Card
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C0F172A),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x207C3AED),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Training & Project Phase Structure',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Learn by building real playable games step-by-step',
                            style: TextStyle(fontSize: 13.5, color: AppColors.textLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                _curriculumStep(
                  stepNumber: '01',
                  stepColor: const Color(0xFF2563EB),
                  title: 'Month 1: Fundamentals, Physics & Sprites',
                  desc:
                      'Dart programming, Flutter UI, Flame game engine setup, game loops, sprite animations, collision detection, particle effects, and joystick controls.',
                ),
                const SizedBox(height: 20),
                _curriculumStep(
                  stepNumber: '02',
                  stepColor: const Color(0xFF7C3AED),
                  title: 'Month 2: Individual Project & Play Store Publishing',
                  desc:
                      'Student original game creation, audio SFX integration, scoreboard UI, level progression, testing, APK/AAB build generation, and Google Play Store deployment.',
                ),
                const SizedBox(height: 20),
                _curriculumStep(
                  stepNumber: '03',
                  stepColor: const Color(0xFF059669),
                  title: 'Dual Certifications Awarded',
                  desc:
                      'Upon completion, students receive both a Training Certificate and an Experience Certificate with QR code online verification.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _curriculumStep({
    required String stepNumber,
    required Color stepColor,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: stepColor.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: stepColor.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: TextStyle(
                color: stepColor,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HoverableFeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final List<Color> gradientColors;

  const _HoverableFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.gradientColors,
  });

  @override
  State<_HoverableFeatureCard> createState() => _HoverableFeatureCardState();
}

class _HoverableFeatureCardState extends State<_HoverableFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        transform: _isHovered ? (Matrix4.identity()..translate(0, -4)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? widget.accentColor.withOpacity(0.5) : const Color(0xFFE2E8F0),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.accentColor.withOpacity(0.12)
                  : const Color(0x0A0F172A),
              blurRadius: _isHovered ? 20 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(widget.icon, color: widget.accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textLight,
                      height: 1.35,
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC STUDENT GAME SHOWCASE & DYNAMIC FIRESTORE PORTFOLIO
// ─────────────────────────────────────────────────────────────────────────────

class _GamePortfolioSection extends StatelessWidget {
  final FirestoreService firestoreService;
  final ValueChanged<String?> onLaunchUrl;

  const _GamePortfolioSection({
    required this.firestoreService,
    required this.onLaunchUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Section(
      backgroundColor: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          const _SectionHeader(
            badgeText: 'Student Creations',
            title: 'Public Student Game Showcase',
            subtitle:
                'Explore original, live playable games developed by our talented students during their training at MAI Gaming Studio.',
          ),
          const SizedBox(height: 48),

          StreamBuilder<List<GameProjectModel>>(
            stream: firestoreService.getGameProjects(onlyPublished: true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingPortfolioState();
              }

              final projects = snapshot.data ?? [];

              if (projects.isEmpty) {
                return const _EmptyPortfolioState();
              }

              final w = MediaQuery.of(context).size.width;
              final crossAxisCount = w < 768 ? 1 : (w < 1100 ? 2 : 3);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: w < 600 ? 0.72 : (w < 1100 ? 0.66 : 0.68),
                ),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final p = projects[index];
                  return _HoverableGameCard(project: p, onLaunchUrl: onLaunchUrl);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HoverableGameCard extends StatefulWidget {
  final GameProjectModel project;
  final ValueChanged<String?> onLaunchUrl;

  const _HoverableGameCard({
    required this.project,
    required this.onLaunchUrl,
  });

  @override
  State<_HoverableGameCard> createState() => _HoverableGameCardState();
}

class _HoverableGameCardState extends State<_HoverableGameCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        transform: _isHovered ? (Matrix4.identity()..translate(0, -6)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered ? const Color(0xFF3B82F6).withOpacity(0.5) : const Color(0xFFE2E8F0),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0xFF3B82F6).withOpacity(0.16)
                  : const Color(0x0C0F172A),
              blurRadius: _isHovered ? 24 : 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image / Header Accent
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  children: [
                    if (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                      Image.network(
                        p.imageUrl!,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderBanner(p),
                      )
                    else
                      _buildPlaceholderBanner(p),

                    // Top Left Genre Pill
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sports_esports, size: 13, color: Color(0xFF2563EB)),
                            const SizedBox(width: 5),
                            Text(
                              p.genre,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top Right Live/Published Tag
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'PUBLISHED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Card Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Student Developer
                    Text(
                      p.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.text,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF7C3AED)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Developer: ${p.studentName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF7C3AED),
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Description
                    Expanded(
                      child: Text(
                        p.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tech Stack Pills
                    if (p.technologies.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: p.technologies.take(4).map((tech) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                              border: Border.fromBorderSide(BorderSide(color: Color(0xFFE2E8F0))),
                            ),
                            child: Text(
                              tech,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475569),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Action Buttons: Play Store & Play in Browser
                    Row(
                      children: [
                        if (p.playStoreUrl != null && p.playStoreUrl!.isNotEmpty)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => widget.onLaunchUrl(p.playStoreUrl),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.shop_rounded, size: 16, color: Color(0xFF38BDF8)),
                              label: const Text(
                                'Play Store',
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        if (p.playStoreUrl != null && p.playStoreUrl!.isNotEmpty)
                          const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => _GamePlayModal(
                                  project: p,
                                  onLaunchUrl: widget.onLaunchUrl,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.play_circle_fill_rounded, size: 16),
                            label: const Text(
                              'Play in Browser',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderBanner(GameProjectModel p) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF2563EB), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.gamepad_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 6),
            Text(
              p.title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIVE BROWSER GAME PLAY MODAL & IFRAME
// ─────────────────────────────────────────────────────────────────────────────

class _GamePlayModal extends StatelessWidget {
  final GameProjectModel project;
  final ValueChanged<String?> onLaunchUrl;

  const _GamePlayModal({
    required this.project,
    required this.onLaunchUrl,
  });

  @override
  Widget build(BuildContext context) {
    final gameUrl = (project.otherUrl != null && project.otherUrl!.isNotEmpty)
        ? project.otherUrl!
        : (project.playStoreUrl ?? '');

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth * 0.9).clamp(320.0, 960.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0284C7).withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Modal Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.sports_esports_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Developer: ${project.studentName} • ${project.genre}',
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, color: Colors.white70, size: 20),
                    tooltip: 'Open in New Tab',
                    onPressed: () => onLaunchUrl(gameUrl),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                    tooltip: 'Close Player',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Game Screen / Web Player Frame
            Container(
              height: 480,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                children: [
                  if (kIsWeb && gameUrl.isNotEmpty)
                    _WebIframePlayer(url: gameUrl)
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videogame_asset_rounded, color: Color(0xFF38BDF8), size: 56),
                            const SizedBox(height: 16),
                            Text(
                              'Live Web Demo for ${project.title}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Click below to launch and play the game demo in a new browser tab.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => onLaunchUrl(gameUrl),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.play_arrow_rounded, size: 20),
                              label: const Text('Launch Web Demo Player', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Modal Footer Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Verified Student Game • MAI Gaming Studio',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Done Playing'),
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

class _WebIframePlayer extends StatefulWidget {
  final String url;
  const _WebIframePlayer({required this.url});

  @override
  State<_WebIframePlayer> createState() => _WebIframePlayerState();
}

class _WebIframePlayerState extends State<_WebIframePlayer> {
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'game-iframe-${DateTime.now().millisecondsSinceEpoch}';
    if (kIsWeb) {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int id) {
          final element = html.IFrameElement()
            ..src = widget.url
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allowFullscreen = true;
          return element;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return HtmlElementView(viewType: _viewId);
    }
    return const Center(child: Text('Web player only available on Web', style: TextStyle(color: Colors.white)));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY & LOADING STATES
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyPortfolioState extends StatelessWidget {
  const _EmptyPortfolioState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFF3E8FF)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sports_esports_outlined, size: 48, color: Color(0xFF2563EB)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Published Games Launching Soon!',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: const Text(
              'Our current batch of students is currently designing and coding exciting new 2D Flutter games. Check back soon to play!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPortfolioState extends StatelessWidget {
  const _LoadingPortfolioState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading Student Showcase...',
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
