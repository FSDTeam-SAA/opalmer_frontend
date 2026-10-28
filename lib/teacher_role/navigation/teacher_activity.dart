import 'package:opalmer_education/core/widgets/app_home_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/teacher_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/assignment_details_screen.dart';
import '../../chat/models/chat_role.dart';
import '../../chat/screens/chat_dashboard.dart';
import '../../notification/notification.dart';
import '../Quiz_Screen/student_detail.dart';
import 'teacher_menu.dart';
import 'teacher_workspace.dart';

final teacherActivityProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      if (ref.watch(authStateProvider) == null) return {};
      final result = await ref
          .read(apiClientProvider)
          .get('/teacher-tools/activity');
      return Map<String, dynamic>.from(result.data['data']);
    });

class TeacherActivityScreen extends StatelessWidget {
  const TeacherActivityScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [const AppHomeButton()],
      title: const Text('Activity'),
    ),
    body: const SingleChildScrollView(child: TeacherActivity()),
  );
}

class TeacherActivity extends ConsumerWidget {
  const TeacherActivity({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: 'Refresh recent activity',
              onPressed: () => ref.invalidate(teacherActivityProvider),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        ref
            .watch(teacherActivityProvider)
            .when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => TextButton(
                onPressed: () => ref.invalidate(teacherActivityProvider),
                child: const Text('Unable to load activity. Retry'),
              ),
              data: (data) => Column(
                children: [
                  _section(
                    context,
                    ref,
                    'Recent submissions',
                    data['submissions'] as List? ?? [],
                    assignment: true,
                  ),
                  _section(
                    context,
                    ref,
                    'Assessments to review',
                    data['reviews'] as List? ?? [],
                  ),
                  _section(
                    context,
                    ref,
                    'Auto-graded results',
                    data['autoGraded'] as List? ?? [],
                    showScore: true,
                  ),
                ],
              ),
            ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Recent messages'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openTeacherPage(
              context,
              const ChatDashboard(role: ChatRole.teacher),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openTeacherPage(context, const NotificationScreen()),
          ),
        ),
      ],
    ),
  );

  Widget _section(
    BuildContext context,
    WidgetRef ref,
    String title,
    List rows, {
    bool assignment = false,
    bool showScore = false,
  }) => Card(
    child: ExpansionTile(
      initiallyExpanded: rows.isNotEmpty,
      title: Text(title),
      subtitle: Text(
        rows.isEmpty ? 'No recent items' : '${rows.length} recent items',
      ),
      children: rows.map((row) {
        final record = row[assignment ? 'homeworkId' : 'quizId'];
        final student = row['studentId'];
        return ListTile(
          title: Text('${record?['title'] ?? 'Unavailable item'}'),
          subtitle: Text(
            '${student?['username'] ?? 'Student'} · ${student?['Id'] ?? 'ID unavailable'}${showScore ? '\n${row['score']} points · ${row['percentage']}% · ${row['gradeStatus'] ?? 'pending_review'}' : ''}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: record is! Map || student is! Map
              ? null
              : () async {
                  final classes =
                      ref.read(teacherClassesProvider).asData?.value ?? [];
                  final classId = record['classId'] is Map
                      ? record['classId']['_id']
                      : record['classId'];
                  final matches = classes.where(
                    (cls) => cls.id == classId?.toString(),
                  );
                  Widget page = assignment
                      ? AssignmentDetailsScreen(
                          homeworkId: record['_id'].toString(),
                          studentId: student['_id'].toString(),
                        )
                      : StudentDetailScreen(resultId: row['_id'].toString());
                  if (matches.isNotEmpty) {
                    page = TeacherContextFrame(
                      classData: matches.first,
                      student: Map<String, dynamic>.from(student),
                      child: page,
                    );
                  }
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => page),
                  );
                  ref.invalidate(teacherActivityProvider);
                },
        );
      }).toList(),
    ),
  );
}
