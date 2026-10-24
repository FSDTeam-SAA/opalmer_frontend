import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/custom_bottom_navigation_bar/custom_bottom_navigation_bar.dart';
import 'package:opalmer_education/core/models/teacher_class_model.dart';
import 'package:opalmer_education/core/providers/teacher_provider.dart';
import 'package:opalmer_education/core/services/api_client.dart';
import 'package:opalmer_education/core/services/attachment_service.dart';
import 'package:opalmer_education/teacher_role/navigation/teacher_menu.dart';
import 'package:opalmer_education/teacher_role/navigation/teacher_workspace.dart';
import 'package:opalmer_education/teacher_role/navigation/teacher_materials.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/add_document.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/add_behavior.dart';

final cls = TeacherClassModel(
  id: 'class-a',
  teacherId: 'teacher',
  grade: 6,
  subject: 'Mathematics',
  section: 'A',
);
final other = TeacherClassModel(
  id: 'class-b',
  teacherId: 'teacher',
  grade: 7,
  subject: 'English',
);
const student = {'_id': 'student-a', 'username': 'Jordan', 'Id': 'TEST-1001'};

class ToolsApi implements ApiClient {
  String? path;
  dynamic sent;
  @override
  Future<Response> post(String path, {dynamic data, Options? options}) async {
    this.path = path;
    sent = data;
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 201,
      data: {
        'success': true,
        'data': {'_id': 'resource'},
      },
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'attachment validation rejects oversize and unsupported types; bytes upload needs no path',
    () async {
      final file = PlatformFile(
        name: 'lesson.PDF',
        size: 4,
        bytes: Uint8List.fromList([1, 2, 3, 4]),
      );
      final multipart = await AttachmentService.multipart(
        file,
        maxMb: 10,
        extensions: ['pdf'],
      );
      expect(multipart.filename, 'lesson.PDF');
      expect(multipart.length, 4);
      expect(
        AttachmentService.validate(
          PlatformFile(name: 'huge.pdf', size: 11 * 1024 * 1024),
          maxMb: 10,
        ),
        contains('10 MB'),
      );
      expect(
        AttachmentService.validate(PlatformFile(name: 'app.exe', size: 20)),
        contains('Unsupported'),
      );
      expect(
        () => AttachmentService.multipart(
          PlatformFile(name: 'missing.pdf', size: 20),
        ),
        throwsFormatException,
      );
    },
  );

  testWidgets('teacher navigation has only the four daily destinations', (
    tester,
  ) async {
    int? selection;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: 0,
            onTap: (index) => selection = index,
          ),
        ),
      ),
    );
    for (final title in ['Home', 'Classes', 'Assignments', 'Grades']) {
      expect(find.text(title), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('teacher-nav-Menu')), findsNothing);
    await tester.tap(find.text('Grades'));
    expect(selection, 3);
  });

  testWidgets('menu search opens attendance through a direct class picker', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          teacherClassesProvider.overrideWith((ref) async => [cls]),
        ],
        child: const MaterialApp(home: TeacherMenuScreen()),
      ),
    );
    await tester.enterText(
      find.byKey(const ValueKey('teacher-menu-search')),
      'Attendance',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('teacher-menu-Attendance')));
    await tester.pumpAndSettle();
    expect(find.text('Select a class'), findsOneWidget);
    expect(find.text('Grade 6 · Mathematics · A'), findsOneWidget);
    expect(find.byType(TeacherClassPicker), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('behavior action retains the selected class and Phantom ID', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          classStudentsProvider('class-a').overrideWith(
            (ref) async => [
              {'studentId': student},
            ],
          ),
        ],
        child: MaterialApp(
          home: TeacherContextFrame(
            classData: cls,
            child: TeacherStudentPicker(
              classData: cls,
              feature: TeacherFeature.newBehavior,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jordan'));
    await tester.pumpAndSettle();
    final form = tester.widget<AddBehaviorScreen>(
      find.byType(AddBehaviorScreen),
    );
    expect(form.studentId, 'student-a');
    expect(form.classId, 'class-a');
    expect(find.textContaining('Jordan · TEST-1001'), findsOneWidget);
    expect(find.textContaining('Grade 6 · Mathematics · A'), findsWidgets);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Jordan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'class picker opens the correct class assignment workspace and back works',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            teacherClassesProvider.overrideWith((ref) async => [cls, other]),
          ],
          child: const MaterialApp(
            home: TeacherClassPicker(feature: TeacherFeature.newAssignment),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Grade 7 · English'));
      await tester.pumpAndSettle();
      expect(find.text('Grade 7 · English'), findsOneWidget);
      expect(find.text('Assignment title'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Select a class'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'academic upload excludes classes where the selected student is not enrolled',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            teacherClassesProvider.overrideWith((ref) async => [cls, other]),
            classStudentsProvider('class-a').overrideWith(
              (ref) async => [
                {'studentId': student},
              ],
            ),
            classStudentsProvider('class-b').overrideWith(
              (ref) async => [
                {
                  'studentId': {'_id': 'someone-else'},
                },
              ],
            ),
          ],
          child: const MaterialApp(
            home: AddDocumentScreen(studentId: 'student-a'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      expect(find.text('Grade 6 - Mathematics (Section A)'), findsWidgets);
      expect(find.textContaining('English'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'homework help sends assignment and student context with independent notification choices',
    (tester) async {
      final api = ToolsApi();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(api)],
          child: MaterialApp(
            home: AddTeachingResource(
              classData: cls,
              homework: const {'_id': 'assignment-a', 'title': 'Fractions'},
              student: student,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField).first, 'Worked example');
      await tester.enterText(
        find.byType(TextField).last,
        'https://example.com/help',
      );
      await tester.tap(find.text('Notify student'));
      await tester.ensureVisible(find.text('Save resource'));
      await tester.tap(find.text('Save resource'));
      await tester.pumpAndSettle();
      final fields = Map.fromEntries((api.sent as FormData).fields);
      expect(api.path, '/teacher-tools/resources');
      expect(fields['homeworkId'], 'assignment-a');
      expect(fields['studentId'], 'student-a');
      expect(fields['classId'], 'class-a');
      expect(fields['notifyStudent'], 'false');
      expect(fields['notifyParent'], 'true');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'announcement form validates its audience and preserves class in the send request',
    (tester) async {
      final api = ToolsApi();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(api),
            teacherAnnouncementsProvider(
              'class-a',
            ).overrideWith((ref) async => []),
          ],
          child: MaterialApp(home: TeacherAnnouncementsScreen(classData: cls)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Reminder');
      await tester.enterText(
        find.byType(TextField).last,
        'Bring your workbook',
      );
      await tester.tap(find.text('Send to students'));
      await tester.tap(find.text('Send to parents'));
      await tester.ensureVisible(find.text('Send announcement'));
      await tester.tap(find.text('Send announcement'));
      await tester.pumpAndSettle();
      expect(api.sent, isNull);
      expect(
        find.text('Enter a title, a message and choose an audience.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Send to parents'));
      await tester.tap(find.text('Send announcement'));
      await tester.pumpAndSettle();
      expect(api.path, '/teacher-tools/announcements');
      expect(api.sent['classId'], 'class-a');
      expect(api.sent['notifyStudent'], false);
      expect(api.sent['notifyParent'], true);
      expect(tester.takeException(), isNull);
    },
  );
}
