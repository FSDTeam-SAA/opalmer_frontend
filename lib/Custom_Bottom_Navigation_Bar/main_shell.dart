import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/custom_bottom_navigation_bar/custom_bottom_navigation_bar.dart';
import 'package:opalmer_education/teacher_role/Home_Dashboard/home_dashboard.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/classes_screen.dart';
import '../teacher_role/navigation/teacher_menu.dart';
import '../teacher_role/navigation/teacher_workspace.dart';
import 'package:opalmer_education/core/providers/navigation_provider.dart';
import '../core/widgets/app_back_button.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openMenu() => _scaffoldKey.currentState?.openDrawer();

  void _selectTab(int index) {
    ref.read(teacherTabIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(teacherTabIndexProvider).clamp(0, 3);

    final List<Widget> pages = [
      HomeDashboard(onOpenMenu: _openMenu),
      const ClassesScreen(),
      const TeacherClassPicker(
        feature: TeacherFeature.assignments,
        embedded: true,
      ),
      const TeacherClassPicker(feature: TeacherFeature.grades, embedded: true),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawerScrimColor: const Color(0xFF21172C).withValues(alpha: 0.42),
      drawer: Drawer(
        width: (MediaQuery.sizeOf(context).width * 0.88).clamp(280.0, 360.0),
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(26)),
        ),
        child: TeacherMenuScreen(
          inDrawer: true,
          currentTab: currentIndex,
          onClose: () => _scaffoldKey.currentState?.closeDrawer(),
          onSelectTab: (index) {
            _scaffoldKey.currentState?.closeDrawer();
            _selectTab(index);
          },
          onOpenPage: (page) {
            _scaffoldKey.currentState?.closeDrawer();
            openTeacherPage(context, page);
          },
        ),
      ),
      body: AppShellRoot(
        child: IndexedStack(index: currentIndex, children: pages),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _selectTab,
      ),
    );
  }
}
