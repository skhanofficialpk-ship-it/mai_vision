import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../models/student_model.dart';
import '../models/payment_model.dart';
import '../models/course_model.dart';

final feeServiceProvider = Provider<FeeService>((ref) => FeeService());

class FeeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _students =>
      _db.collection(AppConstants.studentsCollection);

  CollectionReference<Map<String, dynamic>> _payments(String studentId) =>
      _students.doc(studentId).collection(AppConstants.paymentsSubcollection);

  // ─────────────── Student ID Generator ───────────────
  Future<String> generateStudentId() async {
    final year = DateTime.now().year;
    final snap = await _students
        .orderBy('studentId', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return 'MAI-$year-0001';
    final last = snap.docs.first.data()['studentId'] as String? ?? '';
    final parts = last.split('-');
    final lastNum = parts.length == 3 ? int.tryParse(parts[2]) ?? 0 : 0;
    return 'MAI-$year-${(lastNum + 1).toString().padLeft(4, '0')}';
  }

  // ─────────────── Receipt Number ───────────────
  Future<String> generateReceiptNumber() async {
    final now = DateTime.now();
    final prefix = 'RCP-${now.year}${now.month.toString().padLeft(2, '0')}';
    try {
      final snap = await _db
          .collectionGroup(AppConstants.paymentsSubcollection)
          .where('receiptNumber', isGreaterThanOrEqualTo: prefix)
          .orderBy('receiptNumber', descending: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return '${prefix}-0001';
      final last = snap.docs.first.data()['receiptNumber'] as String? ?? '';
      final parts = last.split('-');
      final seq = parts.isNotEmpty ? int.tryParse(parts.last) ?? 0 : 0;
      return '$prefix-${(seq + 1).toString().padLeft(4, '0')}';
    } catch (e) {
      // Fallback: If index is missing or query fails, generate a random-ish suffix
      // so the transaction doesn't fail.
      return '$prefix-AUTO-${DateTime.now().millisecond}';
    }
  }

  // ─────────────── Students CRUD ───────────────
  Stream<List<StudentModel>> getStudents({String? status, String? courseId}) {
    Query<Map<String, dynamic>> q = _students.orderBy('fullName');
    if (status != null) q = q.where('status', isEqualTo: status);
    if (courseId != null && courseId.isNotEmpty) {
      q = q.where('courseId', isEqualTo: courseId);
    }
    return q.snapshots().map((s) =>
        s.docs.map((d) => StudentModel.fromMap(d.data(), d.id)).toList());
  }

  Future<List<StudentModel>> getStudentsOnce() async {
    final snap = await _students.get();
    return snap.docs
        .map((d) => StudentModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<StudentModel?> getStudentById(String id) async {
    final doc = await _students.doc(id).get();
    if (!doc.exists) return null;
    return StudentModel.fromMap(doc.data()!, doc.id);
  }

  Future<String> addStudent(StudentModel student) async {
    final ref = await _students.add(student.toMap());
    return ref.id;
  }

  Future<void> updateStudent(String id, Map<String, dynamic> data) async {
    await _students.doc(id).update(data);
  }

  /// Deletes the student document AND all subcollection payments atomically
  /// via batched writes (Firestore doesn't auto-delete subcollections).
  Future<void> deleteStudent(String studentId) async {
    final payments = await _payments(studentId).get();
    final batch = _db.batch();
    for (final doc in payments.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_students.doc(studentId));
    await batch.commit();
  }

  // ─────────────── Payments ───────────────
  Stream<List<PaymentModel>> getPayments(String studentId) {
    return _payments(studentId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => PaymentModel.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<PaymentModel>> getAllPayments({String? month}) {
    Query<Map<String, dynamic>> q = _db
        .collectionGroup(AppConstants.paymentsSubcollection)
        .orderBy('paymentDate', descending: true);
    if (month != null && month.isNotEmpty) {
      q = q.where('feeMonth', isEqualTo: month);
    }
    return q.snapshots().map((s) =>
        s.docs.map((d) => PaymentModel.fromMap(d.data(), d.id)).toList());
  }

  /// Records a payment and updates the student's running balance atomically.
  Future<String> recordPayment(PaymentModel payment) async {
    return _db.runTransaction((tx) async {
      final studentRef = _students.doc(payment.studentId);
      final studentSnap = await tx.get(studentRef);
      if (!studentSnap.exists) throw Exception('Student not found');

      final current = StudentModel.fromMap(studentSnap.data()!, studentSnap.id);
      
      final double actualBalanceBefore = (current.effectiveFee - current.totalPaid).clamp(0.0, double.infinity);
      final newTotalPaid = current.totalPaid + payment.amountPaid;
      final newOutstanding = (actualBalanceBefore + payment.fine - payment.discount - payment.amountPaid).clamp(0.0, double.infinity);

      final payRef = _payments(payment.studentId).doc();
      
      final finalPayment = PaymentModel(
        receiptNumber: payment.receiptNumber,
        studentId: payment.studentId,
        studentUid: payment.studentUid,
        studentName: payment.studentName,
        branchId: current.branchId, // Pass branchId from student
        course: payment.course,
        batch: payment.batch,
        feeMonth: payment.feeMonth,
        paymentDate: payment.paymentDate,
        amountPaid: payment.amountPaid,
        discount: payment.discount,
        fine: payment.fine,
        previousDue: actualBalanceBefore,
        totalDue: actualBalanceBefore + payment.fine - payment.discount,
        remainingBalance: newOutstanding,
        paymentType: payment.paymentType,
        paymentMethod: payment.paymentMethod,
        transactionId: payment.transactionId,
        notes: payment.notes,
        adminName: payment.adminName,
        status: payment.status,
      );

      tx.set(payRef, finalPayment.toMap());
      tx.update(studentRef, {
        'totalPaid': newTotalPaid,
        'outstanding': newOutstanding,
        'lastPaymentDate': Timestamp.fromDate(payment.paymentDate),
        'status': newOutstanding <= 0 ? StudentStatus.graduated.value : current.status.value,
      });
      return payRef.id;
    });
  }

  Future<void> deletePayment(String studentId, String paymentId) async {
    final paySnap = await _payments(studentId).doc(paymentId).get();
    if (!paySnap.exists) return;
    final pay = PaymentModel.fromMap(paySnap.data()!, paySnap.id);

    await _db.runTransaction((tx) async {
      final studentRef = _students.doc(studentId);
      final studentSnap = await tx.get(studentRef);
      if (!studentSnap.exists) return;
      final current = StudentModel.fromMap(studentSnap.data()!, studentSnap.id);
      final restoredOutstanding = current.outstanding + pay.amountPaid;
      final restoredTotalPaid = (current.totalPaid - pay.amountPaid).clamp(0.0, double.infinity);
      tx.delete(_payments(studentId).doc(paymentId));
      tx.update(studentRef, {
        'totalPaid': restoredTotalPaid,
        'outstanding': restoredOutstanding,
        'status': restoredOutstanding > 0 ? StudentStatus.active.value : StudentStatus.graduated.value,
      });
    });
  }

  // ─────────────── Dashboard Stats ───────────────
  Future<Map<String, dynamic>> getDashboardStats({String? branchId}) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    Query<Map<String, dynamic>> q = _students;
    if (branchId != null && branchId != 'all') {
      q = q.where('branchId', isEqualTo: branchId);
    }

    int totalStudents = 0;
    int activeStudents = 0;
    double totalOutstanding = 0.0;

    try {
      final studentAggr = await q.aggregate(
        count(),
        sum('outstanding'),
      ).get();
      totalStudents = studentAggr.count ?? 0;
      totalOutstanding = (studentAggr.getSum('outstanding') ?? 0).toDouble();

      final activeAggr = await q.where('status', isEqualTo: 'active').aggregate(count()).get();
      activeStudents = activeAggr.count ?? 0;
    } catch (e) {
      debugPrint('Student aggr error in fee service: $e');
      try {
        final snap = await q.get();
        totalStudents = snap.docs.length;
        for (final doc in snap.docs) {
          final data = doc.data();
          if (data['status'] == 'active') activeStudents++;
          totalOutstanding += (data['outstanding'] ?? 0).toDouble();
        }
      } catch (_) {}
    }

    // Monthly & Annual Collections
    int paidThisMonth = 0;
    double monthlyCollection = 0.0;
    double annualCollection = 0.0;

    try {
      Query<Map<String, dynamic>> payQ = _db
          .collectionGroup(AppConstants.paymentsSubcollection)
          .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
          .where('paymentDate', isLessThanOrEqualTo: Timestamp.fromDate(monthEnd));

      if (branchId != null && branchId != 'all') {
        payQ = payQ.where('branchId', isEqualTo: branchId);
      }

      final monthAggr = await payQ.aggregate(
        count(),
        sum('amountPaid'),
      ).get();
      paidThisMonth = monthAggr.count ?? 0;
      monthlyCollection = (monthAggr.getSum('amountPaid') ?? 0).toDouble();

      final yearStart = DateTime(now.year, 1, 1);
      final yearAggr = await _db
          .collectionGroup(AppConstants.paymentsSubcollection)
          .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(yearStart))
          .aggregate(sum('amountPaid'))
          .get();
      annualCollection = (yearAggr.getSum('amountPaid') ?? 0).toDouble();
    } catch (e) {
      debugPrint('Payment aggr query failed in fee service: $e');
    }

    return {
      'totalStudents': totalStudents,
      'activeStudents': activeStudents,
      'inactiveStudents': totalStudents - activeStudents,
      'pendingFees': totalOutstanding > 0 ? activeStudents : 0,
      'paidThisMonth': paidThisMonth,
      'monthlyCollection': monthlyCollection,
      'totalOutstanding': totalOutstanding,
      'annualCollection': annualCollection,
    };
  }

  // ─────────────── Sync Admissions ───────────────
  Future<int> syncAdmissionsToStudents(List<CourseModel> allCourses) async {
    final approvedSnap = await _db
        .collection(AppConstants.admissionsCollection)
        .where('status', isEqualTo: 'approved')
        .get();

    final studentsSnap = await _students.get();
    
    // Part 1: Fix existing students with 0 outstanding balance bug
    final batch = _db.batch();
    int fixed = 0;
    for (final doc in studentsSnap.docs) {
      final data = doc.data();
      final totalFee = (data['totalFee'] ?? data['monthlyFee'] ?? 0).toDouble();
      final totalPaid = (data['totalPaid'] ?? 0).toDouble();
      final discount = (data['discount'] ?? 0).toDouble();
      
      final effectiveFee = totalFee - discount;
      final actualOutstanding = (effectiveFee - totalPaid).clamp(0.0, double.infinity);
      
      // Force update all critical financial fields for consistency
      batch.update(doc.reference, {
        'totalFee': totalFee,
        'effectiveFee': effectiveFee,
        'outstanding': actualOutstanding,
        'totalPaid': totalPaid,
      });
      fixed++;
    }
    if (fixed > 0) await batch.commit();

    // Part 2: Add new students
    final existingPhones =
        studentsSnap.docs.map((d) => d.data()['phone']?.toString() ?? '').toSet();

    int count = 0;
    for (final doc in approvedSnap.docs) {
      final data = doc.data();
      final phone = data['phone']?.toString() ?? '';

      if (phone.isNotEmpty && !existingPhones.contains(phone)) {
        final courseId = data['selectedCourse'] as String? ?? '';
        final course = allCourses.firstWhere(
          (c) => c.id == courseId,
          orElse: () => allCourses.isNotEmpty ? allCourses.first : defaultCourses[0],
        );

        final studentId = await generateStudentId();
        final student = StudentModel(
          studentId: studentId,
          fullName: data['fullName'] ?? 'Unknown',
          fatherName: data['fatherName'] ?? 'Unknown',
          phone: phone,
          address: data['address'] ?? 'N/A',
          course: course.name,
          courseId: course.id ?? '',
          batch: 'Batch ${DateTime.now().month}_${DateTime.now().year}',
          totalFee: course.totalFee,
          effectiveFee: course.totalFee,
          admissionDate: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: StudentStatus.active,
          outstanding: course.totalFee, // Initial outstanding is total fee
        );

        await _students.add(student.toMap());
        count++;
        // Refresh local set to avoid duplicates if multiple admissions have same phone
        existingPhones.add(phone);
      }
    }
    return count + fixed;
  }

  // ─────────────── Notifications ───────────────
  Future<List<StudentModel>> getOverdueStudents() async {
    final now = DateTime.now();
    final snap = await _students
        .where('status', isEqualTo: 'active')
        .where('outstanding', isGreaterThan: 0)
        .get();
    final students =
        snap.docs.map((d) => StudentModel.fromMap(d.data(), d.id)).toList();
    // overdue = due day has passed this month and still outstanding
    return students.where((s) {
      final dueThisMonth = DateTime(now.year, now.month, s.feeDueDay);
      return now.isAfter(dueThisMonth);
    }).toList();
  }
}
