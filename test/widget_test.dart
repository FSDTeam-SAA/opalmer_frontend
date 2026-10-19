import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/main.dart';
import 'package:opalmer_education/splash_screen/splash_screen.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/student_role/Quizzes/student_quiz_result_screen.dart';

void main() {
  testWidgets('Application opens the splash within its provider scope', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('Unreleased grade shows review status without a score', (
    tester,
  ) async {
    final result = QuizSubmissionResult.fromJson({
      'gradeStatus': 'reviewed',
      'totalQuestions': 10,
      'score': 8,
      'percentage': 80,
      'answers': [],
    });
    await tester.pumpWidget(
      MaterialApp(home: StudentQuizResultScreen(result: result)),
    );
    expect(find.text('Assessment submitted'), findsOneWidget);
    expect(find.textContaining('after your teacher reviews'), findsOneWidget);
    expect(find.textContaining('Score:'), findsNothing);
  });
  testWidgets('Released grade shows the actual percentage', (tester) async {
    final result = QuizSubmissionResult.fromJson({
      'gradeStatus': 'released',
      'correctCount': 8,
      'totalQuestions': 10,
      'percentage': 80,
      'answers': [],
    });
    await tester.pumpWidget(
      MaterialApp(home: StudentQuizResultScreen(result: result)),
    );
    expect(find.text('Score: 80%'), findsOneWidget);
    expect(
      find.text('You answered 8 out of 10 questions correctly'),
      findsOneWidget,
    );
  });
}
