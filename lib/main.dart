import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart'; // New
import 'config/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/splash_screen.dart';
import 'routes/app_router.dart';
import 'services/firestore_service.dart';
import 'services/branch_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Use Path URL Strategy (removes '#' from URL)
  usePathUrlStrategy();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Disable persistence on Web to prevent IndexedDB lockups
  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
  }

  runApp(const ProviderScope(child: MaiVisionApp()));
}

class MaiVisionApp extends ConsumerWidget {
  const MaiVisionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Trigger background seeding once (non-blocking)
    _maybeSeedData(ref);

    // 2. Remove splash screen as soon as possible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      removeSplashScreen();
    });

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '${AppConstants.instituteName} — ${AppConstants.tagline}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 599, name: MOBILE),
          const Breakpoint(start: 600, end: 1023, name: TABLET),
          const Breakpoint(start: 1024, end: 1439, name: DESKTOP),
          const Breakpoint(start: 1440, end: double.infinity, name: '4K'),
        ],
      ),
    );
  }

  // ─────────────── BACKGROUND SEEDING ───────────────
  static bool _seeded = false;

  void _maybeSeedData(WidgetRef ref) {
    if (_seeded) return;
    _seeded = true;

    // Run seeding in background after a short delay
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        final firestore = ref.read(firestoreServiceProvider);
        final branch = ref.read(branchServiceProvider);

        await Future.wait([
          firestore.seedCourses(),
          firestore.seedFaqs(),
          branch.seedInitialBranches(),
        ]);
        debugPrint('Seeding completed.');
      } catch (e) {
        debugPrint('Seeding error: $e');
      }
    });
  }
}
