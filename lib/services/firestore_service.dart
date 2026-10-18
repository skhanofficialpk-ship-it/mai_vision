import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admission_model.dart';
import '../models/certificate_model.dart';
import '../models/course_model.dart';
import '../models/faq_model.dart';
import '../models/game_project_model.dart';
import '../core/constants/app_constants.dart';

import '../models/teacher_model.dart';
import '../models/expense_model.dart';

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ───── EXPENSES ─────

  Future<String> addExpense(ExpenseModel expense) async {
    final ref = await _db.collection(AppConstants.expensesCollection).add(expense.toMap());
    return ref.id;
  }

  Stream<List<ExpenseModel>> getExpenses() {
    return _db.collection(AppConstants.expensesCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ExpenseModel.fromMap(d.data(), d.id)).toList());
  }

  // ───── TEACHERS ─────

  Future<String> addTeacher(TeacherModel teacher) async {
    final ref = await _db.collection('teachers').add(teacher.toMap());
    return ref.id;
  }

  Stream<List<TeacherModel>> getTeachers() {
    return _db.collection('teachers')
        .snapshots()
        .map((s) => s.docs.map((d) => TeacherModel.fromMap(d.data())).toList());
  }

  // ───── ADMISSIONS ─────

  Future<String> submitAdmission(AdmissionModel admission) async {
    final ref = await _db
        .collection(AppConstants.admissionsCollection)
        .add(admission.toMap());
    return ref.id;
  }

  Stream<List<AdmissionModel>> getAdmissions({String? status}) {
    Query<Map<String, dynamic>> query = _db
        .collection(AppConstants.admissionsCollection)
        .orderBy('createdAt', descending: true);
    if (status != null) query = query.where('status', isEqualTo: status);
    return query.snapshots().map((snap) =>
        snap.docs.map((d) => AdmissionModel.fromMap(d.data(), d.id)).toList());
  }

  Future<List<AdmissionModel>> getAdmissionsOnce() async {
    final snap = await _db
        .collection(AppConstants.admissionsCollection)
        .get();
    return snap.docs
        .map((d) => AdmissionModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<void> updateAdmissionStatus(String id, String status) async {
    await _db
        .collection(AppConstants.admissionsCollection)
        .doc(id)
        .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> updateAdmission(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db
        .collection(AppConstants.admissionsCollection)
        .doc(id)
        .update(data);
  }

  Future<void> deleteAdmission(String id) async {
    await _db.collection(AppConstants.admissionsCollection).doc(id).delete();
  }

  // ───── CERTIFICATES ─────

  Future<String> generateCertificateId({bool isExperience = false}) async {
    final year = DateTime.now().year;
    final prefix = isExperience ? 'MAI-EXP-$year' : 'MAI-CERT-$year';
    final snap = await _db
        .collection(AppConstants.certificatesCollection)
        .where('certificateId', isGreaterThanOrEqualTo: prefix)
        .orderBy('certificateId', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return '$prefix-0001';
    final last = snap.docs.first.data()['certificateId'] as String? ?? '';
    final parts = last.split('-');
    final lastNum = parts.length == 4 ? int.tryParse(parts[3]) ?? 0 : 0;
    return '$prefix-${(lastNum + 1).toString().padLeft(4, '0')}';
  }

  Stream<List<CertificateModel>> getCertificates() {
    return _db
        .collection(AppConstants.certificatesCollection)
        .orderBy('issuedDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CertificateModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<CertificateModel?> verifyCertificate(String certId) async {
    final snap = await _db
        .collection(AppConstants.certificatesCollection)
        .where('certificateId', isEqualTo: certId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return CertificateModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  Future<String> issueCertificate(CertificateModel cert) async {
    final ref = await _db
        .collection(AppConstants.certificatesCollection)
        .add(cert.toMap());
    return ref.id;
  }

  Future<void> deleteCertificate(String id) async {
    await _db.collection(AppConstants.certificatesCollection).doc(id).delete();
  }

  // ───── GAME PROJECTS ─────

  Future<String> addGameProject(GameProjectModel project) async {
    final ref = await _db
        .collection(AppConstants.gameProjectsCollection)
        .add(project.toMap());
    return ref.id;
  }

  Future<void> updateGameProject(String id, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.gameProjectsCollection)
        .doc(id)
        .update(data);
  }

  Future<void> deleteGameProject(String id) async {
    await _db
        .collection(AppConstants.gameProjectsCollection)
        .doc(id)
        .delete();
  }

  Stream<List<GameProjectModel>> getGameProjects({bool? onlyPublished}) {
    Query<Map<String, dynamic>> query = _db
        .collection(AppConstants.gameProjectsCollection)
        .orderBy('createdAt', descending: true);
    if (onlyPublished == true) {
      query = query.where('isPublished', isEqualTo: true);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((d) => GameProjectModel.fromMap(d.data(), d.id))
        .toList());
  }

  Stream<List<GameProjectModel>> getStudentGameProjects(String studentId) {
    return _db
        .collection(AppConstants.gameProjectsCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => GameProjectModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ───── COURSES ─────

  Stream<List<CourseModel>> getCourses() {
    return _db
        .collection(AppConstants.coursesCollection)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CourseModel.fromMap(d.data(), d.id)).toList());
  }

  Future<CourseModel?> getCourseById(String id) async {
    final doc =
        await _db.collection(AppConstants.coursesCollection).doc(id).get();
    if (!doc.exists) return null;
    return CourseModel.fromMap(doc.data()!, doc.id);
  }

  /// Full upsert — creates or completely replaces the document so nested
  /// maps like `teacher` are always written correctly. Used by admin
  /// Add Course and Edit Course actions so changes persist across sessions.
  Future<String> saveCourse(CourseModel course) async {
    if (course.id != null) {
      await _db
          .collection(AppConstants.coursesCollection)
          .doc(course.id)
          .set(course.toMap());
      return course.id!;
    } else {
      final ref = await _db
          .collection(AppConstants.coursesCollection)
          .add(course.toMap());
      return ref.id;
    }
  }

  /// Deletes a course document from Firestore permanently.
  Future<void> deleteCourse(String id) async {
    await _db.collection(AppConstants.coursesCollection).doc(id).delete();
  }

  Future<void> updateCourse(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.coursesCollection).doc(id).update(data);
  }

  Future<String> addCourse(CourseModel course) async {
    final ref = await _db
        .collection(AppConstants.coursesCollection)
        .add(course.toMap());
    return ref.id;
  }

  // Seed initial courses
  Future<void> seedCourses({bool force = false}) async {
    final snap = await _db.collection(AppConstants.coursesCollection).get();
    
    if (force || snap.docs.isEmpty) {
      // 1. Delete all existing courses from Firestore if forcing
      if (force) {
        for (final doc in snap.docs) {
          await doc.reference.delete();
        }
      }

      // 2. Add current defaultCourses
      for (final course in defaultCourses) {
        await _db
            .collection(AppConstants.coursesCollection)
            .doc(course.id)
            .set(course.toMap());
      }
    }
  }

  // ───── FAQ ─────

  Stream<List<FaqModel>> getFaqs() {
    return _db
        .collection(AppConstants.faqCollection)
        .orderBy('order')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => FaqModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addFaq(FaqModel faq) async {
    await _db.collection(AppConstants.faqCollection).add(faq.toMap());
  }

  Future<void> updateFaq(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.faqCollection).doc(id).update(data);
  }

  Future<void> deleteFaq(String id) async {
    await _db.collection(AppConstants.faqCollection).doc(id).delete();
  }

  Future<void> seedFaqs() async {
    final snap = await _db.collection(AppConstants.faqCollection).get();
    if (snap.docs.isEmpty) {
      for (int i = 0; i < defaultFaqs.length; i++) {
        await _db.collection(AppConstants.faqCollection).add(
              defaultFaqs[i].toMap(),
            );
      }
    }
  }

  // ───── STATS ─────

  Future<Map<String, int>> getDashboardStats({String? branchId}) async {
    Query<Map<String, dynamic>> admQuery = _db.collection(AppConstants.admissionsCollection);
    Query<Map<String, dynamic>> certQuery = _db.collection(AppConstants.certificatesCollection);
    Query<Map<String, dynamic>> approvedQuery = _db.collection(AppConstants.admissionsCollection).where('status', isEqualTo: 'approved');
    Query<Map<String, dynamic>> pendingQuery = _db.collection(AppConstants.admissionsCollection).where('status', isEqualTo: 'pending');

    if (branchId != null && branchId != 'all') {
      admQuery = admQuery.where('branchId', isEqualTo: branchId);
      certQuery = certQuery.where('branchId', isEqualTo: branchId);
      approvedQuery = approvedQuery.where('branchId', isEqualTo: branchId);
      pendingQuery = pendingQuery.where('branchId', isEqualTo: branchId);
    }

    // Optimization: Run all count queries in parallel using .count().get()
    // which is faster and costs significantly less (1/1000th of a read per 1000 docs).
    final results = await Future.wait([
      admQuery.count().get(),
      certQuery.count().get(),
      approvedQuery.count().get(),
      pendingQuery.count().get(),
    ]);

    return {
      'total_admissions': results[0].count ?? 0,
      'total_certificates': results[1].count ?? 0,
      'approved': results[2].count ?? 0,
      'pending': results[3].count ?? 0,
    };
  }
}
