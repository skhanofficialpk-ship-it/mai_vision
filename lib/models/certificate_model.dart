import 'package:cloud_firestore/cloud_firestore.dart';

class CertificateModel {
  final String? id;
  final String certificateId; // auto-generated e.g. MAI-CERT-2026-0001 or MAI-EXP-2026-0001
  final String studentId;
  final String studentName;
  final String courseName;
  final String courseId;
  final DateTime completionDate;
  final DateTime issuedDate;
  final String instructorName;
  final String? qrUrl; // URL for verification page
  final DateTime createdAt;
  final String certificateType; // 'training' or 'experience'
  final String? projectTitle;
  final String? role;
  final String? experiencePeriod;
  final String? organizationName;

  const CertificateModel({
    this.id,
    required this.certificateId,
    required this.studentId,
    required this.studentName,
    required this.courseName,
    required this.courseId,
    required this.completionDate,
    required this.issuedDate,
    required this.instructorName,
    this.qrUrl,
    required this.createdAt,
    this.certificateType = 'training',
    this.projectTitle,
    this.role,
    this.experiencePeriod,
    this.organizationName,
  });

  bool get isExperience => certificateType == 'experience';

  factory CertificateModel.fromMap(Map<String, dynamic> map, String docId) {
    return CertificateModel(
      id: docId,
      certificateId: map['certificateId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      courseName: map['courseName'] ?? '',
      courseId: map['courseId'] ?? '',
      completionDate: map['completionDate'] is Timestamp
          ? (map['completionDate'] as Timestamp).toDate()
          : DateTime.now(),
      issuedDate: map['issuedDate'] is Timestamp
          ? (map['issuedDate'] as Timestamp).toDate()
          : DateTime.now(),
      instructorName: map['instructorName'] ?? 'Muzammil Khan',
      qrUrl: map['qrUrl'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      certificateType: map['certificateType'] ?? 'training',
      projectTitle: map['projectTitle'],
      role: map['role'],
      experiencePeriod: map['experiencePeriod'],
      organizationName: map['organizationName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'certificateId': certificateId,
      'studentId': studentId,
      'studentName': studentName,
      'courseName': courseName,
      'courseId': courseId,
      'completionDate': Timestamp.fromDate(completionDate),
      'issuedDate': Timestamp.fromDate(issuedDate),
      'instructorName': instructorName,
      'qrUrl': qrUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'certificateType': certificateType,
      'projectTitle': projectTitle,
      'role': role,
      'experiencePeriod': experiencePeriod,
      'organizationName': organizationName,
    };
  }

  CertificateModel copyWith({
    String? id,
    String? certificateId,
    String? studentId,
    String? studentName,
    String? courseName,
    String? courseId,
    DateTime? completionDate,
    DateTime? issuedDate,
    String? instructorName,
    String? qrUrl,
    DateTime? createdAt,
    String? certificateType,
    String? projectTitle,
    String? role,
    String? experiencePeriod,
    String? organizationName,
  }) {
    return CertificateModel(
      id: id ?? this.id,
      certificateId: certificateId ?? this.certificateId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      courseName: courseName ?? this.courseName,
      courseId: courseId ?? this.courseId,
      completionDate: completionDate ?? this.completionDate,
      issuedDate: issuedDate ?? this.issuedDate,
      instructorName: instructorName ?? this.instructorName,
      qrUrl: qrUrl ?? this.qrUrl,
      createdAt: createdAt ?? this.createdAt,
      certificateType: certificateType ?? this.certificateType,
      projectTitle: projectTitle ?? this.projectTitle,
      role: role ?? this.role,
      experiencePeriod: experiencePeriod ?? this.experiencePeriod,
      organizationName: organizationName ?? this.organizationName,
    );
  }
}
