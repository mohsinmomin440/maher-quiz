import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/age_groups.dart';
import '../../services/auth_service.dart';
import '../../utils/app_localization.dart';
import '../../utils/maher_icons.dart';
import '../../utils/maher_theme.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
const RegisterScreen({super.key, });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedAgeGroup = AgeGroups.defaultGroup;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _ageGroups = AgeGroups.all;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = AppLocalization.tr('passwords_not_match');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (Firebase.apps.isEmpty) {
      await _completeRegistration();
      return;
    }

    var phone = _phoneController.text.trim();
    if (!phone.startsWith('+')) {
      if (phone.length == 10) {
        phone = '+91$phone';
      } else {
        phone = '+$phone';
      }
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto verification on some Android devices.
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          _promptLocalFallback(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showOtpDialog(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _promptLocalFallback('Could not connect to SMS verification service.');
    }
  }

  Future<void> _promptLocalFallback(String reason) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('SMS Verification Unavailable'),
        content: Text(
          '$reason\n\nWould you like to register directly on this device instead?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MaherTheme.emeraldPrimary,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Register Offline'),
          ),
        ],
      ),
    );

    if (proceed == true && mounted) {
      await _completeRegistration();
    }
  }

  Future<void> _showOtpDialog(String verificationId) async {
    final otpController = TextEditingController();
    bool isVerifying = false;
    String? localError;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Enter OTP', textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sent to +91 ${_phoneController.text.trim()}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  if (localError != null) ...[
                    Text(localError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    const SizedBox(height: 8),
                  ],
                  TextFormField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(fontSize: 24, letterSpacing: 5),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isVerifying
                      ? null
                      : () async {
                          if (otpController.text.length != 6) return;
                          setDialogState(() {
                            isVerifying = true;
                            localError = null;
                          });

                          try {
                            final credential = PhoneAuthProvider.credential(
                              verificationId: verificationId,
                              smsCode: otpController.text.trim(),
                            );
                            await FirebaseAuth.instance.signInWithCredential(credential);
                            
                            // Verification Success! Proceed to register account in our DB.
                            if (!context.mounted) return;
                            Navigator.pop(context); // Close dialog
                            _completeRegistration();
                          } on FirebaseAuthException catch (e) {
                            if (!context.mounted) return;
                            setDialogState(() {
                              isVerifying = false;
                              localError = e.message ?? 'Invalid OTP';
                            });
                          } catch (e) {
                            if (!context.mounted) return;
                            setDialogState(() {
                              isVerifying = false;
                              localError = 'Something went wrong';
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: MaherTheme.emeraldPrimary),
                  child: isVerifying
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Verify'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _completeRegistration() async {
    setState(() => _isLoading = true);

    final error = await AuthService.register(
      name: _nameController.text,
      identifier: _phoneController.text, // Passed as identifier
      password: _passwordController.text,
      ageGroup: _selectedAgeGroup,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalization.tr('login_success')),
          backgroundColor: MaherTheme.emeraldPrimary,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        switch (error) {
          case 'already_registered':
            _errorMessage = 'This mobile number is already registered. Please login.';
            break;
          case 'weak_password':
            _errorMessage = AppLocalization.tr('password_min_length');
            break;
          case 'network':
            _errorMessage = AppLocalization.tr('network_error');
            break;
          default:
            _errorMessage = 'Could not create your account. Please try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaherTheme.backgroundLight,
      appBar: AppBar(
        title: Text(AppLocalization.tr('register')),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: MaherTheme.emeraldPrimary.withValues(alpha: 0.1),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            MaherIcons.get('logo', size: 60),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalization.tr('register'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: MaherTheme.emeraldDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalization.tr('app_subtitle'),
                              style: const TextStyle(
                                fontSize: 13,
                                color: MaherTheme.textSecondaryLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: MaherTheme.errorRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
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
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Full Name
                      Text(
                        AppLocalization.tr('full_name'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Ali Raza',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: MaherIcons.get('user',
                                size: 20, color: MaherTheme.emeraldPrimary),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Mobile Number
                      Text(
                        AppLocalization.tr('mobile_number'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '9876543210',
                          prefixText: '+91 ',
                          prefixStyle: const TextStyle(
                            fontSize: 16,
                            color: MaherTheme.emeraldDark,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: MaherIcons.get('phone',
                                size: 20, color: MaherTheme.emeraldPrimary),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 10) {
                            return 'Please enter a valid mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Age Group / Syllabus Level
                      Text(
                        AppLocalization.tr('age_group'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAgeGroup,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: MaherIcons.get('book-quran',
                                size: 20, color: MaherTheme.emeraldPrimary),
                          ),
                        ),
                        items: _ageGroups.map((group) {
                          return DropdownMenuItem(
                            value: group,
                            child: Text(group,
                                style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedAgeGroup = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      Text(
                        AppLocalization.tr('password'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: MaherTheme.textSecondaryLight,
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
                          if (value != value.trim()) {
                            return 'Password cannot start or end with a space';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      Text(
                        AppLocalization.tr('confirm_password'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: MaherIcons.get('lock',
                                size: 20, color: MaherTheme.emeraldPrimary),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: MaherTheme.textSecondaryLight,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Register Button
                      GestureDetector(
                        onTap: _isLoading ? null : _handleRegister,
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
                                    MaherIcons.get('shield-check',
                                        size: 18, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalization.tr('register'),
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

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            AppLocalization.tr('already_have_account'),
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
    );
  }
}
