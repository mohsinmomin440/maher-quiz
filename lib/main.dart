import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/cloud_service.dart';
import 'utils/app_localization.dart';
import 'utils/maher_theme.dart';

// Firebase is only needed for the Google sign-in flow on platforms that have
// a Firebase project configured. Without google-services.json / GoogleService-
// Info.plist the SDK throws, so never initialize it unconditionally.
bool get _firebaseRequired =>
    !identical(kIsWeb, true) &&
    const bool.fromEnvironment('HAS_FIREBASE', defaultValue: false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (required for Google OAuth sign-in). Skipped on web
  // and on builds without a Firebase project, where the SDK throws on import.
  if (_firebaseRequired) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }
  }

  // Connects to Supabase only when built with SUPABASE_URL/SUPABASE_ANON_KEY
  // (see SUPABASE_SETUP.md); otherwise the app runs fully local
  try {
    await CloudService.initialize();
  } catch (e) {
    debugPrint('Supabase init failed, continuing offline: $e');
  }

  // Seed the local users DB once at startup (prevents race conditions from
  // calling ensureSeeded() on every getCurrentUser() call).
  await AuthService.ensureSeeded();

  runApp(const MaherQuizApp());
}

class MaherQuizApp extends StatelessWidget {
  const MaherQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalization.currentLang = 'en';
    return MaterialApp(
      title: 'Maher Quiz',
      debugShowCheckedModeBanner: false,
      theme: MaherTheme.themeData,
      home: const SplashScreen(),
    );
  }
}
