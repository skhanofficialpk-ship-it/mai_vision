class ReceiptModel {
  final String? id; // Firestore document ID
  final String receiptNo; // e.g. RAI-REC-YYYYMMDD-XXXX
  final String paymentId;
  final String studentId; // Student Firestore doc ID
  final String studentCode; // Student ID e.g. RAI-STU-0001
  final String studentName;
  final String courseName;
  final String month; // YYYY-MM
  final double amountPaid;
  final double amountDue;
  final double remainingBalance;
  final DateTime paymentDate;
  final String paymentMethod;
  final String issuedBy;

  ReceiptModel({
    this.id,
    required this.receiptNo,
    required this.paymentId,
    required this.studentId,
    required this.studentCode,
    required this.studentName,
    required this.courseName,
    required this.month,
    required this.amountPaid,
    required this.amountDue,
    required this.remainingBalance,
    required this.paymentDate,
    required this.paymentMethod,
    required this.issuedBy,
  });

  factory ReceiptModel.fromMap(Map<String, dynamic> map, String id) {
    return ReceiptModel(
      id: id,
      receiptNo: map['receiptNo'] ?? '',
      paymentId: map['paymentId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentCode: map['studentCode'] ?? '',
      studentName: map['studentName'] ?? '',
      courseName: map['courseName'] ?? '',
      month: map['month'] ?? '',
      amountPaid: (map['amountPaid'] ?? 0.0).toDouble(),
      amountDue: (map['amountDue'] ?? 0.0).toDouble(),
      remainingBalance: (map['remainingBalance'] ?? 0.0).toDouble(),
      paymentDate: map['paymentDate'] != null
          ? (map['paymentDate'] as dynamic).toDate()
          : DateTime.now(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      issuedBy: map['issuedBy'] ?? 'MAI Coaching Academy',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receiptNo': receiptNo,
      'paymentId': paymentId,
      'studentId': studentId,
      'studentCode': studentCode,
      'studentName': studentName,
      'courseName': courseName,
      'month': month,
      'amountPaid': amountPaid,
      'amountDue': amountDue,
      'remainingBalance': remainingBalance,
      'paymentDate': paymentDate,
      'paymentMethod': paymentMethod,
      'issuedBy': issuedBy,
    };
  }
}
