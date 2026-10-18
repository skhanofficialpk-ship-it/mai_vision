import 'package:cloud_firestore/cloud_firestore.dart';

class BatchModel {
  final String? id;
  final String name;
  final String branchId;
  final List<String> courseIds;
  final Map<String, String> courseDurations; // courseId -> duration string
  final Map<String, DateTime> courseEndDates; // courseId -> calculated end date
  final DateTime startDate;
  final String status; // upcoming, active, completed
  final String teacher;
  final DateTime createdAt;

  const BatchModel({
    this.id,
    required this.name,
    required this.branchId,
    required this.courseIds,
    required this.courseDurations,
    required this.courseEndDates,
    required this.startDate,
    this.status = 'upcoming',
    required this.teacher,
    required this.createdAt,
  });

  factory BatchModel.fromMap(Map<String, dynamic> map, String id) {
    List<String> ids = [];
    if (map['courseIds'] != null) {
      ids = List<String>.from(map['courseIds']);
    } else if (map['courseId'] != null) {
      ids = [map['courseId'] as String];
    }

    Map<String, String> durations = {};
    if (map['courseDurations'] != null) {
      durations = Map<String, String>.from(map['courseDurations']);
    } else if (map['duration'] != null && ids.isNotEmpty) {
      // Legacy: Apply single duration to all courses in this batch
      for (var cid in ids) {
        durations[cid] = map['duration'] as String;
      }
    }

    Map<String, DateTime> endDates = {};
    if (map['courseEndDates'] != null) {
      final m = map['courseEndDates'] as Map<String, dynamic>;
      m.forEach((key, value) {
        if (value is Timestamp) endDates[key] = value.toDate();
      });
    } else if (map['endDate'] != null && ids.isNotEmpty) {
      // Legacy: Apply single end date to all courses
      for (var cid in ids) {
        endDates[cid] = (map['endDate'] as Timestamp).toDate();
      }
    }

    return BatchModel(
      id: id,
      name: map['name'] ?? '',
      branchId: map['branchId'] ?? '',
      courseIds: ids,
      courseDurations: durations,
      courseEndDates: endDates,
      startDate: map['startDate'] != null
          ? (map['startDate'] as dynamic).toDate()
          : DateTime.now(),
      status: map['status'] ?? 'upcoming',
      teacher: map['teacher'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'branchId': branchId,
      'courseIds': courseIds,
      'courseDurations': courseDurations,
      'courseEndDates': courseEndDates.map((k, v) => MapEntry(k, Timestamp.fromDate(v))),
      'startDate': Timestamp.fromDate(startDate),
      'status': status,
      'teacher': teacher,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  BatchModel copyWith({
    String? id,
    String? name,
    String? branchId,
    List<String>? courseIds,
    Map<String, String>? courseDurations,
    Map<String, DateTime>? courseEndDates,
    DateTime? startDate,
    String? status,
    String? teacher,
    DateTime? createdAt,
  }) {
    return BatchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      branchId: branchId ?? this.branchId,
      courseIds: courseIds ?? this.courseIds,
      courseDurations: courseDurations ?? this.courseDurations,
      courseEndDates: courseEndDates ?? this.courseEndDates,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      teacher: teacher ?? this.teacher,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
