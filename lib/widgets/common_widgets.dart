import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Responsive horizontal padding wrapper used across all sections.
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? extraPadding;
  const ResponsivePadding({super.key, required this.child, this.extraPadding});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double horizontal;
    if (w < 600) {
      horizontal = 20;
    } else if (w < 1024) {
      horizontal = 40;
    } else if (w < 1440) {
      horizontal = 80;
    } else {
      horizontal = (w - 1280) / 2;
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal).add(
        extraPadding ?? EdgeInsets.zero,
      ),
      child: child,
    );
  }
}

/// A full-width section with consistent vertical rhythm and background.
class Section extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double verticalPadding;
  const Section({
    super.key,
    required this.child,
    this.backgroundColor,
    this.verticalPadding = 80,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final vPad = w < 600 ? verticalPadding * 0.6 : verticalPadding;
    return Container(
      width: double.infinity,
      color: backgroundColor ?? AppColors.background,
      padding: EdgeInsets.symmetric(vertical: vPad),
      child: ResponsivePadding(child: child),
    );
  }
}

/// Small eyebrow label used above section headings.
class SectionEyebrow extends StatelessWidget {
  final String text;
  const SectionEyebrow({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Reveals child with a fade+slide-up animation when it scrolls into view.
class RevealOnScroll extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const RevealOnScroll({super.key, required this.child, this.delayMs = 0});

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  final _key = UniqueKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.15 && !_visible) {
          _visible = true;
          Future.delayed(Duration(milliseconds: widget.delayMs), () {
            if (mounted) _controller.forward();
          });
        }
      },
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}

/// Floating WhatsApp contact button shown on all public pages.
class WhatsAppFab extends StatelessWidget {
  const WhatsAppFab({super.key});

  Future<void> _launch() async {
    final uri = Uri.parse(AppConstants.whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: Material(
        color: const Color(0xFF25D366),
        shape: const CircleBorder(),
        elevation: 6,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _launch,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.chat, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}

/// Primary CTA button with optional outlined style.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool outlined;
  final IconData? icon;
  final Color? color;
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? AppColors.primary,
          side: BorderSide(color: color ?? AppColors.primary, width: 1.5),
        ),
        child: child,
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
      ),
      child: child,
    );
  }
}

/// Badge shown on courses that are visible but not yet open for admission.
/// Driven entirely by [CourseModel.admissionOpen] — no per-course hardcoding.
class NextBatchBadge extends StatelessWidget {
  const NextBatchBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 13, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(
            'Available in the Next Batch',
            style: TextStyle(
              color: AppColors.accent.withOpacity(0.95),
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading indicator with brand color.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

/// Generic page hero banner for non-home pages.
class PageHero extends StatelessWidget {
  final String title;
  final String subtitle;
  const PageHero({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 56 : 88,
      ),
      child: ResponsivePadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 32 : 44,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isMobile ? 15 : 17,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
