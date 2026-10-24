import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/age_groups.dart';
import '../../services/auth_service.dart';
import '../../utils/app_localization.dart';
import '../../utils/maher_icons.dart';
import '../../utils/maher_theme.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  String _selectedAgeGroup = AgeGroups.defaultGroup;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // OTP verification state
  String? _verificationId;
  bool _isOtpSent = false;
  bool _isOtpVerifying = false;
  String? _otpError;

  final List<String> _ageGroups = AgeGroups.all;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Sends a 6-digit OTP to the phone number via Firebase
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    var phone = _phoneController.text.trim();
    if (!phone.startsWith('+')) {
      if (phone.length == 10) {
        phone = '+91$phone';
      } else {
        phone = '+$phone';
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _otpError = null;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification on some Android devices — proceed directly
          _verifyWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _errorMessage = e.message ?? 'Verification failed';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _isOtpSent = true;
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Keep the verificationId for manual entry fallback
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not connect to SMS service.';
      });
    }
  }

  /// Verifies the OTP and creates the account
  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() => _otpError = 'Please enter the 6-digit code');
      return;
    }

    setState(() {
      _isOtpVerifying = true;
      _otpError = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await _verifyWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isOtpVerifying = false;
        _otpError = e.message ?? 'Invalid OTP';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isOtpVerifying = false;
        _otpError = 'Verification failed. Please try again.';
      });
    }
  }

  /// Handles successful verification — completes registration
  Future<void> _verifyWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user == null) {
        if (!mounted) return;
        setState(() {
          _isOtpVerifying = false;
          _errorMessage = 'Verification failed.';
        });
        return;
      }

      // Firebase sign-in succeeded, now create/update local account
      if (!mounted) return;
      setState(() => _isOtpVerifying = false);
      await _completeRegistration(userCredential.user!.phoneNumber ?? '');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isOtpVerifying = false;
        _errorMessage = 'Verification error. Please try again.';
      });
    }
  }

  /// Creates the local account after successful Firebase verification
  Future<void> _completeRegistration(String verifiedPhone) async {
    setState(() => _isLoading = true);

    // Use the verified phone as identifier
    final identifier = verifiedPhone.isEmpty
        ? _phoneController.text.trim()
        : verifiedPhone;

    final error = await AuthService.register(
      name: _nameController.text,
      identifier: identifier,
      password: _passwordController.text,
      ageGroup: _selectedAgeGroup,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isOtpSent = false;
    });

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
            _errorMessage =
                'This mobile number is already registered. Please login.';
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

                      // Error Banner
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

                      // Mobile Number (shown before OTP is sent)
                      if (!_isOtpSent) ...[
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
                      ],

                      // Age Group
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

                      // OTP Section (shown after sending OTP)
                      if (_isOtpSent) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Enter 6-digit OTP sent to your mobile',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: MaherTheme.emeraldDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_otpError != null) ...[
                          Text(
                            _otpError!,
                            style:
                                const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                        ],
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          style: const TextStyle(
                              fontSize: 24, letterSpacing: 5),
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Action Button
                      if (!_isOtpSent)
                        // "Send OTP" button
                        GestureDetector(
                          onTap: _isLoading ? null : _sendOtp,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: MaherTheme.emeraldPrimary,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: MaherTheme.emeraldDark, width: 2),
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
                                        valueColor: AlwaysStoppedAnimation<
                                            Color>(Colors.white),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      MaherIcons.get('shield-check',
                                          size: 18, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Send OTP & Register',
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
                        )
                      else
                        // "Verify OTP & Register" button
                        GestureDetector(
                          onTap: _isOtpVerifying ? null : _verifyOtp,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: MaherTheme.emeraldPrimary,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: MaherTheme.emeraldDark, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: MaherTheme.emeraldDark,
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: _isOtpVerifying
                                ? const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<
                                            Color>(Colors.white),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      MaherIcons.get('check-circle',
                                          size: 18, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Verify OTP & Register',
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

                      // Resend OTP link
                      if (_isOtpSent) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _isOtpSent = false;
                                      _otpError = null;
                                      _otpController.clear();
                                    });
                                    _sendOtp();
                                  },
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(
                                color: MaherTheme.emeraldPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            AppLocalization
                                .tr('already_have_account'),
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
