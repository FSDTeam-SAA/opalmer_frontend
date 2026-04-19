import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/services/student_service.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';

final studentServiceProvider = Provider<StudentService>((ref) => StudentService());

final studentDashboardDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ref.watch(studentServiceProvider).getStudentDashboardData();
});

final studentLessonsProvider = FutureProvider<List<LessonModel>>((ref) async {
  return await ref.watch(studentServiceProvider).getLessons();
});

final studentQuizzesProvider = FutureProvider<List<QuizModel>>((ref) async {
  return await ref.watch(studentServiceProvider).getQuizzes();
});

final studentHomeworkProvider = FutureProvider<List<HomeworkModel>>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user == null) return [];
  return await ref.watch(studentServiceProvider).getHomework(user.id);
});

final studentAcademicDocumentsProvider = FutureProvider<List<dynamic>>((ref) async {
  return await ref.watch(studentServiceProvider).getAcademicDocuments();
});

final studentClassesProvider = FutureProvider<List<dynamic>>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user == null) return [];
  return await ref.watch(studentServiceProvider).getStudentClasses(user.id);
});

final studentAttendanceProvider = FutureProvider<List<AttendanceRecord>>((ref) async {
  final user = ref.watch(authStateProvider);
  final classes = ref.watch(studentClassesProvider).asData?.value ?? [];
  if (user == null || classes.isEmpty) return [];
  
  final classId = (classes.first['classId'] is Map) 
    ? classes.first['classId']['_id'] 
    : classes.first['classId'];
    
  return await ref.watch(studentServiceProvider).getAttendance(user.id, classId);
});

final quizQAProvider = FutureProvider.family<QuizQA?, String>((ref, quizId) async {
  return await ref.watch(studentServiceProvider).getQuizQA(quizId);
});

final studentQuizResultsProvider = FutureProvider<List<QuizResultModel>>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user == null) return [];
  return await ref.watch(studentServiceProvider).getQuizResults(user.id);
});

final studentBehaviorsProvider =
    FutureProvider<List<BehaviorRecord>>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user == null) return [];
  return await ref.watch(studentServiceProvider).getStudentBehaviors();
});
