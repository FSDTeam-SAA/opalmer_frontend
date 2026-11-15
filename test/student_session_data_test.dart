import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/models/user_model.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/core/services/student_service.dart';

class SessionStudentService implements StudentService {
  String account = 'first';
  @override
  Future<List<LessonModel>> getLessons() async => [
    LessonModel(
      id: account,
      studentId: account,
      objective: 'Private lesson',
      note: '',
      isArchived: false,
    ),
  ];
  @override
  Future<List<AcademicDocumentModel>> getAcademicDocuments() async => [
    AcademicDocumentModel(id: account),
  ];
  @override
  Future<Map<String, dynamic>> getStudentDashboardData() async => {
    'account': account,
  };
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'switching student accounts refreshes cached lessons, documents and dashboard; logout clears them',
    () async {
      final service = SessionStudentService();
      final container = ProviderContainer(
        overrides: [studentServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);
      container.listen(studentLessonsProvider, (_, _) {});
      container.listen(studentAcademicDocumentsProvider, (_, _) {});
      container.listen(studentDashboardDataProvider, (_, _) {});
      UserModel student(String id) =>
          UserModel(id: id, username: id, role: 'user', type: 'student');
      container.read(authStateProvider.notifier).state = student('first');
      expect(
        (await container.read(studentLessonsProvider.future)).single.id,
        'first',
      );
      expect(
        (await container.read(
          studentAcademicDocumentsProvider.future,
        )).single.id,
        'first',
      );
      expect(
        (await container.read(studentDashboardDataProvider.future))['account'],
        'first',
      );
      service.account = 'second';
      container.read(authStateProvider.notifier).state = student('second');
      expect(
        (await container.read(studentLessonsProvider.future)).single.id,
        'second',
      );
      expect(
        (await container.read(
          studentAcademicDocumentsProvider.future,
        )).single.id,
        'second',
      );
      expect(
        (await container.read(studentDashboardDataProvider.future))['account'],
        'second',
      );
      container.read(authStateProvider.notifier).state = null;
      expect(await container.read(studentLessonsProvider.future), isEmpty);
      expect(
        await container.read(studentAcademicDocumentsProvider.future),
        isEmpty,
      );
      expect(
        await container.read(studentDashboardDataProvider.future),
        isEmpty,
      );
    },
  );
}
