import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/badge_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/badge_service.dart';
import '../services/cloud_service.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';
import '../utils/app_localization.dart';
import '../utils/maher_icons.dart';
import '../utils/maher_theme.dart';
import '../widgets/change_password_sheet.dart';
import '../widgets/user_avatar.dart';
import 'admin/admin_dashboard_screen.dart';
import 'auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'saved_questions_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
final bool isTab;
  final Function(UserModel)? onUserUpdated;

  const ProfileScreen({
    super.key,
    required this.user,
    this.isTab = false,
    this.onUserUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel _user;
  List<BadgeModel> _badges = [];
  bool _isSoundEnabled = true;
  bool _isNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadProfileData();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      setState(() {
        _user = widget.user;
      });
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    final badges = await BadgeService.getUserBadges(_user);
    final sound = await SoundService.isEnabled();
    final notifs = await NotificationService.isNotificationsEnabled();
    if (mounted) {
      setState(() {
        _badges = badges;
        _isSoundEnabled = sound;
        _isNotificationsEnabled = notifs;
      });
    }
  }

  Future<void> _toggleSound(bool val) async {
    await SoundService.setEnabled(val);
    if (!mounted) return;
    setState(() {
      _isSoundEnabled = val;
    });
  }

  Future<void> _toggleNotifications(bool val) async {
    await NotificationService.setNotificationsEnabled(val);
    if (!mounted) return;
    setState(() {
      _isNotificationsEnabled = val;
    });
  }

  Future<void> _navigateToEditProfile() async {
    final updated = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: _user),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _user = updated;
      });
      widget.onUserUpdated?.call(updated);
      _loadProfileData();
    }
  }

  // Links a guest profile to a real Google account so scores, bookmarks and
  // the daily streak survive the upgrade. In offline mode this creates a
  // local account and migrates the guest's data onto it.
  Future<void> _connectGuestToAccount() async {
    final result = await CloudService.signInWithGoogle();
    if (!mounted) return;

    if (result.user != null) {
      final u = result.user!;
      final upgraded = u.copyWith(
        name: u.name.trim().isNotEmpty ? u.name : _user.name,
        avatar: _user.avatar,
      );
      await AuthService.cacheCloudUser(upgraded);
      if (!mounted) return;
      setState(() {
        _user = upgraded;
      });
      widget.onUserUpdated?.call(upgraded);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account connected! Your scores are saved.'),
          backgroundColor: MaherTheme.emeraldPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Sign-in failed or was cancelled: offer the normal login screen.
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    if (ok == true && mounted) {
      final fresh = await AuthService.getCurrentUser();
      if (fresh != null) {
        setState(() => _user = fresh);
        widget.onUserUpdated?.call(fresh);
      }
    }
  }

  Future<void> _showPhotoOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalization.tr('change_photo'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MaherTheme.emeraldDark,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: MaherTheme.emeraldSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MaherIcons.get('camera',
                      size: 20, color: MaherTheme.emeraldPrimary),
                ),
                title: Text(
                  AppLocalization.tr('choose_photo_gallery'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImageFromGallery();
                },
              ),
              if (_user.avatar.isNotEmpty) ...[
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: MaherTheme.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MaherIcons.get('trash',
                        size: 20, color: MaherTheme.errorRed),
                  ),
                  title: Text(
                    AppLocalization.tr('remove_photo'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: MaherTheme.errorRed),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _removePhoto();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        final result = await AuthService.updateProfile(
          userId: _user.id,
          name: _user.name,
          phone: _user.phone,
          email: _user.email,
          ageGroup: _user.ageGroup,
          avatar: base64String,
        );

        if (result.success && result.user != null && mounted) {
          setState(() {
            _user = result.user!;
          });
          widget.onUserUpdated?.call(result.user!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalization.tr('photo_updated')),
              backgroundColor: MaherTheme.emeraldPrimary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image: $e'),
            backgroundColor: MaherTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _removePhoto() async {
    final result = await AuthService.updateProfile(
      userId: _user.id,
      name: _user.name,
      phone: _user.phone,
      email: _user.email,
      ageGroup: _user.ageGroup,
      avatar: '',
    );

    if (result.success && result.user != null && mounted) {
      setState(() {
        _user = result.user!;
      });
      widget.onUserUpdated?.call(result.user!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalization.tr('photo_updated')),
          backgroundColor: MaherTheme.emeraldPrimary,
        ),
      );
    }
  }

  Future<void> _openChangePassword() async {
    await ChangePasswordSheet.show(context, _user);
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, size: 26, color: MaherTheme.errorRed),
            const SizedBox(width: 10),
            Text(
              AppLocalization.tr('delete_account_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          AppLocalization.tr('delete_account_confirm'),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalization.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MaherTheme.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalization.tr('yes_delete')),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // Show loading overlay to prevent double-tap
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final result = await AuthService.deleteCurrentAccount();

    if (!mounted) return;
    Navigator.pop(context); // dismiss loader

    switch (result) {
      case DeleteResult.success:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        break;
      case DeleteResult.needsRelogin:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalization.tr('delete_needs_relogin')),
            backgroundColor: MaherTheme.errorRed,
          ),
        );
        break;
      case DeleteResult.serverFailed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalization.tr('delete_server_failed')),
            backgroundColor: MaherTheme.errorRed,
          ),
        );
        break;
      case DeleteResult.notSignedIn:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalization.tr('you_are_not_logged_in')),
            backgroundColor: MaherTheme.errorRed,
          ),
        );
        break;
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MaherTheme.errorRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: MaherIcons.get('logout', size: 22, color: MaherTheme.errorRed),
            ),
            const SizedBox(width: 12),
            Text(AppLocalization.tr('logout')),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of Maher Quiz on this device?',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalization.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MaherTheme.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalization.tr('logout')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LoginScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaherTheme.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isTab,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MaherTheme.emeraldSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: MaherIcons.get('user', size: 20, color: MaherTheme.emeraldPrimary),
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalization.tr('nav_profile'),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: MaherTheme.emeraldDark,
              ),
            ),
          ],
        ),
        actions: [
          // Edit Profile action button in App Bar
          TextButton.icon(
            icon: MaherIcons.get('pencil', size: 14, color: MaherTheme.emeraldPrimary),
            label: Text(
              AppLocalization.tr('edit_profile'),
              style: const TextStyle(
                color: MaherTheme.emeraldPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            onPressed: _navigateToEditProfile,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Luxury Arched Hero Profile Card
                _buildHeroProfileHeader(),
                const SizedBox(height: 18),

                // Guest Account Upgrade Banner
                if (_user.isGuest) ...[
                  _buildGuestUpgradeBanner(),
                  const SizedBox(height: 18),
                ],

                // Gamified 3-Metric Stats Bento
                _buildGamifiedStatsBento(),
                const SizedBox(height: 20),

                // Grouped Inset Section: Account Details
                _buildSectionHeader('ACCOUNT & IDENTITY'),
                const SizedBox(height: 8),
                _buildAccountDetailsCard(),
                const SizedBox(height: 20),

                // Grouped Inset Section: Security & Credentials (Only for local password accounts)
                if (_user.authSource == 'local') ...[
                  _buildSectionHeader('SECURITY'),
                  const SizedBox(height: 8),
                  _buildSecurityCard(),
                  const SizedBox(height: 20),
                ],

                // Grouped Inset Section: Preferences & Bookmarks
                _buildSectionHeader('PREFERENCES & TOOLS'),
                const SizedBox(height: 8),
                _buildPreferencesCard(),
                const SizedBox(height: 20),

                // Grouped Inset Section: Islamic Badges & Honors
                _buildSectionHeader('ISLAMIC BADGES & ACHIEVEMENTS'),
                const SizedBox(height: 8),
                ..._badges.map((b) => _buildBadgeTile(b)),
                const SizedBox(height: 16),

                // Admin Console (if user is admin)
                if (_user.isAdmin) ...[
                  _buildAdminConsoleCard(),
                  const SizedBox(height: 20),
                ],

                // Sign Out Button
                OutlinedButton.icon(
                  icon: MaherIcons.get('logout', size: 18, color: MaherTheme.errorRed),
                  label: Text(
                    AppLocalization.tr('logout'),
                    style: const TextStyle(
                      color: MaherTheme.errorRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: MaherTheme.errorRed, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _handleLogout,
                ),
                const SizedBox(height: 12),

                // Privacy Policy Link (Google Play Families & DPDP Compliance)
                TextButton.icon(
                  icon: const Icon(Icons.privacy_tip_outlined, size: 17, color: MaherTheme.emeraldMedium),
                  label: const Text(
                    'Privacy Policy & Child Safety',
                    style: TextStyle(
                      color: MaherTheme.emeraldMedium,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: _showPrivacyPolicyModal,
                ),
                const SizedBox(height: 4),

                // In-App Account Deletion (Store Compliance & DPDP Privacy)
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 17, color: MaherTheme.textMuted),
                  label: const Text(
                    'Delete Account Permanently',
                    style: TextStyle(
                      color: MaherTheme.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _handleDeleteAccount,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: MaherTheme.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // Luxury Arched Hero Profile Header
  Widget _buildHeroProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF045D48),
            Color(0xFF023226),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: MaherTheme.emeraldDark.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: MaherTheme.goldPrimary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Background subtle crescent watermark
          Positioned(
            right: -24,
            top: -24,
            child: Opacity(
              opacity: 0.08,
              child: MaherIcons.get('crescent-star', size: 150, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar with Camera Badge
                UserAvatar(
                  avatar: _user.avatar,
                  name: _user.name,
                  size: 92,
                  borderWidth: 3.2,
                  borderColor: MaherTheme.goldPrimary,
                  showEditBadge: true,
                  onEditTap: _showPhotoOptions,
                  onTap: _showPhotoOptions,
                ),
                const SizedBox(height: 14),

                // Name with Verified check
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        _user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 6),
                    MaherIcons.get('badge-verified',
                        size: 18, color: MaherTheme.goldLight),
                  ],
                ),
                const SizedBox(height: 4),

                // Phone or Email
                Text(
                  _user.phone.isNotEmpty
                      ? '+91 ${_user.phone}'
                      : (_user.email.isNotEmpty ? _user.email : _user.id),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),

                // Role and Edit Profile Pill Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _user.isAdmin
                            ? MaherTheme.goldDark.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _user.isAdmin
                              ? MaherTheme.goldLight
                              : Colors.white.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MaherIcons.get(
                            _user.isAdmin ? 'admin-crown' : 'student-cap',
                            size: 15,
                            color: _user.isAdmin
                                ? MaherTheme.goldLight
                                : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _user.isAdmin ? 'Administrator' : 'Student',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _user.isAdmin
                                  ? MaherTheme.goldLight
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Edit Profile Button
                    ElevatedButton.icon(
                      icon: MaherIcons.get('pencil',
                          size: 13, color: MaherTheme.emeraldDark),
                      label: Text(
                        AppLocalization.tr('edit_profile'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: MaherTheme.emeraldDark,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MaherTheme.goldLight,
                        foregroundColor: MaherTheme.emeraldDark,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _navigateToEditProfile,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gamified 3-Metric Stats Bento
  Widget _buildGamifiedStatsBento() {
    return Row(
      children: [
        // Streak Card
        Expanded(
          child: _buildBentoStatItem(
            icon: 'flame-streak',
            iconColor: MaherTheme.goldDark,
            title: '${_user.effectiveStreak}',
            unit: AppLocalization.tr('days'),
            label: AppLocalization.tr('streak'),
            cardBorder: MaherTheme.goldPrimary.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(width: 10),

        // Score Card
        Expanded(
          child: _buildBentoStatItem(
            icon: 'trophy',
            iconColor: MaherTheme.goldPrimary,
            title: '${_user.totalScore}',
            unit: 'pts',
            label: AppLocalization.tr('your_score'),
            cardBorder: MaherTheme.emeraldPrimary.withValues(alpha: 0.25),
          ),
        ),
        const SizedBox(width: 10),

        // Quizzes Completed
        Expanded(
          child: _buildBentoStatItem(
            icon: 'check-circle',
            iconColor: MaherTheme.successGreen,
            title: '${_user.quizzesCompleted}',
            unit: 'done',
            label: AppLocalization.tr('total_quizzes'),
            cardBorder: MaherTheme.successGreen.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoStatItem({
    required String icon,
    required Color iconColor,
    required String title,
    required String unit,
    required String label,
    required Color cardBorder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: MaherTheme.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: MaherIcons.get(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: MaherTheme.emeraldDark,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: MaherTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: MaherTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Guest Account Upgrade Banner
  Widget _buildGuestUpgradeBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MaherTheme.goldLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MaherTheme.goldDark.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: MaherIcons.get('guest', size: 24, color: MaherTheme.goldDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalization.tr('guest_welcome'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: MaherTheme.goldDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppLocalization.tr('guest_account_notice'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87.withValues(alpha: 0.75),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MaherTheme.emeraldPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            // Real Google sign-in links the guest profile to a Supabase account (or a
            // local one when offline), so scores and bookmarks survive the
            // upgrade instead of being left behind on the guest profile.
            onPressed: _connectGuestToAccount,
            child: Text(
              AppLocalization.tr('connect_account'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Account Details Grouped Card
  Widget _buildAccountDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100, width: 1.2),
        boxShadow: MaherTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildInsetTile(
              iconKey: 'shield-check',
              iconBg: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
              label: 'Member ID',
              value: _user.id,
            ),
            _buildDivider(),
            _buildInsetTile(
              iconKey: 'phone',
              iconBg: MaherTheme.emeraldSoft,
              iconColor: MaherTheme.emeraldPrimary,
              label: AppLocalization.tr('mobile_number'),
              value: _user.phone.isNotEmpty ? '+91 ${_user.phone}' : 'Not configured',
            ),
            _buildDivider(),
            _buildInsetTile(
              iconKey: 'mail',
              iconBg: MaherTheme.goldLight.withValues(alpha: 0.35),
              iconColor: MaherTheme.goldDark,
              label: AppLocalization.tr('email'),
              value: _user.email.isNotEmpty ? _user.email : 'Not configured',
            ),
            _buildDivider(),
            _buildInsetTile(
              iconKey: 'student-cap',
              iconBg: const Color(0xFFF3E8FF),
              iconColor: const Color(0xFF7C3AED),
              label: AppLocalization.tr('age_group'),
              value: _user.ageGroup,
            ),
            _buildDivider(),
            _buildInsetTile(
              iconKey: 'timer-clock',
              iconBg: Colors.grey.shade100,
              iconColor: Colors.grey.shade700,
              label: AppLocalization.tr('member_since'),
              value: _user.createdAt,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }

  Widget _buildInsetTile({
    required String iconKey,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: MaherIcons.get(iconKey, size: 18, color: iconColor),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: MaherTheme.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: MaherTheme.textPrimaryLight,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Security & Credentials Card
  Widget _buildSecurityCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: MaherTheme.goldPrimary.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: MaherTheme.softShadow,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: MaherTheme.goldLight.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: MaherIcons.get('key', size: 20, color: MaherTheme.goldDark),
          ),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
    );
  }

  // Preferences & Tools Card
  Widget _buildPreferencesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100, width: 1.2),
        boxShadow: MaherTheme.softShadow,
      ),
      child: Column(
        children: [
          // Sound Effects
          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            secondary: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: MaherTheme.emeraldSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                color: MaherTheme.emeraldPrimary,
                size: 20,
              ),
            ),
            title: const Text(
              'Sound Effects',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
            subtitle: Text(
              _isSoundEnabled ? 'Audio feedback enabled' : 'Sound muted',
              style: const TextStyle(fontSize: 11.5),
            ),
            activeThumbColor: MaherTheme.emeraldPrimary,
            value: _isSoundEnabled,
            onChanged: _toggleSound,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),

          // Daily Quiz Reminders
          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            secondary: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: MaherTheme.emeraldSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isNotificationsEnabled
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                color: MaherTheme.emeraldPrimary,
                size: 20,
              ),
            ),
            title: const Text(
              'Daily Quiz Reminders',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
            subtitle: Text(
              _isNotificationsEnabled
                  ? 'Daily 8:00 PM & streak reminders'
                  : 'Reminders turned off',
              style: const TextStyle(fontSize: 11.5),
            ),
            activeThumbColor: MaherTheme.emeraldPrimary,
            value: _isNotificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),

          // Saved Questions
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: MaherIcons.get('bookmark-filled',
                    size: 20, color: MaherTheme.emeraldPrimary),
              ),
            ),
            title: const Text(
              'Saved Questions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: MaherTheme.emeraldDark,
              ),
            ),
            subtitle: const Text(
              'Review and test bookmarked MCQs',
              style: TextStyle(fontSize: 11.5),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedQuestionsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Admin Management Console Card
  Widget _buildAdminConsoleCard() {
    return Container(
      decoration: BoxDecoration(
        color: MaherTheme.goldLight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: MaherTheme.goldDark.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: MaherTheme.softShadow,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: MaherTheme.goldDark.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: MaherIcons.get('admin-crown',
              size: 22, color: MaherTheme.goldDark),
        ),
        title: const Text(
          'Admin Management Console',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: MaherTheme.emeraldDark,
          ),
        ),
        subtitle: const Text(
          'Manage users, quiz questions & permissions',
          style: TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: MaherTheme.goldDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'ADMIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDashboardScreen(
                currentUser: _user,),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadgeTile(BadgeModel badge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: badge.isUnlocked
            ? badge.primaryColor.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badge.isUnlocked
              ? badge.primaryColor.withValues(alpha: 0.45)
              : Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: MaherTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: badge.isUnlocked
                  ? badge.primaryColor.withValues(alpha: 0.15)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: MaherIcons.get(
                badge.iconKey,
                size: 24,
                color: badge.isUnlocked
                    ? badge.primaryColor
                    : Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      badge.titleEn,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: badge.isUnlocked
                            ? badge.primaryColor
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badge.isUnlocked
                            ? MaherTheme.successGreen.withValues(alpha: 0.15)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (badge.isUnlocked) ...[
                            MaherIcons.get('check-circle',
                                size: 12, color: MaherTheme.successGreen),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            badge.isUnlocked ? 'Unlocked' : 'Locked',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: badge.isUnlocked
                                  ? MaherTheme.successGreen
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  badge.descEn,
                  style: TextStyle(
                    fontSize: 12,
                    color: MaherTheme.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: badge.progressPercentage,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            badge.isUnlocked
                                ? badge.primaryColor
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${badge.currentProgress}/${badge.maxProgress}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: badge.isUnlocked
                            ? badge.primaryColor
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _showPrivacyPolicyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: MaherTheme.emeraldSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: MaherIcons.get('shield-check',
                      size: 24, color: MaherTheme.emeraldPrimary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy Policy & Child Safety',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MaherTheme.emeraldDark,
                        ),
                      ),
                      Text(
                        'DPDP Act & Google Play Families Compliant',
                        style: TextStyle(
                          fontSize: 12,
                          color: MaherTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPrivacySection(
                      title: '1. Safe Environment for Kids (Ages 4-14)',
                      desc: 'Maher Quiz is designed exclusively for educational and Deeniyat knowledge learning. We do NOT display any third-party advertisements, commercial trackers, or behavioural profiling.',
                    ),
                    _buildPrivacySection(
                      title: '2. Minimal Data Collection',
                      desc: 'We only store the student\'s display name, age group, and quiz scores to maintain the educational leaderboard and daily learning streak. No personal identification numbers or sensitive biological data is requested.',
                    ),
                    _buildPrivacySection(
                      title: '3. Parental Consent & Data Rights',
                      desc: 'Under India\'s Digital Personal Data Protection (DPDP) Act, parents and guardians have full rights to inspect, update, or permanently erase their child\'s account and quiz data at any time via the "Delete Account" button.',
                    ),
                    _buildPrivacySection(
                      title: '4. Offline First & Security',
                      desc: 'All quiz questions, bookmarks, and practice modes are accessible locally on your device without requiring mandatory external tracking.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MaherTheme.emeraldPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection({required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: MaherTheme.emeraldDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12.5,
              color: MaherTheme.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

}
