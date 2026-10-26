import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/core/models/teacher_class_model.dart';
import 'package:opalmer_education/core/providers/teacher_provider.dart';
import 'package:opalmer_education/core/providers/grading_provider.dart';
import 'package:opalmer_education/teacher_role/Home_Dashboard/home_dashboard.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/widgets/teacher_class_card.dart';
import 'package:opalmer_education/core/services/api_client.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/student_attendence.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/student_profile.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/grading_progress.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/add_document.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/class_details.dart';
import 'package:opalmer_education/parent_role/ChildsProfilesScreen/add_child.dart';

final classData = TeacherClassModel(id: 'class-1', teacherId: 'teacher-1', grade: 6, subject: 'Mathematics', section: 'A');
final student = <String, dynamic>{'_id': 'student-1', 'username': 'Actual Student', 'gradeLevel': 6, 'state': 'inactive'};

Response response(dynamic data) => Response(requestOptions: RequestOptions(path: '/test'), statusCode: 200, data: {'success': true, 'data': data});

class AttendanceApi implements ApiClient {
  final pending = Completer<Response>();
  int postCalls = 0;
  int getCalls = 0;
  String? sentStatus;
  final row = {'_id': 'attendance-1', 'userId': 'student-1', 'status': 'absent', 'date': '2026-10-19T00:00:00Z'};
  @override
  Future<Response> post(String path, {dynamic data, Options? options}) async {
    postCalls++;
    return response({'created': [], 'existing': [row]});
  }
  @override
  Future<Response> patch(String path, {dynamic data}) {
    sentStatus = data['status'];
    return pending.future;
  }
  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    getCalls++;
    throw StateError('Unexpected attendance reload');
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class LinkApi implements ApiClient {
  final pending = Completer<Response>();
  dynamic sent;
  @override
  Future<Response> post(String path, {dynamic data, Options? options}) {
    sent = data;
    return pending.future;
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> attendance(WidgetTester tester, AttendanceApi api) async {
  await tester.pumpWidget(ProviderScope(overrides: [
    apiClientProvider.overrideWithValue(api),
    classStudentsProvider('class-1').overrideWith((ref) async => [{'studentId': student}]),
  ], child: MaterialApp(home: StudentAttendanceScreen(classData: classData))));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('link child dialog validates input and stays usable with the keyboard open', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final api = LinkApi();
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => Scaffold(body: TextButton(
      onPressed: () => showDialog(context: context, barrierDismissible: false, builder: (_) => AddChildDialog(apiClient: api)),
      child: const Text('Open link dialog'),
    )))));
    await tester.tap(find.text('Open link dialog'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Link student'));
    await tester.pumpAndSettle();
    expect(find.text('Enter the student ID.'), findsOneWidget);
    expect(find.text('Enter the invitation code.'), findsOneWidget);
    expect(api.sent, isNull);
    await tester.enterText(find.byType(TextFormField).first, ' students-1 ');
    await tester.enterText(find.byType(TextFormField).last, ' abc123 ');
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Link student'));
    await tester.tap(find.text('Link student'));
    await tester.pump();
    expect(api.sent, {'childId': 'students-1', 'invitationCode': 'ABC123'});
    api.pending.complete(response({'linked': true}));
    await tester.pumpAndSettle();
    expect(find.byType(AddChildDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home class stats fill the available phone width and use real roster and missing metric states', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(overrides: [
      teacherClassesProvider.overrideWith((ref) async => [classData]),
      teacherQuizzesProvider.overrideWith((ref) async => []),
      teacherSessionsProvider(null).overrideWith((ref) async => []),
      classStudentsProvider('class-1').overrideWith((ref) async => [{'studentId': student}]),
      classDetailsAttendanceProvider('class|class-1').overrideWith((ref) async => null),
    ], child: const MaterialApp(home: HomeDashboard())));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(TeacherClassCard)).width, 350);
    expect(find.text('1 Student'), findsOneWidget);
    expect(find.text('N/A'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('attendance responds before save, rolls back on failure and does not reload the list', (tester) async {
    final api = AttendanceApi();
    await attendance(tester, api);
    await tester.tap(find.text('Absent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Present').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Present'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(api.sentStatus, 'present');
    api.pending.completeError(StateError('Save failed'));
    await tester.pumpAndSettle();
    expect(find.text('Absent'), findsOneWidget);
    expect(api.postCalls, 1);
    expect(api.getCalls, 0);
  });

  testWidgets('late selection sends the backend status and retains confirmed state', (tester) async {
    final api = AttendanceApi();
    await attendance(tester, api);
    await tester.tap(find.text('Absent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Late').last);
    await tester.pump();
    api.pending.complete(response({...api.row, 'status': 'late'}));
    await tester.pumpAndSettle();
    expect(api.sentStatus, 'late');
    expect(find.text('Late'), findsOneWidget);
    expect(api.getCalls, 0);
  });

  testWidgets('student card has no sample avatar or invented percentage and uses actual status', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      classDetailsAttendanceProvider('student|student-1|class-1').overrideWith((ref) async => null),
    ], child: MaterialApp(home: Scaffold(body: StudentCard(studentData: student, classData: classData)))));
    await tester.pumpAndSettle();
    expect(find.text('Inactive'), findsOneWidget);
    expect(find.text('N/A'), findsNWidgets(2));
    expect(find.text('85%'), findsNothing);
    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('profile dropdown offers day week month and missing assessments remain empty', (tester) async {
    final filters = <String>[];
    await tester.pumpWidget(ProviderScope(overrides: [
      classDetailsAttendanceProvider('student|student-1|class-1').overrideWith((ref) async => null),
      studentParentsProvider('student-1').overrideWith((ref) async => []),
      studentAnalysisProvider.overrideWith((ref, key) async {
        filters.add(key.split('|').last);
        return {'performanceSummary': {'percentage': null}, 'performanceChartData': []};
      }),
    ], child: MaterialApp(home: StudentProfileScreen(studentData: student, classId: 'class-1'))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(DropdownButton<String>));
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    await tester.tap(find.text('Day'));
    await tester.pumpAndSettle();
    expect(filters, containsAll(['weekly', 'daily']));
    expect(find.text('No reviewed assessments for this period.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('document dropdown opens and displays selected class without overflow', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      teacherClassesProvider.overrideWith((ref) async => [classData]),
      classStudentsProvider('class-1').overrideWith((ref) async => [{'studentId': student}]),
    ], child: const MaterialApp(home: AddDocumentScreen(studentId: 'student-1'))));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grade 6 - Mathematics (Section A)').last);
    await tester.pumpAndSettle();
    expect(find.text('Grade 6 - Mathematics (Section A)'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('grading progress displays only reviewed results in the selected class, including actual zero', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      studentQuizResultsProvider('student-1').overrideWith((ref) async => [
        {'quizId': {'classId': 'class-1', 'title': 'Real assessment'}, 'progress': {'status': 'completed'}, 'gradeStatus': 'reviewed', 'percentage': 0, 'submittedAt': '2026-10-19T00:00:00Z'},
        {'quizId': {'classId': 'class-2', 'title': 'Other class'}, 'progress': {'status': 'completed'}, 'gradeStatus': 'released', 'percentage': 93},
        {'quizId': {'classId': 'class-1', 'title': 'Unreviewed'}, 'progress': {'status': 'completed'}, 'gradeStatus': 'pending_review', 'percentage': 93},
      ]),
    ], child: const MaterialApp(home: GradingProgressScreen(studentId: 'student-1', classId: 'class-1'))));
    await tester.pumpAndSettle();
    expect(find.text('Real assessment'), findsOneWidget);
    expect(find.text('19/10/2026'), findsOneWidget);
    expect(find.text('Other class'), findsNothing);
    expect(find.text('Unreviewed'), findsNothing);
    expect(find.text('93%'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
