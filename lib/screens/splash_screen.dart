import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_localization.dart';
import '../utils/maher_icons.dart';
import '../utils/maher_theme.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
const SplashScreen({super.key, });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    _loadPreferencesAndNavigate();
  }

  Timer? _timer;

  Future<void> _loadPreferencesAndNavigate() async {
    AppLocalization.currentLang = 'en';
_timer = Timer(const Duration(milliseconds: 2200), () async {
      if (!mounted) return;

      // Sessions started without "Remember me" end when the app restarts
      await AuthService.clearTemporarySession();
      final currentUser = await AuthService.getCurrentUser();
      if (!mounted) return;

      if (currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaherTheme.emeraldDark,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: MaherTheme.goldPrimary.withValues(alpha: 0.35),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          MaherIcons.get('logo', size: 100),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Arabic Calligraphy Accent
              Text(
                'مہر',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: MaherTheme.goldPrimary,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              // App Name in Gujarati & English
              Text(
                AppLocalization.tr('app_name'),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalization.tr('app_tagline'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalization.tr('app_subtitle'),
                style: TextStyle(
                  fontSize: 13,
                  color: MaherTheme.goldLight.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    MaherTheme.goldPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
