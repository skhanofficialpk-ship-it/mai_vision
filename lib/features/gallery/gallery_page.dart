import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/public_shell.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  // Placeholder gallery items — admin can manage these via Content Management.
  static const _items = [
    ('Computer Lab Session', Icons.computer),
    ('AI Tools Workshop', Icons.smart_toy),
    ('Certificate Distribution', Icons.workspace_premium),
    ('Typing Practice Class', Icons.keyboard),
    ('Group Project Work', Icons.groups),
    ('Graduation Day', Icons.school),
    ('Hands-On Training', Icons.build_circle),
    ('MS Office Class', Icons.description),
    ('Student Achievements', Icons.emoji_events),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w < 600 ? 2 : (w < 1000 ? 3 : 4);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const PageHero(
                title: 'Gallery',
                subtitle: 'A glimpse into life at MAI Coaching Academy — our classes, students, and milestones.',
              ),
              Section(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, i) {
                    final item = _items[i];
                    return RevealOnScroll(
                      delayMs: i * 50,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.08),
                              AppColors.secondary.withOpacity(0.14),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.$2, size: 36, color: AppColors.primary),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                item.$1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(
                                    fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.text),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
