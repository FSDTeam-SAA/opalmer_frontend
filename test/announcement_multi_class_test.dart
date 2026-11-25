import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/core/models/teacher_class_model.dart';
import 'package:opalmer_education/core/providers/teacher_provider.dart';
import 'package:opalmer_education/core/services/api_client.dart';
import 'package:opalmer_education/teacher_role/navigation/teacher_materials.dart';
import 'package:opalmer_education/teacher_role/navigation/teacher_menu.dart';

final _math = TeacherClassModel(
  id: 'class-a',
  teacherId: 't',
  grade: 6,
  subject: 'Mathematics',
  section: 'A',
);
final _english = TeacherClassModel(
  id: 'class-b',
  teacherId: 't',
  grade: 7,
  subject: 'English',
);
final _science = TeacherClassModel(
  id: 'class-c',
  teacherId: 't',
  grade: 8,
  subject: 'Science',
);

class _AnnouncementApi implements ApiClient {
  final posts = <Map<String, dynamic>>[];
  final failFor = <String>{};

  @override
  Future<Response> post(String path, {dynamic data, Options? options}) async {
    final body = Map<String, dynamic>.from(data as Map);
    posts.add({'path': path, ...body});
    if (failFor.contains(body['classId'])) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        response: Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 500,
          data: {'message': 'Server unavailable'},
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 201,
      data: {
        'success': true,
        'data': {'_id': 'a-${body['classId']}'},
      },
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _open(WidgetTester tester, _AnnouncementApi api) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(api),
        teacherClassesProvider.overrideWith(
          (ref) async => [_math, _english, _science],
        ),
        for (final id in ['class-a', 'class-b', 'class-c'])
          teacherAnnouncementsProvider(id).overrideWith((ref) async => []),
      ],
      child: const MaterialApp(home: TeacherAnnouncementsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _compose(WidgetTester tester) async {
  await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Trip');
  await tester.enterText(
    find.widgetWithText(TextField, 'Message'),
    'Museum visit on Friday',
  );
}

Future<void> _tapSend(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Send announcement'));
  await tester.tap(find.text('Send announcement'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('teacher must pick at least one class', (tester) async {
    final api = _AnnouncementApi();
    await _open(tester, api);
    await _compose(tester);
    await _tapSend(tester);
    expect(find.text('Select at least one class.'), findsOneWidget);
    expect(api.posts, isEmpty);
  });

  testWidgets('one announcement is sent to every selected class', (
    tester,
  ) async {
    final api = _AnnouncementApi();
    await _open(tester, api);
    await tester.tap(find.text('Grade 6 · Mathematics · A'));
    await tester.tap(find.text('Grade 8 · Science'));
    await tester.pump();
    expect(find.text('Will be sent to 2 classes.'), findsOneWidget);
    await _compose(tester);
    await _tapSend(tester);

    expect(api.posts.map((p) => p['classId']), ['class-a', 'class-c']);
    for (final post in api.posts) {
      expect(post['path'], '/teacher-tools/announcements');
      expect(post['title'], 'Trip');
      expect(post['message'], 'Museum visit on Friday');
      expect(post['notifyStudent'], true);
      expect(post['notifyParent'], true);
    }
    expect(find.text('Announcement sent to 2 classes.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('select all sends to every class', (tester) async {
    final api = _AnnouncementApi();
    await _open(tester, api);
    await tester.tap(find.text('Select all'));
    await tester.pump();
    expect(find.text('Will be sent to 3 classes.'), findsOneWidget);
    await _compose(tester);
    await _tapSend(tester);
    expect(api.posts.map((p) => p['classId']), [
      'class-a',
      'class-b',
      'class-c',
    ]);
  });

  testWidgets('failed classes stay selected with the text for a resend', (
    tester,
  ) async {
    final api = _AnnouncementApi()..failFor.add('class-b');
    await _open(tester, api);
    await tester.tap(find.text('Select all'));
    await _compose(tester);
    await _tapSend(tester);

    expect(api.posts, hasLength(3));
    expect(find.textContaining('Sent to 2 of 3 classes.'), findsOneWidget);
    expect(find.textContaining('Grade 7 · English'), findsWidgets);
    // Text is kept so the teacher can resend to the failed class only.
    expect(find.text('Trip'), findsOneWidget);

    api.failFor.clear();
    api.posts.clear();
    await _tapSend(tester);
    expect(api.posts.map((p) => p['classId']), ['class-b']);
    expect(find.text('Announcement sent.'), findsOneWidget);
  });

  testWidgets('menu opens the multi-class announcement screen directly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          teacherClassesProvider.overrideWith((ref) async => [_math]),
        ],
        child: const MaterialApp(home: TeacherMenuScreen()),
      ),
    );
    await tester.enterText(
      find.byKey(const ValueKey('teacher-menu-search')),
      'Announcements',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('teacher-menu-Announcements')));
    await tester.pumpAndSettle();
    expect(find.byType(TeacherAnnouncementsScreen), findsOneWidget);
    expect(find.text('Send to classes'), findsOneWidget);
  });
}
