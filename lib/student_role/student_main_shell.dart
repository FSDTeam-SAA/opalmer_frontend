import 'package:flutter/material.dart';
import 'package:opalmer_education/student_role/StudentHomeDashboard/student_home_dashboard.dart';
import 'package:opalmer_education/student_role/widgets/student_bottom_navbar.dart';
import 'package:opalmer_education/student_role/Quizzes/student_quiz_main_screen.dart';
import 'package:opalmer_education/student_role/Subjects/subjects_screen.dart';
import 'package:opalmer_education/student_role/Chat_Screen/chat_dashboard.dart';
import 'package:opalmer_education/teacher_role/profile_screen/profile.dart';

class StudentMainShell extends StatefulWidget {
  const StudentMainShell({Key? key}) : super(key: key);

  @override
  State<StudentMainShell> createState() => _StudentMainShellState();
}

class _StudentMainShellState extends State<StudentMainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // These will be replaced as we build more screens
    final List<Widget> pages = [
      const StudentHomeDashboard(),
      const SubjectsScreen(),
      const ChatDashboard(),
      const StudentQuizMainScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: StudentBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
