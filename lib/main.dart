import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/cloud_service.dart';
import 'services/notification_service.dart';
import 'utils/app_localization.dart';
import 'utils/maher_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (for Google OAuth sign-in and FCM push notifications)
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase init: $e');
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

  // Initialize Notifications (Local Daily Reminders + Firebase Cloud Messaging)
  try {
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('NotificationService init: $e');
  }

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
