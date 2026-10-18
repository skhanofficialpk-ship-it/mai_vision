class AppConstants {
  // Institute Info
  static const String instituteName = 'MAI Coaching Academy';
  static const String tagline = 'Build your future with Modern AI';
  static const String location = 'School Colony Charbagh Swat';
  static const String phone = '03298681641';
  static const String phoneFormatted = '+92 329 8681641';
  static const String whatsapp = '03298681641';
  static const String email = 'skhanofficial.pk@gmail.com';
  
  static const String admissionsOpenText = 'Admissions Open';
  static const String classesStartText = 'Classes Starting 20 October 2026';

  // Founder
  static const String founderName = 'Muzammil Khan';
  static const String founderTitle = 'Founder & Lead Instructor';
  static const String founderQualification = 'BS-IT — University of Swat';

  // URLs
  static const String websiteUrl = 'https://mai-vision.web.app';
  static const String whatsappUrl =
      'https://wa.me/923298681641?text=Hello%2C%20I%20am%20interested%20in%20admission%20at%20MAI%20Vision%20Coaching%20Academy';
  static const String emailUrl = 'mailto:skhanofficial.pk@gmail.com';
  static const String callUrl = 'tel:+923298681641';
  static const String mapsUrl = 'https://maps.app.goo.gl/3Bh4MSnfNNe2bA7XA';

  // Collections
  static const String admissionsCollection = 'admissions';
  static const String certificatesCollection = 'certificates';
  static const String coursesCollection = 'courses';
  static const String galleryCollection = 'gallery';
  static const String faqCollection = 'faq';
  static const String settingsCollection = 'settings';
  static const String studentsCollection = 'students';
  static const String expensesCollection = 'expenses'; // New
  static const String gameProjectsCollection = 'game_projects'; // MAI Gaming Studio
  static const String paymentsSubcollection = 'payments';
  static const String reportsCollection = 'reports';

  // Courses
  static const String course1Id = 'advance_computer';
  static const String course1Name = 'Advance Computer Course';
  static const String course2Id = 'ai_digital_skills';
  static const String course2Name = 'Fundamentals of Artificial Intelligence';

  // Admin
  static const String adminEmail = 'skhanofficial.pk@gmail.com';
  static const String adminDisplayName = 'Mister MJ';

  // Helper to format course IDs to Names
  static String formatCourseName(String name) {
    if (name.isEmpty) return 'General Course';
    final normalized = name.toLowerCase().trim();
    
    // Explicit mapping for known identifiers
    if (normalized == 'ai_digital_skills' ||
        normalized == 'ai & smart digital skills' ||
        normalized == 'ai digital skills' ||
        normalized == 'fundamentals of artificial intelligence') {
      return 'Fundamentals of Artificial Intelligence';
    }
    if (normalized == 'advance_computer' ||
        normalized == 'advance computer course' ||
        normalized == 'cit') {
      return 'Certificate in Information Technology (CIT)';
    }
    if (normalized == 'flutter_game_dev' ||
        normalized == 'flutter game development' ||
        normalized == 'flutter_game_development') {
      return 'Flutter Game Development';
    }
    if (normalized == 'flutter_development' || normalized == 'flutter') {
      return 'Flutter & Dart Development';
    }
    if (normalized == 'matric_science') {
      return 'Matric Science Coaching';
    }
    if (normalized == 'digital_literacy_typing' || normalized == 'digital_literacy') {
      return 'Digital Literacy & Typing';
    }
    if (normalized == 'english_learning' || normalized == 'english_communication') {
      return 'English Learning & Communication';
    }
    
    // Generic fallback for any other snake_case strings
    return name.replaceAll('_', ' ').split(' ').map((str) {
      if (str.isEmpty) return "";
      return str[0].toUpperCase() + str.substring(1).toLowerCase();
    }).join(' ');
  }
}
