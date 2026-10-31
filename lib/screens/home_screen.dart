import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/cloud_service.dart';
import '../services/quiz_service.dart';
import '../utils/app_localization.dart';
import '../utils/maher_icons.dart';
import '../utils/maher_theme.dart';
import '../widgets/change_password_sheet.dart';
import '../widgets/user_avatar.dart';
import 'auth/login_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'quiz_screen.dart';
import 'saved_questions_screen.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key, });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  bool _isLoading = true;

  int _currentIndex = 0;
  final GlobalKey<LeaderboardScreenState> _leaderboardKey =
      GlobalKey<LeaderboardScreenState>();


  String _selectedDifficulty = 'all';
  bool _isForcingPasswordChange = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    // Online: send queued results and refresh the local copy of the profile
    // (no-op in local mode or when offline)
    await CloudService.syncOnHomeLoad();

    // Also submits a daily quiz that was opened but left unfinished (e.g. the
    // app was closed mid-quiz), so it can't be restarted.
    final user = await AuthService.finalizeAbandonedDaily();
    if (!mounted) return;

    // Session no longer valid (account deleted/suspended or corrupt data)
    if (user == null) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LoginScreen(),
        ),
        (route) => false,
      );
      return;
    }

    setState(() {
      _user = user;
      _isLoading = false;
    });

    if (user.mustChangePassword && !_isForcingPasswordChange) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _forcePasswordChange());
    }
  }

  // Seeded admin or admin-reset accounts must replace their temporary
  // password before using the app.
  Future<void> _forcePasswordChange() async {
    if (!mounted || _user == null || _isForcingPasswordChange) return;
    _isForcingPasswordChange = true;
    await ChangePasswordSheet.show(context, _user!, forced: true);
    _isForcingPasswordChange = false;
    if (mounted) _loadUser();
  }


  Future<void> _startDailyQuiz() async {
    // Daily challenge is always mixed-level; the difficulty chips only
    // apply to Practice mode.
    final questions = await QuizService.getDailyQuestions();
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          questions: questions,
          isDaily: true,
        ),
      ),
    );

    if (mounted) {
      await _loadUser();
      _leaderboardKey.currentState?.loadLeaderboard();
    }
  }

  Future<void> _startPracticeQuiz() async {
    final questions = await QuizService.getPracticeQuestions(
      difficulty: _selectedDifficulty,
    );
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          questions: questions,
          isDaily: false,
        ),
      ),
    );

    if (mounted) {
      await _loadUser();
      _leaderboardKey.currentState?.loadLeaderboard();
    }
  }

  void _onTabTapped(int index) {
    if (index == 0 || index == 3) {
      _loadUser();
    } else if (index == 2) {
      _leaderboardKey.currentState?.loadLeaderboard();
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _showCurriculumModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  child: MaherIcons.get('book-quran',
                      size: 26, color: MaherTheme.emeraldPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalization.tr('syllabus_info'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MaherTheme.emeraldDark,
                        ),
                      ),
                      Text(
                        AppLocalization.tr('syllabus_desc'),
                        style: TextStyle(
                          fontSize: 12,
                          color: MaherTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _buildCurriculumTopicTile(
              title: 'Akhlaq & Adab',
              desc: 'Good manners, honoring parents, honesty, patience, and kindness.',
              color: MaherTheme.emeraldPrimary,
            ),
            const SizedBox(height: 10),
            _buildCurriculumTopicTile(
              title: 'Fiqh & Ibadat',
              desc: 'Salah, Wudu, Taharah, Sawm, and basic daily supplications.',
              color: MaherTheme.goldDark,
            ),
            const SizedBox(height: 10),
            _buildCurriculumTopicTile(
              title: 'Islamic History & Seerah',
              desc: 'Life of Prophet Muhammad (ﷺ), Companions, and Prophets.',
              color: const Color(0xFF2563EB),
            ),
            const SizedBox(height: 10),
            _buildCurriculumTopicTile(
              title: 'Aqaed & Iman',
              desc: 'Tawheed, Angels, Revealed Books, and the Day of Judgment.',
              color: const Color(0xFF7C3AED),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MaherTheme.emeraldPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Close Preview'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurriculumTopicTile({
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: MaherTheme.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(MaherTheme.emeraldPrimary),
          ),
        ),
      );
    }

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: MaherTheme.backgroundLight,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            _buildPracticeTab(),
            LeaderboardScreen(
              key: _leaderboardKey,
              currentUser: _user!,
              isTab: true,
            ),
            ProfileScreen(
              user: _user!,
              isTab: true,
              onUserUpdated: (updated) {
                setState(() {
                  _user = updated;
                });
              },
            ),
          ],
        ),
        bottomNavigationBar: _buildModernBottomNav(),
      ),
    );
  }

  // Modern Floating Capsule Navigation Bar
  Widget _buildModernBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: MaherTheme.emeraldPrimary.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1.2,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                iconKey: 'home-outline',
                activeIconKey: 'home',
                label: AppLocalization.tr('nav_home'),
              ),
              _buildNavItem(
                index: 1,
                iconKey: 'book-quran',
                activeIconKey: 'book-quran',
                label: AppLocalization.tr('nav_practice'),
              ),
              _buildNavItem(
                index: 2,
                iconKey: 'trophy',
                activeIconKey: 'trophy',
                label: AppLocalization.tr('nav_leaderboard'),
              ),
              _buildNavItem(
                index: 3,
                iconKey: 'user',
                activeIconKey: 'user',
                label: AppLocalization.tr('nav_profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String iconKey,
    required String activeIconKey,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    // Unselected tabs show only an icon: give them a screen-reader label and
    // a long-press tooltip
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      // Child semantics (incl. the tap action) are excluded, so expose it here
      onTap: () => _onTabTapped(index),
      child: Tooltip(
        message: label,
        child: _buildNavItemBody(
          index: index,
          iconKey: iconKey,
          activeIconKey: activeIconKey,
          label: label,
          isSelected: isSelected,
        ),
      ),
    );
  }

  Widget _buildNavItemBody({
    required int index,
    required String iconKey,
    required String activeIconKey,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? MaherTheme.emeraldSoft
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaherIcons.get(
              isSelected ? activeIconKey : iconKey,
              size: 21,
              color: isSelected
                  ? MaherTheme.emeraldPrimary
                  : MaherTheme.textMuted,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: MaherTheme.emeraldPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    final isCompletedToday =
        QuizService.isDailyQuizCompleted(_user?.lastQuizDate);

    return Scaffold(
      backgroundColor: MaherTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: MaherTheme.glow(MaherTheme.emeraldPrimary, opacity: 0.15),
              ),
              child: MaherIcons.get('logo', size: 36),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalization.tr('app_name'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: MaherTheme.emeraldDark,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: MaherTheme.goldLight.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'DEENIYAT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: MaherTheme.goldDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  AppLocalization.tr('app_tagline'),
                  style: TextStyle(
                    fontSize: 12,
                    color: MaherTheme.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Streak Counter Badge
          GestureDetector(
            onTap: () => _onTabTapped(2),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: MaherTheme.goldLight.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: MaherTheme.goldPrimary.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MaherIcons.get('flame-streak',
                      size: 16, color: MaherTheme.goldDark),
                  const SizedBox(width: 4),
                  Text(
                    '${_user?.effectiveStreak ?? 0}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: MaherTheme.goldDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User Avatar Action
          Padding(
            padding: const EdgeInsets.only(right: 14, left: 4),
            child: GestureDetector(
              onTap: () => _onTabTapped(3),
              child: UserAvatar(
                avatar: _user?.avatar,
                name: _user?.name ?? '',
                size: 38,
                borderWidth: 2,
                borderColor: MaherTheme.emeraldPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bento Welcome Card
                _buildWelcomeHeroCard(),
                const SizedBox(height: 18),

                // Hero Card: 24-Hour Daily 5 MCQs Challenge
                _buildDailyQuizChallengeCard(isCompletedToday),
                const SizedBox(height: 18),

                // Bento Stats Grid (Score & Quizzes)
                _buildBentoStatsGrid(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dedicated Practice Arena Tab
  Widget _buildPracticeTab() {
    return Scaffold(
      backgroundColor: MaherTheme.backgroundLight,
      appBar: AppBar(
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
              child: MaherIcons.get('book-quran',
                  size: 20, color: MaherTheme.emeraldPrimary),
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalization.tr('practice_mode'),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: MaherTheme.emeraldDark,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Practice Arena with Level Chips
                _buildPracticeArenaCard(),
                const SizedBox(height: 18),

                // Saved Questions Card (integrated into Practice)
                _buildSavedQuestionsPreviewCard(),
                const SizedBox(height: 18),

                // Syllabus & Curriculum Card
                _buildSyllabusExploreCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedQuestionsPreviewCard() {
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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MaherTheme.goldLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: MaherIcons.get('bookmark-filled',
                  size: 24, color: MaherTheme.goldDark),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved Questions & Revision',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MaherTheme.emeraldDark,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Review and practice your bookmarked questions',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: MaherTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: MaherTheme.goldDark),
              onPressed: () {
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
      ),
    );
  }

  // Modern Bento Welcome Hero Card
  Widget _buildWelcomeHeroCard() {
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
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: MaherTheme.emeraldDark.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: MaherTheme.goldPrimary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Background subtle Star watermark
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.08,
              child: MaherIcons.get('rub-el-hizb', size: 160, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Arabic greeting
                      Row(
                        children: [
                          Text(
                            'السَّلَامُ عَلَيْكُمْ',
                            style: TextStyle(
                              fontSize: 15,
                              color: MaherTheme.goldLight,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          MaherIcons.get('rub-el-hizb',
                              size: 14, color: MaherTheme.goldPrimary),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _user?.name ?? "",
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          '${_user?.id} • ${_user?.ageGroup}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _onTabTapped(3),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      UserAvatar(
                        avatar: _user?.avatar,
                        name: _user?.name ?? '',
                        size: 68,
                        borderWidth: 2.8,
                        borderColor: MaherTheme.goldLight,
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: MaherTheme.goldPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: MaherIcons.get('pencil',
                              size: 11, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 24-Hour Daily 5 MCQs Challenge Card
  Widget _buildDailyQuizChallengeCard(bool isCompletedToday) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompletedToday
              ? MaherTheme.successGreen.withValues(alpha: 0.4)
              : MaherTheme.goldPrimary.withValues(alpha: 0.45),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCompletedToday
                    ? MaherTheme.successGreen
                    : MaherTheme.goldPrimary)
                .withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompletedToday
                        ? MaherTheme.successGreen.withValues(alpha: 0.15)
                        : MaherTheme.goldLight.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCompletedToday
                          ? MaherTheme.successGreen.withValues(alpha: 0.4)
                          : MaherTheme.goldPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MaherIcons.get(
                        isCompletedToday ? 'check-circle' : 'sparkle',
                        size: 14,
                        color: isCompletedToday
                            ? MaherTheme.successGreen
                            : MaherTheme.goldDark,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isCompletedToday ? 'MISSION ACCOMPLISHED' : 'DAILY MISSION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: isCompletedToday
                              ? MaherTheme.successGreen
                              : MaherTheme.goldDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: MaherTheme.emeraldSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '5 QUESTIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: MaherTheme.emeraldPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              AppLocalization.tr('daily_quiz_title'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MaherTheme.emeraldDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalization.tr('daily_quiz_desc'),
              style: TextStyle(
                fontSize: 13,
                color: MaherTheme.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 18),

            // 24hr Live Countdown Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: MaherTheme.backgroundLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MaherTheme.emeraldSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: MaherIcons.get('timer-clock',
                        size: 20, color: MaherTheme.emeraldPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCompletedToday
                              ? AppLocalization.tr('next_quiz_in')
                              : AppLocalization.tr('time_remaining'),
                          style: TextStyle(
                            fontSize: 12,
                            color: MaherTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Ticks on its own so Home isn't rebuilt every second;
                        // reloads the user at midnight to unlock the new quiz
                        _DailyCountdown(onNewDay: _loadUser, currentIndex: _currentIndex),
                      ],
                    ),
                  ),
                  if (isCompletedToday)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: MaherTheme.successGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          MaherIcons.get('check-circle',
                              size: 15, color: MaherTheme.successGreen),
                          const SizedBox(width: 4),
                          Text(
                            '${_user?.lastQuizScore ?? 0} / 5',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: MaherTheme.successGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // CTA Button
            if (!isCompletedToday)
              GestureDetector(
                onTap: _startDailyQuiz,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: MaherTheme.emeraldPrimary,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: MaherTheme.emeraldDark, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: MaherTheme.emeraldDark,
                        offset: Offset(0, 4.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaherIcons.get('check-circle',
                          size: 20, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalization.tr('start_daily_quiz'),
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
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: MaherTheme.successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: MaherTheme.successGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MaherIcons.get('check-circle',
                          size: 20, color: MaherTheme.successGreen),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalization.tr('daily_quiz_completed'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MaherTheme.successGreen,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Practice Arena Card
  Widget _buildPracticeArenaCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: MaherTheme.emeraldPrimary.withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: MaherTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MaherTheme.emeraldSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: MaherIcons.get('book-quran',
                      size: 28, color: MaherTheme.emeraldPrimary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalization.tr('practice_mode'),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: MaherTheme.emeraldDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalization.tr('practice_desc'),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: MaherTheme.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppLocalization.tr('practice_xp')}: ${_user?.practiceXp ?? 0}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: MaherTheme.goldDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Difficulty Level Chips
            Text(
              AppLocalization.tr('select_difficulty'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: MaherTheme.emeraldDark,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildLevelFilterChip(
                    key: 'all',
                    label: AppLocalization.tr('level_all'),
                    color: MaherTheme.emeraldPrimary,
                  ),
                  const SizedBox(width: 8),
                  _buildLevelFilterChip(
                    key: 'easy',
                    label: AppLocalization.tr('level_easy'),
                    color: MaherTheme.successGreen,
                  ),
                  const SizedBox(width: 8),
                  _buildLevelFilterChip(
                    key: 'medium',
                    label: AppLocalization.tr('level_medium'),
                    color: MaherTheme.goldDark,
                  ),
                  const SizedBox(width: 8),
                  _buildLevelFilterChip(
                    key: 'hard',
                    label: AppLocalization.tr('level_hard'),
                    color: const Color(0xFF7C3AED),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Practice CTA
            GestureDetector(
              onTap: _startPracticeQuiz,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: MaherTheme.emeraldPrimary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: MaherTheme.emeraldDark, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: MaherTheme.emeraldDark,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${AppLocalization.tr('start_practice')} (${AppLocalization.tr('level_$_selectedDifficulty')})',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    MaherIcons.get('chevron-right', size: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelFilterChip({
    required String key,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedDifficulty == key;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = key;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  // Bento Stats Grid (Score & Quizzes)
  Widget _buildBentoStatsGrid() {
    return Row(
      children: [
        // Total Score
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: MaherTheme.goldPrimary.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: MaherTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MaherTheme.goldLight.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MaherIcons.get('trophy',
                      size: 24, color: MaherTheme.goldPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_user?.totalScore ?? 0}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: MaherTheme.emeraldDark,
                  ),
                ),
                Text(
                  AppLocalization.tr('your_score'),
                  style: TextStyle(
                    fontSize: 12,
                    color: MaherTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if ((_user?.practiceXp ?? 0) > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '+${_user?.practiceXp} Practice XP',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: MaherTheme.goldDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Total Quizzes
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: MaherTheme.emeraldPrimary.withValues(alpha: 0.15),
                width: 1.2,
              ),
              boxShadow: MaherTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MaherTheme.emeraldSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MaherIcons.get('check-circle',
                      size: 24, color: MaherTheme.successGreen),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_user?.quizzesCompleted ?? 0}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: MaherTheme.emeraldDark,
                  ),
                ),
                Text(
                  AppLocalization.tr('total_quizzes'),
                  style: TextStyle(
                    fontSize: 12,
                    color: MaherTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Deeniyat Curriculum Syllabus Card
  Widget _buildSyllabusExploreCard() {
    return GestureDetector(
      onTap: _showCurriculumModal,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: MaherTheme.emeraldSoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: MaherTheme.emeraldPrimary.withValues(alpha: 0.2),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: MaherIcons.get('rub-el-hizb',
                  size: 24, color: MaherTheme.emeraldPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalization.tr('syllabus_info'),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: MaherTheme.emeraldDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to view Akhlaq, Fiqh, Tareekh & Aqaed topics',
                    style: TextStyle(
                      fontSize: 12,
                      color: MaherTheme.emeraldMedium,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: MaherTheme.emeraldMedium),
          ],
        ),
      ),
    );
  }
}

// Live countdown to the next daily quiz (local midnight)
class _DailyCountdown extends StatefulWidget {
  final VoidCallback onNewDay;
  final int currentIndex;

  const _DailyCountdown({required this.onNewDay, required this.currentIndex});

  @override
  State<_DailyCountdown> createState() => _DailyCountdownState();
}

class _DailyCountdownState extends State<_DailyCountdown> {
  Timer? _timer;
  Duration _remaining = QuizService.getTimeUntilNextQuiz();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = QuizService.getTimeUntilNextQuiz();
      // Remaining time jumps back up to ~24h once midnight passes
      final crossedMidnight = next > _remaining;
      _remaining = next;
      if (mounted && widget.currentIndex == 0) {
        setState(() {});
      }
      if (crossedMidnight) {
        widget.onNewDay();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _format(_remaining),
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: MaherTheme.emeraldDark,
        fontFamily: 'monospace',
        letterSpacing: 1.5,
      ),
    );
  }
}
