import 'package:opalmer_education/core/constants/api_constants.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/services/api_client.dart';

class StudentService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getStudentDashboardData() async {
    try {
      // In a real scenario, you might have a dedicated dashboard API
      // If not, you can call multiple APIs here.
      // For now, let's assume we fetch lessons and homework as a summary.
      final lessonsResponse = await _apiClient.get(ApiConstants.lessons);
      final homeworkResponse = await _apiClient.get(ApiConstants.homework);

      return {
        'lessons': lessonsResponse.data['data'],
        'homework': homeworkResponse.data['data'],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LessonModel>> getLessons() async {
    try {
      final response = await _apiClient.get(ApiConstants.lessons);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => LessonModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<HomeworkModel>> getHomework(String userId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.homework}/user/$userId');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => HomeworkModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<QuizModel>> getQuizzes() async {
    try {
      final response = await _apiClient.get(ApiConstants.quizzes);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => QuizModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<QuizResultModel>> getQuizResults(String studentId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.quizResults}/$studentId');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => QuizResultModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getAcademicDocuments() async {
    try {
      final response = await _apiClient.get(ApiConstants.academicDocument);
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AttendanceRecord>> getAttendance(String userId, String classId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.attendance}/student?userId=$userId&classId=$classId'
      );
      final List<dynamic> records = response.data['data']['attendanceRecords'] ?? [];
      return records.map((json) => AttendanceRecord.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuizQA?> getQuizQA(String quizId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.quizQA}/$quizId');
      if (response.data['data'] != null) {
        return QuizQA.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> submitQuiz(String quizId, String studentId, int score, int totalQuestions) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.submitQuiz,
        data: {
          'quizId': quizId,
          'studentId': studentId,
          'score': score,
          'totalQuestion': totalQuestions,
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getStudentClasses(String studentId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.stuAssignToClass}/student/$studentId'
      );
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }
}
