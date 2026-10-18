import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentType { monthly, partial, full, advance, previousDue }
enum PaymentMethod { cash, bankTransfer, easypaisa, jazzcash, other }
enum PaymentStatus { paid, partiallyPaid, pending, overdue }

extension PaymentTypeX on PaymentType {
  String get label {
    switch (this) {
      case PaymentType.monthly: return 'Course Fee';
      case PaymentType.partial: return 'Partial Payment';
      case PaymentType.full: return 'Full Payment';
      case PaymentType.advance: return 'Advance Payment';
      case PaymentType.previousDue: return 'Previous Due';
    }
  }
  String get value => name;
}

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash: return 'Cash';
      case PaymentMethod.bankTransfer: return 'Bank Transfer';
      case PaymentMethod.easypaisa: return 'Easypaisa';
      case PaymentMethod.jazzcash: return 'JazzCash';
      case PaymentMethod.other: return 'Other';
    }
  }
  String get value => name;
}

extension PaymentStatusX on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.paid: return 'Paid';
      case PaymentStatus.partiallyPaid: return 'Partially Paid';
      case PaymentStatus.pending: return 'Pending';
      case PaymentStatus.overdue: return 'Overdue';
    }
  }
  String get value => name;
}

class PaymentModel {
  final String? id;
  final String receiptNumber;
  final String studentId;
  final String studentUid;
  final String studentName;
  final String branchId; // New
  final String course;
  final String batch;
  final String feeMonth;
  final DateTime paymentDate;
  final double amountPaid;
  final double discount;
  final double fine;
  final double previousDue;
  final double totalDue;
  final double remainingBalance;
  final PaymentType paymentType;
  final PaymentMethod paymentMethod;
  final String? transactionId;
  final String notes;
  final String adminName;
  final PaymentStatus status;

  const PaymentModel({
    this.id,
    required this.receiptNumber,
    required this.studentId,
    required this.studentUid,
    required this.studentName,
    this.branchId = 'manglor', // Default for legacy data
    required this.course,
    required this.batch,
    required this.feeMonth,
    required this.paymentDate,
    required this.amountPaid,
    this.discount = 0,
    this.fine = 0,
    this.previousDue = 0,
    required this.totalDue,
    required this.remainingBalance,
    required this.paymentType,
    required this.paymentMethod,
    this.transactionId,
    this.notes = '',
    required this.adminName,
    required this.status,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map, String docId) {
    PaymentType type = PaymentType.monthly;
    try { type = PaymentType.values.firstWhere((e) => e.value == map['paymentType']); } catch (_) {}
    PaymentMethod method = PaymentMethod.cash;
    try { method = PaymentMethod.values.firstWhere((e) => e.value == map['paymentMethod']); } catch (_) {}
    PaymentStatus status = PaymentStatus.paid;
    try { status = PaymentStatus.values.firstWhere((e) => e.value == map['status']); } catch (_) {}

    return PaymentModel(
      id: docId,
      receiptNumber: map['receiptNumber'] ?? '',
      studentId: map['studentId'] ?? '',
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? '',
      branchId: map['branchId'] ?? 'manglor',
      course: map['course'] ?? '',
      batch: map['batch'] ?? '',
      feeMonth: map['feeMonth'] ?? '',
      paymentDate: map['paymentDate'] is Timestamp
          ? (map['paymentDate'] as Timestamp).toDate()
          : DateTime.now(),
      amountPaid: (map['amountPaid'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      fine: (map['fine'] ?? 0).toDouble(),
      previousDue: (map['previousDue'] ?? 0).toDouble(),
      totalDue: (map['totalDue'] ?? 0).toDouble(),
      remainingBalance: (map['remainingBalance'] ?? 0).toDouble(),
      paymentType: type,
      paymentMethod: method,
      transactionId: map['transactionId'],
      notes: map['notes'] ?? '',
      adminName: map['adminName'] ?? '',
      status: status,
    );
  }

  Map<String, dynamic> toMap() => {
    'receiptNumber': receiptNumber,
    'studentId': studentId,
    'studentUid': studentUid,
    'studentName': studentName,
    'branchId': branchId,
    'course': course,
    'batch': batch,
    'feeMonth': feeMonth,
    'paymentDate': Timestamp.fromDate(paymentDate),
    'amountPaid': amountPaid,
    'discount': discount,
    'fine': fine,
    'previousDue': previousDue,
    'totalDue': totalDue,
    'remainingBalance': remainingBalance,
    'paymentType': paymentType.value,
    'paymentMethod': paymentMethod.value,
    'transactionId': transactionId,
    'notes': notes,
    'adminName': adminName,
    'status': status.value,
  };
}
