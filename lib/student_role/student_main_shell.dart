import 'package:flutter/material.dart';
import 'package:opalmer_education/student_role/StudentHomeDashboard/student_home_dashboard.dart';
import 'package:opalmer_education/student_role/widgets/student_bottom_navbar.dart';
import 'package:opalmer_education/student_role/Quizzes/student_quiz_main_screen.dart';
import 'package:opalmer_education/student_role/Subjects/subjects_screen.dart';
import 'package:opalmer_education/student_role/Chat_Screen/chat_dashboard.dart';
import 'package:opalmer_education/student_role/Profile/student_profile_screen.dart';
import 'package:opalmer_education/teacher_role/profile_screen/profile.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/providers/navigation_provider.dart';

class StudentMainShell extends ConsumerStatefulWidget {
  const StudentMainShell({super.key});

  @override
  ConsumerState<StudentMainShell> createState() => _StudentMainShellState();
}

class _StudentMainShellState extends ConsumerState<StudentMainShell> {
  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(studentTabIndexProvider);

    final List<Widget> pages = [
      const StudentHomeDashboard(),
      const SubjectsScreen(),
      const ChatDashboard(),
      const StudentQuizMainScreen(),
      const StudentProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: StudentBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(studentTabIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  final String title;
  const _ComingSoonPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Text("Coming Soon", style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

// Temporary placeholder for the screen we are about to build
class _ComingSoonScreen extends StatelessWidget {
  final String title;
  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text(title, style: const TextStyle(fontSize: 18))),
    );
  }
}
