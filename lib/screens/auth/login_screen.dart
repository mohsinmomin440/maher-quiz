import 'package:flutter/material.dart';
import '../../services/cloud_service.dart';
import '../../utils/app_localization.dart';
import '../../utils/maher_icons.dart';
import '../../utils/maher_theme.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await CloudService.signInWithGoogle();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalization.tr('login_welcome')}, ${result.user!.name}!'),
            backgroundColor: MaherTheme.emeraldPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
        return;
      }

      // Map error codes to localized messages
      switch (result.error) {
        case 'cancelled':
          // User closed Google prompt — no error message needed
          break;
        case 'invalid_credentials':
          setState(() => _errorMessage = AppLocalization.tr('google_sign_in_failed'));
          break;
        case 'email_not_confirmed':
          setState(() => _errorMessage = AppLocalization.tr('email_not_confirmed'));
          break;
        case 'network':
        case 'signup_failed':
        case 'profile_missing':
          setState(() => _errorMessage = AppLocalization.tr('network_error'));
          break;
        default:
          setState(() => _errorMessage = AppLocalization.tr('google_sign_in_failed'));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalization.tr('google_sign_in_failed');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaherTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 4,
                shadowColor: MaherTheme.emeraldPrimary.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: MaherTheme.emeraldPrimary.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App Logo & Branding
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: MaherTheme.goldPrimary.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: MaherTheme.emeraldPrimary.withValues(alpha: 0.18),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/app_logo.png',
                                  width: 88,
                                  height: 88,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      MaherIcons.get('logo', size: 68),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'مہر',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: MaherTheme.goldDark,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocalization.tr('app_name'),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: MaherTheme.emeraldDark,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppLocalization.tr('app_tagline'),
                              style: const TextStyle(
                                fontSize: 13,
                                color: MaherTheme.textSecondaryLight,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Welcome & Feature highlight box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: MaherTheme.emeraldPrimary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: MaherTheme.emeraldPrimary.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: MaherTheme.emeraldPrimary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: MaherIcons.get('star', size: 20, color: MaherTheme.emeraldPrimary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Quick & Secure Access',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: MaherTheme.emeraldDark,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Sign in with your Google account to track streaks, save scores, and compete on the leaderboard.',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: MaherTheme.textSecondaryLight,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Error Banner if any
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: MaherTheme.errorRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: MaherTheme.errorRed.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              MaherIcons.get('cross-circle', size: 20, color: MaherTheme.errorRed),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: MaherTheme.errorRed,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Google Sign-In Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading ? null : _signInWithGoogle,
                          borderRadius: BorderRadius.circular(16),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: _isLoading
                                ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            MaherTheme.emeraldPrimary),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MaherIcons.get('google', size: 24),
                                      const SizedBox(width: 12),
                                      Text(
                                        AppLocalization.tr('continue_with_google'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Terms & Privacy footer
                      const Center(
                        child: Text(
                          'By continuing, you agree to our Terms and Privacy Policy.',
                          style: TextStyle(
                            fontSize: 11,
                            color: MaherTheme.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
