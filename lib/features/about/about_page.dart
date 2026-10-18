import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/public_shell.dart';
import '../home/widgets/founder_section.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const PageHero(
                title: 'About MAI Coaching Academy',
                subtitle:
                    'Empowering students in Swat with practical computer and AI skills for a digital future.',
              ),
              const _MissionSection(),
              const FounderSection(),
              const _ValuesSection(),
              const _LocationSection(),
              const AppFooter(),
            ],
          ),
        ),
        const WhatsAppFab(),
      ],
    );
  }
}

class _MissionSection extends StatelessWidget {
  const _MissionSection();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;

    final mission = _InfoCard(
      icon: Icons.flag,
      title: 'Our Mission',
      body:
          'To make practical computer literacy and artificial intelligence skills accessible to every student in Swat — regardless of their starting point — through hands-on, affordable, and locally relevant training.',
    );
    final vision = _InfoCard(
      icon: Icons.visibility,
      title: 'Our Vision',
      body:
          'To become the leading institute in the region for digital skills education, producing graduates who are confident, capable, and ready to compete in modern, AI-driven workplaces.',
    );

    return Section(
      child: isMobile
          ? Column(children: [mission, const SizedBox(height: 24), vision])
          : Row(
              children: [
                Expanded(child: mission),
                const SizedBox(width: 24),
                Expanded(child: vision),
              ],
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _InfoCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return RevealOnScroll(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.sectionBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
            const SizedBox(height: 12),
            Text(body,
                style: const TextStyle(color: AppColors.textLight, fontSize: 14.5, height: 1.7)),
          ],
        ),
      ),
    );
  }
}

class _ValuesSection extends StatelessWidget {
  const _ValuesSection();

  static const _values = [
    (Icons.lightbulb, 'Practical Learning', 'We teach skills you can use immediately — not just theory.'),
    (Icons.diversity_3, 'Accessibility', 'Quality education at a fair price, open to everyone in our community.'),
    (Icons.trending_up, 'Continuous Growth', 'Our curriculum evolves with the latest tools and technology trends.'),
    (Icons.handshake, 'Integrity', 'Honest guidance, transparent fees, and genuine commitment to student success.'),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w < 700 ? 1 : (w < 1100 ? 2 : 4);

    return Section(
      backgroundColor: AppColors.sectionBg,
      child: Column(
        children: [
          const SectionEyebrow(text: 'Our Values'),
          const SizedBox(height: 16),
          Text('What Drives Us', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _values.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: cols == 1 ? 2.6 : 0.9,
            ),
            itemBuilder: (context, i) {
              final v = _values[i];
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(v.$1, color: AppColors.accent, size: 30),
                    const SizedBox(height: 14),
                    Text(v.$2,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.text)),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(v.$3,
                          overflow: TextOverflow.ellipsis,
                          maxLines: cols == 1 ? 2 : 4,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textLight, height: 1.6)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection();

  @override
  Widget build(BuildContext context) {
    return Section(
      child: Column(
        children: [
          const SectionEyebrow(text: 'Find Us'),
          const SizedBox(height: 16),
          Text('Visit Our Campus', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          const Text(
            AppConstants.location,
            style: TextStyle(color: AppColors.textLight, fontSize: 15),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            height: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.sectionBg,
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: const _MapEmbed(),
          ),
        ],
      ),
    );
  }
}

class _MapEmbed extends StatelessWidget {
  const _MapEmbed();

  Future<void> _openMaps() async {
    final uri = Uri.parse(AppConstants.mapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openMaps,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.06), AppColors.secondary.withOpacity(0.1)],
              ),
            ),
          ),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 56, color: AppColors.primary),
                SizedBox(height: 12),
                Text(AppConstants.location,
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text)),
                Text('Tap to open in Google Maps',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
