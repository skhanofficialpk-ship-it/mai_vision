import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class AdminContentPage extends StatefulWidget {
  const AdminContentPage({super.key});

  @override
  State<AdminContentPage> createState() => _AdminContentPageState();
}

class _AdminContentPageState extends State<AdminContentPage> {
  final _heroHeadline = TextEditingController(text: 'Learn AI & Computer Skills');
  final _heroSubheadline = TextEditingController(
      text:
          'Professional certification in AI tools, digital skills and computer sciences.');
  final _founderName = TextEditingController(text: AppConstants.founderName);
  final _founderQualification = TextEditingController(text: AppConstants.founderQualification);
  final _phone = TextEditingController(text: AppConstants.phoneFormatted);
  final _email = TextEditingController(text: AppConstants.email);
  final _address = TextEditingController(text: AppConstants.location);

  void _save(String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$section updated successfully'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Website Content',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: -0.5)),
          const SizedBox(height: 6),
          const Text('Control and update information displayed on the public landing page.',
              style: TextStyle(color: AppColors.textLight, fontSize: 14)),
          const SizedBox(height: 32),
          _ContentCard(
            title: 'Hero / Banner Section',
            icon: Icons.auto_awesome_rounded,
            children: [
              TextField(controller: _heroHeadline, decoration: const InputDecoration(labelText: 'Main Title / Headline')),
              const SizedBox(height: 16),
              TextField(
                  controller: _heroSubheadline,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Introduction / Subheadline')),
            ],
            onSave: () => _save('Hero section'),
          ),
          const SizedBox(height: 24),
          _ContentCard(
            title: 'Founder Information',
            icon: Icons.person_pin_rounded,
            children: [
              TextField(controller: _founderName, decoration: const InputDecoration(labelText: 'Founder Full Name')),
              const SizedBox(height: 16),
              TextField(
                  controller: _founderQualification,
                  decoration: const InputDecoration(labelText: 'Founder Qualification')),
            ],
            onSave: () => _save('Founder section'),
          ),
          const SizedBox(height: 24),
          _ContentCard(
            title: 'Institute Contact Details',
            icon: Icons.contact_support_rounded,
            children: [
              TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone Number / WhatsApp')),
              const SizedBox(height: 16),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Official Email Address')),
              const SizedBox(height: 16),
              TextField(
                  controller: _address,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Physical Office Address')),
            ],
            onSave: () => _save('Contact details'),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final VoidCallback onSave;

  const _ContentCard({
    required this.title,
    required this.icon,
    required this.children,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.text)),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onSave, 
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Update Section'),
            ),
          ),
        ],
      ),
    );
  }
}
