import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/core/models/user_model.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/grading_provider.dart';
import 'package:opalmer_education/core/services/grading_service.dart';

class AccountGradingService implements GradingService {
  String account = 'teacher-a';
  @override
  Future<List<dynamic>> getTeacherSessions({String? classId}) async => [
    {'_id': account},
  ];
  @override
  Future<Map<String, dynamic>> getSessionDetails(String id) async => {
    'teacher': account,
  };
  @override
  Future<List<dynamic>> getSessionQuestions(String id) async => [
    {'teacher': account},
  ];
  @override
  Future<Map<String, dynamic>> getAttendedSubmittedStudents(String id) async =>
      {'teacher': account};
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'assessment caches refresh for a different account and clear on logout',
    () async {
      final service = AccountGradingService();
      final container = ProviderContainer(
        overrides: [gradingServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);
      container.listen(teacherSessionsProvider(null), (_, _) {});
      container.listen(sessionDetailsProvider('quiz'), (_, _) {});
      container.listen(sessionQuestionsProvider('quiz'), (_, _) {});
      container.listen(attendedSubmittedStudentsProvider('quiz'), (_, _) {});
      for (final id in ['teacher-a', 'teacher-b']) {
        service.account = id;
        container.read(authStateProvider.notifier).state = UserModel(
          id: id,
          username: id,
          role: 'user',
          type: 'teacher',
        );
        expect(
          (await container.read(
            teacherSessionsProvider(null).future,
          )).single['_id'],
          id,
        );
        expect(
          (await container.read(
            sessionDetailsProvider('quiz').future,
          ))['teacher'],
          id,
        );
        expect(
          (await container.read(
            sessionQuestionsProvider('quiz').future,
          )).single['teacher'],
          id,
        );
        expect(
          (await container.read(
            attendedSubmittedStudentsProvider('quiz').future,
          ))['teacher'],
          id,
        );
      }
      container.read(authStateProvider.notifier).state = null;
      expect(
        await container.read(teacherSessionsProvider(null).future),
        isEmpty,
      );
      expect(
        await container.read(sessionDetailsProvider('quiz').future),
        isEmpty,
      );
      expect(
        await container.read(sessionQuestionsProvider('quiz').future),
        isEmpty,
      );
      expect(
        await container.read(attendedSubmittedStudentsProvider('quiz').future),
        isEmpty,
      );
    },
  );
}
