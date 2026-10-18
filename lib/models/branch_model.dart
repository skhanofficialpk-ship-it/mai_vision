class BranchModel {
  final String id;
  final String name;
  final String location;
  final bool isActive;
  final bool isMainBranch;
  final String? phone;
  final String branchType; // 'coaching' or 'gaming_studio'

  const BranchModel({
    required this.id,
    required this.name,
    required this.location,
    this.isActive = true,
    this.isMainBranch = false,
    this.phone,
    this.branchType = 'coaching',
  });

  bool get isGamingStudio => branchType == 'gaming_studio';

  factory BranchModel.fromMap(Map<String, dynamic> map, String id) {
    return BranchModel(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      isActive: map['isActive'] ?? true,
      isMainBranch: map['isMainBranch'] ?? false,
      phone: map['phone'],
      branchType: map['branchType'] ?? 'coaching',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'isActive': isActive,
      'isMainBranch': isMainBranch,
      'phone': phone,
      'branchType': branchType,
    };
  }

  BranchModel copyWith({
    String? id,
    String? name,
    String? location,
    bool? isActive,
    bool? isMainBranch,
    String? phone,
    String? branchType,
  }) {
    return BranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      isMainBranch: isMainBranch ?? this.isMainBranch,
      phone: phone ?? this.phone,
      branchType: branchType ?? this.branchType,
    );
  }
}
