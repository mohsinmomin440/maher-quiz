import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/cloud_service.dart';
import '../../utils/app_localization.dart';
import '../../utils/maher_icons.dart';
import '../../utils/maher_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _identifierController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _codeSent = false;
  bool _codeVerified = false; // non-final: set to true after OTP success
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _verificationId;

  /// In cloud mode we use email; in local mode we use phone.
  bool get _isCloud => CloudService.isEnabled;

  @override
  void dispose() {
    _identifierController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  /// Sends a reset code (email in cloud mode, SMS OTP in local mode)
  Future<void> _sendCode() async {
    final input = _identifierController.text.trim();
    if (input.isEmpty) {
      setState(() => _errorMessage = _isCloud
          ? 'Please enter a valid email address'
          : 'Please enter a valid mobile number');
      return;
    }
    if (_isCloud && (!input.contains('@') || !input.contains('.'))) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }
    if (!_isCloud && input.length < 10) {
      setState(() => _errorMessage = 'Please enter a valid mobile number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isCloud) {
        // Cloud mode: send Supabase password reset email
        final email = input.toLowerCase();
        final ok = await CloudService.sendPasswordResetCode(email);
        if (!mounted) return;
        if (ok) {
          setState(() {
            _isLoading = false;
            _codeSent = true;
            _verificationId = 'supabase'; // marker
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to send reset code. Check your internet connection.';
          });
        }
      } else {
        // Local mode: send Firebase SMS OTP
        var phone = input;
        if (!phone.startsWith('+')) {
          if (phone.length == 10) {
            phone = '+91$phone';
          } else {
            phone = '+$phone';
          }
        }

        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          verificationCompleted: (PhoneAuthCredential credential) {
            _verifyWithCredential(credential, phone);
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
              _codeSent = true;
              _verificationId = verificationId;
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  /// Verifies the entered code.
  /// Local mode: verifies Firebase OTP. Cloud mode: just accepts the code
  /// (actual verification happens in _resetPassword via Supabase).
  Future<void> _verifyOtp() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter the 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isCloud) {
        // Cloud mode: don't verify here; just proceed to password entry.
        // The Supabase reset will verify the code when we call resetPasswordWithCode.
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _codeVerified = true;
          _errorMessage = null;
        });
      } else {
        // Local mode: verify Firebase OTP
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: code,
        );
        await _verifyWithCredential(credential, _identifierController.text.trim());
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? 'Invalid OTP';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Something went wrong';
      });
    }
  }

  /// Verifies Firebase credential and proceeds to password entry (local mode only)
  Future<void> _verifyWithCredential(
      PhoneAuthCredential credential, String phone) async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;

      // Firebase auth successful — move to the "set new password" screen.
      // Do NOT reset the password here; wait for the user to enter a new one.
      setState(() {
        _isLoading = false;
        _codeVerified = true;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Verification failed. Please try again.';
      });
    }
  }

  /// Reset password after OTP verification
  Future<void> _resetPassword() async {
    final newPass = _newPasswordController.text;
    if (newPass.length < 6) {
      setState(() => _errorMessage = AppLocalization.tr('password_min_length'));
      return;
    }
    if (newPass != newPass.trim()) {
      setState(() => _errorMessage = 'Password cannot start or end with a space');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final identifier = _identifierController.text.trim();

    // Cloud mode: reset via Supabase (verifies code + sets password)
    // Local mode: reset via local DB (phone + new password)
    bool success;
    if (_isCloud) {
      final email = identifier.toLowerCase();
      success = await CloudService.resetPasswordWithCode(
        email: email,
        code: _codeController.text.trim(),
        newPassword: newPass,
      );
    } else {
      // Local mode: use the normalized phone
      final phone = AuthService.normalizePhone(identifier);
      success = await AuthService.adminResetPassword(phone, newPass);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalization.tr('password_reset_success')),
          backgroundColor: MaherTheme.emeraldPrimary,
        ),
      );
      Navigator.pop(context);
    } else {
      setState(() =>
          _errorMessage = 'Failed to reset password. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaherTheme.backgroundLight,
      appBar: AppBar(
        title: Text(AppLocalization.tr('reset_password')),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: MaherTheme.emeraldPrimary.withValues(alpha: 0.1),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          MaherIcons.get('shield-check',
                              size: 56, color: MaherTheme.emeraldPrimary),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalization.tr('reset_password'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: MaherTheme.emeraldDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _codeVerified
                                ? AppLocalization.tr('new_password')
                                : _codeSent
                                    ? (_isCloud
                                        ? 'Enter the code sent to your email'
                                        : 'Enter the OTP sent via SMS')
                                    : (_isCloud
                                        ? 'We will send a 6-digit code to your email'
                                        : 'We will send a 6-digit OTP to verify'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: MaherTheme.textSecondaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null) ...[
                      _buildError(_errorMessage!),
                      const SizedBox(height: 16),
                    ],
                    ..._buildForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildForm() {
    return [
      TextField(
        controller: _identifierController,
        enabled: !_codeSent,
        keyboardType: _isCloud ? TextInputType.emailAddress : TextInputType.phone,
        decoration: InputDecoration(
          labelText: _isCloud ? AppLocalization.tr('email') : AppLocalization.tr('mobile_number'),
          hintText: _isCloud ? 'student@maher.app' : '9876543210',
          prefixText: _isCloud ? null : '+91 ',
          prefixStyle: const TextStyle(
            fontSize: 16,
            color: MaherTheme.emeraldDark,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: MaherIcons.get(_isCloud ? 'mail' : 'phone',
                size: 20, color: MaherTheme.emeraldPrimary),
          ),
        ),
      ),
      const SizedBox(height: 16),
      if (_codeSent && !_codeVerified) ...[
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: AppLocalization.tr('enter_otp'),
            counterText: '',
          ),
        ),
        const SizedBox(height: 16),
      ],
      if (_codeVerified) ...[
        TextField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: AppLocalization.tr('new_password'),
            suffixIcon: IconButton(
              icon: MaherIcons.get(_obscurePassword ? 'eye-off' : 'eye',
                  size: 20, color: Colors.grey.shade600),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
      ElevatedButton(
        onPressed: _isLoading
            ? null
            : (_codeVerified
                ? _resetPassword
                : (_codeSent ? _verifyOtp : _sendCode)),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(_codeVerified
                ? AppLocalization.tr('verify_and_update')
                : (_codeSent ? 'Verify Code' : AppLocalization.tr('send_otp'))),
      ),
      if (_codeSent && !_codeVerified)
        TextButton(
          onPressed: _isLoading
              ? null
              : () => setState(() {
                    _codeSent = false;
                    _errorMessage = null;
                    _codeController.clear();
                  }),
          child: Text(_isCloud ? 'Use a different email' : AppLocalization.tr('change_number')),
        ),
    ];
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MaherTheme.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: MaherTheme.errorRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          MaherIcons.get('cross-circle',
              size: 20, color: MaherTheme.errorRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style:
                  const TextStyle(color: MaherTheme.errorRed, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}