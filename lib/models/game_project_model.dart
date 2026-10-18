import 'package:cloud_firestore/cloud_firestore.dart';

class GameProjectModel {
  final String? id;
  final String studentId;
  final String studentName;
  final String branchId;
  final String title;
  final String description;
  final String genre;
  final List<String> technologies;
  final String devPeriod;
  final String status; // 'In Development', 'Completed', 'Published'
  final String? playStoreUrl;
  final String? otherUrl;
  final String? imageUrl;
  final bool isPublished;
  final DateTime createdAt;

  const GameProjectModel({
    this.id,
    required this.studentId,
    required this.studentName,
    this.branchId = 'manglor',
    required this.title,
    required this.description,
    this.genre = 'Mobile Game',
    this.technologies = const ['Flutter', 'Dart'],
    this.devPeriod = '2 Months',
    this.status = 'Completed',
    this.playStoreUrl,
    this.otherUrl,
    this.imageUrl,
    this.isPublished = true,
    required this.createdAt,
  });

  factory GameProjectModel.fromMap(Map<String, dynamic> map, String id) {
    return GameProjectModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      branchId: map['branchId'] ?? 'manglor',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      genre: map['genre'] ?? 'Mobile Game',
      technologies: List<String>.from(map['technologies'] ?? ['Flutter', 'Dart']),
      devPeriod: map['devPeriod'] ?? '2 Months',
      status: map['status'] ?? 'Completed',
      playStoreUrl: map['playStoreUrl'],
      otherUrl: map['otherUrl'],
      imageUrl: map['imageUrl'],
      isPublished: map['isPublished'] ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'branchId': branchId,
      'title': title,
      'description': description,
      'genre': genre,
      'technologies': technologies,
      'devPeriod': devPeriod,
      'status': status,
      'playStoreUrl': playStoreUrl,
      'otherUrl': otherUrl,
      'imageUrl': imageUrl,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  GameProjectModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? branchId,
    String? title,
    String? description,
    String? genre,
    List<String>? technologies,
    String? devPeriod,
    String? status,
    String? playStoreUrl,
    String? otherUrl,
    String? imageUrl,
    bool? isPublished,
    DateTime? createdAt,
  }) {
    return GameProjectModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      branchId: branchId ?? this.branchId,
      title: title ?? this.title,
      description: description ?? this.description,
      genre: genre ?? this.genre,
      technologies: technologies ?? this.technologies,
      devPeriod: devPeriod ?? this.devPeriod,
      status: status ?? this.status,
      playStoreUrl: playStoreUrl ?? this.playStoreUrl,
      otherUrl: otherUrl ?? this.otherUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
