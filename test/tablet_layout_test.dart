import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/Custom_Bottom_Navigation_Bar/main_shell.dart';
import 'package:opalmer_education/authentication_screen/login_screen.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/models/teacher_class_model.dart';
import 'package:opalmer_education/core/models/user_model.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/grading_provider.dart';
import 'package:opalmer_education/core/providers/notification_provider.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/core/providers/teacher_provider.dart'
    hide studentQuizResultsProvider;
import 'package:opalmer_education/core/responsive/responsive.dart';
import 'package:opalmer_education/core/theme/app_theme.dart';
import 'package:opalmer_education/onboarding_screen/onboarding_screen.dart';
import 'package:opalmer_education/parent_role/parent_main_shell.dart';
import 'package:opalmer_education/student_role/Quizzes/student_quiz_main_screen.dart';
import 'package:opalmer_education/student_role/Subjects/subjects_screen.dart';
import 'package:opalmer_education/student_role/student_main_shell.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/add_class.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/class_details.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/classes_screen.dart';
import 'package:opalmer_education/teacher_role/profile_screen/profile.dart';
import 'package:opalmer_education/user_role_screen/user_role_screen.dart';

const _sizes = <String, Size>{
  'phone': Size(390, 844),
  'iPad mini portrait': Size(744, 1133),
  'iPad mini landscape': Size(1133, 744),
  'iPad 13" landscape': Size(1366, 1024),
};

final _classes = [
  TeacherClassModel(
    id: 'c1',
    teacherId: 'u1',
    grade: 6,
    subject: 'Mathematics',
    section: 'A',
  ),
  TeacherClassModel(id: 'c2', teacherId: 'u1', grade: 7, subject: 'English'),
  TeacherClassModel(id: 'c3', teacherId: 'u1', grade: 8, subject: 'Science'),
];

final _studentClasses = [
  StudentClassModel(id: 'c1', subject: 'Mathematics', grade: 6),
  StudentClassModel(id: 'c2', subject: 'English', grade: 6),
  StudentClassModel(id: 'c3', subject: 'Science', grade: 6),
];

final _quizzes = [
  QuizModel(id: 'q1', title: 'Fractions', questionCount: 10),
  QuizModel(id: 'q2', title: 'Poetry', questionCount: 8),
];

const _student = {'_id': 's1', 'username': 'Jordan', 'gradeLevel': 6};

List<Override> _overrides() => [
  authStateProvider.overrideWith(
    (ref) => UserModel(id: 'u1', username: 'Sarah Johnson', role: 'teacher'),
  ),
  unreadNotificationCountProvider.overrideWithValue(0),
  teacherClassesProvider.overrideWith((ref) async => _classes),
  teacherQuizzesProvider.overrideWith((ref) async => _quizzes),
  teacherSessionsProvider(null).overrideWith((ref) async => []),
  for (final c in _classes)
    classStudentsProvider(c.id).overrideWith(
      (ref) async => [
        {'studentId': _student},
      ],
    ),
  studentClassesProvider.overrideWith((ref) async => _studentClasses),
  studentQuizzesProvider.overrideWith((ref) async => _quizzes),
  studentQuizResultsProvider.overrideWith((ref) async => []),
  userRoomsProvider.overrideWith((ref) async => []),
];

final _screens = <String, Widget Function()>{
  'onboarding': () => const OnboardingScreen(),
  'role selection': () => const UserRoleScreen(),
  'login': () => const LoginScreen(),
  'teacher shell': () => const MainShell(),
  'parent shell': () => const ParentMainShell(),
  'student shell': () => const StudentMainShell(),
  'teacher classes': () => const ClassesScreen(),
  'teacher profile': () => const ProfileScreen(),
  'class details': () => ClassDetailsScreen(classData: _classes.first),
  'add class': () => const AddClassScreen(),
  'student quizzes': () => const StudentQuizMainScreen(),
  'student subjects': () => const SubjectsScreen(),
};

void main() {
  group('Responsive helpers', () {
    test('gutter keeps phone padding and centers content on wide screens', () {
      expect(Responsive.gutterFor(390), 20);
      expect(Responsive.gutterFor(800), 20);
      expect(Responsive.gutterFor(1200), 220);
      expect(Responsive.gutterFor(1366, maxWidth: 1100, base: 24), 157);
    });

    test('columns grow with width and respect the maximum', () {
      expect(Responsive.columns(350), 1);
      expect(Responsive.columns(760), 2);
      expect(Responsive.columns(1100), 3);
      expect(Responsive.columns(2000, maxColumns: 2), 2);
    });

    testWidgets('ResponsiveBody leaves phones untouched and caps tablets', (
      tester,
    ) async {
      Future<double> widthAt(double screenWidth) async {
        tester.view.physicalSize = Size(screenWidth, 800);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ResponsiveBody(child: SizedBox.expand(key: Key('body'))),
            ),
          ),
        );
        return tester.getSize(find.byKey(const Key('body'))).width;
      }

      addTearDown(tester.view.reset);
      expect(await widthAt(390), 390);
      expect(await widthAt(1366), Responsive.pageMaxWidth);
    });
  });

  for (final screen in _screens.entries) {
    for (final size in _sizes.entries) {
      testWidgets('${screen.key} lays out without overflow on ${size.key}', (
        tester,
      ) async {
        FlutterSecureStorage.setMockInitialValues({});
        tester.view.physicalSize = size.value * 2;
        tester.view.devicePixelRatio = 2;
        tester.view.padding = const FakeViewPadding(top: 48, bottom: 40);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _overrides(),
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: screen.value(),
            ),
          ),
        );
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }

        final error = tester.takeException();
        // Network calls fail in tests; only layout errors matter here.
        if (error is FlutterError) {
          fail('${screen.key} on ${size.key}: $error');
        }

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 3));
      });
    }
  }
}
