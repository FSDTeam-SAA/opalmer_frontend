import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/services/grading_service.dart';

final gradingServiceProvider = Provider((ref) => GradingService());

final teacherSessionsProvider = FutureProvider.family<List<dynamic>, String?>((ref, classId) async {
  final service = ref.watch(gradingServiceProvider);
  return service.getTeacherSessions(classId: classId);
});

final sessionDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, sessionId) async {
  final service = ref.watch(gradingServiceProvider);
  return service.getSessionDetails(sessionId);
});

final sessionQuestionsProvider = FutureProvider.family<List<dynamic>, String>((ref, sessionId) async {
  final service = ref.watch(gradingServiceProvider);
  return service.getSessionQuestions(sessionId);
});

final sessionResultsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, sessionId) async {
  final service = ref.watch(gradingServiceProvider);
  return service.getSessionResults(sessionId);
});

class GradingNotifier extends StateNotifier<AsyncValue<void>> {
  final GradingService _service;
  final Ref _ref;

  GradingNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>?> createAndSaveSession({
    required String classId,
    required String title,
    required List<Map<String, dynamic>> questions,
    int? time,
    bool publish = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      // 1. Create session
      final session = await _service.createSession(
        classId: classId,
        title: title,
        time: time,
      );
      
      final sessionId = session['_id'];

      // 2. Save questions
      await _service.upsertQuestions(
        sessionId: sessionId,
        questions: questions,
      );

      // 3. Publish if requested
      if (publish) {
        await _service.publishSession(sessionId);
      }

      state = const AsyncValue.data(null);
      
      // Refresh the sessions list
      _ref.invalidate(teacherSessionsProvider);
      
      return session;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  Future<List<dynamic>?> generateAIQuestions(String prompt) async {
    try {
      return await _service.generateAIQuestions(prompt: prompt);
    } catch (e) {
      // We don't necessarily want to set the global state to error for AI generation failure
      // so the UI can handle it locally
      return null;
    }
  }
}

final gradingActionProvider = StateNotifierProvider<GradingNotifier, AsyncValue<void>>((ref) {
  return GradingNotifier(ref.watch(gradingServiceProvider), ref);
});
