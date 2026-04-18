import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/models/teacher_class_model.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/services/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final teacherClassesProvider = FutureProvider<List<TeacherClassModel>>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user == null) return [];

  final apiClient = ref.read(apiClientProvider);
  
  // 1. Fetch all classes for this teacher
  final response = await apiClient.get('/classes/teacher/${user.id}');
  
  if (response.statusCode == 200 && response.data['success'] == true) {
    final List<dynamic> classData = response.data['data'];
    final List<TeacherClassModel> classes = classData.map((e) => TeacherClassModel.fromJson(e)).toList();

    // 2. For each class, fetch the student count
    final updatedClasses = await Future.wait(classes.map((cls) async {
      try {
        final stuResponse = await apiClient.get('/student-assign-to-class/class/${cls.id}');
        if (stuResponse.statusCode == 200 && stuResponse.data['success'] == true) {
          final List<dynamic> assignments = stuResponse.data['data'];
          return cls.copyWith(studentCount: assignments.length);
        }
      } catch (e) {
        // Log error or handle gracefully
      }
      return cls;
    }));

    return updatedClasses;
  }
  
  return [];
});

final classStudentsProvider = FutureProvider.family<List<dynamic>, String>((ref, classId) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/student-assign-to-class/class/$classId');
  if (response.statusCode == 200 && response.data['success'] == true) {
    return response.data['data'];
  }
  return [];
});

final classLessonsProvider = FutureProvider.family<List<dynamic>, String>((ref, classId) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/lessons/class/$classId');
  if (response.statusCode == 200 && response.data['success'] == true) {
    return response.data['data'];
  }
  return [];
});

final classHomeworkProvider = FutureProvider.family<List<dynamic>, String>((ref, classId) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/homework/class/$classId');
  if (response.statusCode == 200 && response.data['success'] == true) {
    return response.data['data'];
  }
  return [];
});

final userRoomsProvider = FutureProvider<List<dynamic>>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user == null) return [];
  
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/rooms/user/${user.id}');
  if (response.statusCode == 200 && response.data['success'] == true) {
    return response.data['data'];
  }
  return [];
});


