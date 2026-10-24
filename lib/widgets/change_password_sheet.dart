import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_localization.dart';
import '../utils/maher_icons.dart';
import '../utils/maher_theme.dart';

class ChangePasswordSheet extends StatefulWidget {
  final UserModel user;
  // Forced mode (temporary/default password): the sheet can't be dismissed
  // until a new password is set.
  final bool forced;

  const ChangePasswordSheet({
    super.key,
    required this.user,
    this.forced = false,
  });

  static Future<bool?> show(BuildContext context, UserModel user,
      {bool forced = false}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: !forced,
      enableDrag: !forced,
      backgroundColor: Colors.transparent,
      builder: (context) => PopScope(
        canPop: !forced,
        child: ChangePasswordSheet(user: user, forced: forced),
      ),
    );
  }

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int _calculateStrength(String pass) {
    if (pass.isEmpty) return 0;
    if (pass.length < 6) return 1;
    bool hasLetter = pass.contains(RegExp(r'[a-zA-Z]'));
    bool hasDigit = pass.contains(RegExp(r'[0-9]'));
    bool hasSpecial = pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    if (pass.length >= 8 && hasLetter && (hasDigit || hasSpecial)) {
      return 3;
    }
    return 2;
  }

  Future<void> _handleSubmit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = AppLocalization.tr('passwords_not_match');
      });
      return;
    }

    if (_currentPasswordController.text == _newPasswordController.text) {
      setState(() {
        _errorMessage = 'New password cannot be the same as current password';
      });
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.changePassword(
      userId: widget.user.id,
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              MaherIcons.get('check-circle', size: 20, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalization.tr('password_updated_success'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: MaherTheme.emeraldPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      setState(() {
        if (result.errorMessage == 'wrong_current_password') {
          _errorMessage = AppLocalization.tr('wrong_current_password');
        } else if (result.errorMessage == 'password_min_length') {
          _errorMessage = AppLocalization.tr('password_min_length');
        } else {
          _errorMessage =
              AppLocalization.tr(result.errorMessage ?? 'Failed to update password');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final strength = _calculateStrength(_newPasswordController.text);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        margin: const EdgeInsets.only(top: 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: MaherTheme.goldLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: MaherTheme.goldPrimary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: MaherIcons.get('key',
                          size: 26, color: MaherTheme.goldDark),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalization.tr('change_password_title'),
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: MaherTheme.emeraldDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.forced
                                ? 'You are using a temporary or default password. Set a new password to continue.'
                                : AppLocalization.tr('change_password_subtitle'),
                            style: TextStyle(
                              fontSize: 12,
                              color: MaherTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.forced)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                  ],
                ),
                const SizedBox(height: 18),

                // Error message banner
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: MaherTheme.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: MaherTheme.errorRed.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        MaherIcons.get('shield-alert',
                            size: 18, color: MaherTheme.errorRed),
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
                  const SizedBox(height: 14),
                ],

                // Current Password Field
                Text(
                  AppLocalization.tr('current_password'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: MaherTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrent,
                  decoration: InputDecoration(
                    hintText: AppLocalization.tr('enter_current_password'),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: MaherIcons.get('lock',
                          size: 20, color: MaherTheme.emeraldPrimary),
                    ),
                    suffixIcon: IconButton(
                      icon: MaherIcons.get(
                        _obscureCurrent ? 'eye' : 'eye-off',
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // New Password Field
                Text(
                  AppLocalization.tr('new_password'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: MaherTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Enter at least 6 characters',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: MaherIcons.get('key',
                          size: 20, color: MaherTheme.goldDark),
                    ),
                    suffixIcon: IconButton(
                      icon: MaherIcons.get(
                        _obscureNew ? 'eye' : 'eye-off',
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.length < 6) {
                      return AppLocalization.tr('password_min_length');
                    }
                    if (val != val.trim()) {
                      return 'Password cannot start or end with a space';
                    }
                    return null;
                  },
                ),

                // Password strength meter
                if (_newPasswordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: strength >= 1
                                ? (strength == 1
                                    ? Colors.red
                                    : (strength == 2
                                        ? Colors.orange
                                        : Colors.green))
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: strength >= 2
                                ? (strength == 2 ? Colors.orange : Colors.green)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: strength >= 3
                                ? Colors.green
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        strength == 1
                            ? 'Weak'
                            : (strength == 2 ? 'Good' : 'Strong'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: strength == 1
                              ? Colors.red
                              : (strength == 2 ? Colors.orange : Colors.green),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Confirm New Password Field
                Text(
                  AppLocalization.tr('confirm_password'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: MaherTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Re-enter your new password',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: MaherIcons.get('shield-check',
                          size: 20, color: MaherTheme.emeraldPrimary),
                    ),
                    suffixIcon: IconButton(
                      icon: MaherIcons.get(
                        _obscureConfirm ? 'eye' : 'eye-off',
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (val != _newPasswordController.text) {
                      return AppLocalization.tr('passwords_not_match');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    if (!widget.forced) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(AppLocalization.tr('cancel')),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MaherTheme.emeraldPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MaherIcons.get('key',
                                      size: 18, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalization.tr('save_changes'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
