import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/teacher_class_model.dart';
import '../../core/providers/teacher_provider.dart';
import '../../core/widgets/assignment_details_screen.dart';
import '../Classes_Screen/behavior_record.dart';
import '../Classes_Screen/grading_progress.dart';
import '../Classes_Screen/student_attendence.dart';
import '../Quiz_Screen/student_detail.dart';
import 'teacher_workspace.dart';

class TeacherStudentActions extends ConsumerWidget {
  final Map<String, dynamic> student;
  final String? classId;
  final VoidCallback? onMessage;
  const TeacherStudentActions({
    super.key,
    required this.student,
    this.classId,
    this.onMessage,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(teacherClassesProvider).asData?.value ?? [];
    final matches = classes.where((cls) => cls.id == classId);
    final cls = matches.isEmpty ? null : matches.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Student ID: ${student['Id'] ?? 'Unavailable'}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (cls != null) ...[
          Text(classLabel(cls)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (onMessage != null)
                ActionChip(label: const Text('Messages'), onPressed: onMessage),
              _action(
                context,
                cls,
                'Grades',
                GradingProgressScreen(
                  studentId: student['_id'].toString(),
                  classId: cls.id,
                ),
              ),
              _action(
                context,
                cls,
                'Assignments',
                StudentAssignmentsScreen(classData: cls, student: student),
              ),
              _action(
                context,
                cls,
                'Assessments',
                StudentAssessmentsScreen(classData: cls, student: student),
              ),
              _action(
                context,
                cls,
                'Attendance',
                StudentAttendanceScreen(
                  classData: cls,
                  studentId: student['_id'].toString(),
                ),
              ),
              _action(
                context,
                cls,
                'Behavior',
                BehaviorRecordScreen(
                  studentId: student['_id'].toString(),
                  student: student,
                  classId: cls.id,
                ),
              ),
              _action(
                context,
                cls,
                'Homework Help',
                TeacherHelpAssignments(classData: cls, student: student),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _action(
    BuildContext context,
    TeacherClassModel cls,
    String title,
    Widget page,
  ) => ActionChip(
    label: Text(title),
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TeacherContextFrame(classData: cls, student: student, child: page),
      ),
    ),
  );
}

class StudentAssignmentsScreen extends ConsumerWidget {
  final TeacherClassModel classData;
  final Map<String, dynamic> student;
  const StudentAssignmentsScreen({
    super.key,
    required this.classData,
    required this.student,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Student Assignments')),
    body: ref
        .watch(classHomeworkProvider(classData.id))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: TextButton(
              onPressed: () =>
                  ref.invalidate(classHomeworkProvider(classData.id)),
              child: const Text('Unable to load assignments. Retry'),
            ),
          ),
          data: (rows) {
            final items = rows.where((hw) {
              final ids = hw['studentIds'] as List? ?? [];
              return ids.isEmpty ||
                  ids.any(
                    (id) =>
                        (id is Map ? id['_id'] : id).toString() ==
                        student['_id'].toString(),
                  );
            }).toList();
            return ListView(
              children: [
                if (items.isEmpty)
                  const ListTile(
                    title: Text('No assignments for this student.'),
                  ),
                ...items.map(
                  (item) => ListTile(
                    title: Text('${item['title']}'),
                    subtitle: Text('${item['status'] ?? 'published'}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherContextFrame(
                          classData: classData,
                          student: student,
                          child: AssignmentDetailsScreen(
                            homeworkId: item['_id'].toString(),
                            studentId: student['_id'].toString(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
  );
}

class StudentAssessmentsScreen extends ConsumerWidget {
  final TeacherClassModel classData;
  final Map<String, dynamic> student;
  const StudentAssessmentsScreen({
    super.key,
    required this.classData,
    required this.student,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Student Assessments')),
    body: ref
        .watch(studentQuizResultsProvider(student['_id'].toString()))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(
                studentQuizResultsProvider(student['_id'].toString()),
              ),
              child: const Text('Unable to load assessments. Retry'),
            ),
          ),
          data: (rows) {
            final items = rows
                .where(
                  (r) =>
                      r['quizId'] is Map &&
                      (r['quizId']['classId'] is Map
                                  ? r['quizId']['classId']['_id']
                                  : r['quizId']['classId'])
                              ?.toString() ==
                          classData.id,
                )
                .toList();
            return ListView(
              children: [
                if (items.isEmpty)
                  const ListTile(
                    title: Text('No assessment attempts in this class.'),
                  ),
                ...items.map(
                  (r) => ListTile(
                    title: Text('${r['quizId']['title']}'),
                    subtitle: Text(
                      '${r['progress']?['status']} · ${r['gradeStatus'] ?? 'pending_review'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: r['progress']?['status'] != 'completed'
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TeacherContextFrame(
                                classData: classData,
                                student: student,
                                child: StudentDetailScreen(
                                  resultId: r['_id'].toString(),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
  );
}
