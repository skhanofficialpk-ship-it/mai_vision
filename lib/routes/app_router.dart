import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../features/home/home_page.dart';
import '../features/about/about_page.dart';
import '../features/courses/courses_page.dart';
import '../features/courses/course_detail_page.dart';
import '../features/admissions/admissions_page.dart';
import '../features/gallery/gallery_page.dart';
import '../features/contact/contact_page.dart';
import '../features/certificate/certificate_page.dart';
import '../features/auth/login_page.dart';
import '../admin/dashboard/admin_shell.dart';
import '../admin/dashboard/admin_overview_page.dart';
import '../admin/admissions/admin_admissions_page.dart';
import '../admin/students/admin_students_page.dart';
import '../admin/courses/admin_courses_page.dart';
import '../admin/certificates/admin_certificates_page.dart';
import '../admin/faq/admin_faq_page.dart';
import '../admin/branches/admin_branches_page.dart';
import '../admin/batches/admin_batches_page.dart';
import '../admin/content/admin_content_page.dart';
import '../admin/fee/admin_fees_page.dart';
import '../admin/teachers/admin_teachers_page.dart';
import '../admin/expenses/admin_expenses_page.dart';
import '../admin/projects/admin_projects_page.dart';
import '../features/gaming_studio/gaming_studio_page.dart';
import '../widgets/public_shell.dart';

// 1. Auth Change Notifier: GoRouter ko state change ki itla dene ke liye
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(
      authStateProvider,
          (_, __) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

// 2. Main Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier, // Auth state badalne par auto-redirect trigger karega
    debugLogDiagnostics: false,
    redirect: (context, state) {
      // Direct state read karein taake router recreate na ho
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull != null;

      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isLoginRoute = state.matchedLocation == '/login';
      final isVerifyRoute = state.matchedLocation.startsWith('/verify'); // New: QR/Verify check

      // 1. Force authenticated admins to stay in the Admin Panel
      // EXEMPTION: Allow admins to view public verification pages (QR scans)
      if (!isAdminRoute && !isLoginRoute && !isVerifyRoute && isLoggedIn) return '/admin';

      // 2. Protect Admin Routes
      if (isAdminRoute && !isLoggedIn) return '/login';

      // 3. Prevent Login access if already logged in
      if (isLoginRoute && isLoggedIn) return '/admin';

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => PublicShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (c, s) => const HomePage()),
          GoRoute(path: '/gaming-studio', builder: (c, s) => const GamingStudioPage()),
          GoRoute(path: '/about', builder: (c, s) => const AboutPage()),
          GoRoute(path: '/courses', builder: (c, s) => const CoursesPage()),
          GoRoute(
            path: '/courses/:id',
            builder: (c, s) => CourseDetailPage(courseId: s.pathParameters['id']!),
          ),
          GoRoute(path: '/admissions', builder: (c, s) => const AdmissionsPage()),
          GoRoute(path: '/gallery', builder: (c, s) => const GalleryPage()),
          GoRoute(path: '/contact', builder: (c, s) => const ContactPage()),
          GoRoute(
            path: '/verify-certificate',
            builder: (c, s) => const CertificatePage(),
          ),
          GoRoute(
            path: '/verify/:id',
            builder: (c, s) => CertificatePage(certificateId: s.pathParameters['id']),
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin', builder: (c, s) => const AdminOverviewPage()),
          GoRoute(path: '/admin/branches', builder: (c, s) => const AdminBranchesPage()),
          GoRoute(path: '/admin/batches', builder: (c, s) => const AdminBatchesPage()),
          GoRoute(path: '/admin/admissions', builder: (c, s) => const AdminAdmissionsPage()),
          GoRoute(path: '/admin/students', builder: (c, s) => const AdminStudentsPage()),
          GoRoute(path: '/admin/courses', builder: (c, s) => const AdminCoursesPage()),
          GoRoute(path: '/admin/projects', builder: (c, s) => const AdminProjectsPage()),
          GoRoute(path: '/admin/certificates', builder: (c, s) => const AdminCertificatesPage()),
          GoRoute(path: '/admin/faq', builder: (c, s) => const AdminFaqPage()),
          GoRoute(path: '/admin/content', builder: (c, s) => const AdminContentPage()),
          GoRoute(path: '/admin/fee', builder: (c, s) => const AdminFeesPage()),
          GoRoute(path: '/admin/teachers', builder: (c, s) => const AdminTeachersPage()),
          GoRoute(path: '/admin/expenses', builder: (c, s) => const AdminExpensesPage()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});