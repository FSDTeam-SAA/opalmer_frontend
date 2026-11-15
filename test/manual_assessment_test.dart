import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/core/models/user_model.dart';
import 'package:opalmer_education/core/models/teacher_class_model.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/teacher_provider.dart';
import 'package:opalmer_education/core/providers/grading_provider.dart';
import 'package:opalmer_education/core/services/grading_service.dart';
import 'package:opalmer_education/teacher_role/Quiz_Screen/create_quiz.dart';

class ManualGradingService implements GradingService {
  int creates = 0, aiCalls = 0;
  String title = '';
  @override
  Future<Map<String, dynamic>> createSession({
    required String classId,
    required String title,
    String? description,
    int? time,
  }) async {
    creates++;
    this.title = title;
    return {'_id': 'manual-draft'};
  }

  @override
  Future<Map<String, dynamic>> getSessionDetails(String id) async => {
    '_id': id,
    'title': title,
    'status': 'draft',
    'questionCount': 0,
    'time': 10,
    'classId': {'subject': 'Fractions', 'grade': 4},
  };
  @override
  Future<List<dynamic>> getSessionQuestions(String id) async =>
      throw StateError('An empty draft has no question document yet');
  @override
  Future<List<dynamic>> getTeacherSessions({String? classId}) async => [];
  @override
  Future<List<dynamic>> generateAIQuestions({
    required String prompt,
    int count = 10,
  }) async {
    aiCalls++;
    throw StateError('AI unavailable');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'teachers can create an empty draft and write questions without an AI request',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = ManualGradingService();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => UserModel(
                id: 'teacher',
                username: 'Teacher',
                role: 'user',
                type: 'teacher',
              ),
            ),
            gradingServiceProvider.overrideWithValue(service),
            teacherClassesProvider.overrideWith(
              (ref) async => [
                TeacherClassModel(
                  id: 'class',
                  teacherId: 'teacher',
                  grade: 4,
                  subject: 'Fractions',
                ),
              ],
            ),
          ],
          child: const MaterialApp(home: CreateQuizScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Write questions manually'));
      await tester.pumpAndSettle();
      expect(service.creates, 0);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fractions · Grade 4').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).at(0),
        'Handwritten fractions',
      );
      await tester.enterText(find.byType(TextField).at(1), '10');
      await tester.ensureVisible(find.text('Write questions manually'));
      await tester.tap(find.text('Write questions manually'));
      await tester.pumpAndSettle();
      expect(service.creates, 1);
      expect(service.aiCalls, 0);
      expect(find.text('Edit Quiz'), findsOneWidget);
      await tester.tap(find.byTooltip('Add question'));
      await tester.pumpAndSettle();
      expect(find.text('Question 1'), findsOneWidget);
      await tester.tap(find.text('PUBLISH'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Question 1 is missing question text',
        ),
        findsOneWidget,
      );
    },
  );
}
