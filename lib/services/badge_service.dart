import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/badge_model.dart';
import '../models/user_model.dart';
import '../utils/maher_theme.dart';
import 'auth_service.dart';

class BadgeService {
  static const String _jumuahKey = 'maher_badge_jumuah_unlocked';

  // Evaluate all badges for current user
  static Future<List<BadgeModel>> getUserBadges(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final jumuahKey = await AuthService.userScopedKey(prefs, _jumuahKey);
    final jumuahUnlocked = prefs.getBool(jumuahKey) ?? false;

    // Check if today or last quiz was on a Friday (DateTime.friday == 5)
    bool hasPlayedOnFriday = jumuahUnlocked;
    if (!hasPlayedOnFriday && user.lastQuizDate != null) {
      try {
        final parsed = DateTime.parse(user.lastQuizDate!);
        if (parsed.weekday == DateTime.friday) {
          hasPlayedOnFriday = true;
          await prefs.setBool(jumuahKey, true);
        }
      } catch (_) {}
    }

    // Every correct answer counts toward Noor-e-Ilm (daily + practice);
    // Champion only counts daily-quiz points; Mustaqeem uses the best streak
    // so the badge isn't lost when a streak later breaks.
    final correctAnswers = user.totalScore + user.practiceXp;
    final noorUnlocked = correctAnswers >= 50;
    final mustaqeemUnlocked = user.bestStreak >= 7;
    final championUnlocked = user.totalScore >= 100;

    return [
      BadgeModel(
        id: 'noor_ilm',
        titleGu: 'Noor-e-Ilm',
        titleEn: 'Noor-e-Ilm',
        descGu: 'Answered 50 questions correctly to earn the Light of Knowledge!',
        descEn: 'Answered 50 questions correctly to earn the Light of Knowledge!',
        iconKey: 'sparkle',
        primaryColor: MaherTheme.goldDark,
        isUnlocked: noorUnlocked,
        currentProgress: correctAnswers.clamp(0, 50),
        maxProgress: 50,
      ),
      BadgeModel(
        id: 'mustaqeem',
        titleGu: 'Mustaqeem (7-Day)',
        titleEn: 'Mustaqeem (7-Day)',
        descGu: 'Maintained a 7-day daily quiz streak with steadfastness!',
        descEn: 'Maintained a 7-day daily quiz streak with steadfastness!',
        iconKey: 'flame-streak',
        primaryColor: const Color(0xFFD97706),
        isUnlocked: mustaqeemUnlocked,
        currentProgress: user.bestStreak.clamp(0, 7),
        maxProgress: 7,
      ),
      BadgeModel(
        id: 'champion',
        titleGu: 'Deeniyat Champion',
        titleEn: 'Deeniyat Champion',
        descGu: 'Earned 100+ points in Daily Quizzes!',
        descEn: 'Earned 100+ points in Daily Quizzes!',
        iconKey: 'admin-crown',
        primaryColor: MaherTheme.emeraldPrimary,
        isUnlocked: championUnlocked,
        currentProgress: user.totalScore.clamp(0, 100),
        maxProgress: 100,
      ),
      BadgeModel(
        id: 'jumuah_special',
        titleGu: 'Jumu\'ah Mubarak',
        titleEn: 'Jumu\'ah Mubarak',
        descGu: 'Completed an Islamic quiz round on the blessed day of Friday!',
        descEn: 'Completed an Islamic quiz round on the blessed day of Friday!',
        iconKey: 'rub-el-hizb',
        primaryColor: const Color(0xFF0F766E),
        isUnlocked: hasPlayedOnFriday,
        currentProgress: hasPlayedOnFriday ? 1 : 0,
        maxProgress: 1,
      ),
    ];
  }

  // Record a quiz completion and check if Jumuah badge unlocks
  static Future<bool> checkJumuahUnlock() async {
    final now = DateTime.now();
    if (now.weekday == DateTime.friday) {
      final prefs = await SharedPreferences.getInstance();
      final jumuahKey = await AuthService.userScopedKey(prefs, _jumuahKey);
      await prefs.setBool(jumuahKey, true);
      return true;
    }
    return false;
  }
}
