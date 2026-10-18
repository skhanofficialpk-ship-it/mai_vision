import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import '../../models/payment_model.dart';
import '../../models/student_model.dart';

class ExcelExportHelper {
  static Future<void> exportStudentFeeList(List<StudentModel> students) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Student List'];
    excel.setDefaultSheet('Student List');

    // Headers
    List<String> headers = [
      'Student ID',
      'Student Name',
      'Father Name',
      'Course',
      'Batch',
      'Total Course Fee',
      'Discount',
      'Effective Fee',
      'Total Paid',
      'Outstanding',
      'Status'
    ];

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Data
    for (var s in students) {
      sheet.appendRow([
        TextCellValue(s.studentId),
        TextCellValue(s.fullName),
        TextCellValue(s.fatherName),
        TextCellValue(s.course),
        TextCellValue(s.batch),
        DoubleCellValue(s.totalFee),
        DoubleCellValue(s.discount),
        DoubleCellValue(s.effectiveFee),
        DoubleCellValue(s.totalPaid),
        DoubleCellValue(s.outstanding),
        TextCellValue(s.status.value.toUpperCase()),
      ]);
    }

    final dateStr = DateFormat('yyyy_MM_dd').format(DateTime.now());
    final fileName = 'student_fee_list_$dateStr.xlsx';

    final bytes = excel.save();
    if (bytes != null) {
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: Uint8List.fromList(bytes),
        mimeType: MimeType.microsoftExcel,
      );
    }
  }

  static Future<void> exportPaymentHistory(List<PaymentModel> payments, String contextName) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Payment History'];
    excel.setDefaultSheet('Payment History');

    List<String> headers = [
      'Receipt No',
      'Student ID',
      'Student Name',
      'Course',
      'Batch',
      'Fee Month',
      'Payment Date',
      'Amount Paid',
      'Discount',
      'Fine',
      'Total Due',
      'Remaining Balance',
      'Payment Method',
      'Status',
      'Admin'
    ];

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');

    for (var p in payments) {
      sheet.appendRow([
        TextCellValue(p.receiptNumber),
        TextCellValue(p.studentUid),
        TextCellValue(p.studentName),
        TextCellValue(p.course),
        TextCellValue(p.batch),
        TextCellValue(p.feeMonth),
        TextCellValue(dateFmt.format(p.paymentDate)),
        DoubleCellValue(p.amountPaid),
        DoubleCellValue(p.discount),
        DoubleCellValue(p.fine),
        DoubleCellValue(p.totalDue),
        DoubleCellValue(p.remainingBalance),
        TextCellValue(p.paymentMethod.label),
        TextCellValue(p.status.label),
        TextCellValue(p.adminName),
      ]);
    }

    final dateStr = DateFormat('yyyy_MM_dd').format(DateTime.now());
    final safeContext = contextName.replaceAll(' ', '_').toLowerCase();
    final fileName = 'payment_history_${safeContext}_$dateStr.xlsx';

    final bytes = excel.save();
    if (bytes != null) {
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: Uint8List.fromList(bytes), // <-- Wrap 'bytes' right here        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
    }
  }

  static Future<void> exportMonthlyCollection(List<PaymentModel> payments, String month) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Monthly Collection'];
    excel.setDefaultSheet('Monthly Collection');

    List<String> headers = [
      'Receipt No',
      'Date',
      'Student Name',
      'Course',
      'Method',
      'Amount Collected'
    ];

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    double total = 0;
    final dateFmt = DateFormat('yyyy-MM-dd');

    for (var p in payments) {
      total += p.amountPaid;
      sheet.appendRow([
        TextCellValue(p.receiptNumber),
        TextCellValue(dateFmt.format(p.paymentDate)),
        TextCellValue(p.studentName),
        TextCellValue(p.course),
        TextCellValue(p.paymentMethod.label),
        DoubleCellValue(p.amountPaid),
      ]);
    }

    sheet.appendRow([
      TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue(''),
      TextCellValue('GRAND TOTAL'),
      DoubleCellValue(total),
    ]);

    final fileName = 'monthly_collection_${month}.xlsx';
    final bytes = excel.save();
    if (bytes != null) {
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: Uint8List.fromList(bytes), // <-- Wrap 'bytes' right here        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
    }
  }
}