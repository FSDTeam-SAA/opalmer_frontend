import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/parent_children_provider.dart';
import '../core/widgets/app_back_button.dart';
import '../core/navigation/role_menu.dart';
import 'package:opalmer_education/chat/models/chat_role.dart';
import 'package:opalmer_education/chat/screens/chat_dashboard.dart';
import 'package:opalmer_education/parent_role/parent_bottom_navigation_bar.dart';
import 'package:opalmer_education/parent_role/ParentHomeDashboard/parent_home_dashboard.dart';
import 'package:opalmer_education/parent_role/ChildsProfilesScreen/childs_profiles_screen.dart';
import 'package:opalmer_education/parent_role/ProfileScreen/parent_profile_screen.dart';

class ParentMainShell extends ConsumerStatefulWidget {
  const ParentMainShell({super.key});

  @override
  ConsumerState<ParentMainShell> createState() => _ParentMainShellState();
}

class _ParentMainShellState extends ConsumerState<ParentMainShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  void _selectTab(int index) {
    if (index == 0 || index == 1) {
      ref.read(parentChildrenRevisionProvider.notifier).state++;
    }
    setState(() => _currentIndex = index);
  }

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
          _selectTab(index);
        },
        onOpenPage: (page) {
          _scaffoldKey.currentState?.closeDrawer();
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
        },
      ),
      body: AppShellRoot(
        role: 'parent',
        onHome: () => _selectTab(0),
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: ParentBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _selectTab,
      ),
    );
  }
}
