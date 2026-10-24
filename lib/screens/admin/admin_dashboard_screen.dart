import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/cloud_service.dart';
import '../../services/quiz_service.dart';
import '../../utils/app_localization.dart';
import '../../utils/maher_icons.dart';
import '../../utils/maher_theme.dart';
import '../../widgets/user_avatar.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserModel currentUser;

  const AdminDashboardScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedRoleFilter = 'all'; // 'all', 'admin', 'student'
  int _totalQuestionsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final users = await AuthService.getAllUsers();
    final questions = await QuizService.loadQuestions();
    if (mounted) {
      setState(() {
        _users = users;
        _totalQuestionsCount = questions.length;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(UserModel targetUser) async {
    if (targetUser.email == widget.currentUser.email ||
        targetUser.id == widget.currentUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot delete your own admin account!'),
          backgroundColor: MaherTheme.errorRed,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            MaherIcons.get('shield-alert', size: 24, color: MaherTheme.errorRed),
            const SizedBox(width: 10),
            Text(AppLocalization.tr('delete_user')),
          ],
        ),
        content: Text(
          '${AppLocalization.tr('confirm_delete')}\n\n${targetUser.name} (${targetUser.email})',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalization.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MaherTheme.errorRed,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalization.tr('yes_delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.adminDeleteUser(targetUser.email);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${targetUser.name} removed successfully.'),
            backgroundColor: MaherTheme.emeraldPrimary,
          ),
        );
      }
    }
  }

  Future<void> _toggleRole(UserModel targetUser) async {
    if (targetUser.email == widget.currentUser.email ||
        targetUser.id == widget.currentUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot change your own admin role!'),
          backgroundColor: MaherTheme.errorRed,
        ),
      );
      return;
    }

    final willBeAdmin = !targetUser.isAdmin;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            MaherIcons.get('admin-crown', size: 24, color: MaherTheme.goldDark),
            const SizedBox(width: 10),
            Text(willBeAdmin
                ? AppLocalization.tr('make_admin')
                : AppLocalization.tr('remove_admin')),
          ],
        ),
        content: Text(
          willBeAdmin
              ? 'Promote ${targetUser.name} to Administrator?'
              : 'Demote ${targetUser.name} to Student?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalization.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: willBeAdmin
                  ? MaherTheme.goldDark
                  : MaherTheme.emeraldPrimary,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final updated = await AuthService.adminToggleUserRole(targetUser.email);
      _loadData();
      if (mounted && updated != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${updated.name} role changed to: ${updated.role.toUpperCase()}',
            ),
            backgroundColor: MaherTheme.emeraldPrimary,
          ),
        );
      }
    }
  }

  Future<void> _resetPassword(UserModel targetUser) async {
    final passController =
        TextEditingController(text: AuthService.generateTemporaryPassword());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            MaherIcons.get('key', size: 24, color: MaherTheme.emeraldPrimary),
            const SizedBox(width: 10),
            const Text('Reset User Password'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set a temporary password for ${targetUser.name}. '
              'They will be asked to choose a new one at their next login.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                hintText: 'Enter new password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalization.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MaherTheme.emeraldPrimary,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final newPass = passController.text.trim();
      if (newPass.length < 6) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password must be at least 6 characters!'),
              backgroundColor: MaherTheme.errorRed,
            ),
          );
        }
        return;
      }
      final ok = await AuthService.adminResetPassword(targetUser.email, newPass);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok
                ? 'Temporary password set for ${targetUser.name}. Share it with them privately.'
                : 'Could not reset password for ${targetUser.name}.'),
            backgroundColor: ok ? MaherTheme.emeraldPrimary : MaherTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.currentUser.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaherIcons.get('shield-alert', size: 64, color: MaherTheme.errorRed),
              const SizedBox(height: 16),
              Text(
                AppLocalization.tr('access_denied'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    // Online accounts are managed in Supabase (needs privileges the app must
    // never hold); this console only manages accounts stored on this device
    if (CloudService.isEnabled) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Console'),
          foregroundColor: MaherTheme.emeraldDark,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MaherIcons.get('admin-crown',
                      size: 56, color: MaherTheme.goldDark),
                  const SizedBox(height: 16),
                  const Text(
                    'Accounts are online',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Students reset their own passwords by email. To remove a '
                    'student or make someone an admin, use the Supabase '
                    'dashboard (Authentication → Users, and the profiles '
                    'table). See SUPABASE_SETUP.md.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14, color: MaherTheme.textSecondaryLight),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final filteredUsers = _users.where((u) {
      final matchesSearch = u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.id.toLowerCase().contains(_searchQuery.toLowerCase());

      if (_selectedRoleFilter == 'admin') {
        return matchesSearch && u.isAdmin;
      } else if (_selectedRoleFilter == 'student') {
        return matchesSearch && !u.isAdmin;
      }
      return matchesSearch;
    }).toList();

    final totalUsers = _users.length;
    final totalStudents = _users.where((u) => !u.isAdmin).length;
    final totalAttempts = _users.fold<int>(0, (sum, u) => sum + u.quizzesCompleted);

    return Scaffold(
      backgroundColor: MaherTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaherIcons.get('admin-crown', size: 24, color: MaherTheme.goldDark),
            const SizedBox(width: 8),
            Text(
              AppLocalization.tr('admin_dashboard'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Data',
            icon: MaherIcons.get('refresh', size: 20, color: Colors.white),
            onPressed: _loadData,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(MaherTheme.emeraldPrimary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Overview Metric Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: AppLocalization.tr('total_users'),
                              value: '$totalUsers',
                              icon: 'users-group',
                              iconColor: MaherTheme.emeraldPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMetricCard(
                              title: AppLocalization.tr('active_students'),
                              value: '$totalStudents',
                              icon: 'user',
                              iconColor: MaherTheme.goldDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: AppLocalization.tr('total_attempts'),
                              value: '$totalAttempts',
                              icon: 'sparkle',
                              iconColor: MaherTheme.goldDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Questions Bank',
                              value: '$_totalQuestionsCount',
                              icon: 'book-quran',
                              iconColor: MaherTheme.emeraldPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Users Management Header & Search
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  MaherIcons.get('users-group',
                                      size: 20,
                                      color: MaherTheme.emeraldPrimary),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalization.tr('registered_users_list'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: MaherTheme.emeraldDark,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: MaherTheme.emeraldSoft,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${filteredUsers.length} Users',
                                      style: TextStyle(
                                        color: MaherTheme.emeraldDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Search Field
                              TextField(
                                decoration: InputDecoration(
                                  hintText: AppLocalization.tr('search_users'),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: MaherIcons.get('search',
                                        size: 18, color: MaherTheme.textMuted),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),

                              // Role Filter Chips
                              Row(
                                children: [
                                  _buildRoleFilterChip(
                                      'all', 'All (${_users.length})'),
                                  const SizedBox(width: 8),
                                  _buildRoleFilterChip('student',
                                      'Students ($totalStudents)'),
                                  const SizedBox(width: 8),
                                  _buildRoleFilterChip(
                                      'admin',
                                      'Admins (${_users.where((u) => u.isAdmin).length})'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 10),

                              // User Cards List
                              if (filteredUsers.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 30),
                                  child: Center(
                                    child: Text(
                                      'No matching users found.',
                                      style: TextStyle(
                                          color: MaherTheme.textMuted),
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredUsers.length,
                                  separatorBuilder: (_, _) =>
                                      const Divider(height: 16),
                                  itemBuilder: (context, index) {
                                    final u = filteredUsers[index];
                                    final isCurrentUser =
                                        (u.email == widget.currentUser.email ||
                                            u.id == widget.currentUser.id);

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Role Avatar
                                          UserAvatar(
                                            avatar: u.avatar,
                                            name: u.name,
                                            size: 44,
                                            borderWidth: 2,
                                            borderColor: u.isAdmin
                                                ? MaherTheme.goldDark
                                                : MaherTheme.emeraldPrimary
                                                    .withValues(alpha: 0.3),
                                          ),
                                          const SizedBox(width: 14),

                                          // User Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        u.name,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    if (isCurrentUser) ...[
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 6,
                                                                vertical: 2),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .grey.shade200,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        ),
                                                        child: const Text(
                                                          'You',
                                                          style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${u.email.isNotEmpty ? u.email : u.phone} • ${u.id}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: MaherTheme
                                                        .textSecondaryLight,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    MaherIcons.get('trophy',
                                                        size: 14,
                                                        color: MaherTheme
                                                            .goldPrimary),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${u.totalScore} pts (${u.quizzesCompleted} quizzes)',
                                                      style: const TextStyle(
                                                          fontSize: 11),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    MaherIcons.get(
                                                        'flame-streak',
                                                        size: 14,
                                                        color: MaherTheme
                                                            .goldDark),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${u.effectiveStreak} day streak',
                                                      style: const TextStyle(
                                                          fontSize: 11),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Actions
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Toggle Role Button
                                              IconButton(
                                                tooltip: u.isAdmin
                                                    ? AppLocalization.tr(
                                                        'remove_admin')
                                                    : AppLocalization.tr(
                                                        'make_admin'),
                                                icon: MaherIcons.get(
                                                    'admin-crown',
                                                    size: 18,
                                                    color: u.isAdmin
                                                        ? MaherTheme.goldDark
                                                        : Colors.grey.shade400),
                                                onPressed: isCurrentUser
                                                    ? null
                                                    : () => _toggleRole(u),
                                              ),
                                              // Reset Password Button
                                              IconButton(
                                                tooltip: 'Reset Password',
                                                icon: MaherIcons.get('key',
                                                    size: 18,
                                                    color: MaherTheme
                                                        .emeraldPrimary),
                                                onPressed: () =>
                                                    _resetPassword(u),
                                              ),
                                              // Delete Button
                                              IconButton(
                                                tooltip: AppLocalization.tr(
                                                    'delete_user'),
                                                icon: MaherIcons.get('trash',
                                                    size: 18,
                                                    color: isCurrentUser
                                                        ? Colors.grey.shade300
                                                        : MaherTheme.errorRed),
                                                onPressed: isCurrentUser
                                                    ? null
                                                    : () => _deleteUser(u),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: MaherTheme.emeraldDark,
                  ),
                ),
                MaherIcons.get(icon, size: 24, color: iconColor),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: MaherTheme.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleFilterChip(String roleKey, String label) {
    final isSelected = (_selectedRoleFilter == roleKey);
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRoleFilter = roleKey;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? MaherTheme.emeraldPrimary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
