import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';
import 'auth_service.dart';
import 'cloud_service.dart';
import 'quiz_service.dart';

class BookmarkService {
  static const String _bookmarkKey = 'maher_bookmarked_questions';

  // Get all bookmarked question IDs
  static Future<Set<String>> getBookmarkedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await AuthService.userScopedKey(prefs, _bookmarkKey);
      final list = prefs.getStringList(key) ?? [];
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  // Check if a specific question is bookmarked
  static Future<bool> isBookmarked(String questionId) async {
    final ids = await getBookmarkedIds();
    return ids.contains(questionId);
  }

  // Toggle bookmark for a question ID. Returns true if added, false if removed.
  static Future<bool> toggleBookmark(String questionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await AuthService.userScopedKey(prefs, _bookmarkKey);
      final current = prefs.getStringList(key) ?? [];
      final set = current.toSet();

      bool isAdded;
      if (set.contains(questionId)) {
        set.remove(questionId);
        isAdded = false;
      } else {
        set.add(questionId);
        isAdded = true;
      }

      await prefs.setStringList(key, set.toList());
      CloudService.setBookmark(questionId, isAdded); // no-op when offline/local
      return isAdded;
    } catch (_) {
      return false;
    }
  }

  // Add several questions at once (e.g. the ones answered wrong in a quiz).
  // Returns how many were newly added.
  static Future<int> addBookmarks(Iterable<String> questionIds,
      {bool syncRemote = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await AuthService.userScopedKey(prefs, _bookmarkKey);
      final set = (prefs.getStringList(key) ?? []).toSet();
      final before = set.length;
      final added = questionIds.where((id) => !set.contains(id)).toList();
      set.addAll(added);
      await prefs.setStringList(key, set.toList());
      if (syncRemote) {
        for (final id in added) {
          CloudService.setBookmark(id, true);
        }
      }
      return set.length - before;
    } catch (_) {
      return 0;
    }
  }

  // Get full QuestionModel objects for all saved bookmarks
  static Future<List<QuestionModel>> getBookmarkedQuestions() async {
    final bookmarkedIds = await getBookmarkedIds();
    if (bookmarkedIds.isEmpty) return [];

    final allQuestions = await QuizService.loadQuestions();
    return allQuestions
        .where((q) => bookmarkedIds.contains(q.id))
        .toList();
  }

  // Clear all bookmarks
  static Future<void> clearAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await AuthService.userScopedKey(prefs, _bookmarkKey);
      await prefs.remove(key);
    } catch (_) {}
  }
}
