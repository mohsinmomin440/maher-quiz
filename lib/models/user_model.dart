import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String ageGroup;
  final String role; // 'admin' or 'student'
  /// Authentication source: 'local' (password), 'google' (OAuth), or 'phone' (OTP)
  final String authSource; // 'local' | 'google' | 'phone'
  final String createdAt;
  final String status; // 'active' or 'suspended'
  final int streak;
  final int quizzesCompleted;
  final int totalScore;
  final String? lastQuizDate;
  final int lastQuizScore;
  final String avatar;
  // Points from practice/revision rounds; kept out of totalScore so the
  // leaderboard only reflects daily quizzes.
  final int practiceXp;
  final int bestStreak;
  // Date (yyyy-MM-dd) the daily quiz was last opened; used to lock it.
  final String? dailyStartedDate;
  // Set for the seeded admin and after an admin password reset; the user
  // must choose a new password before using the app.
  final bool mustChangePassword;

  /// Authentication source: 'local' (password), 'google' (OAuth), or 'phone' (OTP)
  /// Defaults to 'local' for existing users during migration

UserModel({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.ageGroup = 'General / Adult',
    this.role = 'student',
    String? createdAt,
    this.status = 'active',
    this.streak = 0,
    this.quizzesCompleted = 0,
    this.totalScore = 0,
    this.lastQuizDate,
    this.lastQuizScore = 0,
    this.avatar = '',
    this.practiceXp = 0,
    this.bestStreak = 0,
    this.dailyStartedDate,
    this.mustChangePassword = false,
    this.authSource = 'local',
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String().substring(0, 10);

  bool get isAdmin => role == 'admin';

  // Streak as it stands today: the stored streak only updates when a daily
  // quiz is completed, so it is already broken if the last one was before
  // yesterday.
  int get effectiveStreak {
    if (lastQuizDate == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime.tryParse(lastQuizDate!);
    if (last == null) return 0;
    final days = today.difference(DateTime(last.year, last.month, last.day)).inDays;
    return days <= 1 ? streak : 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'ageGroup': ageGroup,
      'role': role,
      'createdAt': createdAt,
      'status': status,
      'streak': streak,
      'quizzesCompleted': quizzesCompleted,
      'totalScore': totalScore,
      'lastQuizDate': lastQuizDate,
      'lastQuizScore': lastQuizScore,
      'avatar': avatar,
      'practiceXp': practiceXp,
      'bestStreak': bestStreak,
      'dailyStartedDate': dailyStartedDate,
      'mustChangePassword': mustChangePassword,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? 'MHR-${(map['email'] ?? map['phone'] ?? '').hashCode.abs() % 10000}',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      ageGroup: map['ageGroup'] ?? 'General / Adult',
      role: map['role'] ?? 'student',
      createdAt: map['createdAt'] ?? DateTime.now().toIso8601String().substring(0, 10),
      status: map['status'] ?? 'active',
      streak: map['streak'] ?? 0,
      quizzesCompleted: map['quizzesCompleted'] ?? 0,
      totalScore: map['totalScore'] ?? 0,
      lastQuizDate: map['lastQuizDate'],
      lastQuizScore: map['lastQuizScore'] ?? 0,
      avatar: map['avatar'] ?? '',
      practiceXp: map['practiceXp'] ?? 0,
      bestStreak: map['bestStreak'] ?? map['streak'] ?? 0,
      dailyStartedDate: map['dailyStartedDate'],
      mustChangePassword: map['mustChangePassword'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? ageGroup,
    String? role,
    String? createdAt,
    String? status,
    int? streak,
    int? quizzesCompleted,
    int? totalScore,
    String? lastQuizDate,
    int? lastQuizScore,
    String? avatar,
    int? practiceXp,
    int? bestStreak,
    String? dailyStartedDate,
    bool? mustChangePassword,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      ageGroup: ageGroup ?? this.ageGroup,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      streak: streak ?? this.streak,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      totalScore: totalScore ?? this.totalScore,
      lastQuizDate: lastQuizDate ?? this.lastQuizDate,
      lastQuizScore: lastQuizScore ?? this.lastQuizScore,
      avatar: avatar ?? this.avatar,
      practiceXp: practiceXp ?? this.practiceXp,
      bestStreak: bestStreak ?? this.bestStreak,
      dailyStartedDate: dailyStartedDate ?? this.dailyStartedDate,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }
}
