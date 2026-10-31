import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/leaderboard_service.dart';
import '../utils/maher_icons.dart';
import '../utils/maher_theme.dart';
import '../widgets/user_avatar.dart';

class LeaderboardScreen extends StatefulWidget {
  final UserModel currentUser;
  final bool isTab;

  const LeaderboardScreen({
    super.key,
    required this.currentUser,
    this.isTab = false,
  });

  @override
  State<LeaderboardScreen> createState() => LeaderboardScreenState();
}

class LeaderboardScreenState extends State<LeaderboardScreen> {
  LeaderboardFilter _selectedFilter = LeaderboardFilter.allTime;
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLeaderboard();
  }

  @override
  void didUpdateWidget(covariant LeaderboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentUser != widget.currentUser) {
      loadLeaderboard();
    }
  }

  Future<void> loadLeaderboard() async {
    setState(() => _isLoading = true);
    final list = await LeaderboardService.getLeaderboard(
      filter: _selectedFilter,
      currentUser: widget.currentUser,
    );
    if (!mounted) return;
    setState(() {
      _entries = list;
      _isLoading = false;
    });
  }

  void _onFilterChanged(LeaderboardFilter filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
    });
    loadLeaderboard();
  }

  String _formatScore(UserModel user) {
    switch (_selectedFilter) {
      case LeaderboardFilter.today:
        return '${user.lastQuizScore} pts';
      case LeaderboardFilter.streak:
        return '${user.effectiveStreak} days';
      case LeaderboardFilter.allTime:
        return '${user.totalScore} pts';
    }
  }

  LeaderboardEntry? get _currentUserEntry {
    for (final e in _entries) {
      if (e.isCurrentUser) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentEntry = _currentUserEntry;

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
                color: MaherTheme.goldLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: MaherIcons.get('trophy', size: 20, color: MaherTheme.goldDark),
            ),
            const SizedBox(width: 10),
            const Text(
              'Leaderboard',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: MaherTheme.emeraldDark,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: MaherIcons.get('refresh', size: 20, color: MaherTheme.emeraldPrimary),
            onPressed: loadLeaderboard,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(MaherTheme.emeraldPrimary),
              ),
            )
          : Column(
              children: [
                // Filter Tabs (All-Time, Streak, Today)
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _buildTabButton(
                        title: 'All-Time',
                        filter: LeaderboardFilter.allTime,
                        icon: 'trophy',
                      ),
                      const SizedBox(width: 8),
                      _buildTabButton(
                        title: 'Streak',
                        filter: LeaderboardFilter.streak,
                        icon: 'flame-streak',
                      ),
                      const SizedBox(width: 8),
                      _buildTabButton(
                        title: 'Today',
                        filter: LeaderboardFilter.today,
                        icon: 'sparkle',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Main Leaderboard Content
                Expanded(
                  child: _entries.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                child: Center(
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 680),
                                    child: Column(
                                      children: [
                                        // Podium for Top 3 if 3+ entries
                                        if (_entries.length >= 3) ...[
                                          _buildPodium(),
                                          const SizedBox(height: 16),
                                          ...List.generate(
                                            _entries.length - 3,
                                            (idx) => _buildRankTile(
                                                _entries[idx + 3]),
                                          ),
                                        ] else ...[
                                          // If fewer than 3 entries, show tiles for all
                                          ..._entries.map(
                                              (e) => _buildRankTile(e)),
                                        ],
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (widget.isTab && currentEntry != null)
                              _buildUserRankBanner(currentEntry),
                          ],
                        ),
                ),
              ],
            ),
      bottomNavigationBar: (!widget.isTab && currentEntry != null)
          ? _buildUserRankBanner(currentEntry)
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: MaherTheme.emeraldSoft,
                shape: BoxShape.circle,
              ),
              child: MaherIcons.get('trophy',
                  size: 50, color: MaherTheme.goldDark),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Scores Recorded Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MaherTheme.emeraldDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Take the daily quiz to earn points and claim your spot on the leaderboard!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: MaherTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRankBanner(LeaderboardEntry currentEntry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: MaherTheme.emeraldDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: MaherTheme.goldDark,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#${currentEntry.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Your Rank: #${currentEntry.rank}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${_formatScore(currentEntry.user)} • ${currentEntry.user.effectiveStreak} day streak',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.currentUser.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required LeaderboardFilter filter,
    required String icon,
  }) {
    final isSelected = _selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onFilterChanged(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? MaherTheme.emeraldPrimary : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? MaherTheme.emeraldDark
                  : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? MaherTheme.emeraldDark.withValues(alpha: 0.4)
                    : Colors.grey.shade300,
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaherIcons.get(
                icon,
                size: 16,
                color: isSelected ? Colors.white : MaherTheme.emeraldPrimary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : MaherTheme.emeraldDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodium() {
    final rank1 = _entries[0];
    final rank2 = _entries[1];
    final rank3 = _entries[2];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaherIcons.get('admin-crown',
                    size: 26, color: MaherTheme.goldDark),
                const SizedBox(width: 8),
                const Text(
                  'Top 3 Champions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: MaherTheme.emeraldDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 2nd Place (Silver)
                _buildPodiumStep(
                  entry: rank2,
                  podiumHeight: 120,
                  medalColor: const Color(0xFF94A3B8), // Silver
                  svgIconName: 'medal-silver',
                  medalLabel: '2nd',
                ),
                // 1st Place (Gold)
                _buildPodiumStep(
                  entry: rank1,
                  podiumHeight: 150,
                  medalColor: MaherTheme.goldDark, // Gold
                  svgIconName: 'crown-gold',
                  medalLabel: '1st',
                  isFirst: true,
                ),
                // 3rd Place (Bronze)
                _buildPodiumStep(
                  entry: rank3,
                  podiumHeight: 100,
                  medalColor: const Color(0xFFB45309), // Bronze
                  svgIconName: 'medal-bronze',
                  medalLabel: '3rd',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumStep({
    required LeaderboardEntry entry,
    required double podiumHeight,
    required Color medalColor,
    required String svgIconName,
    required String medalLabel,
    bool isFirst = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MaherIcons.get(svgIconName, size: isFirst ? 34 : 26),
        const SizedBox(height: 4),
        UserAvatar(
          avatar: entry.user.avatar,
          name: entry.user.name,
          size: isFirst ? 60 : 48,
          borderColor: medalColor,
          borderWidth: 3,
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 96,
          child: Text(
            entry.user.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: medalColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _formatScore(entry.user),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: medalColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 86,
          height: podiumHeight * 0.48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                medalColor,
                medalColor.withValues(alpha: 0.85),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(
              top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.4), width: 2),
              left: BorderSide(color: medalColor, width: 1.5),
              right: BorderSide(color: medalColor, width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: medalColor.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                medalLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankTile(LeaderboardEntry entry) {
    final isCurrent = entry.isCurrentUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? MaherTheme.emeraldSoft
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent
              ? MaherTheme.emeraldPrimary
              : Colors.grey.shade200,
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? MaherTheme.emeraldPrimary.withValues(alpha: 0.25)
                : Colors.grey.shade200,
            offset: const Offset(0, 3.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCurrent
                    ? MaherTheme.emeraldPrimary
                    : (entry.rank <= 3
                        ? MaherTheme.goldLight.withValues(alpha: 0.5)
                        : Colors.grey.shade100),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent
                      ? MaherTheme.emeraldDark
                      : (entry.rank <= 3
                          ? MaherTheme.goldDark
                          : Colors.grey.shade300),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  '${entry.rank}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isCurrent
                        ? Colors.white
                        : (entry.rank <= 3
                            ? MaherTheme.goldDark
                            : MaherTheme.textSecondaryLight),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            UserAvatar(
              avatar: entry.user.avatar,
              name: entry.user.name,
              size: 40,
              showBorder: true,
              borderColor: isCurrent
                  ? MaherTheme.emeraldPrimary
                  : Colors.grey.shade200,
            ),
          ],
        ),
        title: Text(
          entry.user.name,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: isCurrent ? MaherTheme.emeraldDark : Colors.black87,
          ),
        ),
        subtitle: Row(
          children: [
            MaherIcons.get('flame-streak',
                size: 14, color: MaherTheme.goldDark),
            const SizedBox(width: 4),
            Text(
              '${entry.user.effectiveStreak} days • ${entry.user.ageGroup}',
              style: TextStyle(
                fontSize: 12,
                color: MaherTheme.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isCurrent
                ? MaherTheme.emeraldPrimary
                : MaherTheme.emeraldSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            _formatScore(entry.user),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isCurrent ? Colors.white : MaherTheme.emeraldPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
