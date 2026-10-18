import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/public_shell.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    // Opens the user's mail client with prefilled content directed to the institute email.
    final subject = Uri.encodeComponent('Website Contact from ${_name.text}');
    final body = Uri.encodeComponent('${_message.text}\n\nFrom: ${_name.text} (${_email.text})');
    await _launch('mailto:${AppConstants.email}?subject=$subject&body=$body');
    setState(() => _sending = false);
    Fluttertoast.showToast(msg: 'Opening your email app...');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 900;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const PageHero(
                title: 'Contact Us',
                subtitle: 'Have a question about courses or admissions? Reach out — we respond quickly.',
              ),
              Section(
                child: isMobile
                    ? Column(
                        children: [
                          _ContactInfoCard(onLaunch: _launch),
                          const SizedBox(height: 28),
                          _ContactForm(
                            formKey: _formKey,
                            name: _name,
                            email: _email,
                            message: _message,
                            sending: _sending,
                            onSubmit: _send,
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _ContactInfoCard(onLaunch: _launch)),
                          const SizedBox(width: 32),
                          Expanded(
                            child: _ContactForm(
                              formKey: _formKey,
                              name: _name,
                              email: _email,
                              message: _message,
                              sending: _sending,
                              onSubmit: _send,
                            ),
                          ),
                        ],
                      ),
              ),
              Section(
                backgroundColor: AppColors.sectionBg,
                child: Container(
                  width: double.infinity,
                  height: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _launch(AppConstants.mapsUrl),
                    child: Container(
                      color: AppColors.white,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 56, color: AppColors.primary),
                            SizedBox(height: 12),
                            Text('View on Google Maps',
                                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text)),
                            Text(AppConstants.location,
                                style: TextStyle(fontSize: 12.5, color: AppColors.textLight)),
                          ],
                        ),
                      ),
                    ),
                  ),
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

class _ContactInfoCard extends StatelessWidget {
  final Future<void> Function(String) onLaunch;
  const _ContactInfoCard({required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Get in Touch',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 8),
        const Text(
          'Whether you have questions about our courses, admissions, or anything else — we\'re here to help.',
          style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 28),
        _InfoTile(
          icon: Icons.location_on,
          title: 'Visit Us',
          subtitle: AppConstants.location,
          onTap: () => onLaunch(AppConstants.mapsUrl),
        ),
        const SizedBox(height: 16),
        _InfoTile(
          icon: Icons.phone,
          title: 'Call Us',
          subtitle: AppConstants.phoneFormatted,
          onTap: () => onLaunch(AppConstants.callUrl),
        ),
        const SizedBox(height: 16),
        _InfoTile(
          icon: Icons.email,
          title: 'Email Us',
          subtitle: AppConstants.email,
          onTap: () => onLaunch(AppConstants.emailUrl),
        ),
        const SizedBox(height: 16),
        _InfoTile(
          icon: Icons.chat,
          title: 'WhatsApp',
          subtitle: AppConstants.phoneFormatted,
          onTap: () => onLaunch(AppConstants.whatsappUrl),
          color: const Color(0xFF25D366),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.sectionBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color ?? AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.text)),
                  Text(subtitle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ContactForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController message;
  final bool sending;
  final VoidCallback onSubmit;

  const _ContactForm({
    required this.formKey,
    required this.name,
    required this.email,
    required this.message,
    required this.sending,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send a Message',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
            const SizedBox(height: 20),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Your Name *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Your Email *'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$').hasMatch(v.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: message,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Message *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sending ? null : onSubmit,
                child: sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Send Message'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
