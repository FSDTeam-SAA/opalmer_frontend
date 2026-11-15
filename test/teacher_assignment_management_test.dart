import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/core/models/user_model.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/teacher_provider.dart';
import 'package:opalmer_education/core/services/api_client.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/widgets/teacher_assignment_list.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/widgets/teacher_lesson_list.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/group_detail_screen.dart';

class AssignmentApi implements ApiClient {
  String? patched;
  final rows = <Map<String, dynamic>>[
    {
      '_id': 'active',
      'title': 'Active practice',
      'description': 'Draw fractions',
      'pointsPossible': 20,
      'status': 'published',
      'archived': false,
    },
    {
      '_id': 'archived',
      'title': 'Old practice',
      'description': 'Archived work',
      'status': 'published',
      'archived': true,
    },
  ];
  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async => Response(
    requestOptions: RequestOptions(path: path),
    statusCode: 200,
    data: {'success': true, 'data': rows},
  );
  @override
  Future<Response> patch(String path, {dynamic data}) async {
    patched = path;
    rows.first['archived'] = data['archived'];
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'group detail renders populated member identities and uses real assignment archive state',
    (tester) async {
      final api = AssignmentApi();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(api),
            classStudentsProvider('class-1').overrideWith(
              (ref) async => [
                {
                  'studentId': {
                    '_id': 'student-1',
                    'username': 'Example student',
                  },
                },
              ],
            ),
          ],
          child: const MaterialApp(
            home: GroupDetailScreen(
              classId: 'class-1',
              roomData: {
                '_id': 'group-1',
                'name': 'Study group',
                'createdBy': 'teacher-1',
                'participants': [
                  {
                    'userId': {
                      '_id': 'teacher-1',
                      'username': 'Example teacher',
                    },
                  },
                  {
                    'userId': {
                      '_id': 'student-1',
                      'username': 'Example student',
                    },
                  },
                ],
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Example teacher'), findsOneWidget);
      expect(find.text('Example student'), findsOneWidget);
      expect(find.text('Open group chat'), findsOneWidget);
      await tester.tap(find.text('Class assignments'));
      await tester.pumpAndSettle();
      expect(find.text('Active practice'), findsOneWidget);
      expect(find.text('Old practice'), findsNothing);
      await tester.tap(find.text('Archived'));
      await tester.pumpAndSettle();
      expect(find.text('Old practice'), findsOneWidget);
      expect(find.text('Active practice'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'lesson active/archive filter and editor use saved lesson fields',
    (tester) async {
      final api = AssignmentApi();
      api.rows.clear();
      api.rows.addAll([
        {
          '_id': 'lesson-1',
          'classId': 'class-1',
          'title': 'Fractions lesson',
          'objective': 'Compare halves',
          'note': 'Two quarters make a half.',
          'isArchived': false,
        },
        {
          '_id': 'lesson-2',
          'classId': 'class-1',
          'title': 'Archived lesson',
          'objective': 'Old objective',
          'note': 'Old note',
          'isArchived': true,
        },
      ]);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(api)],
          child: const MaterialApp(
            home: Scaffold(body: TeacherLessonList(classId: 'class-1')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Fractions lesson'), findsOneWidget);
      expect(find.text('Archived lesson'), findsNothing);
      await tester.tap(find.text('Archived'));
      await tester.pumpAndSettle();
      expect(find.text('Archived lesson'), findsOneWidget);
      expect(find.text('Fractions lesson'), findsNothing);
      await tester.tap(find.text('Active'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.text('Edit lesson'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Compare halves'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Two quarters make a half.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'active and archived assignments are separate and archiving uses the selected assignment',
    (tester) async {
      final api = AssignmentApi();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(api)],
          child: const MaterialApp(
            home: Scaffold(body: TeacherAssignmentList(classId: 'class-1')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Active practice'), findsOneWidget);
      expect(find.text('Old practice'), findsNothing);
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();
      expect(api.patched, '/homework/archive/active');
      expect(find.text('No active assignments.'), findsOneWidget);
      await tester.tap(find.text('Archived'));
      await tester.pumpAndSettle();
      expect(find.text('Active practice'), findsOneWidget);
      expect(find.text('Old practice'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'edit pre-fills saved instructions and points; delete requires confirmation',
    (tester) async {
      final api = AssignmentApi();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(api),
            authStateProvider.overrideWith(
              (ref) => UserModel(
                id: 'teacher',
                username: 'Teacher',
                role: 'user',
                type: 'teacher',
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: TeacherAssignmentList(classId: 'class-1')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.text('Edit assignment'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Active practice'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Draw fractions'), findsOneWidget);
      expect(find.widgetWithText(TextField, '20'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete assignment?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Active practice'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
