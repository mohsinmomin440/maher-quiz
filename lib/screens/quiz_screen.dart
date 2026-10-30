import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/age_groups.dart';
import '../models/question_model.dart';
import '../services/auth_service.dart';
import '../services/badge_service.dart';
import '../services/bookmark_service.dart';
import '../services/sound_service.dart';
import '../utils/app_localization.dart';
import '../utils/maher_icons.dart';
import '../utils/maher_theme.dart';

class QuizScreen extends StatefulWidget {
  final List<QuestionModel> questions;
  final bool isDaily;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.isDaily,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswerSubmitted = false;
  int _score = 0;
  bool _isQuizCompleted = false;
  bool _isFinishing = false;
  Set<String> _bookmarkedIds = {};
  String _lang = 'gu';
  bool _wrongAnswersSaved = false;

  final List<_AnswerRecord> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadBookmarks();
    if (widget.isDaily && widget.questions.isNotEmpty) {
      // Fire-and-forget: locking the daily quiz must not block the first frame.
      unawaited(AuthService.markDailyStarted());
    }
  }

  Future<void> _loadLanguage() async {
    if (mounted) {
      setState(() => _lang = 'gu');
    }
  }

  Future<void> _loadBookmarks() async {
    final ids = await BookmarkService.getBookmarkedIds();
    if (mounted) {
      setState(() {
        _bookmarkedIds = ids;
      });
    }
  }





  Future<void> _toggleBookmarkCurrent() async {
    if (widget.questions.isEmpty) return;
    final qId = widget.questions[_currentIndex].id;
    final isNowBookmarked = await BookmarkService.toggleBookmark(qId);
    if (!mounted) return;
    setState(() {
      if (isNowBookmarked) {
        _bookmarkedIds.add(qId);
      } else {
        _bookmarkedIds.remove(qId);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            MaherIcons.get(
              isNowBookmarked ? 'bookmark' : 'bookmark-outline',
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isNowBookmarked
                  ? 'Question saved to bookmarks'
                  : 'Question removed from bookmarks',
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor:
            isNowBookmarked ? MaherTheme.emeraldPrimary : Colors.grey.shade800,
      ),
    );
  }

  void _selectOption(int index) {
    if (_isAnswerSubmitted) return;
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _submitAnswer() {
    if (_selectedOptionIndex == null || _isAnswerSubmitted) return;

    final q = widget.questions[_currentIndex];
    final isCorrect = (_selectedOptionIndex == q.getForLang(_lang).correct);

    // Feedback is shown inline (see _buildFeedbackBanner) for both outcomes
    if (isCorrect) {
      _score++;
      SoundService.playCorrect();
    } else {
      SoundService.playIncorrect();
    }

    _userAnswers.add(_AnswerRecord(
      question: q,
      selectedIndex: _selectedOptionIndex!,
      isCorrect: isCorrect,
    ));

    setState(() {
      _isAnswerSubmitted = true;
    });

    if (widget.isDaily) {
      AuthService.saveDailyProgress(_score);
    }
  }

  Future<void> _nextQuestion() async {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isAnswerSubmitted = false;
      });
    } else {
      // Quiz finished; guard against double taps recording the score twice
      if (_isFinishing || _isQuizCompleted) return;
      setState(() => _isFinishing = true);

      await AuthService.recordQuizCompletion(
        score: _score,
        isDaily: widget.isDaily,
      );
      await BadgeService.checkJumuahUnlock();
      SoundService.playVictory();

      if (!mounted) return;
      setState(() {
        _isQuizCompleted = true;
        _isFinishing = false;
      });
    }
  }

  Future<bool> _confirmExit() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Leave Quiz?'),
        content: Text(
          widget.isDaily
              ? 'Today\'s quiz can only be attempted once. If you leave now, '
                  'your score so far ($_score / ${widget.questions.length}) '
                  'will be submitted as today\'s result.'
              : 'Are you sure you want to leave? Current quiz progress will not be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continue Quiz'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MaherTheme.errorRed,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  Future<void> _handleBack() async {
    if (_isQuizCompleted) {
      if (mounted) Navigator.pop(context, true);
      return;
    }
    final leave = await _confirmExit();
    if (!leave || !mounted) return;

    // A daily attempt counts once opened: submit what was earned so far
    if (widget.isDaily && !_isFinishing) {
      setState(() => _isFinishing = true);
      await AuthService.recordQuizCompletion(score: _score, isDaily: true);
      if (!mounted) return;
    }
    Navigator.pop(context, widget.isDaily);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: MaherTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: MaherIcons.get('arrow-left', size: 22, color: MaherTheme.emeraldDark),
            onPressed: _handleBack,
          ),
          title: Text(
            widget.isDaily
                ? AppLocalization.tr('daily_quiz_title')
                : AppLocalization.tr('practice_mode'),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: MaherTheme.emeraldDark,
            ),
          ),
          actions: const [],
        ),
        body: _isQuizCompleted ? _buildResultView() : _buildQuestionView(),
      ),
    );
  }



  // Inline result for the submitted answer (replaces the old SnackBar, which
  // only appeared for correct answers and stacked when answering quickly)
  Widget _buildFeedbackBanner(QuestionLang qLang) {
    final isCorrect = _selectedOptionIndex == qLang.correct;
    final color = isCorrect ? MaherTheme.successGreen : MaherTheme.errorRed;
    final correctLetter = String.fromCharCode(65 + qLang.correct);
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            MaherIcons.get(isCorrect ? 'check-circle' : 'cross-circle',
                size: 22, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isCorrect
                    ? 'MashaAllah! Correct answer.'
                    : 'Not quite. The correct answer is $correctLetter.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color:
                      isCorrect ? MaherTheme.emeraldDark : MaherTheme.errorRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    if (widget.questions.isEmpty) {
      return Center(
        child: Text(
          'No questions available',
          style: TextStyle(color: MaherTheme.textSecondaryLight),
        ),
      );
    }

    final currentQ = widget.questions[_currentIndex];
    final qLang = currentQ.getForLang(_lang);

    // Clean English Category display
    String categoryDisplay = currentQ.category;
    if (categoryDisplay.contains('/')) {
      categoryDisplay = categoryDisplay.split('/').last.trim();
    }

    // Clean English Age Group display. The bank stores Gujarati labels
    // (e.g. '૪ થી ૭ વર્ષ'), so map them via AgeGroups.normalize first.
    final normalizedAgeGroup = AgeGroups.normalize(currentQ.ageGroup);
    String ageGroupDisplay = normalizedAgeGroup;
    if (normalizedAgeGroup.startsWith(AgeGroups.class1)) {
      ageGroupDisplay = 'Ages 4-7';
    } else if (normalizedAgeGroup.startsWith(AgeGroups.class3)) {
      ageGroupDisplay = 'Ages 12-14';
    } else if (normalizedAgeGroup.startsWith(AgeGroups.class2)) {
      ageGroupDisplay = 'Ages 8-11';
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar & Question Counter
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              MaherIcons.get('rub-el-hizb',
                                  size: 20, color: MaherTheme.goldPrimary),
                              const SizedBox(width: 8),
                              Text(
                                '${AppLocalization.tr('question_progress')} ${_currentIndex + 1} ${AppLocalization.tr('of')} ${widget.questions.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: MaherTheme.emeraldDark,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: MaherTheme.emeraldSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              categoryDisplay,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: MaherTheme.emeraldPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          // Fills as questions are answered (0% before the first)
                          value: (_currentIndex + (_isAnswerSubmitted ? 1 : 0)) /
                              widget.questions.length,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            MaherTheme.emeraldLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Question Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              MaherIcons.get('book-quran',
                                  size: 20, color: MaherTheme.emeraldPrimary),
                              const SizedBox(width: 8),
                              Text(
                                ageGroupDisplay,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: MaherTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: currentQ.difficulty == 'easy'
                                      ? MaherTheme.successGreen.withValues(alpha: 0.12)
                                      : currentQ.difficulty == 'hard'
                                          ? MaherTheme.errorRed.withValues(alpha: 0.12)
                                          : MaherTheme.goldDark.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: currentQ.difficulty == 'easy'
                                        ? MaherTheme.successGreen.withValues(alpha: 0.4)
                                        : currentQ.difficulty == 'hard'
                                            ? MaherTheme.errorRed.withValues(alpha: 0.4)
                                            : MaherTheme.goldDark.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  AppLocalization.tr('level_${currentQ.difficulty}'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: currentQ.difficulty == 'easy'
                                        ? MaherTheme.successGreen
                                        : currentQ.difficulty == 'hard'
                                            ? MaherTheme.errorRed
                                            : MaherTheme.goldDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: MaherIcons.get(
                                  _bookmarkedIds.contains(currentQ.id)
                                      ? 'bookmark'
                                      : 'bookmark-outline',
                                  size: 24,
                                  color: _bookmarkedIds.contains(currentQ.id)
                                      ? MaherTheme.goldDark
                                      : Colors.grey.shade400,
                                ),
                                tooltip: 'Bookmark Question',
                                onPressed: _toggleBookmarkCurrent,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        qLang.question,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: MaherTheme.textPrimaryLight,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4 Options
              ...List.generate(qLang.options.length, (optIdx) {
                final optionText = qLang.options[optIdx];
                final isSelected = (_selectedOptionIndex == optIdx);
                final isCorrectOption = (optIdx == qLang.correct);

                Color borderColor = Colors.grey.shade300;
                Color bgColor = Colors.white;
                Widget? trailingIcon;

                if (_isAnswerSubmitted) {
                  if (isCorrectOption) {
                    borderColor = MaherTheme.successGreen;
                    bgColor = MaherTheme.emeraldSoft;
                    trailingIcon = MaherIcons.get('check-circle',
                        size: 20, color: MaherTheme.successGreen);
                  } else if (isSelected && !isCorrectOption) {
                    borderColor = MaherTheme.errorRed;
                    bgColor = MaherTheme.errorRed.withValues(alpha: 0.08);
                    trailingIcon = MaherIcons.get('cross-circle',
                        size: 20, color: MaherTheme.errorRed);
                  }
                } else if (isSelected) {
                  borderColor = MaherTheme.emeraldPrimary;
                  bgColor = MaherTheme.emeraldSoft;
                }

                final letter = String.fromCharCode(65 + optIdx);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    label: 'Option $letter: $optionText'
                        '${_isAnswerSubmitted && isCorrectOption ? ', correct answer' : ''}',
                    excludeSemantics: true,
                    onTap: () => _selectOption(optIdx),
                    child: InkWell(
                      onTap: () => _selectOption(optIdx),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor, width: 1.8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? MaherTheme.emeraldPrimary
                                    : Colors.grey.shade100,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + optIdx),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                optionText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: MaherTheme.textPrimaryLight,
                                ),
                              ),
                            ),
                            trailingIcon ?? const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),

              // Explanation Box (Shown after submission)
              if (_isAnswerSubmitted) ...[
                _buildFeedbackBanner(qLang),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MaherTheme.emeraldSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: MaherTheme.emeraldPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          MaherIcons.get('sparkle',
                              size: 18, color: MaherTheme.emeraldPrimary),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalization.tr('explanation'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: MaherTheme.emeraldDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        qLang.explanation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: MaherTheme.textSecondaryLight,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Action Buttons
              if (!_isAnswerSubmitted)
                ElevatedButton(
                  onPressed: _selectedOptionIndex != null ? _submitAnswer : null,
                  child: Text(AppLocalization.tr('submit_answer')),
                )
              else
                ElevatedButton(
                  onPressed: _isFinishing ? null : _nextQuestion,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentIndex < widget.questions.length - 1
                            ? AppLocalization.tr('next_question')
                            : AppLocalization.tr('finish_quiz'),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      MaherIcons.get('chevron-right',
                          size: 18, color: Colors.white),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final percentage = (_score / widget.questions.length) * 100;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(
                    color: MaherTheme.goldPrimary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: MaherTheme.goldLight.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: MaherIcons.get('trophy',
                            size: 64, color: MaherTheme.goldDark),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalization.tr('quiz_complete'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: MaherTheme.emeraldDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        percentage >= 60
                            ? AppLocalization.tr('excellent')
                            : AppLocalization.tr('good_try'),
                        style: TextStyle(
                          fontSize: 15,
                          color: percentage >= 60
                              ? MaherTheme.emeraldPrimary
                              : MaherTheme.goldDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: MaherTheme.emeraldPrimary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              AppLocalization.tr('your_score'),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_score / ${widget.questions.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Review Heading
              Row(
                children: [
                  MaherIcons.get('sparkle',
                      size: 20, color: MaherTheme.emeraldPrimary),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalization.tr('review_answers'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MaherTheme.emeraldDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Detailed Question Reviews
              ..._userAnswers.map((item) {
                // Rendered in the current language; indices are shared
                final qLang = item.question.getForLang(_lang);
                final bool isCorrect = item.isCorrect;
                final String q = qLang.question;
                final List<String> opts = qLang.options;
                final int correctIdx = qLang.correct;
                final int selectedIdx = item.selectedIndex;
                final String explanation = qLang.explanation;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: MaherIcons.get(
                                isCorrect ? 'check-circle' : 'cross-circle',
                                size: 20,
                                color: isCorrect
                                    ? MaherTheme.successGreen
                                    : MaherTheme.errorRed,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                q,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Correct Answer: ${opts[correctIdx]}',
                          style: const TextStyle(
                            color: MaherTheme.emeraldPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (!isCorrect && selectedIdx >= 0 && selectedIdx < opts.length)
                          Text(
                            'Your Answer: ${opts[selectedIdx]}',
                            style: const TextStyle(
                              color: MaherTheme.errorRed,
                              fontSize: 13,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          explanation,
                          style: TextStyle(
                            color: MaherTheme.textSecondaryLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              if (_userAnswers.any((a) => !a.isCorrect)) ...[
                OutlinedButton.icon(
                  icon: MaherIcons.get(
                    _wrongAnswersSaved ? 'bookmark' : 'bookmark-outline',
                    size: 18,
                    color: MaherTheme.emeraldPrimary,
                  ),
                  label: Text(_wrongAnswersSaved
                      ? AppLocalization.tr('wrong_answers_saved')
                      : AppLocalization.tr('save_wrong_answers')),
                  onPressed: _wrongAnswersSaved ? null : _saveWrongAnswers,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              OutlinedButton.icon(
                icon: const Icon(Icons.copy_rounded,
                    size: 18, color: MaherTheme.emeraldPrimary),
                label: Text(AppLocalization.tr('copy_result')),
                onPressed: _copyResult,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              ElevatedButton.icon(
                icon: MaherIcons.get('arrow-left',
                    size: 18, color: Colors.white),
                label: Text(AppLocalization.tr('back_to_home')),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveWrongAnswers() async {
    final wrongIds =
        _userAnswers.where((a) => !a.isCorrect).map((a) => a.question.id);
    await BookmarkService.addBookmarks(wrongIds);
    final ids = await BookmarkService.getBookmarkedIds();
    if (!mounted) return;
    setState(() {
      _bookmarkedIds = ids;
      _wrongAnswersSaved = true;
    });
  }

  // No share dependency yet: the text is copied for pasting into WhatsApp etc.
  Future<void> _copyResult() async {
    final total = widget.questions.length;
    final marks =
        _userAnswers.map((a) => a.isCorrect ? 'O' : 'X').join(' ');
    final title = widget.isDaily ? 'Daily Quiz' : 'Practice Quiz';
    final text = 'Maher Quiz - $title\n'
        'MashaAllah! I scored $_score / $total\n'
        '$marks';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalization.tr('result_copied')),
        backgroundColor: MaherTheme.emeraldPrimary,
      ),
    );
  }
}

class _AnswerRecord {
  final QuestionModel question;
  final int selectedIndex;
  final bool isCorrect;

  const _AnswerRecord({
    required this.question,
    required this.selectedIndex,
    required this.isCorrect,
  });
}

