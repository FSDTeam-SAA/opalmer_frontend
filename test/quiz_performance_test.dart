import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/student_role/StudentHomeDashboard/student_home_dashboard.dart';
import 'package:opalmer_education/student_role/Quizzes/quiz_performance.dart';
import 'package:opalmer_education/student_role/Quizzes/quiz_summary_card.dart';

QuizResultModel result(DateTime date, double percent) => QuizResultModel(
  id: 'result',
  quizId: 'quiz',
  quizTitle: 'Fractions',
  score: 0,
  percentage: percent,
  status: 'completed',
  createdAt: date,
);

void main() {
  testWidgets('home preserves submitted and released assessment states', (
    tester,
  ) async {
    final pending = QuizModel.fromJson({
      '_id': 'pending',
      'title': 'Pending fractions',
      'resultStatus': 'completed',
    });
    final released = QuizModel.fromJson({
      '_id': 'quiz',
      'title': 'Released fractions',
      'resultStatus': 'completed',
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studentClassesProvider.overrideWith((ref) async => []),
          studentQuizzesProvider.overrideWith((ref) async => [pending, released]),
          studentQuizResultsProvider.overrideWith(
            (ref) async => [result(DateTime(2026, 11, 15), 1)],
          ),
        ],
        child: const MaterialApp(home: StudentHomeDashboard()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('View result'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Released score: 100%'), findsOneWidget);
    expect(find.text('View submission'), findsOneWidget);
    expect(find.text('Retake Quiz'), findsNothing);
    expect(find.text('Start Learning'), findsNothing);
    expect(find.text('0%'), findsNothing);
  });
  testWidgets(
    'submitted assessments show saved status without restarting or exposing an unreleased grade',
    (tester) async {
      final quiz = QuizModel.fromJson({
        '_id': 'quiz',
        'title': 'Fractions',
        'resultStatus': 'completed',
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: QuizSummaryCard(quiz: quiz)),
        ),
      );
      expect(find.text('View submission'), findsOneWidget);
      expect(find.text('Open assessment'), findsNothing);
      expect(find.textContaining('%'), findsNothing);
      await tester.tap(find.text('View submission'));
      await tester.pumpAndSettle();
      expect(find.text('Assessment submitted'), findsOneWidget);
      expect(find.textContaining('Your answers are saved.'), findsOneWidget);
    },
  );
  test(
    'daily results average multiple attempts and distinguish no grade from zero',
    () {
      final now = DateTime(2026, 11, 15);
      final results = [
        result(now, 0),
        result(now, 1),
        result(DateTime(2026, 11, 14), 0),
        result(DateTime(2026, 10, 29), .8),
      ];
      final week = quizPerformance(results, now: now, days: 7);
      expect(week.last.percentage, 50);
      expect(week[5].percentage, 0);
      expect(week[4].percentage, isNull);
      final month = quizPerformance(results, now: now, days: 30);
      expect(month.where((day) => day.percentage != null).length, 3);
      expect(month.first.date, DateTime(2026, 10, 17));
      expect(month.last.date, now);
    },
  );

  testWidgets(
    'unreleased scores are not invented and a released zero opens its result',
    (tester) async {
      final quiz = QuizModel.fromJson({'_id': 'quiz', 'title': 'Fractions'});
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: QuizSummaryCard(quiz: quiz)),
        ),
      );
      expect(find.textContaining('0%'), findsNothing);
      expect(find.text('Open assessment'), findsOneWidget);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizSummaryCard(
              quiz: quiz,
              result: result(DateTime(2026, 11, 15), 0),
            ),
          ),
        ),
      );
      expect(find.text('Released score: 0%'), findsOneWidget);
      await tester.tap(find.text('View result'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Points earned: 0'), findsOneWidget);
      expect(find.text('Open assessment'), findsNothing);
    },
  );
}
