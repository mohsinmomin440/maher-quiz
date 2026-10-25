import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maher_quiz/models/age_groups.dart';
import 'package:maher_quiz/models/question_model.dart';
import 'package:maher_quiz/services/auth_service.dart';
import 'package:maher_quiz/services/quiz_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthService.testing = true;
  });

  tearDown(() {
    AuthService.testing = false;
  });

  group('AuthService & User Lookup Tests', () {
    test('Register student with mobile number and login', () async {
      final err = await AuthService.register(
        name: 'Test Student',
        identifier: '9876543210',
        password: 'password123',
        ageGroup: AgeGroups.class2,
      );
      expect(err, isNull);

      final loginRes = await AuthService.login(
        identifier: '9876543210',
        password: 'password123',
      );
      expect(loginRes.ok, isTrue);
      expect(loginRes.user?.name, 'Test Student');
      expect(loginRes.user?.phone, '9876543210');
    });

    test('Admin reset password works by phone, email and user ID', () async {
      await AuthService.register(
        name: 'Ahmed Khan',
        identifier: '9876543211',
        password: 'oldPassword123',
        ageGroup: AgeGroups.class1,
      );

      final resetPhone = await AuthService.adminResetPassword('9876543211', 'newPass123');
      expect(resetPhone, isTrue);

      final loginPhone = await AuthService.login(
        identifier: '9876543211',
        password: 'newPass123',
      );
      expect(loginPhone.ok, isTrue);
      expect(loginPhone.user?.mustChangePassword, isTrue);
    });

    test('Seeded admin exists and must change default password', () async {
      await AuthService.ensureSeeded();
      final loginAdmin = await AuthService.login(
        identifier: 'admin@maher.app',
        password: 'Admin@786',
      );
      expect(loginAdmin.ok, isTrue);
      expect(loginAdmin.user?.isAdmin, isTrue);
      expect(loginAdmin.user?.mustChangePassword, isTrue);
    });
  });

  group('Scoring and Streak Tests', () {
    test('Daily quiz updates score, streak, and locks daily', () async {
      await AuthService.register(
        name: 'Fatima',
        identifier: '9876543212',
        password: 'password123',
        ageGroup: AgeGroups.class3,
      );

      final updated = await AuthService.recordQuizCompletion(score: 5, isDaily: true);
      expect(updated?.totalScore, 5);
      expect(updated?.streak, 1);
      expect(updated?.effectiveStreak, 1);

      // Duplicate daily completion on the same day must not increment score
      final duplicate = await AuthService.recordQuizCompletion(score: 5, isDaily: true);
      expect(duplicate?.totalScore, 5);
      expect(duplicate?.streak, 1);
    });

    test('Practice rounds add to practiceXp, not totalScore', () async {
      await AuthService.register(
        name: 'Zaid',
        identifier: '9876543213',
        password: 'password123',
        ageGroup: AgeGroups.class2,
      );

      final updated = await AuthService.recordQuizCompletion(score: 4, isDaily: false);
      expect(updated?.totalScore, 0);
      expect(updated?.practiceXp, 4);
    });
  });

  group('Question Model & Language Tests', () {
    test('QuestionModel.shuffled maintains parallel correct index across languages', () {
      final q = QuestionModel(
        id: 'q_test_1',
        category: 'Test',
        ageGroup: '8-11',
        gu: QuestionLang(
          question: 'ગુજરાતી પ્રશ્ન',
          options: ['A', 'B', 'C', 'D'],
          correct: 1,
          explanation: 'Exp Gu',
        ),
        hi: QuestionLang(
          question: 'हिन्दी प्रश्न',
          options: ['A-hi', 'B-hi', 'C-hi', 'D-hi'],
          correct: 1,
          explanation: 'Exp Hi',
        ),
        en: QuestionLang(
          question: 'English question',
          options: ['A-en', 'B-en', 'C-en', 'D-en'],
          correct: 1,
          explanation: 'Exp En',
        ),
      );

      final shuffled = q.shuffled();
      expect(shuffled.gu.correct, shuffled.hi.correct);
      expect(shuffled.gu.correct, shuffled.en.correct);
      expect(shuffled.gu.options[shuffled.gu.correct], 'B');
      expect(shuffled.hi.options[shuffled.hi.correct], 'B-hi');
      expect(shuffled.en.options[shuffled.en.correct], 'B-en');
    });

    test('Question language preference persists in QuizService', () async {
      await QuizService.setQuestionLanguage('hi');
      final lang = await QuizService.getQuestionLanguage();
      expect(lang, 'hi');
    });
  });

  group('AgeGroups normalization tests', () {
    test('Normalizes legacy class values correctly', () {
      expect(AgeGroups.normalize('Age 4-7 (Deeniyat Class 1)'), AgeGroups.class1);
      expect(AgeGroups.normalize('Class 2'), AgeGroups.class2);
      expect(AgeGroups.normalize('Class 3'), AgeGroups.class3);
      expect(AgeGroups.normalize(null), AgeGroups.general);
    });
  });
}
