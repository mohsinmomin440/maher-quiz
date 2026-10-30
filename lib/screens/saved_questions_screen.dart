import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/bookmark_service.dart';
import '../utils/maher_icons.dart';
import '../utils/maher_theme.dart';
import 'quiz_screen.dart';

class SavedQuestionsScreen extends StatefulWidget {
  final bool isTab;

  const SavedQuestionsScreen({
    super.key,
    this.isTab = false,
  });

  @override
  State<SavedQuestionsScreen> createState() => SavedQuestionsScreenState();
}

class SavedQuestionsScreenState extends State<SavedQuestionsScreen> {
  static const int _maxRevisionQuestions = 10;

  List<QuestionModel> _savedQuestions = [];
  bool _isLoading = true;
  static const String _lang = 'gu';

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    setState(() => _isLoading = true);
    final list = await BookmarkService.getBookmarkedQuestions();
    if (!mounted) return;
    setState(() {
      _savedQuestions = list;
      _isLoading = false;
    });
  }

  Future<void> _removeBookmark(QuestionModel q) async {
    await BookmarkService.toggleBookmark(q.id);
    loadBookmarks();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question removed from bookmarks'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _startRevisionQuiz() {
    if (_savedQuestions.isEmpty) return;

    // Random order, shuffled options and a capped round so answers can't be
    // memorised by position and a large bookmark list stays a short quiz.
    final round = (List<QuestionModel>.from(_savedQuestions)..shuffle())
        .take(_maxRevisionQuestions)
        .map((q) => q.shuffled())
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          questions: round,
          isDaily: false,
        ),
      ),
    ).then((_) {
      if (mounted) loadBookmarks();
    });
  }

  Widget _buildPracticeButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: _startRevisionQuiz,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: MaherTheme.emeraldPrimary,
              borderRadius: BorderRadius.circular(18),
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
                MaherIcons.get('book-quran', size: 22, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  _savedQuestions.length > _maxRevisionQuestions
                      ? 'Practice $_maxRevisionQuestions of ${_savedQuestions.length} Saved'
                      : 'Practice Saved Questions (${_savedQuestions.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                color: MaherTheme.emeraldSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: MaherIcons.get('bookmark-filled', size: 20, color: MaherTheme.emeraldPrimary),
            ),
            const SizedBox(width: 10),
            const Text(
              'Saved Questions',
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
            onPressed: loadBookmarks,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(MaherTheme.emeraldPrimary),
              ),
            )
          : _savedQuestions.isEmpty
              ? _buildEmptyState()
              : widget.isTab
                  ? Column(
                      children: [
                        Expanded(child: _buildList()),
                        _buildPracticeButton(),
                      ],
                    )
                  : _buildList(),
      bottomNavigationBar: (!widget.isTab && _savedQuestions.isNotEmpty)
          ? _buildPracticeButton()
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: MaherTheme.emeraldSoft,
                shape: BoxShape.circle,
              ),
              child: MaherIcons.get('rub-el-hizb',
                  size: 64, color: MaherTheme.emeraldPrimary),
            ),
            const SizedBox(height: 20),
            const Text(
              'No saved questions yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MaherTheme.emeraldDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on any question during quiz to review and practice it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: MaherTheme.textSecondaryLight,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _savedQuestions.length,
      itemBuilder: (context, index) {
        final q = _savedQuestions[index];
        final qLang = q.getForLang(_lang);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: MaherTheme.goldPrimary.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: MaherTheme.goldDark.withValues(alpha: 0.15),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: MaherTheme.emeraldSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        q.category.contains('/')
                            ? q.category.split('/').last.trim()
                            : q.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MaherTheme.emeraldPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: MaherIcons.get('trash',
                          color: MaherTheme.errorRed, size: 20),
                      tooltip: 'Remove',
                      onPressed: () => _removeBookmark(q),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${index + 1}. ${qLang.question}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MaherTheme.textPrimaryLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MaherTheme.emeraldSoft.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: MaherTheme.emeraldPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          MaherIcons.get('check-circle',
                              size: 16, color: MaherTheme.successGreen),
                          const SizedBox(width: 6),
                          Text(
                            'Correct Answer: ${qLang.options[qLang.correct]}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: MaherTheme.emeraldDark,
                            ),
                          ),
                        ],
                      ),
                      if (qLang.explanation.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          qLang.explanation,
                          style: TextStyle(
                            fontSize: 12,
                            color: MaherTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
