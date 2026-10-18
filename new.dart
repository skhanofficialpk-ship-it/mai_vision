import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Premium Color Palette ---
class CertColors {
  static const Color navy = Color(0xFF0A1D37);
  static const Color gold = Color(0xFFC5A059);
  static const Color white = Colors.white;
  static const Color darkGray = Color(0xFF333333);
  static const Color lightGray = Color(0xFFF5F5F5);
}

class PremiumCertificate extends StatelessWidget {
  // Dynamic Fields
  final String studentName;
  final String courseName;
  final String completionDate;
  final String issueDate;
  final String courseDuration;
  final String verificationId;

  const PremiumCertificate({
    super.key,
    this.studentName = "ABDULLAH AL-MANSOOR",
    this.courseName = "EXECUTIVE MASTERCLASS IN ARTIFICIAL INTELLIGENCE",
    this.completionDate = "September 24, 2023",
    this.issueDate = "October 01, 2023",
    this.courseDuration = "6 Months (480 Contact Hours)",
    this.verificationId = "RAI-9928-8812-X01",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CertColors.lightGray,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: AspectRatio(
              aspectRatio: 1.414, // Perfect A4 Landscape Ratio
              child: Container(
                decoration: BoxDecoration(
                  color: CertColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 50,
                      offset: const Offset(0, 20),
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    // 1. Watermark Layer
                    const Positioned.fill(child: _AIWatermark()),

                    // 2. Double Border Layer
                    const Positioned.fill(child: _CertificateBorders()),

                    // 3. Content Layer
                    _buildMainContent(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(80.0),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          const Divider(thickness: 1, color: CertColors.navy),
          const Spacer(flex: 2),
          _buildTitle(),
          const Spacer(flex: 2),
          _buildRecipientSection(),
          const Spacer(flex: 1),
          _buildCourseSection(),
          const Spacer(flex: 3),
          _buildInformationGrid(),
          const Spacer(flex: 4),
          _buildSignatureAndSealRow(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(Icons.auto_awesome, size: 60, color: CertColors.navy),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "MAI COACHING ACADEMY",
              style: GoogleFonts.cinzel(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: CertColors.navy,
                letterSpacing: 2,
              ),
            ),
            Text(
              "BUILD YOUR FUTURE WITH AI",
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CertColors.gold,
                letterSpacing: 5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          "CERTIFICATE",
          style: GoogleFonts.cinzel(
            fontSize: 60,
            fontWeight: FontWeight.w400,
            color: CertColors.navy,
            letterSpacing: 15,
          ),
        ),
        Text(
          "OF COMPLETION",
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: CertColors.darkGray,
            letterSpacing: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientSection() {
    return Column(
      children: [
        Text(
          "THIS IS TO PROUDLY PRESENT TO",
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: CertColors.darkGray,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: CertColors.gold, width: 1.5)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              studentName,
              style: GoogleFonts.montserrat(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: CertColors.navy,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseSection() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        courseName,
        style: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: CertColors.navy,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildInformationGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoColumn("COMPLETION DATE", completionDate),
        _buildInfoColumn("ISSUE DATE", issueDate),
        _buildInfoColumn("COURSE DURATION", courseDuration),
        _buildInfoColumn("VERIFICATION ID", verificationId),
        _buildQRSection(),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.montserrat(
            fontSize: 9, fontWeight: FontWeight.bold, color: CertColors.gold)),
        const SizedBox(height: 5),
        Text(value, style: GoogleFonts.montserrat(
            fontSize: 11, fontWeight: FontWeight.w600, color: CertColors.navy)),
      ],
    );
  }

  Widget _buildQRSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              border: Border.all(color: CertColors.navy, width: 1)),
          child: const Icon(Icons.qr_code_2, size: 55, color: CertColors.navy),
        ),
        const SizedBox(height: 4),
        Text("Scan to Verify", style: GoogleFonts.montserrat(
            fontSize: 8, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSignatureAndSealRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Instructor Column
        Expanded(child: _buildSignature("INSTRUCTOR SIGNATURE")),

        // SEAL Column (Dedicated Space, Non-overlapping)
        Expanded(
          child: Center(
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: CertColors.gold.withOpacity(0.3), width: 4),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CertColors.gold, width: 2),
                ),
                child: Center(
                  child: Text(
                    "OFFICIAL\nINSTITUTE\nSEAL",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: CertColors.gold),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Director Column
        Expanded(child: _buildSignature("DIRECTOR SIGNATURE")),
      ],
    );
  }

  Widget _buildSignature(String label) {
    return Column(
      children: [
        Container(
          width: 180,
          padding: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(border: Border(
              bottom: BorderSide(color: CertColors.navy, width: 1))),
          child: const Center(
            child: Text("Signature", style: TextStyle(
                fontStyle: FontStyle.italic, color: Colors.grey)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.montserrat(
            fontSize: 10, fontWeight: FontWeight.bold, color: CertColors.navy)),
      ],
    );
  }
}

class _CertificateBorders extends StatelessWidget {
  const _CertificateBorders();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Outer Gold Border
        Container(
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              border: Border.all(color: CertColors.gold, width: 2)),
        ),
        // Inner Navy Border
        Container(
          margin: const EdgeInsets.all(25),
          decoration: BoxDecoration(
              border: Border.all(color: CertColors.navy, width: 1)),
        ),
        // Corner Decorations
        Positioned.fill(child: CustomPaint(painter: _CornerPainter())),
      ],
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CertColors.navy
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    double p = 25; // padding
    double l = 40; // length

    canvas.drawPath(Path()
      ..moveTo(p, p + l)
      ..lineTo(p, p)..lineTo(p + l, p), paint);
    canvas.drawPath(Path()
      ..moveTo(size.width - p - l, p)
      ..lineTo(size.width - p, p)..lineTo(size.width - p, p + l), paint);
    canvas.drawPath(Path()
      ..moveTo(p, size.height - p - l)
      ..lineTo(p, size.height - p)..lineTo(p + l, size.height - p), paint);
    canvas.drawPath(Path()
      ..moveTo(size.width - p - l, size.height - p)
      ..lineTo(size.width - p, size.height - p)..lineTo(
          size.width - p, size.height - p - l), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _AIWatermark extends StatelessWidget {
  const _AIWatermark();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.04,
      child: CustomPaint(
        painter: _WatermarkPainter(),
      ),
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = CertColors.navy
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double spacing = 50.0;
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1, paint);
        if (i % 100 == 0) {
          canvas.drawLine(Offset(i, j), Offset(i + 20, j + 20), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
