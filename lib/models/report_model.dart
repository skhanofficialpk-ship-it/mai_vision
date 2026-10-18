class ReportModel {
  final String? id; // Firestore document ID
  final String title;
  final String generatedBy;
  final DateTime generatedAt;
  final String type; // e.g. Fee Revenue, Student Summary
  final Map<String, dynamic> filters;
  final Map<String, dynamic> summary;

  ReportModel({
    this.id,
    required this.title,
    required this.generatedBy,
    required this.generatedAt,
    required this.type,
    required this.filters,
    required this.summary,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      id: id,
      title: map['title'] ?? '',
      generatedBy: map['generatedBy'] ?? 'Admin',
      generatedAt: map['generatedAt'] != null
          ? (map['generatedAt'] as dynamic).toDate()
          : DateTime.now(),
      type: map['type'] ?? '',
      filters: Map<String, dynamic>.from(map['filters'] ?? {}),
      summary: Map<String, dynamic>.from(map['summary'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'generatedBy': generatedBy,
      'generatedAt': generatedAt,
      'type': type,
      'filters': filters,
      'summary': summary,
    };
  }
}
