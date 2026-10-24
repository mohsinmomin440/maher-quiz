class QuestionLang {
  final String question;
  final List<String> options;
  final int correct;
  final String explanation;

  QuestionLang({
    required this.question,
    required this.options,
    required this.correct,
    required this.explanation,
  });

  factory QuestionLang.fromJson(Map<String, dynamic> json) {
    return QuestionLang(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correct: json['correct'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
  // Reorders options so that new position i holds old option order[i]
  QuestionLang permuted(List<int> order) {
    if (order.length != options.length) return shuffled();
    return QuestionLang(
      question: question,
      options: [for (final i in order) options[i]],
      correct: order.indexOf(correct).clamp(0, options.length - 1),
      explanation: explanation,
    );
  }

  QuestionLang shuffled() {
    if (options.length <= 1) return this;
    final correctValue = options[correct];
    final List<String> newOptions = List<String>.from(options)..shuffle();
    final newCorrect = newOptions.indexOf(correctValue);
    return QuestionLang(
      question: question,
      options: newOptions,
      correct: newCorrect >= 0 ? newCorrect : 0,
      explanation: explanation,
    );
  }
}

class QuestionModel {
  final String id;
  final String category;
  final String ageGroup;
  final String difficulty; // 'easy', 'medium', 'hard'
  final QuestionLang gu;
  final QuestionLang hi;
  final QuestionLang en;

  QuestionModel({
    required this.id,
    required this.category,
    required this.ageGroup,
    this.difficulty = 'medium',
    required this.gu,
    required this.hi,
    required this.en,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      ageGroup: json['age_group'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      gu: QuestionLang.fromJson(json['gu'] ?? {}),
      hi: QuestionLang.fromJson(json['hi'] ?? {}),
      en: QuestionLang.fromJson(json['en'] ?? {}),
    );
  }

  // One shared permutation for all languages (options are parallel across
  // gu/hi/en in the bank), so the correct index is the same in every
  // language and the quiz can switch language mid-question.
  QuestionModel shuffled() {
    final order = List<int>.generate(gu.options.length, (i) => i)..shuffle();
    return QuestionModel(
      id: id,
      category: category,
      ageGroup: ageGroup,
      difficulty: difficulty,
      gu: gu.permuted(order),
      hi: hi.permuted(order),
      en: en.permuted(order),
    );
  }

  static const List<String> languages = ['gu', 'hi', 'en'];

  static String languageLabel(String langCode) {
    switch (langCode) {
      case 'hi':
        return 'हिन्दी';
      case 'en':
        return 'English';
      case 'gu':
      default:
        return 'ગુજરાતી';
    }
  }

  QuestionLang getForLang(String langCode) {
    switch (langCode) {
      case 'hi':
        return hi;
      case 'en':
        return en;
      case 'gu':
      default:
        return gu;
    }
  }
}
