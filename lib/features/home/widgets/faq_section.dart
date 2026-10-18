import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../models/faq_model.dart';

class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  int? _expanded = 0;

  @override
  Widget build(BuildContext context) {
    final faqs = defaultFaqs;
    return Section(
      backgroundColor: AppColors.sectionBg,
      child: Column(
        children: [
          const SectionEyebrow(text: 'FAQ'),
          const SizedBox(height: 16),
          Text(
            'Frequently Asked Questions',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 40),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: List.generate(faqs.length, (i) {
                final isOpen = _expanded == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isOpen ? AppColors.primary : AppColors.border),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => _expanded = isOpen ? null : i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    faqs[i].question,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: AppColors.text),
                                  ),
                                ),
                                Icon(
                                  isOpen ? Icons.remove_circle_outline : Icons.add_circle_outline,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedCrossFade(
                          firstChild: const SizedBox(width: double.infinity, height: 0),
                          secondChild: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                faqs[i].answer,
                                style: const TextStyle(
                                    color: AppColors.textLight, fontSize: 14, height: 1.6),
                              ),
                            ),
                          ),
                          crossFadeState:
                              isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 200),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
