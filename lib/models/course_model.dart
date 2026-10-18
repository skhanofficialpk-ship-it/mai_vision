import 'package:flutter/material.dart';
import 'teacher_model.dart';

class CourseModel {
  final String? id;
  final String name;
  final String description;
  final String duration;
  final double totalFee;
  final List<String> modules;
  final String category;
  final bool isActive;
  final String iconName;

  final bool admissionOpen;

  /// The instructor teaching this course. Optional — courses created before
  /// this field existed simply get [TeacherModel.empty], and the UI hides
  /// the "Teacher" section when [TeacherModel.isEmpty] is true.
  final TeacherModel teacher;

  const CourseModel({
    this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.totalFee,
    required this.modules,
    required this.category,
    this.isActive = true,
    this.iconName = 'computer',
    this.admissionOpen = true,
    this.teacher = const TeacherModel.empty(),
  });

  factory CourseModel.fromMap(Map<String, dynamic> map, String id) {
    return CourseModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      duration: map['duration'] ?? '3 Months',
      totalFee: (map['totalFee'] ?? 0).toDouble(),
      modules: List<String>.from(map['modules'] ?? []),
      category: map['category'] ?? '',
      isActive: map['isActive'] ?? true,
      iconName: map['iconName'] ?? 'computer',
      admissionOpen: map['admissionOpen'] ?? true,
      teacher: TeacherModel.fromMap(map['teacher'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'duration': duration,
      'totalFee': totalFee,
      'modules': modules,
      'category': category,
      'isActive': isActive,
      'iconName': iconName,
      'admissionOpen': admissionOpen,
      'teacher': teacher.toMap(),
    };
  }

  CourseModel copyWith({
    String? id,
    String? name,
    String? description,
    String? duration,
    double? totalFee,
    List<String>? modules,
    String? category,
    bool? isActive,
    String? iconName,
    bool? admissionOpen,
    TeacherModel? teacher,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      totalFee: totalFee ?? this.totalFee,
      modules: modules ?? this.modules,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      iconName: iconName ?? this.iconName,
      admissionOpen: admissionOpen ?? this.admissionOpen,
      teacher: teacher ?? this.teacher,
    );
  }

  /// Centralized icon resolver — add new icon keys here only.
  /// Every screen that renders a course icon should call this instead of
  /// re-implementing its own iconName ternary/switch.
  IconData get icon {
    switch (iconName) {
      case 'smart_toy':
        return Icons.smart_toy;
      case 'flutter':
        return Icons.phone_iphone;
      case 'gamepad':
      case 'sports_esports':
        return Icons.sports_esports_rounded;
      case 'computer':
      default:
        return Icons.computer;
    }
  }
}

// Default courses used as seed data
final List<CourseModel> defaultCourses = [
  CourseModel(
    id: 'cit',
    name: 'Certificate in Information Technology (CIT)',
    description:
        'A comprehensive 3-month program covering computer fundamentals, office productivity tools, and essential digital literacy skills for today\'s workplace.',
    duration: '3 Months',
    totalFee: 5000,
    modules: [
      'Computer Fundamentals',
      'Typing Skills',
      'MS Office',
      'Internet Usage',
      'Email Usage',
      'Digital Literacy',
    ],
    category: 'Computer Skills',
    iconName: 'computer',
    admissionOpen: true,
    teacher: const TeacherModel(
      name: 'Muzammil Khan',
      address: 'Manglor Pull, Near NBP, Swat, Pakistan',
      contact: '+92 329 8681641',
      experienceYears: 3,
    ),
  ),
  CourseModel(
    id: 'ai_digital_skills',
    name: 'Fundamentals of Artificial Intelligence',
    description:
        'Stay ahead of the curve with our AI-focused 2-month course. Learn to harness the power of artificial intelligence tools for study, work, and creativity.',
    duration: '2 Months',
    totalFee: 6000,
    modules: [
      'ChatGPT & AI Tools',
      'Prompt Engineering',
      'AI for Study & Productivity',
      'AI Content Creation',
      'Smart Research Techniques',
    ],
    category: 'AI & Technology',
    iconName: 'smart_toy',
    admissionOpen: true,
    teacher: const TeacherModel(
      name: 'Muzammil Khan',
      address: 'Manglor Pull, Near NBP, Swat, Pakistan',
      contact: '+92 329 8681641',
      experienceYears: 3,
    ),
  ),
  CourseModel(
    id: 'flutter_game_dev',
    name: 'Flutter Game Development',
    description:
        'A hands-on, beginner-friendly 2-month training program at MAI Gaming Studio. Learn Flutter & Flame game engine, develop 2D games from scratch, and publish student games to Google Play Store.',
    duration: '2 Months',
    totalFee: 8000,
    modules: [
      'Dart & Flutter UI for Games',
      'Flame Game Engine & Game Loop',
      '2D Sprites, Physics & Animation',
      'Sound Effects & Score Tracking',
      'Publishing Games to Play Store',
    ],
    category: 'Gaming Studio',
    iconName: 'sports_esports',
    admissionOpen: true,
    teacher: const TeacherModel(
      name: 'Muzammil Khan',
      address: 'MAI Gaming Studio, Manglor, Swat',
      contact: '+92 329 8681641',
      experienceYears: 4,
    ),
  ),
  CourseModel(
    id: 'flutter_development',
    name: 'Flutter Development',
    description:
        'Build real, cross-platform mobile and web apps with Flutter & Dart. A hands-on course covering UI design, state management, APIs, and publishing apps to real app stores.',
    duration: '2 Months',
    totalFee: 8000,
    modules: [
      'Dart Programming Fundamentals',
      'Flutter Widgets & Layouts',
      'State Management',
      'Working with APIs & Firebase',
      'Building Real Mobile Apps',
    ],
    category: 'App Development',
    iconName: 'flutter',
    admissionOpen: true,
    teacher: const TeacherModel(
      name: 'Muzammil Khan',
      address: 'Charbagh, Swat',
      contact: '+92 329 8681641',
      experienceYears: 4,
    ),
  ),
  CourseModel(
    id: 'matric_science',
    name: 'Matric Science Coaching',
    description:
        'Comprehensive coaching for Matric Science students in Mathematics, Physics, Chemistry, and Biology.',
    duration: 'Ongoing',
    totalFee: 2500, // Default for 4 subjects
    modules: [
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
    ],
    category: 'Coaching',
    iconName: 'school',
    admissionOpen: true,
    teacher: const TeacherModel(
      name: 'Muzammil Khan',
      address: 'Charbagh, Swat',
      contact: '+92 329 8681641',
      experienceYears: 5,
    ),
  ),
  CourseModel(
    id: 'english_communication',
    name: 'English Learning & Communication',
    description:
        'Improve your English speaking, writing, and professional communication skills in just 40 days.',
    duration: '40 Days',
    totalFee: 3000,
    modules: [
      'Spoken English',
      'Grammar Fundamentals',
      'Professional Writing',
      'Public Speaking',
    ],
    category: 'Languages',
    iconName: 'language',
    admissionOpen: true,
    teacher: const TeacherModel(
      name: 'Muzammil Khan',
      address: 'Charbagh, Swat',
      contact: '+92 329 8681641',
      experienceYears: 3,
    ),
  ),
];
