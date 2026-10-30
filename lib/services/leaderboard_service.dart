import '../models/user_model.dart';
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

    // Always ensure current student is present with their latest session stats
    if (!currentUser.isAdmin) {
      map[currentUser.id] = currentUser;
    }

    List<UserModel> list = map.values.toList();
    final today = DateTime.now().toIso8601String().substring(0, 10);

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
          final aToday = a.lastQuizDate == today ? 1 : 0;
          final bToday = b.lastQuizDate == today ? 1 : 0;
          final cmpToday = bToday.compareTo(aToday);
          if (cmpToday != 0) return cmpToday;
          final cmpScore = b.lastQuizScore.compareTo(a.lastQuizScore);
          if (cmpScore != 0) return cmpScore;
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
