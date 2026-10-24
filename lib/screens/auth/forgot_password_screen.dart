import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_localization.dart';
import '../../utils/maher_icons.dart';
import '../../utils/maher_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _codeSent = false;
  final bool _codeVerified = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  /// Sends a 6-digit OTP to the phone number
  Future<void> _sendCode() async {
    var phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      setState(() =>
          _errorMessage = 'Please enter a valid mobile number');
      return;
    }
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
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification: proceed to reset
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  /// Verifies OTP and proceeds to password reset
  Future<void> _verifyWithCredential(
      PhoneAuthCredential credential, String phone) async {
    setState(() => _isLoading = true);
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted || userCredential.user == null) return;

      // Firebase auth successful — now reset the password locally
      final success =
          await AuthService.adminResetPassword(phone, _newPasswordController.text);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalization.tr('password_reset_success')),
            backgroundColor: MaherTheme.emeraldPrimary,
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() => _errorMessage =
            'No account found with this mobile number.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() =>
          _errorMessage = 'Verification failed. Please try again.');
    }
  }

  /// Manual OTP verification (user enters the code)
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
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await _verifyWithCredential(
          credential, _phoneController.text.trim());
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

  /// Reset password after OTP verification (local mode)
  Future<void> _resetPassword() async {
    final newPass = _newPasswordController.text;
    if (newPass.length < 6) {
      setState(
          () => _errorMessage = AppLocalization.tr('password_min_length'));
      return;
    }
    if (newPass != newPass.trim()) {
      setState(
          () => _errorMessage = 'Password cannot start or end with a space');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AuthService.adminResetPassword(
        _phoneController.text.trim(), newPass);

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
          _errorMessage = 'No account found with this mobile number.');
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
                                ? 'Set your new password'
                                : _codeSent
                                    ? 'Enter the OTP sent via SMS'
                                    : 'We will send a 6-digit OTP to verify',
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
        controller: _phoneController,
        enabled: !_codeSent,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: AppLocalization.tr('mobile_number'),
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
      ),
      const SizedBox(height: 16),
      if (_codeSent && !_codeVerified) ...[
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: '6-digit code',
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
                : (_codeSent ? 'Verify OTP' : AppLocalization.tr('send_otp'))),
      ),
      if (_codeSent && !_codeVerified)
        TextButton(
          onPressed: _isLoading
              ? null
              : () => setState(() {
                    _codeSent = false;
                    _errorMessage = null;
                  }),
          child: const Text('Use a different mobile number'),
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
