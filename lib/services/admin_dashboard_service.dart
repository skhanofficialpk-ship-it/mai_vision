import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../models/student_model.dart';

final adminDashboardServiceProvider = Provider<AdminDashboardService>((ref) => AdminDashboardService());

class AdminDashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getCommandCenterStats({String branchId = 'all'}) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);

    // 1. Student Aggregates (Direct Model parsing for exact match with Fee Management)
    int totalActiveStudents = 0;
    int courseStudentsCount = 0;
    int tuitionStudentsCount = 0;
    double totalReceivables = 0.0;

    try {
      final studentSnap = await _db.collection(AppConstants.studentsCollection).get();
      final allStudents = studentSnap.docs
          .map((d) => StudentModel.fromMap(d.data(), d.id))
          .toList();

      final filteredStudents = branchId == 'all'
          ? allStudents
          : allStudents.where((s) => s.branchId == branchId).toList();

      for (final s in filteredStudents) {
        if (s.status == StudentStatus.active) {
          totalActiveStudents++;
          if (s.studentType == StudentType.course) {
            courseStudentsCount++;
          } else if (s.studentType == StudentType.tuition) {
            tuitionStudentsCount++;
          }
          totalReceivables += s.outstanding;
        }
      }
    } catch (e) {
      debugPrint('Student query error in dashboard service: $e');
    }

    // 2. Collections (Today and Month)
    double todayCollection = 0.0;
    double monthlyCollection = 0.0;

    try {
      final paymentSnap = await _db
          .collectionGroup(AppConstants.paymentsSubcollection)
          .get();

      for (final doc in paymentSnap.docs) {
        final data = doc.data();
        final amt = (data['amountPaid'] ?? 0).toDouble();
        final dt = (data['paymentDate'] as Timestamp?)?.toDate();
        final docBranch = data['branchId'] ?? 'all';

        if (branchId == 'all' || docBranch == branchId) {
          if (dt != null) {
            if (dt.isAfter(startOfDay) || dt.isAtSameMomentAs(startOfDay)) {
              todayCollection += amt;
            }
            if (dt.isAfter(startOfMonth) || dt.isAtSameMomentAs(startOfMonth)) {
              monthlyCollection += amt;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Payment query error in dashboard service: $e');
    }

    // 3. Expenses (Month)
    double monthlyExpenses = 0.0;
    try {
      final expSnap = await _db.collection(AppConstants.expensesCollection).get();
      for (final doc in expSnap.docs) {
        final data = doc.data();
        final dt = (data['date'] as Timestamp?)?.toDate();
        final amt = (data['amount'] ?? 0).toDouble();
        final docBranch = data['branchId'] ?? 'all';

        if (branchId == 'all' || docBranch == branchId) {
          if (dt != null && (dt.isAfter(startOfMonth) || dt.isAtSameMomentAs(startOfMonth))) {
            monthlyExpenses += amt;
          }
        }
      }
    } catch (e) {
      debugPrint('Expense query error in dashboard service: $e');
    }

    // 4. Teachers Count
    int teachersCount = 0;
    try {
      final teachersSnap = await _db.collection('teachers').get();
      teachersCount = teachersSnap.docs.length;
    } catch (_) {}

    // 5. Total Admissions Count
    int totalAdmissions = 0;
    try {
      final admSnap = await _db.collection(AppConstants.admissionsCollection).get();
      totalAdmissions = admSnap.docs.length;
    } catch (_) {}

    return {
      'activeStudents': totalActiveStudents,
      'courseStudents': courseStudentsCount,
      'tuitionStudents': tuitionStudentsCount,
      'todayCollection': todayCollection,
      'pendingDues': totalReceivables,
      'teachersCount': teachersCount,
      'monthlyCollection': monthlyCollection,
      'monthlyExpenses': monthlyExpenses,
      'netCash': monthlyCollection - monthlyExpenses,
      'totalAdmissions': totalAdmissions,
    };
  }

  Stream<List<Map<String, dynamic>>> getPaymentsStream({String branchId = 'all', int limit = 10}) {
    Query<Map<String, dynamic>> q = _db.collectionGroup(AppConstants.paymentsSubcollection)
        .orderBy('paymentDate', descending: true)
        .limit(limit);
    if (branchId != 'all') q = q.where('branchId', isEqualTo: branchId);
    return q.snapshots().map((snap) => snap.docs.map((d) {
      final data = d.data();
      return {
        'reference': data['receiptNumber'] ?? 'FEE-REC',
        'particulars': '${data['studentName']} - ${data['feeMonth']}',
        'type': 'Income',
        'method': (data['paymentMethod'] as String?)?.toUpperCase() ?? 'CASH',
        'date': (data['paymentDate'] as Timestamp).toDate(),
        'amount': (data['amountPaid'] ?? 0).toDouble(),
        'isPositive': true,
      };
    }).toList());
  }

  Stream<List<Map<String, dynamic>>> getExpensesStream({String branchId = 'all', int limit = 10}) {
    Query<Map<String, dynamic>> q = _db.collection(AppConstants.expensesCollection)
        .orderBy('date', descending: true)
        .limit(limit);
    if (branchId != 'all') q = q.where('branchId', isEqualTo: branchId);
    return q.snapshots().map((snap) => snap.docs.map((d) {
      final data = d.data();
      return {
        'reference': data['reference'] ?? 'EXP',
        'particulars': data['particulars'] ?? 'General Expense',
        'type': 'Expense',
        'method': data['category']?.toUpperCase() ?? 'GENERAL',
        'date': (data['date'] as Timestamp).toDate(),
        'amount': (data['amount'] ?? 0).toDouble(),
        'isPositive': false,
      };
    }).toList());
  }
}
