import 'package:flutter/material.dart';
import 'package:opalmer_education/custom_bottom_navigation_bar/custom_bottom_navigation_bar.dart';
import 'package:opalmer_education/teacher_role/Home_Dashboard/home_dashboard.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/classes_screen.dart';
import 'package:opalmer_education/profile_screen/profile.dart';
import 'package:opalmer_education/teacher_role/Chat_Screen/chat_dashboard.dart';
import 'package:opalmer_education/teacher_role/Quiz_Screen/grading_tool.dart';

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeDashboard(),
      const ClassesScreen(),
      const GradingToolScreen(),
      const ChatDashboard(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: CustomBottomNavigationBar(
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

// Placeholder pages for tabs that aren't built yet
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: const Color(0xFF871DAD).withOpacity(0.3),
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
            Text(
              "Coming Soon",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
