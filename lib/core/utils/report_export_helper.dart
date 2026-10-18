import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../models/payment_model.dart';
import '../../models/student_model.dart';
import '../constants/app_constants.dart';

class ReportExportHelper {
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF1E40AF); // AppColors.primary
  static const PdfColor secondaryColor = PdfColor.fromInt(0xFF2563EB); // AppColors.secondary
  static const PdfColor textLight = PdfColor.fromInt(0xFF64748B);

  static pw.Widget _buildInstituteHeader(String reportTitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          AppConstants.instituteName.toUpperCase(),
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: primaryColor),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          AppConstants.tagline,
          style: pw.TextStyle(fontSize: 12, color: secondaryColor),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          '${AppConstants.location}  |  Phone: ${AppConstants.phoneFormatted}',
          style: const pw.TextStyle(fontSize: 10, color: textLight),
        ),
        pw.SizedBox(height: 16),
        pw.Divider(color: primaryColor, thickness: 1.5),
        pw.SizedBox(height: 12),
        pw.Text(
          reportTitle,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}  |  Generated on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
        style: const pw.TextStyle(fontSize: 10, color: textLight),
      ),
    );
  }

  static Future<void> generateOutstandingReport(List<StudentModel> students) async {
    final outstandingStudents = students.where((s) => s.outstanding > 0).toList();
    final currencyFmt = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildInstituteHeader('OUTSTANDING FEE REPORT'),
        footer: _buildFooter,
        build: (context) {
          double totalOutstanding = 0;

          return [
            pw.TableHelper.fromTextArray(
              context: context,
              headerDecoration: const pw.BoxDecoration(color: primaryColor),
              headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
              cellAlignment: pw.Alignment.centerLeft,
              headers: ['Student ID', 'Student Name', 'Course', 'Phone', 'Outstanding'],
              data: outstandingStudents.map((s) {
                totalOutstanding += s.outstanding;
                return [
                  s.studentId,
                  s.fullName,
                  '${s.course} (${s.batch})',
                  s.phone,
                  currencyFmt.format(s.outstanding),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'GRAND TOTAL OUTSTANDING: ${currencyFmt.format(totalOutstanding)}',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.red800),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Outstanding_Report_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.pdf',
    );
  }

  static Future<void> generatePaymentReceipt(PaymentModel payment, StudentModel student) async {
    final currencyFmt = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

    // Financial Calculation for Receipt
    final double totalCourseFee = student.totalFee - student.discount;
    final double paidNow = payment.amountPaid;
    // Calculate remaining correctly regardless of what is stored in the payment object
    final double previouslyPaid = (student.totalPaid - paidNow).clamp(0.0, double.infinity);
    final double balanceAfterThis = (totalCourseFee - (previouslyPaid + paidNow)).clamp(0.0, double.infinity);

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInstituteHeader('PAYMENT RECEIPT'),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Receipt No: ${payment.receiptNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date: ${dateFmt.format(payment.paymentDate)}'),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: primaryColor),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _receiptRow('Student ID:', payment.studentUid),
                    _receiptRow('Student Name:', payment.studentName),
                    _receiptRow('Course:', '${payment.course} (${payment.batch})'),
                    _receiptRow('Fee Month:', payment.feeMonth),
                    _receiptRow('Payment Method:', payment.paymentMethod.label),
                    if (payment.notes.isNotEmpty)
                      _receiptRow('Remarks:', payment.notes),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              _receiptRow('Total Course Fee:', currencyFmt.format(totalCourseFee)),
              _receiptRow('Previously Paid:', currencyFmt.format(previouslyPaid)),
              if (payment.fine > 0) _receiptRow('Fine Applied:', currencyFmt.format(payment.fine)),
              pw.Divider(),
              _receiptRow('Amount Paid Now:', currencyFmt.format(paidNow), isBold: true, color: PdfColors.green800),
              _receiptRow('Remaining Balance:', currencyFmt.format(balanceAfterThis), isBold: true, color: balanceAfterThis > 0 ? PdfColors.red800 : PdfColors.green800),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Admin Signature\n________________', textAlign: pw.TextAlign.center),
                  pw.Text('Student Signature\n________________', textAlign: pw.TextAlign.center),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('Thank you for choosing ${AppConstants.instituteName}!', style: const pw.TextStyle(fontSize: 10, color: textLight)),
              )
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Receipt_${payment.receiptNumber}.pdf',
    );
  }

  static pw.Widget _receiptRow(String label, String value, {bool isBold = false, PdfColor color = PdfColors.black}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> generateMonthlyFeeReport(List<PaymentModel> payments, String month) async {
    final currencyFmt = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildInstituteHeader('MONTHLY COLLECTION - $month'),
        footer: _buildFooter,
        build: (context) {
          double totalCollected = 0;

          return [
            pw.TableHelper.fromTextArray(
              context: context,
              headerDecoration: const pw.BoxDecoration(color: primaryColor),
              headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
              cellAlignment: pw.Alignment.centerLeft,
              headers: ['Receipt No', 'Date', 'Student Name', 'Course', 'Method', 'Amount'],
              data: payments.map((p) {
                totalCollected += p.amountPaid;
                return [
                  p.receiptNumber,
                  DateFormat('dd MMM yyyy').format(p.paymentDate),
                  p.studentName,
                  p.course,
                  p.paymentMethod.label,
                  currencyFmt.format(p.amountPaid),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'TOTAL COLLECTION: ${currencyFmt.format(totalCollected)}',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Monthly_Collection_${month}.pdf',
    );
  }
}