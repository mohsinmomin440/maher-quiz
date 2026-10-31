import '../models/user_model.dart';
import '../utils/date_utils.dart';
import 'auth_service.dart';
import 'cloud_service.dart';

enum LeaderboardFilter { allTime, streak, today }

class LeaderboardEntry {
  final int rank;
  final UserModel user;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.user,
    required this.isCurrentUser,
  });
}

class LeaderboardService {
  // Fetch real ranking list of registered students (no fake data)
  static Future<List<LeaderboardEntry>> getLeaderboard({
    required LeaderboardFilter filter,
    required UserModel currentUser,
  }) async {
    // Online: global ranking from the server (falls back to this device's
    // users when offline)
    if (CloudService.hasSession) {
      try {
        final rows = await CloudService.fetchLeaderboard(filter.name);
        return [
          for (var i = 0; i < rows.length; i++)
            LeaderboardEntry(
              rank: i + 1,
              user: rows[i].user,
              isCurrentUser: rows[i].isMe,
            ),
        ];
      } catch (_) {}
    }

    final registered = await AuthService.getAllUsers();

    // Map real registered students by unique ID
    final Map<String, UserModel> map = {};
    // Admin accounts are staff, not participants, so they are not ranked
    for (final reg in registered) {
      if (reg.id.isNotEmpty && !reg.isAdmin) {
        map[reg.id] = reg;
      }
    }

    // Always ensure current user is present with their latest session stats (if student)
    if (!currentUser.isAdmin && currentUser.id.isNotEmpty) {
      map[currentUser.id] = currentUser;
    }

    List<UserModel> list = map.values.toList();
    // "Played today" is judged against the IST calendar date so students in
    // other timezones (or with a fiddled clock) get the same ranking.
    final today = istToday;

    switch (filter) {
      case LeaderboardFilter.allTime:
        list.sort((a, b) {
          final cmp = b.totalScore.compareTo(a.totalScore);
          if (cmp != 0) return cmp;
          return b.effectiveStreak.compareTo(a.effectiveStreak);
        });
        break;

      case LeaderboardFilter.streak:
        list.sort((a, b) {
          final cmp = b.effectiveStreak.compareTo(a.effectiveStreak);
          if (cmp != 0) return cmp;
          return b.totalScore.compareTo(a.totalScore);
        });
        break;

      case LeaderboardFilter.today:
        list.sort((a, b) {
          final aTodayScore = a.lastQuizDate == today ? a.lastQuizScore : 0;
          final bTodayScore = b.lastQuizDate == today ? b.lastQuizScore : 0;
          final cmpScore = bTodayScore.compareTo(aTodayScore);
          if (cmpScore != 0) return cmpScore;
          final cmpTotal = b.totalScore.compareTo(a.totalScore);
          if (cmpTotal != 0) return cmpTotal;
          return b.effectiveStreak.compareTo(a.effectiveStreak);
        });
        break;
    }

    final entries = <LeaderboardEntry>[];
    for (int i = 0; i < list.length; i++) {
      final u = list[i];
      final isCurrent = (u.id == currentUser.id) ||
          (currentUser.phone.isNotEmpty && u.phone == currentUser.phone) ||
          (currentUser.email.isNotEmpty && u.email == currentUser.email);

      entries.add(
        LeaderboardEntry(
          rank: i + 1,
          user: u,
          isCurrentUser: isCurrent,
        ),
      );
    }

    return entries;
  }
}
