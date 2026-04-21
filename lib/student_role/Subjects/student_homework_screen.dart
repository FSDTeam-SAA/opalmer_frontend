import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:opalmer_education/student_role/Subjects/widgets/homework_card.dart';
import 'package:opalmer_education/student_role/Subjects/widgets/group_member_card.dart';

class StudentHomeworkScreen extends ConsumerStatefulWidget {
  const StudentHomeworkScreen({super.key});

  @override
  ConsumerState<StudentHomeworkScreen> createState() =>
      _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends ConsumerState<StudentHomeworkScreen> {
  bool isClassSelected = true;

  @override
  Widget build(BuildContext context) {
    final homeworkAsync = ref.watch(studentHomeworkProvider);
    final groupWorkAsync = ref.watch(studentGroupWorkProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildTabToggle(),
          const SizedBox(height: 24),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (isClassSelected) {
                  ref.invalidate(studentHomeworkProvider);
                  try {
                    await ref.read(studentHomeworkProvider.future);
                  } catch (_) {}
                } else {
                  ref.invalidate(studentGroupWorkProvider);
                  try {
                    await ref.read(studentGroupWorkProvider.future);
                  } catch (_) {}
                }
              },
              child: ListView(
                key: const ValueKey('homework_main_list'),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (isClassSelected)
                    ...homeworkAsync.maybeWhen(
                      data: (homework) => _buildClassHomeworkItems(homework),
                      loading: () => [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                      orElse: () => [
                        if (homeworkAsync.hasError)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child:
                                Center(child: Text('Error: ${homeworkAsync.error}')),
                          ),
                      ],
                    )
                  else
                    ...groupWorkAsync.maybeWhen(
                      data: (groupWork) => _buildGroupsHomeworkItems(groupWork),
                      loading: () => [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                      orElse: () => [
                        if (groupWorkAsync.hasError)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child:
                                Center(child: Text('Error: ${groupWorkAsync.error}')),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryMid,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      title: const Text(
        "Homework",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTabToggle() {
    return Center(
      child: Container(
        width: 250,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isClassSelected = true),
                child: Container(
                  decoration: BoxDecoration(
                    color: isClassSelected
                        ? AppColors.primaryMid
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Class",
                    style: TextStyle(
                      color: isClassSelected
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontWeight: isClassSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isClassSelected = false),
                child: Container(
                  decoration: BoxDecoration(
                    color: !isClassSelected
                        ? AppColors.primaryMid
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Groups",
                    style: TextStyle(
                      color: !isClassSelected
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontWeight: !isClassSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildClassHomeworkItems(List<HomeworkModel> homework) {
    final activeHomework = homework.where((h) => h.archived == false).toList();
    final archivedHomework = homework.where((h) => h.archived == true).toList();

    return [
      const Text(
        "Today's Homework",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 16),
      if (activeHomework.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                const Text(
                  "No active homework found for your classes.",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        )
      else
        ...activeHomework.map(
          (h) => HomeworkCard(
            title: h.title,
            description: h.description ??
                (h.fileUrls.isNotEmpty
                    ? "${h.fileUrls.length} file(s) attached"
                    : "No additional description."),
            dueDate: h.dueDate != null
                ? "Due: ${_formatDate(h.dueDate!)}"
                : (h.createdAt != null
                    ? "Assigned: ${_formatDate(h.createdAt!)}"
                    : "Assigned: N/A"),
          ),
        ),
      const SizedBox(height: 32),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "Archived Homework",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Icon(
            Icons.calendar_month_outlined,
            color: AppColors.primaryMid,
            size: 24,
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (archivedHomework.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "No archived homework",
            style: TextStyle(color: Colors.grey),
          ),
        )
      else
        ...archivedHomework.map(
          (h) => HomeworkCard(
            title: h.title,
            description: h.description ?? "Archived assignment",
            dueDate: h.dueDate != null
                ? "Due: ${_formatDate(h.dueDate!)}"
                : (h.createdAt != null
                    ? "Assigned: ${_formatDate(h.createdAt!)}"
                    : "N/A"),
          ),
        ),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> _buildGroupsHomeworkItems(List<GroupWorkModel> groupWork) {
    if (groupWork.isEmpty) {
      return [
        const SizedBox(height: 40),
        const Center(
          child: Column(
            children: [
              Icon(Icons.group_outlined, size: 48, color: Color(0xFFCCCCCC)),
              SizedBox(height: 16),
              Text(
                "No group assignments found.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ];
    }

    final List<Widget> items = [];
    for (final gw in groupWork) {
      items.add(
        Text(
          gw.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      );
      items.add(const SizedBox(height: 8));
      if (gw.description != null) {
        items.add(
          Text(
            gw.description!,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        );
      }
      items.add(const SizedBox(height: 16));
      items.add(
        const Text(
          "Group Members",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      );
      items.add(const SizedBox(height: 12));
      items.addAll(
        gw.members.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GroupMemberCard(name: m.username, avatarUrl: m.avatar),
          ),
        ),
      );
      items.add(const SizedBox(height: 20));
      items.add(
        HomeworkCard(
          title: "Assignment Details",
          description: gw.description ?? "No additional description.",
          dueDate: gw.dueDate != null
              ? "Due: ${gw.dueDate.toString().split(' ')[0]}"
              : (gw.createdAt != null
                  ? "Created: ${gw.createdAt.toString().split(' ')[0]}"
                  : "Assigned: N/A"),
        ),
      );
      items.add(const Divider(height: 40));
    }
    return items;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Today";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
}


