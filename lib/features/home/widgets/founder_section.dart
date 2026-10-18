import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class FounderSection extends StatelessWidget {
  const FounderSection({super.key});

  static const _skills = [
    ('Flutter Development', Icons.phone_iphone),
    ('AI Tools', Icons.smart_toy),
    ('MS Office', Icons.description),
    ('Soft Skills', Icons.groups),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;

    final image = Container(
      width: isMobile ? 220 : 320,
      height: isMobile ? 220 : 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/founder.png',
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(
            color: AppColors.sectionBg,
            child: const Icon(Icons.person, size: 80, color: AppColors.textMuted),
          ),
        ),
      ),
    );

    final info = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const SectionEyebrow(text: 'Meet the Founder'),
        const SizedBox(height: 16),
        Text(
          'Muzammil Khan',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 6),
        const Text(
          'Founder & Lead Instructor',
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 18, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'BS-IT — University of Swat',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'Muzammil Khan is a Flutter developer and IT Graduated with a passion for teaching. '
            'He founded MAI Coaching Academy to bring practical, modern computer and AI skills to students '
            'in Swat — skills that open real doors in today\'s digital job market.',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: const TextStyle(color: AppColors.textLight, height: 1.7, fontSize: 15),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          spacing: 12,
          runSpacing: 12,
          children: _skills
              .map((s) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.sectionBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(s.$2, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(s.$1,
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );

    return Section(
      backgroundColor: AppColors.sectionBg,
      child: isMobile
          ? Column(children: [image, const SizedBox(height: 36), info])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                image,
                const SizedBox(width: 56),
                Expanded(child: info),
              ],
            ),
    );
  }
}
