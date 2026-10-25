import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/cloud_service.dart';
import '../../utils/app_localization.dart';
import '../../utils/maher_icons.dart';
import '../../utils/maher_theme.dart';
import '../home_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    final user = result.user;
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalization.tr('login_welcome')}, ${user.name}!'),
          backgroundColor: MaherTheme.emeraldPrimary,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } else {
      setState(() {
        switch (result.error) {
          case 'email_not_confirmed':
            _errorMessage = AppLocalization.tr('email_not_confirmed');
            break;
          case 'network':
          case 'profile_missing':
            _errorMessage = AppLocalization.tr('network_error');
            break;
          default:
            _errorMessage = CloudService.isEnabled
                ? AppLocalization.tr('invalid_credentials')
                : AppLocalization.tr('enter_valid_email_or_mobile');
        }
      });
    }
  }

  /// Signs in with Google via Supabase OAuth (not Firebase).
  /// Fixes G1: was broken in online mode because it created a Firebase user
  /// then called register(password: ''), which Supabase rejects.
  /// Fixes G3: also signs out of Google/Firebase so accounts can be switched.
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header with Logo
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: MaherTheme.goldPrimary
                                        .withValues(alpha: 0.5),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: MaherTheme.emeraldPrimary
                                          .withValues(alpha: 0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
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
                                    errorBuilder: (_, _, _) =>
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
                        const SizedBox(height: 26),

                        // Error Banner if any
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MaherTheme.errorRed
                                  .withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: MaherTheme.errorRed
                                    .withValues(alpha: 0.3),
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
                          const SizedBox(height: 18),
                        ],

                        // Mobile Number or Email Field
                        Text(
                          AppLocalization.tr('mobile_or_email'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: MaherTheme.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _identifierController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: '9876543210 or admin@maher.app',
                            prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: MaherIcons.get('user',
                                    size: 20, color: MaherTheme.emeraldPrimary),
                            ),
                          ),
                          validator: (value) {
                            final input = value?.trim() ?? '';
                            if (input.isEmpty) {
                              return AppLocalization.tr('enter_valid_email_or_mobile');
                            }
                            if (input.contains('@')) {
                              if (!input.contains('.') || input.length < 5) {
                                return AppLocalization.tr('enter_valid_email');
                              }
                            } else {
                              final digits = input.replaceAll(RegExp(r'\D'), '');
                              if (digits.length < 10) {
                                return AppLocalization.tr('enter_mobile_number');
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Password Field
                        Text(
                          AppLocalization.tr('password'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: MaherTheme.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: MaherIcons.get('lock',
                                  size: 20, color: MaherTheme.emeraldPrimary),
                            ),
                            suffixIcon: IconButton(
                              icon: MaherIcons.get(
                                _obscurePassword ? 'eye-off' : 'eye',
                                size: 20,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                                return AppLocalization.tr('password_min_length');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  activeColor: MaherTheme.emeraldPrimary,
                                  onChanged: (val) {
                                    setState(() {
                                      _rememberMe = val ?? true;
                                    });
                                  },
                                ),
                                Text(
                                  AppLocalization.tr('remember_me'),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                AppLocalization.tr('forgot_password'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: MaherTheme.emeraldPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Login Button
                        GestureDetector(
                          onTap: _isLoading ? null : _handleLogin,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: MaherTheme.emeraldPrimary,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: MaherTheme.emeraldDark,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: MaherTheme.emeraldDark,
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
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
                                                Colors.white),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MaherIcons.get('check-circle',
                                          size: 18, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppLocalization.tr('login'),
                                        style: const TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // OR Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                AppLocalization.tr('or_continue_with'),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Google Sign-In Button
                        GestureDetector(
                          onTap: _isLoading ? null : _signInWithGoogle,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Google "G" logo
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'G',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
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
                        const SizedBox(height: 22),

                        // Register Link
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              AppLocalization.tr('do_not_have_account'),
                              style: const TextStyle(
                                color: MaherTheme.emeraldPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
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
      ),
    );
  }
}
