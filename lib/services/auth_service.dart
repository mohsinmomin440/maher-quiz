import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'cloud_service.dart';

class AuthService {
  static const String _userKey = 'maher_current_user';
  static const String _usersDbKey = 'maher_registered_users';
  static const String _passwordsDbKey = 'maher_user_passwords';
  static const String _salt = 'maher_deeniyat_secure_salt_786';
  static const String _sessionTemporaryKey = 'maher_session_temporary';
  static const String _defaultAdminEmail = 'admin@maher.app';
  static const String _defaultAdminPassword = 'Admin@786';

  // Secure Password Hashing with SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password + _salt);
    return sha256.convert(bytes).toString();
  }

  // Current session's user ID, read straight from prefs (no seeding)
  static String? sessionUserId(SharedPreferences prefs) {
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    try {
      final id = UserModel.fromJson(userStr).id;
      return id.isEmpty ? null : id;
    } catch (_) {
      return null;
    }
  }

  // Scopes a prefs key to the logged-in user so data like bookmarks is not
  // shared between accounts on the same device. A legacy device-wide value
  // is migrated to the first user that reads it.
  static Future<String> userScopedKey(
      SharedPreferences prefs, String baseKey) async {
    final id = sessionUserId(prefs);
    if (id == null) return baseKey;
    final scoped = '${baseKey}_$id';
    if (!prefs.containsKey(scoped) && prefs.containsKey(baseKey)) {
      final legacy = prefs.get(baseKey);
      if (legacy is List) {
        await prefs.setStringList(scoped, List<String>.from(legacy));
      } else if (legacy is bool) {
        await prefs.setBool(scoped, legacy);
      }
      await prefs.remove(baseKey);
    }
    return scoped;
  }

  // Pre-seed default Student and purge any old admin accounts
  static Future<void> ensureSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString(_usersDbKey);

    Map<String, dynamic> users = {};
    Map<String, dynamic> passwords = {};

    if (usersStr != null && usersStr.isNotEmpty && usersStr != '{}') {
      try {
        users = json.decode(usersStr);
        final passStr = prefs.getString(_passwordsDbKey);
        if (passStr != null) {
          passwords = json.decode(passStr);
        }
      } catch (_) {}
    }

    // Seed a bootstrap admin only when the device has no admin at all (so
    // renaming or replacing the admin doesn't re-create the default one).
    // Its well-known default password must be changed on first login.
    final hasAdmin = users.values.any(
        (u) => u is Map<String, dynamic> && UserModel.fromMap(u).isAdmin);
    if (!hasAdmin) {
      final admin = UserModel(
        id: 'MHR-ADMIN-01',
        name: 'Maher Admin',
        email: _defaultAdminEmail,
        phone: '',
        ageGroup: 'General / Adult',
        role: 'admin',
        createdAt: '2026-09-01',
        status: 'active',
        mustChangePassword: true,
      );
      users[_defaultAdminEmail] = admin.toMap();
      passwords[_defaultAdminEmail] = hashPassword(_defaultAdminPassword);
    }

    // Installs seeded before the forced change: flag the admin if it still
    // uses the default password.
    final seeded = users[_defaultAdminEmail];
    if (seeded is Map<String, dynamic> &&
        passwords[_defaultAdminEmail] == hashPassword(_defaultAdminPassword) &&
        seeded['mustChangePassword'] != true) {
      seeded['mustChangePassword'] = true;
    }

    await prefs.setString(_usersDbKey, json.encode(users));
    await prefs.setString(_passwordsDbKey, json.encode(passwords));
  }

  // Get current logged-in user with session integrity check
  static Future<UserModel?> getCurrentUser() async {
    await ensureSeeded();
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      try {
        final parsed = UserModel.fromJson(userStr);
        final usersStr = prefs.getString(_usersDbKey);
        if (usersStr != null) {
          final Map<String, dynamic> users = json.decode(usersStr);
          for (final val in users.values) {
            final dbUser = UserModel.fromMap(val);
            if ((parsed.id.isNotEmpty && dbUser.id == parsed.id) ||
                (parsed.phone.isNotEmpty && dbUser.phone == parsed.phone) ||
                (parsed.email.isNotEmpty && dbUser.email == parsed.email)) {
              if (dbUser.status == 'active') {
                return dbUser;
              }
            }
          }
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Register a new student. Returns null on success, otherwise an error code:
  // already_registered | confirm_email | weak_password | signup_failed | network
  static Future<String?> register({
    required String name,
    String? identifier,
    String? email,
    required String password,
    required String ageGroup,
  }) async {
    final rawInput = (identifier ?? email ?? '').trim();
    final cleanDigits = rawInput.replaceAll(RegExp(r'\D'), '');
    final isPhone = cleanDigits.length >= 10 && !rawInput.contains('@');
    final mappedEmail = isPhone ? '$cleanDigits@phone.maher.quiz' : rawInput.toLowerCase();

    if (CloudService.isEnabled) {
      final res = await CloudService.signUp(
        name: name,
        email: mappedEmail,
        password: password,
        ageGroup: ageGroup,
      );
      if (!res.ok) return res.error;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionTemporaryKey);
      return null;
    }

    await ensureSeeded();
    final prefs = await SharedPreferences.getInstance();
    final cleanInput = rawInput.toLowerCase();

    Map<String, dynamic> users = {};
    final usersStr = prefs.getString(_usersDbKey);
    if (usersStr != null) {
      try {
        users = json.decode(usersStr);
      } catch (_) {}
    }

    // Check if user already exists
    for (final entry in users.entries) {
      final u = UserModel.fromMap(entry.value);
      if (entry.key.toLowerCase() == cleanInput ||
          (isPhone && u.phone == cleanDigits) ||
          (!isPhone && u.email.toLowerCase() == cleanInput)) {
        return 'already_registered';
      }
    }

    Map<String, dynamic> passwords = {};
    final passStr = prefs.getString(_passwordsDbKey);
    if (passStr != null) {
      try {
        passwords = json.decode(passStr);
      } catch (_) {}
    }

    final newId = _generateUserId(users);
    final newUser = UserModel(
      id: newId,
      name: name.trim(),
      email: isPhone ? '$cleanDigits@maher.app' : cleanInput,
      phone: isPhone ? cleanDigits : '',
      ageGroup: ageGroup,
      role: 'student',
      createdAt: DateTime.now().toIso8601String().substring(0, 10),
    );

    final key = isPhone ? cleanDigits : cleanInput;
    users[key] = newUser.toMap();
    passwords[key] = hashPassword(password);

    await prefs.setString(_usersDbKey, json.encode(users));
    await prefs.setString(_passwordsDbKey, json.encode(passwords));
    await prefs.setString(_userKey, newUser.toJson());
    await prefs.remove(_sessionTemporaryKey);

    return null;
  }

  // Random member ID (e.g. MHR-7KQ2XP), unique among existing users. The
  // alphabet skips look-alike characters (0/O, 1/I).
  static String _generateUserId(Map<String, dynamic> users) {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final existing = users.values
        .whereType<Map<String, dynamic>>()
        .map((u) => u['id'])
        .toSet();
    while (true) {
      final suffix = List.generate(
          6, (_) => alphabet[random.nextInt(alphabet.length)]).join();
      final id = 'MHR-$suffix';
      if (!existing.contains(id)) return id;
    }
  }

  // Secure Login with Phone or Email + Password. With rememberMe false the
  // session is cleared the next time the app starts.
  static Future<AuthResult> login({
    required String identifier,
    required String password,
    bool rememberMe = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final cleanDigits = identifier.replaceAll(RegExp(r'\D'), '');
    final isPhone = cleanDigits.length >= 10 && !identifier.contains('@');
    final mappedEmail = isPhone ? '$cleanDigits@phone.maher.quiz' : identifier.trim().toLowerCase();

    if (CloudService.isEnabled) {
      final res =
          await CloudService.signIn(email: mappedEmail, password: password);
      if (!res.ok) return AuthResult.failure(res.error!);
      await prefs.setBool(_sessionTemporaryKey, !rememberMe);
      return AuthResult.success(res.user!);
    }
    final user = await _localLogin(prefs, identifier, password);
    if (user == null) return const AuthResult.failure('invalid_credentials');
    await prefs.setBool(_sessionTemporaryKey, !rememberMe);
    return AuthResult.success(user);
  }

  static Future<UserModel?> _localLogin(
      SharedPreferences prefs, String identifier, String password) async {
    await ensureSeeded();
    final cleanInput = identifier.trim().toLowerCase();
    // Only treat the input as a phone number when it isn't an email
    var cleanDigits = cleanInput.contains('@')
        ? ''
        : identifier.replaceAll(RegExp(r'\D'), '');
    // Phones are stored as 10 digits; accept a country-code prefix (+91 …)
    if (cleanDigits.length > 10) {
      cleanDigits = cleanDigits.substring(cleanDigits.length - 10);
    }

    final passStr = prefs.getString(_passwordsDbKey);
    if (passStr == null) return null;

    final Map<String, dynamic> passwords = json.decode(passStr);
    final inputHash = hashPassword(password);

    final usersStr = prefs.getString(_usersDbKey);
    if (usersStr == null) return null;
    final Map<String, dynamic> users = json.decode(usersStr);

    String? matchedKey;
    UserModel? matchedUser;

    for (final entry in users.entries) {
      final u = UserModel.fromMap(entry.value);
      if (entry.key.toLowerCase() == cleanInput ||
          u.email.toLowerCase() == cleanInput ||
          (cleanDigits.isNotEmpty && u.phone == cleanDigits)) {
        matchedKey = entry.key;
        matchedUser = u;
        break;
      }
    }

    if (matchedUser == null || matchedKey == null) {
      return null;
    }

    final storedPass = passwords[matchedKey] ??
        passwords[matchedUser.email] ??
        passwords[matchedUser.phone];
    if (storedPass == null) return null;

    if (storedPass != inputHash) {
      // Accounts from old versions may still hold a plain-text password:
      // accept it once and replace it with the hash so it is never stored
      // or compared in plain text again.
      if (storedPass != password) return null; // Invalid credentials
      _setPasswordForUser(passwords, matchedKey, matchedUser, inputHash);
      await prefs.setString(_passwordsDbKey, json.encode(passwords));
    }

    if (matchedUser.status != 'active') return null;

    await prefs.setString(_userKey, matchedUser.toJson());
    return matchedUser;
  }

  // Writes a password hash under the user's DB key and every alias (email,
  // phone) that login and changePassword may look it up by.
  static void _setPasswordForUser(Map<String, dynamic> passwords, String key,
      UserModel user, String hash) {
    passwords[key] = hash;
    if (user.email.isNotEmpty) passwords[user.email] = hash;
    if (user.phone.isNotEmpty) passwords[user.phone] = hash;
  }

  // Called once at app start: ends a session that was logged in without
  // "Remember me", or whose Supabase session has ended (cloud mode).
  static Future<void> clearTemporarySession() async {
    final prefs = await SharedPreferences.getInstance();
    final temporary = prefs.getBool(_sessionTemporaryKey) ?? false;
    final cloudSessionLost = CloudService.isEnabled &&
        prefs.containsKey(_userKey) &&
        !CloudService.hasSession;
    if (temporary || cloudSessionLost) {
      await logout();
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_sessionTemporaryKey);
    await CloudService.signOut();
  }

  // Self-deletion of current user account (Store compliance & DPDP privacy)
  static Future<bool> deleteCurrentAccount() async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return false;

    if (CloudService.isEnabled && CloudService.hasSession) {
      await CloudService.deleteAccount();
    }

    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString(_usersDbKey);
    if (usersStr != null) {
      Map<String, dynamic> users = json.decode(usersStr);
      users.remove(currentUser.id);
      users.remove(currentUser.email.toLowerCase());
      if (currentUser.phone.isNotEmpty) users.remove(currentUser.phone);
      await prefs.setString(_usersDbKey, json.encode(users));
    }

    final passStr = prefs.getString(_passwordsDbKey);
    if (passStr != null) {
      Map<String, dynamic> pass = json.decode(passStr);
      pass.remove(currentUser.id);
      pass.remove(currentUser.email.toLowerCase());
      if (currentUser.phone.isNotEmpty) pass.remove(currentUser.phone);
      await prefs.setString(_passwordsDbKey, json.encode(pass));
    }

    await logout();
    return true;
  }

  // ---------------------------------------------------------------------------
  // Cloud mirror helpers (used by CloudService)
  // ---------------------------------------------------------------------------

  static Future<UserModel?> findLocalUserByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString(_usersDbKey);
    if (usersStr == null) return null;
    try {
      final Map<String, dynamic> users = json.decode(usersStr);
      for (final val in users.values) {
        if (val is! Map<String, dynamic>) continue;
        final u = UserModel.fromMap(val);
        if (u.email.toLowerCase() == normalized) return u;
      }
    } catch (_) {}
    return null;
  }

  // Writes the signed-in cloud user into the local users DB and session.
  // When it replaces an old local account (legacyLocalId), that account's
  // per-user prefs (bookmarks, seen questions, ...) move to the new ID.
  static Future<void> cacheCloudUser(UserModel user,
      {String? legacyLocalId}) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> users = {};
    final usersStr = prefs.getString(_usersDbKey);
    if (usersStr != null) {
      try {
        users = json.decode(usersStr);
      } catch (_) {}
    }
    users.removeWhere((key, val) {
      if (val is! Map<String, dynamic>) return false;
      final u = UserModel.fromMap(val);
      return u.id == user.id ||
          (legacyLocalId != null && u.id == legacyLocalId) ||
          u.email.toLowerCase() == user.email.toLowerCase();
    });
    users[user.email.toLowerCase()] = user.toMap();
    await prefs.setString(_usersDbKey, json.encode(users));
    await prefs.setString(_userKey, user.toJson());

    if (legacyLocalId != null && legacyLocalId != user.id) {
      await _migrateScopedPrefs(prefs, legacyLocalId, user.id);
    }
  }

  static const List<String> _userScopedBaseKeys = [
    'maher_bookmarked_questions',
    'maher_seen_question_ids',
    'maher_badge_jumuah_unlocked',
    'maher_question_lang',
    'maher_daily_progress',
    'maher_cloud_pending',
  ];

  static Future<void> _migrateScopedPrefs(
      SharedPreferences prefs, String fromId, String toId) async {
    for (final base in _userScopedBaseKeys) {
      final from = '${base}_$fromId';
      final to = '${base}_$toId';
      if (!prefs.containsKey(from) || prefs.containsKey(to)) continue;
      final value = prefs.get(from);
      if (value is List) {
        await prefs.setStringList(to, List<String>.from(value));
      } else if (value is bool) {
        await prefs.setBool(to, value);
      } else if (value is String) {
        await prefs.setString(to, value);
      }
      await prefs.remove(from);
    }
  }

  static String _todayStr() =>
      DateTime.now().toIso8601String().substring(0, 10);

  static const String _dailyProgressKey = 'maher_daily_progress';

  // Locks today's daily quiz as soon as it is opened, so leaving and
  // restarting it (with the same date-seeded questions) is not possible.
  static Future<UserModel?> markDailyStarted() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = await getCurrentUser();
    if (currentUser == null) return null;

    final today = _todayStr();
    if (currentUser.dailyStartedDate == today) return currentUser;

    final updated = currentUser.copyWith(dailyStartedDate: today);
    // No progress reset here: a stale entry from another day is ignored by
    // finalizeAbandonedDaily, and resetting could race the first answer.
    await _saveCurrentUser(prefs, currentUser, updated);
    return updated;
  }

  // Running score of the in-progress daily quiz, so it can still be
  // submitted if the app is closed mid-quiz.
  static Future<void> saveDailyProgress(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await userScopedKey(prefs, _dailyProgressKey);
    await prefs.setString(key, '${_todayStr()}|$score');
  }

  // If today's daily quiz was opened but never finished (app closed), submit
  // the score earned so far. Returns the up-to-date user.
  static Future<UserModel?> finalizeAbandonedDaily() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = await getCurrentUser();
    if (currentUser == null) return null;

    final today = _todayStr();
    if (currentUser.dailyStartedDate != today ||
        currentUser.lastQuizDate == today) {
      return currentUser;
    }

    final key = await userScopedKey(prefs, _dailyProgressKey);
    final parts = (prefs.getString(key) ?? '').split('|');
    final score = (parts.length == 2 && parts[0] == today)
        ? (int.tryParse(parts[1]) ?? 0)
        : 0;
    return recordQuizCompletion(score: score, isDaily: true);
  }

  // Update user score and daily streak. Daily quizzes feed totalScore (used
  // for ranking); practice and revision rounds only earn practiceXp.
  static Future<UserModel?> recordQuizCompletion({
    required int score,
    required bool isDaily,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = await getCurrentUser();
    if (currentUser == null) return null;

    final todayStr = _todayStr();

    // Only one daily result per day counts
    if (isDaily && currentUser.lastQuizDate == todayStr) return currentUser;

    UserModel updated;
    if (isDaily) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr = yesterday.toIso8601String().substring(0, 10);
      final newStreak =
          currentUser.lastQuizDate == yesterdayStr ? currentUser.streak + 1 : 1;

      updated = currentUser.copyWith(
        streak: newStreak,
        bestStreak: newStreak > currentUser.bestStreak
            ? newStreak
            : currentUser.bestStreak,
        quizzesCompleted: currentUser.quizzesCompleted + 1,
        totalScore: currentUser.totalScore + score,
        lastQuizDate: todayStr,
        lastQuizScore: score,
        dailyStartedDate: todayStr,
      );
      final key = await userScopedKey(prefs, _dailyProgressKey);
      await prefs.remove(key);
    } else {
      updated = currentUser.copyWith(
        quizzesCompleted: currentUser.quizzesCompleted + 1,
        practiceXp: currentUser.practiceXp + score,
      );
    }

    await _saveCurrentUser(prefs, currentUser, updated);

    // The server applies the same rules (with its own date) and is
    // authoritative; offline results are queued and sent on the next Home load
    if (CloudService.isEnabled) {
      final synced =
          await CloudService.submitQuizResult(score: score, isDaily: isDaily);
      if (synced != null) return synced;
    }
    return updated;
  }

  // Persists an updated copy of the logged-in user to both the session and
  // the users database.
  static Future<void> _saveCurrentUser(
      SharedPreferences prefs, UserModel currentUser, UserModel updated) async {
    await prefs.setString(_userKey, updated.toJson());

    final usersStr = prefs.getString(_usersDbKey);
    if (usersStr != null) {
      Map<String, dynamic> users = json.decode(usersStr);
      String? foundKey;
      for (final entry in users.entries) {
        final u = UserModel.fromMap(entry.value);
        if ((currentUser.id.isNotEmpty && u.id == currentUser.id) ||
            (currentUser.phone.isNotEmpty && u.phone == currentUser.phone) ||
            (currentUser.email.isNotEmpty && u.email == currentUser.email)) {
          foundKey = entry.key;
          break;
        }
      }
      if (foundKey != null) {
        users[foundKey] = updated.toMap();
      } else {
        final k = currentUser.phone.isNotEmpty
            ? currentUser.phone
            : currentUser.email;
        users[k] = updated.toMap();
      }
      await prefs.setString(_usersDbKey, json.encode(users));
    }
  }

  // Get all real registered users for Leaderboard
  static Future<List<UserModel>> getAllUsers() async {
    await ensureSeeded();
    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString(_usersDbKey);
    if (usersStr == null || usersStr.isEmpty) return [];

    try {
      final Map<String, dynamic> usersMap = json.decode(usersStr);
      final Map<String, UserModel> uniqueMap = {};
      for (final val in usersMap.values) {
        if (val is Map<String, dynamic>) {
          final u = UserModel.fromMap(val);
          if (u.status == 'active' && u.name.trim().isNotEmpty) {
            // Deduplicate by ID
            uniqueMap[u.id] = u;
          }
        }
      }
      return uniqueMap.values.toList();
    } catch (_) {
      return [];
    }
  }

  // Helper to locate a user by identifier (email, phone, ID, or key)
  static MapEntry<String, UserModel>? _findUserEntry(
      Map<String, dynamic> users, String identifier) {
    final normalized = identifier.trim().toLowerCase();
    final cleanDigits = normalized.replaceAll(RegExp(r'\D'), '');
    final last10Digits = cleanDigits.length >= 10
        ? cleanDigits.substring(cleanDigits.length - 10)
        : cleanDigits;

    for (final entry in users.entries) {
      if (entry.value is! Map<String, dynamic>) continue;
      final u = UserModel.fromMap(entry.value);
      final phoneDigits = u.phone.replaceAll(RegExp(r'\D'), '');
      if (entry.key.toLowerCase() == normalized ||
          u.email.toLowerCase() == normalized ||
          u.id.toLowerCase() == normalized ||
          (last10Digits.isNotEmpty &&
              phoneDigits.isNotEmpty &&
              phoneDigits.endsWith(last10Digits))) {
        return MapEntry(entry.key, u);
      }
    }
    return null;
  }

  // Admin deletes a user account
  static Future<bool> adminDeleteUser(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString(_usersDbKey);
    if (usersStr == null) return false;

    Map<String, dynamic> users = json.decode(usersStr);
    final match = _findUserEntry(users, identifier);
    if (match == null) return false;

    final foundKey = match.key;
    final foundUser = match.value;

    users.remove(foundKey);
    await prefs.setString(_usersDbKey, json.encode(users));

    final passStr = prefs.getString(_passwordsDbKey);
    if (passStr != null) {
      Map<String, dynamic> pass = json.decode(passStr);
      pass.remove(foundKey);
      if (foundUser.email.isNotEmpty) pass.remove(foundUser.email.toLowerCase());
      if (foundUser.phone.isNotEmpty) pass.remove(foundUser.phone);
      if (foundUser.id.isNotEmpty) pass.remove(foundUser.id);
      await prefs.setString(_passwordsDbKey, json.encode(pass));
    }
    return true;
  }

  // Admin toggles user role (student <-> admin)
  static Future<UserModel?> adminToggleUserRole(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString(_usersDbKey);
    if (usersStr == null) return null;

    Map<String, dynamic> users = json.decode(usersStr);
    final match = _findUserEntry(users, identifier);
    if (match == null) return null;

    final foundKey = match.key;
    final foundUser = match.value;

    final newRole = (foundUser.role == 'admin') ? 'student' : 'admin';
    final updated = foundUser.copyWith(role: newRole);
    users[foundKey] = updated.toMap();
    await prefs.setString(_usersDbKey, json.encode(users));
    return updated;
  }

  // Admin resets a user's password
  // Sets a temporary password; the user must change it at next login. The
  // hash is written under the user's real DB key and all aliases, since
  // users with a phone are looked up by phone first.
  static Future<bool> adminResetPassword(String identifier, String newPass) async {
    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString(_usersDbKey);
    if (usersStr == null) return false;
    final Map<String, dynamic> users = json.decode(usersStr);

    final match = _findUserEntry(users, identifier);
    if (match == null) return false;

    final foundKey = match.key;
    final foundUser = match.value;

    final passStr = prefs.getString(_passwordsDbKey);
    Map<String, dynamic> passwords = {};
    if (passStr != null) {
      try {
        passwords = json.decode(passStr);
      } catch (_) {}
    }

    _setPasswordForUser(passwords, foundKey, foundUser, hashPassword(newPass));
    users[foundKey] = foundUser.copyWith(mustChangePassword: true).toMap();

    await prefs.setString(_passwordsDbKey, json.encode(passwords));
    await prefs.setString(_usersDbKey, json.encode(users));
    return true;
  }

  // Readable temporary password for admin resets (no look-alike characters)
  static String generateTemporaryPassword() {
    const alphabet = 'abcdefghjkmnpqrstuvwxyz23456789';
    final random = Random.secure();
    return List.generate(8, (_) => alphabet[random.nextInt(alphabet.length)])
        .join();
  }

  // Update Profile (Name, Phone, Email, Age Group, Avatar)
  static Future<ProfileUpdateResult> updateProfile({
    required String userId,
    required String name,
    required String phone,
    required String email,
    required String ageGroup,
    required String avatar,
  }) async {
    await ensureSeeded();
    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString(_usersDbKey);
    if (usersStr == null) {
      return const ProfileUpdateResult(
        success: false,
        errorMessage: 'Users database not found',
      );
    }

    Map<String, dynamic> users = json.decode(usersStr);
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final cleanEmail = email.trim().toLowerCase();

    // Cloud mode: name and age group are saved to Supabase; the email is the
    // login and can't be changed here. Phone and photo stay on the device.
    if (CloudService.isEnabled) {
      UserModel? existing;
      for (final val in users.values) {
        final u = UserModel.fromMap(val);
        if (u.id == userId) existing = u;
      }
      if (existing != null) {
        if (cleanEmail != existing.email.toLowerCase()) {
          return const ProfileUpdateResult(
            success: false,
            errorMessage: 'email_change_not_supported',
          );
        }
        if (name.trim() != existing.name || ageGroup != existing.ageGroup) {
          final error =
              await CloudService.updateProfile(name: name, ageGroup: ageGroup);
          if (error != null) {
            return ProfileUpdateResult(success: false, errorMessage: error);
          }
        }
      }
    }

    // Check collision for phone and email with other users
    for (final entry in users.entries) {
      final u = UserModel.fromMap(entry.value);
      if (u.id != userId) {
        if (cleanPhone.isNotEmpty && u.phone.isNotEmpty && u.phone == cleanPhone) {
          return const ProfileUpdateResult(
            success: false,
            errorMessage: 'mobile_already_registered',
          );
        }
        if (cleanEmail.isNotEmpty &&
            u.email.isNotEmpty &&
            u.email.toLowerCase() == cleanEmail) {
          return const ProfileUpdateResult(
            success: false,
            errorMessage: 'email_already_registered',
          );
        }
      }
    }

    // Find current user's existing key and record
    String? currentKey;
    UserModel? currentUser;
    for (final entry in users.entries) {
      final u = UserModel.fromMap(entry.value);
      if (u.id == userId) {
        currentKey = entry.key;
        currentUser = u;
        break;
      }
    }

    if (currentUser == null || currentKey == null) {
      // Fallback search by old phone or email
      for (final entry in users.entries) {
        final u = UserModel.fromMap(entry.value);
        if ((cleanEmail.isNotEmpty && u.email.toLowerCase() == cleanEmail) ||
            (cleanPhone.isNotEmpty && u.phone == cleanPhone)) {
          currentKey = entry.key;
          currentUser = u;
          break;
        }
      }
    }

    if (currentUser == null || currentKey == null) {
      return const ProfileUpdateResult(
        success: false,
        errorMessage: 'User account not found',
      );
    }

    // Determine new primary key
    final String newKey = cleanPhone.isNotEmpty
        ? cleanPhone
        : (cleanEmail.isNotEmpty ? cleanEmail : currentKey);

    // Read passwords
    final passStr = prefs.getString(_passwordsDbKey);
    Map<String, dynamic> passwords = {};
    if (passStr != null) {
      try {
        passwords = json.decode(passStr);
      } catch (_) {}
    }

    // Migrate password to new key if key changed
    final existingPassword = passwords[currentKey] ??
        passwords[currentUser.email] ??
        passwords[currentUser.phone];
    if (existingPassword != null) {
      passwords[newKey] = existingPassword;
      if (cleanEmail.isNotEmpty) passwords[cleanEmail] = existingPassword;
      if (cleanPhone.isNotEmpty) passwords[cleanPhone] = existingPassword;
    }

    // If key changed, remove old key
    if (newKey != currentKey) {
      users.remove(currentKey);
    }

    final updatedUser = currentUser.copyWith(
      name: name.trim(),
      phone: cleanPhone,
      email: cleanEmail,
      ageGroup: ageGroup,
      avatar: avatar,
    );

    users[newKey] = updatedUser.toMap();

    await prefs.setString(_usersDbKey, json.encode(users));
    await prefs.setString(_passwordsDbKey, json.encode(passwords));
    await prefs.setString(_userKey, updatedUser.toJson());

    return ProfileUpdateResult(success: true, user: updatedUser);
  }

  // Change Password for Logged-In User
  static Future<PasswordChangeResult> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    await ensureSeeded();
    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString(_usersDbKey);
    if (usersStr == null) {
      return const PasswordChangeResult(
        success: false,
        errorMessage: 'User database not found',
      );
    }

    final Map<String, dynamic> users = json.decode(usersStr);
    String? matchedKey;
    UserModel? matchedUser;

    for (final entry in users.entries) {
      final u = UserModel.fromMap(entry.value);
      if (u.id == userId) {
        matchedKey = entry.key;
        matchedUser = u;
        break;
      }
    }

    if (matchedUser == null || matchedKey == null) {
      return const PasswordChangeResult(
        success: false,
        errorMessage: 'User account not found',
      );
    }

    // Cloud mode: passwords live in Supabase Auth only
    if (CloudService.isEnabled) {
      if (newPassword.length < 6) {
        return const PasswordChangeResult(
          success: false,
          errorMessage: 'password_min_length',
        );
      }
      final error = await CloudService.changePassword(
        email: matchedUser.email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return PasswordChangeResult(success: error == null, errorMessage: error);
    }

    final passStr = prefs.getString(_passwordsDbKey);
    if (passStr == null) {
      return const PasswordChangeResult(
        success: false,
        errorMessage: 'Password storage error',
      );
    }

    final Map<String, dynamic> passwords = json.decode(passStr);
    final storedPass = passwords[matchedKey] ??
        passwords[matchedUser.email] ??
        passwords[matchedUser.phone];

    // Hash only: legacy plain-text passwords are upgraded at login
    if (storedPass != hashPassword(currentPassword)) {
      return const PasswordChangeResult(
        success: false,
        errorMessage: 'wrong_current_password',
      );
    }

    // Passwords are never trimmed, so what is stored matches what login hashes
    if (newPassword.length < 6) {
      return const PasswordChangeResult(
        success: false,
        errorMessage: 'password_min_length',
      );
    }

    _setPasswordForUser(
        passwords, matchedKey, matchedUser, hashPassword(newPassword));
    await prefs.setString(_passwordsDbKey, json.encode(passwords));

    // A chosen password clears any forced-change requirement
    if (matchedUser.mustChangePassword) {
      final updated = matchedUser.copyWith(mustChangePassword: false);
      users[matchedKey] = updated.toMap();
      await prefs.setString(_usersDbKey, json.encode(users));
      if (sessionUserId(prefs) == matchedUser.id) {
        await prefs.setString(_userKey, updated.toJson());
      }
    }
    return const PasswordChangeResult(success: true);
  }
}

class ProfileUpdateResult {
  final bool success;
  final String? errorMessage;
  final UserModel? user;

  const ProfileUpdateResult({
    required this.success,
    this.errorMessage,
    this.user,
  });
}

class AuthResult {
  final UserModel? user;
  // invalid_credentials | email_not_confirmed | network | profile_missing
  final String? error;

  const AuthResult.success(UserModel this.user) : error = null;
  const AuthResult.failure(String this.error) : user = null;

  bool get ok => user != null;
}

class PasswordChangeResult {
  final bool success;
  final String? errorMessage;

  const PasswordChangeResult({
    required this.success,
    this.errorMessage,
  });
}

