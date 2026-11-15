import 'package:flutter/material.dart';
import '../../core/widgets/app_home_button.dart';
import 'widgets/teacher_lesson_list.dart';

class LessonsScreen extends StatelessWidget {
  final String classId;
  const LessonsScreen({super.key, required this.classId});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Lessons'),
      actions: const [AppHomeButton()],
    ),
    body: TeacherLessonList(classId: classId),
  );
}
