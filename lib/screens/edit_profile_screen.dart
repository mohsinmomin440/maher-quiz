import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/age_groups.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_localization.dart';
import '../utils/maher_icons.dart';
import '../utils/maher_theme.dart';
import '../widgets/change_password_sheet.dart';
import '../widgets/user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late String _selectedAgeGroup;
  late String _selectedAvatar;

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _ageGroups = AgeGroups.all;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _emailController = TextEditingController(text: widget.user.email);

    // Normalize legacy age group values to one of the valid options
    _selectedAgeGroup = AgeGroups.normalize(widget.user.ageGroup);

    _selectedAvatar = widget.user.avatar.startsWith('avatar_') ? '' : widget.user.avatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = base64Encode(bytes);
        if (!mounted) return;
        setState(() {
          _selectedAvatar = 'data:image/jpeg;base64,$base64String';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open gallery: $e'),
            backgroundColor: MaherTheme.errorRed,
          ),
        );
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedAvatar = '';
    });
  }

  void _openChangePassword() async {
    await ChangePasswordSheet.show(context, widget.user);
  }

  Future<void> _handleSave() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.updateProfile(
      userId: widget.user.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      ageGroup: _selectedAgeGroup,
      avatar: _selectedAvatar,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success && result.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              MaherIcons.get('check-circle', size: 20, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalization.tr('profile_updated_success'),
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
      Navigator.pop(context, result.user);
    } else {
      setState(() {
        if (result.errorMessage == 'mobile_already_registered') {
          _errorMessage = AppLocalization.tr('mobile_already_registered');
        } else if (result.errorMessage == 'email_already_registered') {
          _errorMessage = AppLocalization.tr('email_already_registered');
        } else {
          // Error codes (network_error, email_change_not_supported, ...) are
          // string keys; tr() returns plain messages unchanged
          _errorMessage =
              AppLocalization.tr(result.errorMessage ?? 'Failed to update profile');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaherTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: MaherIcons.get('arrow-left', size: 22, color: MaherTheme.emeraldDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalization.tr('edit_profile'),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: MaherTheme.emeraldDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: MaherTheme.emeraldPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                AppLocalization.tr('save_changes'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar Section Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: BorderSide(
                        color: MaherTheme.goldPrimary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          UserAvatar(
                            avatar: _selectedAvatar,
                            name: _nameController.text.isNotEmpty
                                ? _nameController.text
                                : widget.user.name,
                            size: 96,
                            borderWidth: 3,
                            showEditBadge: true,
                            onEditTap: _pickImageFromGallery,
                            onTap: _pickImageFromGallery,
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                icon: MaherIcons.get('camera',
                                    size: 16, color: Colors.white),
                                label: Text(
                                  AppLocalization.tr('choose_photo_gallery'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MaherTheme.emeraldPrimary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _pickImageFromGallery,
                              ),
                              if (_selectedAvatar.isNotEmpty)
                                OutlinedButton.icon(
                                  icon: MaherIcons.get('trash',
                                      size: 15, color: MaherTheme.errorRed),
                                  label: Text(
                                    AppLocalization.tr('remove_photo'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: MaherTheme.errorRed,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: MaherTheme.errorRed, width: 1.2),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _removePhoto,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Error banner
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: MaherTheme.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: MaherTheme.errorRed.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          MaherIcons.get('shield-alert',
                              size: 20, color: MaherTheme.errorRed),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: MaherTheme.errorRed,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Form Fields Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              MaherIcons.get('user',
                                  size: 20, color: MaherTheme.emeraldPrimary),
                              const SizedBox(width: 8),
                              const Text(
                                'Personal Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: MaherTheme.emeraldDark,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Full Name
                          Text(
                            AppLocalization.tr('full_name'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: MaherTheme.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: AppLocalization.tr('enter_name_hint'),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: MaherIcons.get('user',
                                    size: 20,
                                    color: MaherTheme.emeraldPrimary),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().length < 2) {
                                return AppLocalization.tr('name_required');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Mobile Number
                          Text(
                            AppLocalization.tr('mobile_number'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: MaherTheme.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: InputDecoration(
                              hintText: '10-digit mobile number',
                              prefixIcon: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    MaherIcons.get('phone',
                                        size: 18,
                                        color: MaherTheme.emeraldPrimary),
                                    const SizedBox(width: 6),
                                    const Text(
                                      '+91',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: MaherTheme.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      height: 18,
                                      width: 1,
                                      color: Colors.grey.shade300,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            validator: (val) {
                              final clean = val?.replaceAll(RegExp(r'\D'), '') ?? '';
                              if (clean.isNotEmpty && clean.length != 10) {
                                return 'Please enter a valid 10-digit mobile number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Email Address
                          Text(
                            AppLocalization.tr('email'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: MaherTheme.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'E.g. student@maher.app',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: MaherIcons.get('mail',
                                    size: 20,
                                    color: MaherTheme.emeraldPrimary),
                              ),
                            ),
                            validator: (val) {
                              if (val != null && val.trim().isNotEmpty) {
                                final clean = val.trim();
                                if (!clean.contains('@') || !clean.contains('.')) {
                                  return AppLocalization.tr('enter_valid_email');
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Deeniyat Age Group Dropdown
                          Text(
                            AppLocalization.tr('age_group'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: MaherTheme.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedAgeGroup,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: MaherIcons.get('student-cap',
                                    size: 20,
                                    color: MaherTheme.emeraldPrimary),
                              ),
                            ),
                            items: _ageGroups.map((group) {
                              return DropdownMenuItem<String>(
                                value: group,
                                child: Text(
                                  group,
                                  style: const TextStyle(fontSize: 14),
                                ),
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Security & Password Card (Only for non-Google accounts)
                  if (widget.user.authSource != 'google') ...[
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: MaherTheme.goldDark.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: MaherTheme.goldLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: MaherIcons.get('key',
                              size: 22, color: MaherTheme.goldDark),
                        ),
                        title: Text(
                          AppLocalization.tr('change_password_title'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: MaherTheme.emeraldDark,
                          ),
                        ),
                        subtitle: Text(
                          AppLocalization.tr('change_password_subtitle'),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MaherTheme.goldPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _openChangePassword,
                          child: const Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Account Metadata (Read-only)
                  Card(
                    color: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              MaherIcons.get('shield-check',
                                  size: 18, color: MaherTheme.successGreen),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account ID: ${widget.user.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Role: ${widget.user.isAdmin ? "Administrator" : "Student"} • Status: Active',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: MaherTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: MaherTheme.successGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'VERIFIED',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: MaherTheme.successGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Profile Changes Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MaherTheme.emeraldPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MaherIcons.get('check-circle',
                                  size: 20, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                AppLocalization.tr('save_changes'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
