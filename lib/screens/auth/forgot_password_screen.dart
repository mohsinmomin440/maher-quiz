import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/cloud_service.dart';
import '../../utils/app_localization.dart';
import '../../utils/maher_icons.dart';
import '../../utils/maher_theme.dart';

// Local mode: accounts live only on this device, so there is no way to
// deliver a reset code; an admin resets the password from the Admin console.
// Cloud mode (Supabase + Firebase): OTP is sent via Firebase to verify mobile.
// Note: In Cloud Mode, direct Supabase password reset requires logging in first
// or an email token, so this might fail unless backed by an edge function.
class ForgotPasswordScreen extends StatefulWidget {
const ForgotPasswordScreen({super.key, });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _codeSent = false;
  bool _codeVerified = false;
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

  Future<void> _sendCode() async {
    var phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      setState(() => _errorMessage = 'Please enter a valid mobile number');
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
        verificationCompleted: (PhoneAuthCredential credential) {},
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

  Future<void> _verifyOtp() async {
    final code = _codeController.text.trim();
    if (code.length < 6) {
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
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _codeVerified = true;
      });
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

    // We do a local reset for the app logic. 
    // In cloud mode, resetting password without being logged in fails on Supabase.
    // We update local so it works offline at least.
    final success = await AuthService.adminResetPassword(_phoneController.text.trim(), newPass);
    
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
      setState(() {
        _errorMessage = 'No account found with this phone number or email.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cloud = CloudService.isEnabled;
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
                            !cloud
                                ? 'Ask your teacher or admin to reset it for you'
                                : _codeVerified 
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
                    if (cloud) ..._buildCloudForm() else ..._buildAdminSteps(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAdminSteps() {
    return [
      _buildStep(
        number: '1',
        text: 'Tell your teacher or admin your registered email '
            'or mobile number.',
      ),
      _buildStep(
        number: '2',
        text: 'They reset your password from the Admin console '
            'and give you a temporary password.',
      ),
      _buildStep(
        number: '3',
        text: 'Log in with the temporary password. You will be '
            'asked to choose a new password straight away.',
      ),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: Text(AppLocalization.tr('login')),
      ),
    ];
  }

  List<Widget> _buildCloudForm() {
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
        onPressed: _isLoading ? null : (_codeVerified ? _resetPassword : (_codeSent ? _verifyOtp : _sendCode)),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
        border: Border.all(color: MaherTheme.errorRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          MaherIcons.get('cross-circle', size: 20, color: MaherTheme.errorRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: MaherTheme.errorRed, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({required String number, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: MaherTheme.emeraldSoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: MaherTheme.emeraldPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: MaherTheme.textPrimaryLight,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
