import 'package:opalmer_education/core/constants/api_constants.dart';
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

  Future<List<dynamic>> getLessons() async {
    try {
      final response = await _apiClient.get(ApiConstants.lessons);
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getHomework() async {
    try {
      final response = await _apiClient.get(ApiConstants.homework);
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getQuizzes() async {
    try {
      final response = await _apiClient.get(ApiConstants.quizzes);
      return response.data['data'];
    } catch (e) {
      rethrow;
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

  Future<List<dynamic>> getAttendance(String userId, String classId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.attendance}/student?userId=$userId&classId=$classId'
      );
      return response.data['data']['attendanceRecords'];
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
