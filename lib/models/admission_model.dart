import 'student_model.dart';

class AdmissionModel {
  final String? id;
  final String fullName;
  final String fatherName;
  final String phone;
  final String? parentPhone; // New
  final String email;
  final String address;
  final String qualification;
  final String selectedCourse;
  final StudentType studentType; // New
  final List<String> selectedSubjects; // New (for Matric Science)
  final String branchId; // New
  final String branchName; // New
  final double monthlyFee; // New
  final String? cnicBForm;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AdmissionModel({
    this.id,
    required this.fullName,
    required this.fatherName,
    required this.phone,
    this.parentPhone,
    required this.email,
    required this.address,
    required this.qualification,
    required this.selectedCourse,
    this.studentType = StudentType.course, // New
    this.selectedSubjects = const [],
    this.branchId = 'charbagh',
    this.branchName = 'Charbagh',
    this.monthlyFee = 0,
    this.cnicBForm,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
  });

  factory AdmissionModel.fromMap(Map<String, dynamic> map, String id) {
    return AdmissionModel(
      id: id,
      fullName: map['fullName'] ?? '',
      fatherName: map['fatherName'] ?? '',
      phone: map['phone']?.toString() ?? '',
      parentPhone: map['parentPhone']?.toString(),
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      qualification: map['qualification'] ?? '',
      selectedCourse: map['selectedCourse'] ?? '',
      studentType: map['studentType'] == 'tuition' ? StudentType.tuition : StudentType.course,
      selectedSubjects: List<String>.from(map['selectedSubjects'] ?? []),
      branchId: map['branchId'] ?? 'manglor', // Default to manglor for old data
      branchName: map['branchName'] ?? 'Manglor Pull',
      monthlyFee: (map['monthlyFee'] ?? 0).toDouble(),
      cnicBForm: map['cnicBForm']?.toString(),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'fatherName': fatherName,
      'phone': phone,
      'parentPhone': parentPhone,
      'email': email,
      'address': address,
      'qualification': qualification,
      'selectedCourse': selectedCourse,
      'studentType': studentType.value,
      'selectedSubjects': selectedSubjects,
      'branchId': branchId,
      'branchName': branchName,
      'monthlyFee': monthlyFee,
      'cnicBForm': cnicBForm,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  AdmissionModel copyWith({
    String? id,
    String? fullName,
    String? fatherName,
    String? phone,
    String? parentPhone,
    String? email,
    String? address,
    String? qualification,
    String? selectedCourse,
    StudentType? studentType,
    List<String>? selectedSubjects,
    String? branchId,
    String? branchName,
    double? monthlyFee,
    String? cnicBForm,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdmissionModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      fatherName: fatherName ?? this.fatherName,
      phone: phone ?? this.phone,
      parentPhone: parentPhone ?? this.parentPhone,
      email: email ?? this.email,
      address: address ?? this.address,
      qualification: qualification ?? this.qualification,
      selectedCourse: selectedCourse ?? this.selectedCourse,
      studentType: studentType ?? this.studentType,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      cnicBForm: cnicBForm ?? this.cnicBForm,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
