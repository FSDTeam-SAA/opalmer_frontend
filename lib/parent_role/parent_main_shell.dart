import 'package:flutter/material.dart';
import '../core/widgets/app_back_button.dart';
import '../core/navigation/role_menu.dart';
import 'package:opalmer_education/chat/models/chat_role.dart';
import 'package:opalmer_education/chat/screens/chat_dashboard.dart';
import 'package:opalmer_education/parent_role/parent_bottom_navigation_bar.dart';
import 'package:opalmer_education/parent_role/ParentHomeDashboard/parent_home_dashboard.dart';
import 'package:opalmer_education/parent_role/ChildsProfilesScreen/childs_profiles_screen.dart';
import 'package:opalmer_education/parent_role/ProfileScreen/parent_profile_screen.dart';

class ParentMainShell extends StatefulWidget {
  const ParentMainShell({super.key});

  @override
  State<ParentMainShell> createState() => _ParentMainShellState();
}

class _ParentMainShellState extends State<ParentMainShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ParentHomeDashboard(
        onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      const ChildsProfilesScreen(),
      const ChatDashboard(role: ChatRole.parent),
      const ParentProfileScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: RoleMenuDrawer(
        role: 'parent',
        currentTab: _currentIndex,
        onClose: () => _scaffoldKey.currentState?.closeDrawer(),
        onSelectTab: (index) {
          _scaffoldKey.currentState?.closeDrawer();
          setState(() => _currentIndex = index);
        },
        onOpenPage: (page) {
          _scaffoldKey.currentState?.closeDrawer();
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
        },
      ),
      body: AppShellRoot(
        role: 'parent',
        onHome: () => setState(() => _currentIndex = 0),
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
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
