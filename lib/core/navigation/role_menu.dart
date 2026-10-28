import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/access_guide_screen.dart';
import '../widgets/drawer_logout_button.dart';
import '../../notification/notification.dart';
import '../../parent_role/LearningTipsScreen/learning_tips_screen.dart';
import '../../parent_role/SubjectsScreen/subjects_screen.dart' as parent;
import '../../student_role/Subjects/student_homework_screen.dart';
import '../../student_role/Subjects/student_attendance_screen.dart';
import '../../student_role/Subjects/student_lessons_screen.dart';
import '../../student_role/Subjects/student_academic_notes_screen.dart';
import '../../student_role/Subjects/student_grading_progress_screen.dart';

class RoleMenuItem {
  final String label;
  final IconData icon;
  final String group;
  final int? tab;
  final Widget Function()? page;
  const RoleMenuItem(this.label, this.icon, this.group, {this.tab, this.page});
}

List<RoleMenuItem> roleMenuItems(String role) {
  if (!['parent', 'student'].contains(role)) throw ArgumentError.value(role);
  return [
    const RoleMenuItem('Home', Icons.home_outlined, 'LEARNING', tab: 0),
    if (role == 'parent') ...[
      const RoleMenuItem(
        'My Students',
        Icons.people_outline,
        'LEARNING',
        tab: 1,
      ),
      for (final feature in parent.ParentStudyFeature.values)
        RoleMenuItem(
          feature.title,
          feature.icon,
          'LEARNING',
          page: () => parent.SubjectsScreen(feature: feature),
        ),
      RoleMenuItem(
        'Learning Tips',
        Icons.lightbulb_outline,
        'LEARNING',
        page: () => const LearningTipsScreen(),
      ),
    ] else ...[
      const RoleMenuItem('Subjects', Icons.school_outlined, 'LEARNING', tab: 1),
      RoleMenuItem(
        'Homework & Groups',
        Icons.assignment_outlined,
        'LEARNING',
        page: () => const StudentHomeworkScreen(),
      ),
      RoleMenuItem(
        'Lessons',
        Icons.menu_book_outlined,
        'LEARNING',
        page: () => const StudentLessonsScreen(),
      ),
      const RoleMenuItem('Quizzes', Icons.quiz_outlined, 'LEARNING', tab: 3),
      RoleMenuItem(
        'Grades & Progress',
        Icons.insights_outlined,
        'LEARNING',
        page: () => const StudentGradingProgressScreen(),
      ),
      RoleMenuItem(
        'Attendance',
        Icons.how_to_reg_outlined,
        'LEARNING',
        page: () => const StudentAttendanceScreen(),
      ),
      RoleMenuItem(
        'Academic Documents',
        Icons.folder_open_outlined,
        'LEARNING',
        page: () => const StudentAcademicNotesScreen(),
      ),
    ],
    const RoleMenuItem(
      'Messages',
      Icons.chat_bubble_outline,
      'COMMUNICATION',
      tab: 2,
    ),
    RoleMenuItem(
      'Notifications',
      Icons.notifications_none_outlined,
      'COMMUNICATION',
      page: () => const NotificationScreen(),
    ),
    RoleMenuItem(
      'How to use',
      Icons.help_outline,
      'ACCOUNT',
      page: () => AccessGuideScreen(role: role),
    ),
    RoleMenuItem(
      'Profile & settings',
      Icons.settings_outlined,
      'ACCOUNT',
      tab: role == 'parent' ? 3 : 4,
    ),
  ];
}

class RoleMenuDrawer extends ConsumerStatefulWidget {
  final String role;
  final int currentTab;
  final VoidCallback onClose;
  final ValueChanged<int> onSelectTab;
  final ValueChanged<Widget> onOpenPage;
  const RoleMenuDrawer({
    super.key,
    required this.role,
    required this.currentTab,
    required this.onClose,
    required this.onSelectTab,
    required this.onOpenPage,
  });
  @override
  ConsumerState<RoleMenuDrawer> createState() => _RoleMenuDrawerState();
}

class _RoleMenuDrawerState extends ConsumerState<RoleMenuDrawer> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final name = ref.watch(authStateProvider)?.username.trim();
    final title = '${widget.role[0].toUpperCase()}${widget.role.substring(1)}';
    final username = name == null || name.isEmpty ? title : name;
    final items = roleMenuItems(
      widget.role,
    ).where((item) => item.label.toLowerCase().contains(_query)).toList();
    return Drawer(
      width: (MediaQuery.sizeOf(context).width * .88).clamp(280.0, 360.0),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(26)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 12, 18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryMid,
                    child: Text(
                      username.characters.first.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close menu',
                    onPressed: widget.onClose,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 21,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                key: ValueKey('${widget.role}-menu-search'),
                onChanged: (text) =>
                    setState(() => _query = text.trim().toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Find a tool',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final group in ['LEARNING', 'COMMUNICATION', 'ACCOUNT'])
                    if (items.any((item) => item.group == group)) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
                        child: Text(
                          group,
                          style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      for (final item in items.where(
                        (item) => item.group == group,
                      ))
                        ListTile(
                          selected: item.tab == widget.currentTab,
                          selectedTileColor: AppColors.primaryMid.withValues(
                            alpha: .08,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: Icon(
                            item.icon,
                            size: 21,
                            color: item.group == 'ACCOUNT'
                                ? AppColors.textSecondary
                                : AppColors.primaryMid,
                          ),
                          title: Text(
                            item.label,
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            size: 17,
                          ),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            if (item.tab != null) {
                              widget.onSelectTab(item.tab!);
                            } else {
                              widget.onOpenPage(item.page!());
                            }
                          },
                        ),
                    ],
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No matching tools'),
                    ),
                ],
              ),
            ),
            const DrawerLogoutButton(),
          ],
        ),
      ),
    );
  }
}
