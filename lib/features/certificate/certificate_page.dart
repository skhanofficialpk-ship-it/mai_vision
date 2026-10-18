import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/public_shell.dart';
import '../../models/certificate_model.dart';
import '../../services/firestore_service.dart';
import '../../core/utils/certificate_helper.dart';

class CertificatePage extends ConsumerStatefulWidget {
  final String? certificateId;
  const CertificatePage({super.key, this.certificateId});

  @override
  ConsumerState<CertificatePage> createState() => _CertificatePageState();
}

enum _SearchState { idle, loading, found, notFound }

class _CertificatePageState extends ConsumerState<CertificatePage> {
  final _controller = TextEditingController();
  _SearchState _state = _SearchState.idle;
  CertificateModel? _result;

  @override
  void initState() {
    super.initState();
    if (widget.certificateId != null) {
      _controller.text = widget.certificateId!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verify(widget.certificateId!);
      });
    }
  }

  Future<void> _verify([String? id]) async {
    final searchId = id ?? _controller.text.trim();
    if (searchId.isEmpty) return;
    
    setState(() => _state = _SearchState.loading);
    try {
      final cert = await ref.read(firestoreServiceProvider).verifyCertificate(searchId);
      if (mounted) {
        setState(() {
          _result = cert;
          _state = cert != null ? _SearchState.found : _SearchState.notFound;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _state = _SearchState.notFound);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const PageHero(
                title: 'Certificate Verification',
                subtitle:
                    'Instantly verify the authenticity of certificates issued by MAI Coaching Academy.',
              ),
              Section(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.cardShadow,
                                  blurRadius: 24,
                                  offset: const Offset(0, 12)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Verify Certificate Authenticity',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      textCapitalization: TextCapitalization.characters,
                                      decoration: const InputDecoration(
                                        labelText: 'Enter Certificate ID',
                                        hintText: 'e.g. RAI-CERT-2024-0001',
                                        prefixIcon: Icon(Icons.badge_outlined),
                                      ),
                                      onSubmitted: (_) => _verify(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: _state == _SearchState.loading ? null : _verify,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 18),
                                    ),
                                    child: _state == _SearchState.loading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                                color: Colors.white, strokeWidth: 2.5),
                                          )
                                        : const Text('Verify'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (_state == _SearchState.found && _result != null)
                          _ResultCard(cert: _result!),
                        if (_state == _SearchState.notFound) const _NotFoundCard(),
                        if (_state == _SearchState.idle && widget.certificateId == null)
                          _InstructionCard(),
                      ],
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

class _InstructionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.sectionBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 32),
          const SizedBox(height: 12),
          const Text(
            'How to Verify?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Every official certificate from MAI Coaching Academy contains a unique Certificate ID and a QR code. Simply enter the ID above or scan the QR code to verify its authenticity.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final CertificateModel cert;
  const _ResultCard({required this.cert});

  String _formatCourseName(String name) {
    return AppConstants.formatCourseName(name);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMMM d, yyyy');
    final isExp = cert.isExperience;
    final org = cert.organizationName ?? (cert.courseName.toLowerCase().contains('game') ? 'MAI Gaming Studio' : 'MAI Coaching Academy');

    return RevealOnScroll(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isExp ? Colors.purple.withOpacity(0.05) : AppColors.success.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isExp ? Colors.purple.withOpacity(0.4) : AppColors.success.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isExp ? Colors.purple : AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(isExp ? Icons.verified_user : Icons.verified, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isExp ? '✅ Experience Certificate Verified' : '✅ Training Certificate Verified',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isExp ? Colors.purple : AppColors.success,
                        ),
                      ),
                      Text('Official Digital Record Found • $org',
                          style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _row('Certificate ID', cert.certificateId),
            _row('Certificate Type', isExp ? 'Experience Certificate' : 'Training / Course Certificate'),
            _row('Student Name', cert.studentName),
            _row('Issuing Organization', org),
            if (isExp) ...[
              _row('Role / Designation', cert.role ?? 'Flutter Game Developer'),
              _row('Game / Project Title', cert.projectTitle ?? 'Game Development Project'),
              _row('Experience Period', cert.experiencePeriod ?? '2 Months'),
            ] else ...[
              _row('Course Name', _formatCourseName(cert.courseName)),
              _row('Completion Date', dateFmt.format(cert.completionDate)),
            ],
            _row('Issue Date', dateFmt.format(cert.issuedDate)),
            _row('Instructor / Lead', cert.instructorName),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => CertificateHelper.generateAndPrint(cert),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isExp ? Colors.purple : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.qr_code_rounded, size: 20),
                label: const Text('Export Official Verification QR Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 400;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.text)),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 160,
                child: Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.w500)),
              ),
              Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.text)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotFoundCard extends StatelessWidget {
  const _NotFoundCard();

  @override
  Widget build(BuildContext context) {
    return RevealOnScroll(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('❌ Invalid Certificate',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.error)),
                  SizedBox(height: 4),
                  Text(
                    'No record found for this Certificate ID. Please verify the ID or contact support.',
                    style: TextStyle(color: AppColors.textLight, fontSize: 13.5, height: 1.5),
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
