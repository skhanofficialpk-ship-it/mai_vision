import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:file_saver/file_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/certificate_model.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

class CertificateHelper {
  static final ScreenshotController _screenshotController = ScreenshotController();

  /// Generates a high-resolution JPEG containing only the QR Code and Certificate ID.
  /// This allows admins to print or attach the QR code onto physical/manual certificates.
  static Future<void> generateAndPrint(CertificateModel cert) async {
    Fluttertoast.showToast(msg: "Generating QR & ID for export...");

    try {
      final verifyUrl = '${AppConstants.websiteUrl}/verify/${cert.certificateId}';

      final widget = Container(
        width: 400,
        height: 520,
        color: Colors.white,
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // High-quality QR Code (Pure Black on White)
            QrImageView(
              data: verifyUrl,
              version: QrVersions.auto,
              size: 320,
              gapless: true,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
            ),
            const SizedBox(height: 30),
            // Professional Identification Label
            const Text(
              'CERTIFICATE ID',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cert.certificateId,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      );

      final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 200),
        pixelRatio: 4.0,
      );

      if (imageBytes == null) throw 'Image capture failed';

      final fileName = 'MAI_QR_${cert.studentName.replaceAll(' ', '_')}';
      
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: imageBytes,
        ext: 'jpg',
        mimeType: MimeType.jpeg,
      );

      Fluttertoast.showToast(msg: "QR Code Exported Successfully!");

    } catch (e) {
      debugPrint('Export Error: $e');
      Fluttertoast.showToast(msg: "Export Error: $e", backgroundColor: AppColors.error);
    }
  }

  /// Alias for backward compatibility
  static Future<void> downloadPdf(CertificateModel cert) async {
    await generateAndPrint(cert);
  }

  /// Displays the QR details in-app for quick preview
  static void showQrPreview(BuildContext context, CertificateModel cert) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Export QR Code for Print', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: QrImageView(
                data: '${AppConstants.websiteUrl}/verify/${cert.certificateId}',
                size: 180,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              cert.certificateId,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text),
            ),
            const SizedBox(height: 5),
            const Text(
              'Download this high-resolution QR code to place on your physical certificate.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              generateAndPrint(cert);
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download JPEG'),
          ),
        ],
      ),
    );
  }
}
