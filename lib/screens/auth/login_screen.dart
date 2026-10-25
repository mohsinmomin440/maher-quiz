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
    if (!CloudService.isEnabled) {
      setState(() => _errorMessage = 'App requires online mode. Run with --dart-define-from-file=supabase.json');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await CloudService.signInWithGoogle();
      if (!mounted) return;

      setState(() => _isLoading = false);
      if (result.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalization.tr('login_welcome')}, ${result.user!.name}!'),
            backgroundColor: MaherTheme.emeraldPrimary,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        // Map error codes to localized messages
        switch (result.error) {
          case 'cancelled':
            break; // user cancelled — no error to show
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalization.tr('google_sign_in_failed');
        });
      }
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
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 4,
                shadowColor: MaherTheme.emeraldPrimary.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(
                    color: MaherTheme.emeraldPrimary.withValues(alpha: 0.12),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo & App Name
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: MaherTheme.goldPrimary.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: MaherTheme.emeraldPrimary.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  'assets/images/app_logo.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      MaherIcons.get('logo', size: 64),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'مہر',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: MaherTheme.goldDark,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocalization.tr('app_name'),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: MaherTheme.emeraldDark,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
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

                      // Error Message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: MaherTheme.errorRed.withValues(alpha: 0.09),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: MaherTheme.errorRed.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              MaherIcons.get('cross-circle',
                                  size: 20, color: MaherTheme.errorRed),
                              const SizedBox(width: 8),
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
                        const SizedBox(height: 24),
                      ],

                      // Google Sign‑In Button
                      GestureDetector(
                        onTap: _isLoading ? null : _signInWithGoogle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              MaherTheme.emeraldPrimary),
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MaherIcons.get('google', size: 24),
                                    const SizedBox(width: 14),
                                    Text(
                                      AppLocalization.tr('continue_with_google'),
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
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