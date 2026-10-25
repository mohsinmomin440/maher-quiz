import 'package:flutter/material.dart';
import '../models/age_groups.dart';
import '../models/user_model.dart';
import '../services/cloud_service.dart';
import '../utils/maher_icons.dart';
import '../utils/maher_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late String _selectedAgeGroup;
  late String _selectedAvatar;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _ageGroups = AgeGroups.all;
  final Map<String, String> _avatarMap = {
    'default': 'assets/images/default_avatar.png',
    '1': 'assets/images/avatar_1.png',
    '2': 'assets/images/avatar_2.png',
  };

  @override
  void initState() {
    super.initState();
    _selectedAgeGroup = AgeGroups.normalize(widget.user.ageGroup);
    _selectedAvatar = widget.user.avatar.startsWith('avatar_') ? widget.user.avatar : 'default';
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickAvatar(String key) async {
    setState(() => _selectedAvatar = key);
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await CloudService.updateUserInSupabase(
        userId: widget.user.id,
        name: _selectedName,
        ageGroup: _selectedAgeGroup,
      );
    } catch (e) {
      setState(() => _errorMessage = 'Profile update failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaherTheme.backgroundLight,
      appBar: AppBar(title: Text(AppLocalization.tr('edit_profile'))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                // Avatar selector
                GestureDetector(
                  onTap: () => _showAvatarPicker(context),
                  child: UserAvatar(
                    avatarPath: _selectedAvatar,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 20),

                // Full name field (this might also be unnecessary now)
                Text(
                  AppLocalization.tr('full_name'),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: AppLocalization.tr('full_name_hint'),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: MaherIcons.get('user', size: 20, color: MaherTheme.emeraldPrimary),
                    ),
                  ),
                  const SizedBox(height: 20),

                // Save button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(MaherTheme.emeraldPrimary),
                            ),
                          )
                        : Text(
                            AppLocalization.tr('save_changes'),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                          ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(_errorMessage!,
                        style: const TextStyle(color: MaherTheme.errorRed, fontSize: 13)),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (c) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _avatarOption('default', AppLocalization.tr('use_default_avatar')),
          const Divider(),
          _avatarOption('1', AppLocalization.tr('avatar_1')),
          const Divider(),
          _avatarOption('2', AppLocalization.tr('avatar_2')),
        ],
      ),
    );
  }

  Widget _avatarOption(String key, String label) {
    final color = key == _selectedAvatar ? Colors.green : Colors.grey;
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      child: Text(label),
      onPressed: () => _pickAvatar(key),
    );
  }