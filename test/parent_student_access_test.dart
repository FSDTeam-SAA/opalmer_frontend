import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/core/models/notification_model.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/notification_provider.dart';
import 'package:opalmer_education/core/services/api_client.dart';
import 'package:opalmer_education/notification/notification.dart';
import 'package:opalmer_education/parent_role/SubjectsScreen/homework_screen.dart';
import 'package:opalmer_education/parent_role/SubjectsScreen/lessons_screen.dart';

class ParentApi implements ApiClient {
  final queries = <Map<String, dynamic>?>[];
  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    queries.add(queryParameters);
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'success': true, 'data': []},
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestNotifications extends NotificationNotifier {
  TestNotifications(super.ref) {
    state = NotificationState(
      items: [
        NotificationModel(
          id: 'maya',
          to: 'parent',
          message: 'Maya attendance',
          type: 'attendance',
          studentId: 'maya',
          isViewed: false,
        ),
        NotificationModel(
          id: 'jordan',
          to: 'parent',
          message: 'Jordan attendance',
          type: 'attendance',
          studentId: 'jordan',
          isViewed: false,
        ),
      ],
    );
  }
  @override
  Future<void> load({bool silent = false}) async {}
}

void main() {
  testWidgets('homework and group work requests include the selected child', (
    tester,
  ) async {
    final api = ParentApi();
    await tester.pumpWidget(
      MaterialApp(
        home: HomeworkScreen(
          childId: 'maya',
          classId: 'class',
          subjectName: 'Math',
          apiClient: api,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(api.queries, [
      {'childId': 'maya'},
      {'childId': 'maya'},
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lesson requests include the selected child', (tester) async {
    final api = ParentApi();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: LessonsScreen(
            childId: 'maya',
            classId: 'class',
            subjectName: 'Math',
            apiClient: api,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(api.queries, [
      {'childId': 'maya'},
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'selected child notification screen hides sibling notifications',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => null),
            notificationsProvider.overrideWith((ref) => TestNotifications(ref)),
          ],
          child: const MaterialApp(home: NotificationScreen(childId: 'maya')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Maya attendance'), findsOneWidget);
      expect(find.text('Jordan attendance'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
