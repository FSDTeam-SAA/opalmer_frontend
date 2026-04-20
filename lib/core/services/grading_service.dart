import 'package:dio/dio.dart';
import 'package:opalmer_education/core/services/api_client.dart';

class GradingService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getTeacherSessions({String? classId}) async {
    final response = await _apiClient.get(
      '/grading/sessions',
      queryParameters: classId != null ? {'classId': classId} : null,
    );
    return response.data['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createSession({
    required String classId,
    required String title,
    String? description,
    int? time,
  }) async {
    final response = await _apiClient.post(
      '/grading/sessions',
      data: {
        'classId': classId,
        'title': title,
        'description': description ?? '',
        'time': time ?? 5,
      },
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> upsertQuestions({
    required String sessionId,
    required List<Map<String, dynamic>> questions,
  }) async {
    final response = await _apiClient.post(
      '/grading/sessions/$sessionId/questions',
      data: {'questions': questions},
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> publishSession(String sessionId) async {
    final response = await _apiClient.patch(
      '/grading/sessions/$sessionId/publish',
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSessionDetails(String sessionId) async {
    final response = await _apiClient.get('/grading/sessions/$sessionId');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getSessionQuestions(String sessionId) async {
    final response = await _apiClient.get('/grading/sessions/$sessionId/questions');
    // The controller returns questions wrapped in a data object
    return response.data['data']['questions'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getSessionResults(String sessionId) async {
    final response = await _apiClient.get('/grading/sessions/$sessionId/results');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> generateAIQuestions({
    required String prompt,
    int count = 5,
  }) async {
    final response = await _apiClient.post(
      '/quiz/qa/generate',
      data: {'prompt': prompt, 'count': count},
    );
    // Assuming the AI generator returns an array of questions directly or in a specific field
    return response.data['data'] as List<dynamic>;
  }
}

