import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/public_shell.dart';
import '../../widgets/admission_form_widget.dart';

class AdmissionsPage extends ConsumerStatefulWidget {
  const AdmissionsPage({super.key});

  @override
  ConsumerState<AdmissionsPage> createState() => _AdmissionsPageState();
}

class _AdmissionsPageState extends ConsumerState<AdmissionsPage> {
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const PageHero(
                title: 'Online Admission',
                subtitle:
                    'Apply in minutes. Our team will reach out within 24–48 hours to confirm your enrollment.',
              ),
              Section(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: _submitted 
                        ? _SuccessState(onReset: () => setState(() => _submitted = false)) 
                        : _buildFormContainer(),
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

  Widget _buildFormContainer() {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Admission Form',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 4),
          const Text('Fill out the details below to apply.',
              style: TextStyle(fontSize: 13, color: AppColors.textLight)),
          const SizedBox(height: 28),
          AdmissionFormWidget(
            onSuccess: () => setState(() => _submitted = true),
          ),
        ],
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  final VoidCallback onReset;
  const _SuccessState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
          ),
          const SizedBox(height: 24),
          const Text('Application Submitted!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 12),
          const Text(
            'Thank you for applying to MAI Coaching Academy. Our team will contact you within 24–48 hours to confirm your enrollment.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.7),
          ),
          const SizedBox(height: 28),
          AppButton(label: 'Submit Another Application', onPressed: onReset),
        ],
      ),
    );
  }
}
