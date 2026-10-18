import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course_model.dart';
import '../services/firestore_service.dart';

/// Live stream of all courses from Firestore.
///
/// Every Add/Edit/Delete performed in the admin panel updates Firestore, and
/// this provider automatically pushes the change to every page that watches it
/// (public courses listing, home page preview, course detail, admission form).
///
/// On first run the courses collection is empty, so [FirestoreService.seedCourses]
/// populates it from [defaultCourses] in main.dart — after that Firestore is the
/// single source of truth for course data.
final coursesProvider = StreamProvider<List<CourseModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getCourses();
});

/// Convenience provider that returns a single course by its Firestore document
/// ID, or null if not found. Used by the Course Detail page.
final courseByIdProvider =
    StreamProvider.family<CourseModel?, String>((ref, id) {
  return ref.watch(coursesProvider.stream).map(
        (courses) {
          try {
            return courses.firstWhere((c) => c.id == id);
          } catch (_) {
            return null;
          }
        },
      );
});
