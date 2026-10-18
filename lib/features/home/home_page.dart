import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/public_shell.dart';
import 'widgets/hero_section.dart';
import 'widgets/why_choose_us_section.dart';
import 'widgets/founder_section.dart';
import 'widgets/courses_preview_section.dart';
import 'widgets/stats_cta_section.dart';
import 'widgets/faq_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: const [
              HeroSection(),
              WhyChooseUsSection(),
              FounderSection(),
              CoursesPreviewSection(),
              StatsSection(),
              CtaSection(),
              FaqSection(),
              AppFooter(),
            ],
          ),
        ),
        const WhatsAppFab(),
      ],
    );
  }
}
