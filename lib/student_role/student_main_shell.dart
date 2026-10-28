import 'package:flutter/material.dart';
import '../core/widgets/app_back_button.dart';
import '../core/navigation/role_menu.dart';
import 'package:opalmer_education/student_role/StudentHomeDashboard/student_home_dashboard.dart';
import 'package:opalmer_education/student_role/widgets/student_bottom_navbar.dart';
import 'package:opalmer_education/student_role/Quizzes/student_quiz_main_screen.dart';
import 'package:opalmer_education/student_role/Subjects/subjects_screen.dart';
import 'package:opalmer_education/chat/models/chat_role.dart';
import 'package:opalmer_education/chat/screens/chat_dashboard.dart';
import 'package:opalmer_education/student_role/Profile/student_profile_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/providers/navigation_provider.dart';

class StudentMainShell extends ConsumerStatefulWidget {
  const StudentMainShell({super.key});

  @override
  ConsumerState<StudentMainShell> createState() => _StudentMainShellState();
}

class _StudentMainShellState extends ConsumerState<StudentMainShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(studentTabIndexProvider);

    final List<Widget> pages = [
      StudentHomeDashboard(
        onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      const SubjectsScreen(),
      const ChatDashboard(role: ChatRole.student),
      const StudentQuizMainScreen(),
      const StudentProfileScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: RoleMenuDrawer(
        role: 'student',
        currentTab: currentIndex,
        onClose: () => _scaffoldKey.currentState?.closeDrawer(),
        onSelectTab: (index) {
          _scaffoldKey.currentState?.closeDrawer();
          ref.read(studentTabIndexProvider.notifier).state = index;
        },
        onOpenPage: (page) {
          _scaffoldKey.currentState?.closeDrawer();
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
        },
      ),
      body: AppShellRoot(
        role: 'student',
        onHome: () => ref.read(studentTabIndexProvider.notifier).state = 0,
        child: IndexedStack(index: currentIndex, children: pages),
      ),
      bottomNavigationBar: StudentBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(studentTabIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}
