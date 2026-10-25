import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/backend_config.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'bookmark_service.dart';

// Supabase backend (see supabase/schema.sql and SUPABASE_SETUP.md). Only used
// when BackendConfig.isEnabled; otherwise the app stays fully local.
//
// Supabase is the source of truth for auth and scores. The signed-in user is
// mirrored into the local users DB (AuthService.cacheCloudUser) so the rest of
// the app, which reads the local session, keeps working unchanged and offline.
class CloudService {
  static const String _pendingKey = 'maher_cloud_pending';

  static bool _initialized = false;

  // True only when configured AND initialized, so a failed init (bad URL)
  // falls back to local mode instead of crashing on the first call
  static bool get isEnabled => _initialized;

  static Future<void> initialize() async {
    if (!BackendConfig.isEnabled || _initialized) return;
    await Supabase.initialize(
      url: BackendConfig.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: BackendConfig.supabaseAnonKey,
    );
    _initialized = true;
  }

  static SupabaseClient get _client => Supabase.instance.client;

  static bool get hasSession =>
      isEnabled && _client.auth.currentSession != null;

  /// Returns the date string in IST (UTC+5:30), matching the server's expectation.
  static String _todayStrIst() {
    final ist = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    return ist.toIso8601String().substring(0, 10);
  }

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  static Future<CloudAuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      if (res.user == null) {
        return const CloudAuthResult.failure('invalid_credentials');
      }
      final user = await _loadProfileAndCache(importLegacy: true);
      if (user == null) return const CloudAuthResult.failure('profile_missing');
      return CloudAuthResult.success(user);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('confirm')) {
        return const CloudAuthResult.failure('email_not_confirmed');
      }
      return const CloudAuthResult.failure('invalid_credentials');
    } catch (e) {
      debugPrint('CloudService.signIn: $e');
      return const CloudAuthResult.failure('network');
    }
  }

  static Future<CloudAuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required String ageGroup,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {'name': name.trim(), 'age_group': ageGroup},
      );
      // Email confirmation enabled in the project: no session until confirmed
      if (res.session == null) {
        return const CloudAuthResult.failure('confirm_email');
      }
      final user = await _loadProfileAndCache(importLegacy: true);
      if (user == null) return const CloudAuthResult.failure('profile_missing');
      return CloudAuthResult.success(user);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already') || msg.contains('registered')) {
        return const CloudAuthResult.failure('already_registered');
      }
      if (msg.contains('password')) {
        return const CloudAuthResult.failure('weak_password');
      }
      debugPrint('CloudService.signUp: ${e.message}');
      return const CloudAuthResult.failure('signup_failed');
    } catch (e) {
      debugPrint('CloudService.signUp: $e');
      return const CloudAuthResult.failure('network');
    }
  }

  /// Signs in to Supabase using a Google ID token obtained from GoogleSignIn.
  /// This avoids Firebase entirely for the Google flow.
  static Future<CloudAuthResult> signInWithGoogle() async {
    try {
      final gs = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      final account = await gs.signIn();
      if (account == null) return const CloudAuthResult.failure('cancelled');
      final auth = await account.authentication;
      if (auth.idToken == null) return const CloudAuthResult.failure('signup_failed');

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: auth.idToken!,
        accessToken: auth.accessToken,
      );
      final user = await _loadProfileAndCache(importLegacy: true);
      return user == null
          ? const CloudAuthResult.failure('profile_missing')
          : CloudAuthResult.success(user);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid')) return const CloudAuthResult.failure('invalid_credentials');
      if (msg.contains('confir')) return const CloudAuthResult.failure('email_not_confirmed');
      debugPrint('CloudService.signInWithGoogle: $e');
      return const CloudAuthResult.failure('network');
    } catch (_) {
      return const CloudAuthResult.failure('network');
    }
  }

  static Future<void> signOut() async {
    if (!isEnabled) return;
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('CloudService.signOut: $e');
    }
    // Sign out of Google so the next "Continue with Google" doesn't
    // silently reuse the previous account (fixes G3).
    try {
      await GoogleSignIn().signOut();
      await GoogleSignIn().disconnect();
    } catch (e) {
      debugPrint('CloudService.signOut google: $e');
    }
  }

  // Deletes current user account permanently via delete_my_account RPC
  static Future<bool> deleteAccount() async {
    if (!isEnabled || !hasSession) return false;
    try {
      await _client.rpc('delete_my_account');
      await _client.auth.signOut();
      return true;
    } catch (e) {
      debugPrint('CloudService.deleteAccount: $e');
      return false;
    }
  }

  // Sends a 6-digit recovery code by email (the project's "Reset Password"
  // email template must contain {{ .Token }}, see SUPABASE_SETUP.md).
  static Future<bool> sendPasswordResetCode(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim().toLowerCase());
      return true;
    } catch (e) {
      debugPrint('CloudService.sendPasswordResetCode: $e');
      return false;
    }
  }

  static Future<bool> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _client.auth.verifyOTP(
        email: email.trim().toLowerCase(),
        token: code.trim(),
        type: OtpType.recovery,
      );
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      // The recovery flow signs the user in; leave them on the login screen
      await _client.auth.signOut();
      return true;
    } catch (e) {
      debugPrint('CloudService.resetPasswordWithCode: $e');
      return false;
    }
  }

  // Re-authenticates with the current password, then sets the new one
  static Future<String?> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: currentPassword,
      );
    } on AuthException {
      return 'wrong_current_password';
    } catch (_) {
      return 'network_error';
    }
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return null;
    } catch (e) {
      debugPrint('CloudService.changePassword: $e');
      return 'network_error';
    }
  }

  static Future<String?> updateProfile({
    required String name,
    required String ageGroup,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return 'network_error';
    try {
      await _client
          .from('profiles')
          .update({'name': name.trim(), 'age_group': ageGroup})
          .eq('id', uid);
      return null;
    } catch (e) {
      debugPrint('CloudService.updateProfile: $e');
      return 'network_error';
    }
  }

  // ---------------------------------------------------------------------------
  // Profile mirror & sync
  // ---------------------------------------------------------------------------

  static UserModel _profileToUser(Map<String, dynamic> p, String email,
      {UserModel? localCopy}) {
    final base = localCopy ?? UserModel(id: p['member_code'] as String, name: '');
    return base.copyWith(
      id: p['member_code'] as String,
      name: (p['name'] as String?) ?? '',
      email: email,
      ageGroup: (p['age_group'] as String?) ?? 'General / Adult',
      role: (p['role'] as String?) ?? 'student',
      status: 'active',
      totalScore: (p['total_score'] as num?)?.toInt() ?? 0,
      practiceXp: (p['practice_xp'] as num?)?.toInt() ?? 0,
      quizzesCompleted: (p['quizzes_completed'] as num?)?.toInt() ?? 0,
      streak: (p['streak'] as num?)?.toInt() ?? 0,
      bestStreak: (p['best_streak'] as num?)?.toInt() ?? 0,
      lastQuizDate: p['last_quiz_date'] as String?,
      lastQuizScore: (p['last_quiz_score'] as num?)?.toInt() ?? 0,
      mustChangePassword: false,
    );
  }

  static Map<String, dynamic>? _asRow(dynamic res) {
    if (res is Map<String, dynamic>) return res;
    if (res is List && res.isNotEmpty && res.first is Map<String, dynamic>) {
      return res.first as Map<String, dynamic>;
    }
    return null;
  }

  // Fetches the server profile and writes the local mirror. On the first
  // sign-in on a device that has an old local account with the same email,
  // its stats and bookmarks are imported once.
  static Future<UserModel?> _loadProfileAndCache({bool importLegacy = false}) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;
    final email = (authUser.email ?? '').toLowerCase();

    var profile = await _client
        .from('profiles')
        .select()
        .eq('id', authUser.id)
        .single();

    final memberCode = profile['member_code'] as String;
    final legacy = await AuthService.findLocalUserByEmail(email);
    final hasLegacy = legacy != null && legacy.id != memberCode;

    if (importLegacy && hasLegacy && profile['stats_imported'] != true) {
      try {
        final imported = _asRow(await _client.rpc('import_local_stats', params: {
          'p_total_score': legacy.totalScore,
          'p_practice_xp': legacy.practiceXp,
          'p_quizzes': legacy.quizzesCompleted,
          'p_streak': legacy.streak,
          'p_best_streak': legacy.bestStreak,
          'p_last_quiz_date': legacy.lastQuizDate,
          'p_last_quiz_score': legacy.lastQuizScore,
        }));
        if (imported != null) profile = imported;
      } catch (e) {
        debugPrint('CloudService: stats import failed: $e');
      }
    }

    // Keep local-only fields (avatar, phone, daily lock) from the local copy,
    // whether that is the existing mirror or the old local account
    final user = _profileToUser(profile, email, localCopy: legacy);
    await AuthService.cacheCloudUser(user, legacyLocalId: hasLegacy ? legacy.id : null);
    await _syncBookmarks();
    return user;
  }

  // Called on Home load: sends queued results, then refreshes the mirror
  // from the server. Returns null when offline (local data is used as is).
  static Future<UserModel?> syncOnHomeLoad() async {
    if (!hasSession) return null;
    try {
      await _flushPending();
      return await _loadProfileAndCache();
    } catch (e) {
      debugPrint('CloudService.syncOnHomeLoad (offline?): $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Scores (queued while offline)
  // ---------------------------------------------------------------------------

  // Returns the updated user from the server, or null if it was queued
  static Future<UserModel?> submitQuizResult({
    required int score,
    required bool isDaily,
  }) async {
    if (!hasSession) return null;
    final item = {
      'type': isDaily ? 'daily' : 'practice',
      'date': _todayStrIst(), // Use IST date to match server (C4 fix)
      'score': score,
    };
    try {
      final row = await _sendResult(item);
      if (row == null) return null;
      final email = (_client.auth.currentUser?.email ?? '').toLowerCase();
      final local = await AuthService.getCurrentUser();
      final user = _profileToUser(row, email, localCopy: local);
      await AuthService.cacheCloudUser(user);
      return user;
    } catch (e) {
      debugPrint('CloudService: result queued for later sync: $e');
      await _queue(item);
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _sendResult(Map<String, dynamic> item) async {
    if (item['type'] == 'daily') {
      return _asRow(await _client.rpc('submit_daily_result', params: {
        'p_date': item['date'],
        'p_score': item['score'],
      }));
    }
    return _asRow(await _client.rpc('add_practice_xp', params: {
      'p_score': item['score'],
    }));
  }

  static Future<void> _queue(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await AuthService.userScopedKey(prefs, _pendingKey);
    final list = prefs.getStringList(key) ?? [];
    list.add(json.encode(item));
    await prefs.setStringList(key, list);
  }

  static Future<void> _flushPending() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await AuthService.userScopedKey(prefs, _pendingKey);
    final list = prefs.getStringList(key) ?? [];
    if (list.isEmpty) return;

    final remaining = <String>[];
    for (final raw in list) {
      try {
        await _sendResult(json.decode(raw) as Map<String, dynamic>);
      } on PostgrestException catch (e) {
        // Rejected by the server (e.g. too old to count): drop it
        debugPrint('CloudService: dropped pending result: ${e.message}');
      } catch (_) {
        remaining.add(raw); // still offline
      }
    }
    await prefs.setStringList(key, remaining);
  }

  // ---------------------------------------------------------------------------
  // Leaderboard
  // ---------------------------------------------------------------------------

  static Future<List<CloudRankRow>> fetchLeaderboard(String filter) async {
    final res = await _client.rpc('get_leaderboard', params: {'p_filter': filter});
    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.map((r) {
      final today = (r['today_score'] as num?)?.toInt();
      final user = UserModel(
        id: r['member_code'] as String,
        name: (r['name'] as String?) ?? '',
        ageGroup: (r['age_group'] as String?) ?? '',
        totalScore: (r['total_score'] as num?)?.toInt() ?? 0,
        streak: (r['streak'] as num?)?.toInt() ?? 0,
        bestStreak: (r['best_streak'] as num?)?.toInt() ?? 0,
        lastQuizDate: r['last_quiz_date'] as String?,
        // For the "today" view, show today's score (or 0 if not played)
        lastQuizScore: filter == 'today'
            ? (today ?? 0)
            : (r['last_quiz_score'] as num?)?.toInt() ?? 0,
      );
      return CloudRankRow(user: user, isMe: r['is_me'] == true);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Bookmarks
  // ---------------------------------------------------------------------------

  static Future<void> setBookmark(String questionId, bool saved) async {
    // Check before touching the client: Supabase isn't initialized in local mode
    if (!hasSession) return;
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      if (saved) {
        await _client
            .from('bookmarks')
            .upsert({'user_id': uid, 'question_id': questionId});
      } else {
        await _client
            .from('bookmarks')
            .delete()
            .eq('user_id', uid)
            .eq('question_id', questionId);
      }
    } catch (e) {
      debugPrint('CloudService.setBookmark: $e');
    }
  }

  // Two-way merge: uploads local-only bookmarks, downloads remote ones
  static Future<void> _syncBookmarks() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final remoteRows =
          await _client.from('bookmarks').select('question_id').eq('user_id', uid);
      final remote =
          (remoteRows as List).map((r) => r['question_id'] as String).toSet();
      final local = await BookmarkService.getBookmarkedIds();

      final toUpload = local.difference(remote);
      if (toUpload.isNotEmpty) {
        await _client.from('bookmarks').upsert([
          for (final id in toUpload) {'user_id': uid, 'question_id': id},
        ]);
      }
      final toDownload = remote.difference(local);
      if (toDownload.isNotEmpty) {
        await BookmarkService.addBookmarks(toDownload, syncRemote: false);
      }
    } catch (e) {
      debugPrint('CloudService._syncBookmarks: $e');
    }
  }
}

class CloudAuthResult {
  final UserModel? user;
  // invalid_credentials | email_not_confirmed | confirm_email |
  // already_registered | weak_password | signup_failed | network | profile_missing
  final String? error;

  const CloudAuthResult.success(UserModel this.user) : error = null;
  const CloudAuthResult.failure(String this.error) : user = null;

  bool get ok => user != null;
}

class CloudRankRow {
  final UserModel user;
  final bool isMe;

  const CloudRankRow({required this.user, required this.isMe});
}
