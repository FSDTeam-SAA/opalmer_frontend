import 'package:flutter/material.dart';
import 'package:opalmer_education/parent_role/parent_bottom_navigation_bar.dart';
import 'package:opalmer_education/parent_role/ParentHomeDashboard/parent_home_dashboard.dart';

class ParentMainShell extends StatefulWidget {
  const ParentMainShell({Key? key}) : super(key: key);

  @override
  State<ParentMainShell> createState() => _ParentMainShellState();
}

class _ParentMainShellState extends State<ParentMainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const ParentHomeDashboard(),
      const _PlaceholderPage(title: "Teachers/Classes"),
      const _PlaceholderPage(title: "Messages"),
      const _PlaceholderPage(title: "Profile"),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: ParentBottomNavigationBar(
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
