import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/teacher_class_model.dart';
import '../../core/providers/teacher_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/assignment_details_screen.dart';
import '../Classes_Screen/add_behavior.dart';
import '../Classes_Screen/add_class.dart';
import '../Classes_Screen/add_homework_screen.dart';
import '../Classes_Screen/behavior_record.dart';
import '../Classes_Screen/grading_progress.dart';
import '../Classes_Screen/homework_screen.dart';
import '../Classes_Screen/lessons_screen.dart';
import '../Classes_Screen/student_attendence.dart';
import '../Classes_Screen/student_profile.dart';
import '../Quiz_Screen/quiz_details.dart';
import '../../core/providers/grading_provider.dart';
import 'teacher_materials.dart';

enum TeacherFeature {
  assignments('Assignments', 'Create and manage class assignments'),
  newAssignment('Create Assignment', 'Choose the class for this assignment'),
  grades('Grades', 'Review assignment submissions and assessment results'),
  attendance('Attendance', 'Take and review attendance'),
  behavior('Behavior', 'Record and review student behavior'),
  newBehavior('Add Behavior', 'Choose a student to record behavior'),
  help('Homework Help', 'Attach PDF, video or links to an assignment'),
  announcements('Announcements', 'Send updates to students and parents'),
  reports('Reports & Data', 'Class and student performance and attendance'),
  resources('Resources', 'Files, videos and teaching materials'),
  lessons('Lessons', 'Create and manage lesson materials'),
  groups('Groups', 'Group assignments and members'),
  students('Classes & Students', 'Rosters and student profiles');

  final String title;
  final String description;
  const TeacherFeature(this.title, this.description);
}

String classLabel(TeacherClassModel cls) =>
    'Grade ${cls.grade} · ${cls.subject}${cls.section?.isNotEmpty == true ? ' · ${cls.section}' : ''}';
final teacherLastClassProvider = StateProvider<String?>((ref) {
  ref.watch(authStateProvider);
  return null;
});

class TeacherClassPicker extends ConsumerWidget {
  final TeacherFeature feature;
  final bool embedded;
  const TeacherClassPicker({
    super.key,
    required this.feature,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(teacherClassesProvider);
    final lastId = ref.watch(teacherLastClassProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(feature.title),
        automaticallyImplyLeading: !embedded,
      ),
      body: classes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(teacherClassesProvider),
            child: const Text('Unable to load classes. Retry'),
          ),
        ),
        data: (items) {
          final sorted = [...items]
            ..sort(
              (a, b) => a.id == b.id
                  ? 0
                  : a.id == lastId
                  ? -1
                  : b.id == lastId
                  ? 1
                  : classLabel(a).compareTo(classLabel(b)),
            );
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(feature.description),
              const SizedBox(height: 8),
              const Text('Select a class'),
              if (sorted.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('You have no classes yet.'),
                ),
                FilledButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddClassScreen()),
                    );
                    ref.invalidate(teacherClassesProvider);
                  },
                  child: const Text('Create class'),
                ),
              ],
              ...sorted.map(
                (cls) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.class_outlined),
                    title: Text(classLabel(cls)),
                    subtitle: Text(
                      '${cls.studentCount} students${cls.id == lastId ? ' · Recently used' : ''}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ref.read(teacherLastClassProvider.notifier).state =
                          cls.id;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => teacherFeaturePage(feature, cls),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget teacherFeaturePage(TeacherFeature feature, TeacherClassModel cls) {
  Widget page;
  switch (feature) {
    case TeacherFeature.assignments:
      page = HomeworkScreen(classId: cls.id);
    case TeacherFeature.newAssignment:
      page = AddHomeworkScreen(classId: cls.id);
    case TeacherFeature.groups:
      page = HomeworkScreen(classId: cls.id, initialGroups: true);
    case TeacherFeature.lessons:
      page = LessonsScreen(classId: cls.id);
    case TeacherFeature.attendance:
      page = StudentAttendanceScreen(classData: cls);
    case TeacherFeature.grades:
      page = TeacherGradebook(classData: cls);
    case TeacherFeature.behavior:
    case TeacherFeature.newBehavior:
    case TeacherFeature.students:
      page = TeacherStudentPicker(classData: cls, feature: feature);
    case TeacherFeature.reports:
      page = TeacherReportsScreen(classData: cls);
    case TeacherFeature.announcements:
      page = TeacherAnnouncementsScreen(classData: cls);
    case TeacherFeature.resources:
      page = TeacherMaterialsScreen(classData: cls);
    case TeacherFeature.help:
      page = TeacherHelpAssignments(classData: cls);
  }
  return TeacherContextFrame(classData: cls, child: page);
}

/// Context belongs to the route, so switching tabs cannot relabel an open record.
class TeacherContextFrame extends StatelessWidget {
  final TeacherClassModel classData;
  final Map<String, dynamic>? student;
  final Widget child;
  const TeacherContextFrame({
    super.key,
    required this.classData,
    this.student,
    required this.child,
  });

  static Widget carry(
    BuildContext context,
    Widget page, {
    Map<String, dynamic>? student,
  }) {
    final frame = context.findAncestorWidgetOfExactType<TeacherContextFrame>();
    return frame == null
        ? page
        : TeacherContextFrame(
            classData: frame.classData,
            student: student ?? frame.student,
            child: page,
          );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${classLabel(classData)}${student == null ? '' : '\n${student!['username'] ?? 'Student'} · ${student!['Id'] ?? 'ID unavailable'}'}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    ),
  );
}

class TeacherStudentPicker extends ConsumerWidget {
  final TeacherClassModel classData;
  final TeacherFeature feature;
  const TeacherStudentPicker({
    super.key,
    required this.classData,
    this.feature = TeacherFeature.students,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: Text(feature.title)),
    body: ref
        .watch(classStudentsProvider(classData.id))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: TextButton(
              onPressed: () =>
                  ref.invalidate(classStudentsProvider(classData.id)),
              child: const Text('Unable to load students. Retry'),
            ),
          ),
          data: (rows) => rows.isEmpty
              ? const Center(child: Text('No students enrolled in this class.'))
              : ListView(
                  children: rows.map((row) {
                    final student = Map<String, dynamic>.from(row['studentId']);
                    return ListTile(
                      title: Text('${student['username'] ?? 'Student'}'),
                      subtitle: Text('${student['Id'] ?? 'ID unavailable'}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        final id = student['_id'].toString();
                        final Widget page =
                            feature == TeacherFeature.newBehavior
                            ? AddBehaviorScreen(
                                studentId: id,
                                student: student,
                                classId: classData.id,
                              )
                            : feature == TeacherFeature.behavior
                            ? BehaviorRecordScreen(
                                studentId: id,
                                student: student,
                                classId: classData.id,
                              )
                            : feature == TeacherFeature.grades
                            ? GradingProgressScreen(
                                studentId: id,
                                classId: classData.id,
                              )
                            : StudentProfileScreen(
                                studentData: student,
                                classId: classData.id,
                              );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeacherContextFrame(
                              classData: classData,
                              student: student,
                              child: page,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
        ),
  );
}

class TeacherGradebook extends ConsumerWidget {
  final TeacherClassModel classData;
  const TeacherGradebook({super.key, required this.classData});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Gradebook')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Individual student grades'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherContextFrame(
                classData: classData,
                child: TeacherStudentPicker(
                  classData: classData,
                  feature: TeacherFeature.grades,
                ),
              ),
            ),
          ),
        ),
        const Divider(),
        Text(
          'Assignment submissions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ref
            .watch(classHomeworkProvider(classData.id))
            .when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => TextButton(
                onPressed: () =>
                    ref.invalidate(classHomeworkProvider(classData.id)),
                child: const Text('Retry assignments'),
              ),
              data: (rows) => Column(
                children: [
                  if (rows.isEmpty)
                    const ListTile(title: Text('No assignments yet.')),
                  ...rows.map(
                    (hw) => ListTile(
                      title: Text('${hw['title']}'),
                      subtitle: Text(
                        '${hw['status'] ?? 'published'} · Review submissions and publish grades',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeacherContextFrame(
                            classData: classData,
                            child: AssignmentDetailsScreen(
                              homeworkId: hw['_id'].toString(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        const Divider(),
        Text(
          'Assessment results',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ref
            .watch(teacherSessionsProvider(classData.id))
            .when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => TextButton(
                onPressed: () =>
                    ref.invalidate(teacherSessionsProvider(classData.id)),
                child: const Text('Retry assessments'),
              ),
              data: (rows) => Column(
                children: [
                  if (rows.isEmpty)
                    const ListTile(title: Text('No assessments yet.')),
                  ...rows.map(
                    (quiz) => ListTile(
                      title: Text('${quiz['title']}'),
                      subtitle: const Text(
                        'Automatic results, review and grade overrides',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeacherContextFrame(
                            classData: classData,
                            child: QuizDetailScreen(
                              sessionId: quiz['_id'].toString(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    ),
  );
}

class TeacherReportsScreen extends ConsumerWidget {
  final TeacherClassModel classData;
  const TeacherReportsScreen({super.key, required this.classData});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Reports & Data')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _metric(
          'Class attendance',
          ref.watch(classDetailsAttendanceProvider('class|${classData.id}')),
        ),
        _metric(
          'Assessment performance',
          ref.watch(classPerformanceProvider(classData.id)),
        ),
        ListTile(
          title: const Text('Student performance trends'),
          subtitle: const Text(
            'Student profiles, attendance and performance charts',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherContextFrame(
                classData: classData,
                child: TeacherStudentPicker(classData: classData),
              ),
            ),
          ),
        ),
        ListTile(
          title: const Text('Attendance records'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  teacherFeaturePage(TeacherFeature.attendance, classData),
            ),
          ),
        ),
        ListTile(
          title: const Text('Behavior records'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  teacherFeaturePage(TeacherFeature.behavior, classData),
            ),
          ),
        ),
        ListTile(
          title: const Text('Assignment and assessment grades'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  teacherFeaturePage(TeacherFeature.grades, classData),
            ),
          ),
        ),
      ],
    ),
  );
  Widget _metric(String title, AsyncValue<int?> metric) => Card(
    child: ListTile(
      title: Text(title),
      trailing: metric.when(
        data: (value) => Text(value == null ? 'No records' : '$value%'),
        loading: () => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(),
        ),
        error: (_, _) => const Text('Unavailable'),
      ),
    ),
  );
}

class TeacherHelpAssignments extends ConsumerWidget {
  final TeacherClassModel classData;
  final Map<String, dynamic>? student;
  const TeacherHelpAssignments({
    super.key,
    required this.classData,
    this.student,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Homework Help')),
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
            final published = rows
                .where(
                  (hw) =>
                      hw['status'] != 'draft' &&
                      (student == null ||
                          (hw['studentIds'] as List? ?? []).isEmpty ||
                          (hw['studentIds'] as List).any(
                            (id) =>
                                (id is Map ? id['_id'] : id).toString() ==
                                student!['_id'].toString(),
                          )),
                )
                .toList();
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Select a published assignment to add PDF, video or linked help.',
                ),
                if (published.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No published assignments for this selection.'),
                  ),
                ...published.map(
                  (hw) => Card(
                    child: ListTile(
                      title: Text('${hw['title']}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeacherContextFrame(
                            classData: classData,
                            student: student,
                            child: TeacherMaterialsScreen(
                              classData: classData,
                              homework: Map<String, dynamic>.from(hw),
                              student: student,
                            ),
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
