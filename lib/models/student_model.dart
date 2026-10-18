import 'package:cloud_firestore/cloud_firestore.dart';

enum StudentStatus { active, inactive, graduated, archived }
enum StudentType { course, tuition }

extension StudentTypeX on StudentType {
  String get label => name == 'course' ? 'Course' : 'Tuition';
  String get value => name;
}

extension StudentStatusX on StudentStatus {
  String get label {
    switch (this) {
      case StudentStatus.active: return 'Active';
      case StudentStatus.inactive: return 'Inactive';
      case StudentStatus.graduated: return 'Graduated';
      case StudentStatus.archived: return 'Archived';
    }
  }
  String get value => name; // 'active' | 'inactive' | 'graduated' | 'archived'
}

class StudentModel {
  final String? id;
  final String studentId; // auto-generated e.g. RAI-2024-0001
  final String fullName;
  final String fatherName;
  final String phone;
  final String? parentPhone; // New
  final String address;
  final String course;
  final String courseId;
  final StudentType studentType; // New
  final List<String> selectedSubjects; // New
  final String branchId; // New
  final String branchName; // New
  final String batch; // e.g. "Batch 1", "Jan 2025"
  final double totalFee;
  final double discount; // amount, not percentage
  final double effectiveFee; // totalFee - discount
  final DateTime admissionDate;
  final int feeDueDay; // day of month (1-28)
  final StudentStatus status;

  // Running balances — updated on every payment write
  final double totalPaid;
  final double outstanding;
  final DateTime? lastPaymentDate;

  const StudentModel({
    this.id,
    required this.studentId,
    required this.fullName,
    required this.fatherName,
    required this.phone,
    this.parentPhone,
    required this.address,
    required this.course,
    required this.courseId,
    this.studentType = StudentType.course, // New
    this.selectedSubjects = const [],
    this.branchId = 'charbagh',
    this.branchName = 'Charbagh',
    required this.batch,
    required this.totalFee,
    this.discount = 0,
    required this.effectiveFee,
    required this.admissionDate,
    this.feeDueDay = 10,
    this.status = StudentStatus.active,
    this.totalPaid = 0,
    this.outstanding = 0,
    this.lastPaymentDate,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map, String docId) {
    final tFee = (map['totalFee'] ?? map['monthlyFee'] ?? 0).toDouble();
    final disc = (map['discount'] ?? 0).toDouble();
    // Use stored effectiveFee, or compute if missing/zero
    final eFee = map['effectiveFee'] != null && map['effectiveFee'] != 0 
        ? (map['effectiveFee'] as num).toDouble() 
        : (tFee - disc);

    return StudentModel(
      id: docId,
      studentId: map['studentId'] ?? '',
      fullName: map['fullName'] ?? '',
      fatherName: map['fatherName'] ?? '',
      phone: map['phone'] ?? '',
      parentPhone: map['parentPhone']?.toString(),
      address: map['address'] ?? '',
      course: map['course'] ?? '',
      courseId: map['courseId'] ?? '',
      studentType: map['studentType'] == 'tuition' ? StudentType.tuition : StudentType.course,
      selectedSubjects: List<String>.from(map['selectedSubjects'] ?? []),
      branchId: map['branchId'] ?? 'manglor', // Default for legacy data
      branchName: map['branchName'] ?? 'Manglor Pull',
      batch: map['batch'] ?? '',
      totalFee: tFee,
      discount: disc,
      effectiveFee: eFee,
      admissionDate: map['admissionDate'] is Timestamp
          ? (map['admissionDate'] as Timestamp).toDate()
          : DateTime.now(),
      feeDueDay: map['feeDueDay'] ?? 10,
      status: _parseStatus(map['status']),
      totalPaid: (map['totalPaid'] ?? 0).toDouble(),
      outstanding: (map['outstanding'] ?? 0).toDouble(),
      lastPaymentDate: map['lastPaymentDate'] is Timestamp
          ? (map['lastPaymentDate'] as Timestamp).toDate()
          : null,
    );
  }

  static StudentStatus _parseStatus(String? val) {
    if (val == null) return StudentStatus.active;
    final str = val.toString().trim().toLowerCase();
    if (str == 'inactive') return StudentStatus.inactive;
    if (str == 'graduated') return StudentStatus.graduated;
    if (str == 'archived') return StudentStatus.archived;
    return StudentStatus.active;
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'fullName': fullName,
      'fatherName': fatherName,
      'phone': phone,
      'parentPhone': parentPhone,
      'address': address,
      'course': course,
      'courseId': courseId,
      'studentType': studentType.value,
      'selectedSubjects': selectedSubjects,
      'branchId': branchId,
      'branchName': branchName,
      'batch': batch,
      'totalFee': totalFee,
      'monthlyFee': totalFee, // Legacy fallback
      'discount': discount,
      'effectiveFee': effectiveFee,
      'admissionDate': Timestamp.fromDate(admissionDate),
      'feeDueDay': feeDueDay,
      'status': status.value,
      'totalPaid': totalPaid,
      'outstanding': outstanding,
      'lastPaymentDate':
          lastPaymentDate != null ? Timestamp.fromDate(lastPaymentDate!) : null,
    };
  }

  StudentModel copyWith({
    String? id,
    String? studentId,
    String? fullName,
    String? fatherName,
    String? phone,
    String? parentPhone,
    String? address,
    String? course,
    String? courseId,
    StudentType? studentType,
    List<String>? selectedSubjects,
    String? branchId,
    String? branchName,
    String? batch,
    double? totalFee,
    double? discount,
    double? effectiveFee,
    DateTime? admissionDate,
    int? feeDueDay,
    StudentStatus? status,
    double? totalPaid,
    double? outstanding,
    DateTime? lastPaymentDate,
  }) {
    return StudentModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      fullName: fullName ?? this.fullName,
      fatherName: fatherName ?? this.fatherName,
      phone: phone ?? this.phone,
      parentPhone: parentPhone ?? this.parentPhone,
      address: address ?? this.address,
      course: course ?? this.course,
      courseId: courseId ?? this.courseId,
      studentType: studentType ?? this.studentType,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      batch: batch ?? this.batch,
      totalFee: totalFee ?? this.totalFee,
      discount: discount ?? this.discount,
      effectiveFee: effectiveFee ?? this.effectiveFee,
      admissionDate: admissionDate ?? this.admissionDate,
      feeDueDay: feeDueDay ?? this.feeDueDay,
      status: status ?? this.status,
      totalPaid: totalPaid ?? this.totalPaid,
      outstanding: outstanding ?? this.outstanding,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
    );
  }
}
