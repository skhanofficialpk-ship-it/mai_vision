/// Represents the teacher/instructor assigned to a course.
///
/// Embedded directly on [CourseModel] (one teacher per course) rather than
/// stored as a separate Firestore collection — this keeps the data model
/// simple and avoids an extra collection/relationship for a 1:1 association.
class TeacherModel {
  final String name;
  final String address;
  final String contact;
  final int experienceYears;

  const TeacherModel({
    required this.name,
    required this.address,
    required this.contact,
    required this.experienceYears,
  });

  factory TeacherModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const TeacherModel.empty();
    return TeacherModel(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      contact: map['contact'] ?? '',
      experienceYears: (map['experienceYears'] ?? 0) is int
          ? map['experienceYears'] ?? 0
          : (map['experienceYears'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'contact': contact,
      'experienceYears': experienceYears,
    };
  }

  const TeacherModel.empty()
      : name = '',
        address = '',
        contact = '',
        experienceYears = 0;

  /// True when no teacher information has been entered yet — lets the UI
  /// decide whether to show a "Teacher" section at all.
  bool get isEmpty => name.trim().isEmpty;

  TeacherModel copyWith({
    String? name,
    String? address,
    String? contact,
    int? experienceYears,
  }) {
    return TeacherModel(
      name: name ?? this.name,
      address: address ?? this.address,
      contact: contact ?? this.contact,
      experienceYears: experienceYears ?? this.experienceYears,
    );
  }
}
