import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/services/student_service.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';

final studentServiceProvider = Provider<StudentService>((ref) => StudentService());

final studentDashboardDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ref.watch(studentServiceProvider).getStudentDashboardData();
});

final studentLessonsProvider = FutureProvider<List<dynamic>>((ref) async {
  return await ref.watch(studentServiceProvider).getLessons();
});

final studentQuizzesProvider = FutureProvider<List<dynamic>>((ref) async {
  return await ref.watch(studentServiceProvider).getQuizzes();
});

final studentHomeworkProvider = FutureProvider<List<dynamic>>((ref) async {
  return await ref.watch(studentServiceProvider).getHomework();
});

final studentAcademicDocumentsProvider = FutureProvider<List<dynamic>>((ref) async {
  return await ref.watch(studentServiceProvider).getAcademicDocuments();
});

final studentClassesProvider = FutureProvider<List<dynamic>>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user == null) return [];
  return await ref.watch(studentServiceProvider).getStudentClasses(user.id);
});

final studentAttendanceProvider = FutureProvider<List<dynamic>>((ref) async {
  final user = ref.watch(authStateProvider);
  final classes = ref.watch(studentClassesProvider).asData?.value ?? [];
  if (user == null || classes.isEmpty) return [];
  
  final classId = classes.first['classId']['_id'] ?? classes.first['classId'];
  return await ref.watch(studentServiceProvider).getAttendance(user.id, classId);
});
