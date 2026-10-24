import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chat/models/chat_role.dart';
import '../../chat/screens/chat_dashboard.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_logo.dart';
import '../../notification/notification.dart';
import '../Classes_Screen/classes_screen.dart';
import '../Quiz_Screen/create_quiz.dart';
import '../Quiz_Screen/grading_tool.dart';
import '../profile_screen/profile.dart';
import 'teacher_activity.dart';
import 'teacher_workspace.dart';

void openTeacherPage(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}

class TeacherMenuScreen extends ConsumerStatefulWidget {
  final bool inDrawer;
  final int currentTab;
  final VoidCallback? onClose;
  final ValueChanged<int>? onSelectTab;
  final ValueChanged<Widget>? onOpenPage;
  const TeacherMenuScreen({
    super.key,
    this.inDrawer = false,
    this.currentTab = 0,
    this.onClose,
    this.onSelectTab,
    this.onOpenPage,
  });
  @override
  ConsumerState<TeacherMenuScreen> createState() => _TeacherMenuScreenState();
}

class _TeacherMenuScreenState extends ConsumerState<TeacherMenuScreen> {
  final _search = TextEditingController();
  String _query = '';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(Widget page) {
    FocusScope.of(context).unfocus();
    if (widget.onOpenPage != null) {
      widget.onOpenPage!(page);
    } else {
      openTeacherPage(context, page);
    }
  }

  void _select(_MenuItem item) {
    if (item.tab != null && widget.onSelectTab != null) {
      FocusScope.of(context).unfocus();
      widget.onSelectTab!(item.tab!);
    } else if (item.page != null) {
      _open(item.page!());
    } else {
      widget.onClose?.call();
    }
  }

  List<_MenuGroup> get _groups => [
    _MenuGroup('TEACHING', AppColors.primaryMid, [
      const _MenuItem('Home', Icons.home_outlined, tab: 0),
      _MenuItem(
        'Classes & students',
        Icons.people_outline,
        tab: 1,
        page: () => const ClassesScreen(),
        keywords: 'roster profiles',
      ),
      _MenuItem(
        'Assignments',
        Icons.assignment_outlined,
        tab: 2,
        page: () =>
            const TeacherClassPicker(feature: TeacherFeature.assignments),
        keywords: 'homework submissions',
      ),
      _MenuItem(
        'Gradebook',
        Icons.fact_check_outlined,
        tab: 3,
        page: () => const TeacherClassPicker(feature: TeacherFeature.grades),
        keywords: 'grades results scores',
      ),
      _MenuItem(
        'Assessments',
        Icons.quiz_outlined,
        page: () => const GradingToolScreen(),
        keywords: 'quizzes answer keys',
      ),
      _MenuItem(
        'Lessons',
        Icons.menu_book_outlined,
        page: () => const TeacherClassPicker(feature: TeacherFeature.lessons),
      ),
      _MenuItem(
        'Groups',
        Icons.groups_outlined,
        page: () => const TeacherClassPicker(feature: TeacherFeature.groups),
      ),
    ]),
    _MenuGroup('CLASSROOM', const Color(0xFF258679), [
      _MenuItem(
        'Attendance',
        Icons.how_to_reg_outlined,
        page: () =>
            const TeacherClassPicker(feature: TeacherFeature.attendance),
      ),
      _MenuItem(
        'Behavior',
        Icons.star_outline_rounded,
        page: () => const TeacherClassPicker(feature: TeacherFeature.behavior),
      ),
      _MenuItem(
        'Homework help',
        Icons.support_agent_outlined,
        page: () => const TeacherClassPicker(feature: TeacherFeature.help),
        keywords: 'pdf video assistance',
      ),
      _MenuItem(
        'Resources',
        Icons.folder_open_outlined,
        page: () => const TeacherClassPicker(feature: TeacherFeature.resources),
        keywords: 'files materials upload',
      ),
      _MenuItem(
        'Reports & data',
        Icons.insights_outlined,
        page: () => const TeacherClassPicker(feature: TeacherFeature.reports),
        keywords: 'analytics performance',
      ),
    ]),
    _MenuGroup('COMMUNICATION', const Color(0xFF4677B5), [
      _MenuItem(
        'Messages',
        Icons.chat_bubble_outline_rounded,
        page: () => const ChatDashboard(role: ChatRole.teacher),
        keywords: 'chat parents students',
      ),
      _MenuItem(
        'Notifications',
        Icons.notifications_none_rounded,
        page: () => const NotificationScreen(),
        keywords: 'alerts',
      ),
      _MenuItem(
        'Announcements',
        Icons.campaign_outlined,
        page: () =>
            const TeacherClassPicker(feature: TeacherFeature.announcements),
      ),
      _MenuItem(
        'Activity',
        Icons.history_rounded,
        page: () => const TeacherActivityScreen(),
        keywords: 'recent submissions review auto graded',
      ),
    ]),
    _MenuGroup('ACCOUNT', const Color(0xFF777080), [
      _MenuItem(
        'Profile & settings',
        Icons.settings_outlined,
        page: () => const ProfileScreen(),
        keywords: 'language privacy logout account',
      ),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final username = ref.watch(authStateProvider)?.username.trim();
    final name = username == null || username.isEmpty ? 'Teacher' : username;
    final groups = _groups
        .map(
          (group) => _MenuGroup(
            group.title,
            group.color,
            group.items
                .where(
                  (item) => '${item.label} ${item.keywords}'
                      .toLowerCase()
                      .contains(_query),
                )
                .toList(),
          ),
        )
        .where((group) => group.items.isNotEmpty)
        .toList();
    final content = Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 12, 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: 42,
                    height: 42,
                    child: BrandLogo(size: 42),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'AchieverPlus',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close menu',
                    onPressed:
                        widget.onClose ?? () => Navigator.maybePop(context),
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
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryMid,
                    child: Text(
                      name.characters.first.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Teacher workspace',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                key: const ValueKey('teacher-menu-search'),
                controller: _search,
                onChanged: (text) =>
                    setState(() => _query = text.trim().toLowerCase()),
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Find a tool',

                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close_rounded, size: 17),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: PopupMenuButton<int>(
                tooltip: 'Create new',
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE7E2EC)),
                ),
                onSelected: (index) => _open(_createActions[index].page!()),
                itemBuilder: (_) => List.generate(
                  _createActions.length,
                  (index) => PopupMenuItem(
                    value: index,
                    child: Row(
                      children: [
                        Icon(
                          _createActions[index].icon,
                          size: 20,
                          color: AppColors.primaryMid,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _createActions[index].label,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMid,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Create new',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                key: const ValueKey('teacher-menu-items'),
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  if (groups.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No tools found. Try another name.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ...groups.expand(
                    (group) => [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 18, 12, 7),
                        child: Text(
                          group.title,
                          style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      ...group.items.map((item) => _toolRow(item, group.color)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return widget.inDrawer ? content : Scaffold(body: content);
  }

  Widget _toolRow(_MenuItem item, Color color) {
    final selected = item.tab == widget.currentTab;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? AppColors.primaryVeryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          key: ValueKey('teacher-menu-${item.label}'),
          onTap: () => _select(item),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minTileHeight: 48,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          horizontalTitleGap: 12,
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(item.icon, size: 18, color: color),
          ),
          title: Text(
            item.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.primaryMid : AppColors.textPrimary,
            ),
          ),
          trailing: Icon(
            selected ? Icons.circle : Icons.chevron_right_rounded,
            size: selected ? 6 : 17,
            color: selected ? AppColors.primaryMid : const Color(0xFFB9B3C1),
          ),
        ),
      ),
    );
  }

  List<_MenuItem> get _createActions => [
    _MenuItem(
      'New assignment',
      Icons.assignment_outlined,
      page: () =>
          const TeacherClassPicker(feature: TeacherFeature.newAssignment),
    ),
    _MenuItem(
      'New assessment',
      Icons.quiz_outlined,
      page: () => const CreateQuizScreen(),
    ),
    _MenuItem(
      'Take attendance',
      Icons.how_to_reg_outlined,
      page: () => const TeacherClassPicker(feature: TeacherFeature.attendance),
    ),
    _MenuItem(
      'Add behavior',
      Icons.star_outline_rounded,
      page: () => const TeacherClassPicker(feature: TeacherFeature.newBehavior),
    ),
    _MenuItem(
      'Send message',
      Icons.chat_bubble_outline_rounded,
      page: () => const ChatDashboard(role: ChatRole.teacher),
    ),
    _MenuItem(
      'Send announcement',
      Icons.campaign_outlined,
      page: () =>
          const TeacherClassPicker(feature: TeacherFeature.announcements),
    ),
  ];
}

class _MenuGroup {
  final String title;
  final Color color;
  final List<_MenuItem> items;
  const _MenuGroup(this.title, this.color, this.items);
}

class _MenuItem {
  final String label;
  final IconData icon;
  final int? tab;
  final Widget Function()? page;
  final String keywords;
  const _MenuItem(
    this.label,
    this.icon, {
    this.tab,
    this.page,
    this.keywords = '',
  });
}
