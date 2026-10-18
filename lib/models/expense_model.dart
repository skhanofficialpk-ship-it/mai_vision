import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String? id;
  final String reference;
  final String particulars;
  final String category; // Rent, Utility, Salary, Marketing, etc.
  final double amount;
  final DateTime date;
  final String branchId;
  final String adminName;

  const ExpenseModel({
    this.id,
    required this.reference,
    required this.particulars,
    required this.category,
    required this.amount,
    required this.date,
    required this.branchId,
    required this.adminName,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String docId) {
    return ExpenseModel(
      id: docId,
      reference: map['reference'] ?? '',
      particulars: map['particulars'] ?? '',
      category: map['category'] ?? 'General',
      amount: (map['amount'] ?? 0).toDouble(),
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      branchId: map['branchId'] ?? 'all',
      adminName: map['adminName'] ?? 'Admin',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reference': reference,
      'particulars': particulars,
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'branchId': branchId,
      'adminName': adminName,
    };
  }
}
