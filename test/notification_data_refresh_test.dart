import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/models/user_model.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/core/providers/notification_provider.dart';
import 'package:opalmer_education/core/services/student_service.dart';
import 'package:opalmer_education/core/services/notification_socket_service.dart';

class ChangeSocket implements NotificationSocketService {
  @override
  NotificationCallback? onNotification;
  @override
  void Function(Map<String, dynamic>)? onDataChanged;
  @override
  Future<void> connect(String id) async {}
  @override
  void disconnect() {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ChangeStudentService implements StudentService {
  int version = 0;
  @override
  Future<List<StudentClassModel>> getStudentClasses(String id) async => [];
  @override
  Future<List<QuizModel>> getQuizzes(String id) async => [];
  @override
  Future<List<QuizResultModel>> getQuizResults(String id) async => [
    QuizResultModel(
      id: 'version-$version',
      quizTitle: 'Fractions',
      score: version,
      percentage: version.toDouble(),
      status: 'completed',
    ),
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'own grade data changes refresh cached results without requiring a notification or relogin',
    () async {
      final socket = ChangeSocket(), service = ChangeStudentService();
      final container = ProviderContainer(
        overrides: [
          notificationSocketProvider.overrideWithValue(socket),
          studentServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);
      container.read(authStateProvider.notifier).state = UserModel(
        id: 'student',
        username: 'Student',
        role: 'user',
        type: 'student',
      );
      container.read(notificationsProvider);
      container.listen(studentQuizResultsProvider, (_, _) {});
      expect(
        (await container.read(studentQuizResultsProvider.future)).single.id,
        'version-0',
      );
      service.version = 1;
      socket.onDataChanged!({'type': 'grade'});
      expect(
        (await container.read(studentQuizResultsProvider.future)).single.id,
        'version-1',
      );
      expect(container.read(notificationsProvider).items, isEmpty);
      container.read(authStateProvider.notifier).state = null;
      socket.onDataChanged!({'type': 'grade'});
      expect(await container.read(studentQuizResultsProvider.future), isEmpty);
    },
  );
}
