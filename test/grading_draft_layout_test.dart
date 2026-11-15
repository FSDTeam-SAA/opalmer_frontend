import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/core/providers/grading_provider.dart';
import 'package:opalmer_education/core/theme/app_theme.dart';
import 'package:opalmer_education/teacher_role/Quiz_Screen/grading_tool.dart';

void main() {
  testWidgets(
    'a saved draft renders its Publish action under the application button theme',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            teacherSessionsProvider(null).overrideWith(
              (ref) async => [
                {
                  '_id': 'draft',
                  'title':
                      'QA equivalent fractions assessment with a long title',
                  'status': 'draft',
                  'time': 10,
                  'questionCount': 1,
                },
              ],
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const GradingToolScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('QA equivalent fractions'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Publish'), findsOneWidget);
    },
  );
}
