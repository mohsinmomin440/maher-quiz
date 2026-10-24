import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';
import 'auth_service.dart';

List<QuestionModel> _parseQuestions(String jsonStr) {
  final List<dynamic> list = json.decode(jsonStr);
  return list.map((item) => QuestionModel.fromJson(item)).toList();
}

class QuizService {
  static List<QuestionModel>? _cachedQuestions;
  static const String _seenQuestionKey = 'maher_seen_question_ids';

  // Load all questions from asset JSON
  static Future<List<QuestionModel>> loadQuestions() async {
    if (_cachedQuestions != null && _cachedQuestions!.isNotEmpty) {
      return _cachedQuestions!;
    }

    try {
      final jsonStr =
          await rootBundle.loadString('assets/data/questions_bank.json');
      // Parse the ~1.5 MB bank on a background isolate to avoid UI jank
      _cachedQuestions = await compute(_parseQuestions, jsonStr);
      return _cachedQuestions!;
    } catch (e) {
      debugPrint('QuizService: failed to load question bank: $e');
      return [];
    }
  }

  static const String _questionLangKey = 'maher_question_lang';

  // Language questions are shown in (gu/hi/en); Gujarati by default
  static Future<String> getQuestionLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await AuthService.userScopedKey(prefs, _questionLangKey);
      final lang = prefs.getString(key);
      return QuestionModel.languages.contains(lang) ? lang! : 'gu';
    } catch (_) {
      return 'gu';
    }
  }

  static Future<void> setQuestionLanguage(String lang) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await AuthService.userScopedKey(prefs, _questionLangKey);
      await prefs.setString(key, lang);
    } catch (_) {}
  }

  // Get questions filtered by difficulty level
  static Future<List<QuestionModel>> getQuestionsByLevel(
      String difficulty) async {
    final all = await loadQuestions();
    if (difficulty == 'all' || difficulty.isEmpty) return all;
    return all.where((q) => q.difficulty == difficulty).toList();
  }

  // Get difficulty breakdown counts
  static Future<Map<String, int>> getLevelCounts() async {
    final all = await loadQuestions();
    int easy = 0, medium = 0, hard = 0;
    for (final q in all) {
      if (q.difficulty == 'easy') {
        easy++;
      } else if (q.difficulty == 'hard') {
        hard++;
      } else {
        medium++;
      }
    }
    return {'all': all.length, 'easy': easy, 'medium': medium, 'hard': hard};
  }

  // Get seen question IDs to prevent repetitions
  static Future<Set<String>> getSeenQuestionIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await AuthService.userScopedKey(prefs, _seenQuestionKey);
      final list = prefs.getStringList(key) ?? [];
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  // Record questions as seen
  static Future<void> markQuestionsAsSeen(List<String> newIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await AuthService.userScopedKey(prefs, _seenQuestionKey);
      final current = prefs.getStringList(key) ?? [];
      final updated = <String>{...current, ...newIds}.toList();
      await prefs.setStringList(key, updated);
    } catch (_) {}
  }

  // Reset seen history (for fresh cycles)
  static Future<void> resetSeenQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await AuthService.userScopedKey(prefs, _seenQuestionKey);
      await prefs.remove(key);
    } catch (_) {}
  }

  // Get exactly 5 questions for today's 24-hour cycle
  // Uses date hash as deterministic seed, with dynamically shuffled options
  static Future<List<QuestionModel>> getDailyQuestions(
      {String difficulty = 'all'}) async {
    final all = await loadQuestions();
    if (all.isEmpty) return [];

    List<QuestionModel> pool = all;
    if (difficulty != 'all') {
      final filtered = all.where((q) => q.difficulty == difficulty).toList();
      if (filtered.length >= 5) {
        pool = filtered;
      }
    }

    final now = DateTime.now();
    // Daily seed: year * 10000 + month * 100 + day
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);

    final shuffledPool = List<QuestionModel>.from(pool);
    shuffledPool.shuffle(random);

    final selected = shuffledPool.take(5).toList();
    // Dynamically shuffle options for each selected question
    return selected.map((q) => q.shuffled()).toList();
  }

  // Get 5 randomized questions for practice round with anti-repetition protection
  static Future<List<QuestionModel>> getPracticeQuestions(
      {String difficulty = 'all'}) async {
    final all = await loadQuestions();
    if (all.isEmpty) return [];

    List<QuestionModel> pool = all;
    if (difficulty != 'all') {
      final filtered = all.where((q) => q.difficulty == difficulty).toList();
      if (filtered.isNotEmpty) {
        pool = filtered;
      }
    }

    final seenIds = await getSeenQuestionIds();
    // Pick from questions user hasn't seen recently
    List<QuestionModel> candidates =
        pool.where((q) => !seenIds.contains(q.id)).toList();

    // If unseen questions are fewer than 5, reset seen pool to avoid exhaustion
    if (candidates.length < 5) {
      await resetSeenQuestions();
      candidates = List<QuestionModel>.from(pool);
    }

    final shuffled = List<QuestionModel>.from(candidates);
    shuffled.shuffle(Random());

    final selected = shuffled.take(5).toList();
    // Save selected question IDs so they won't repeat immediately
    await markQuestionsAsSeen(selected.map((q) => q.id).toList());

    // Dynamically shuffle options (A, B, C, D) for every question
    return selected.map((q) => q.shuffled()).toList();
  }

  // Check if today's quiz was already completed by user
  static bool isDailyQuizCompleted(String? lastQuizDate) {
    if (lastQuizDate == null) return false;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastQuizDate == today;
  }

  // Duration remaining until next midnight (24hr cycle reset)
  static Duration getTimeUntilNextQuiz() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }
}
