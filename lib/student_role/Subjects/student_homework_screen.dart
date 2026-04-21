import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';

class StudentHomeworkScreen extends ConsumerStatefulWidget {
  const StudentHomeworkScreen({Key? key}) : super(key: key);

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
                ref.invalidate(studentHomeworkProvider);
                ref.invalidate(studentGroupWorkProvider);
                await ref.read(studentHomeworkProvider.future);
              },
              // ✅ FIX 1: AnimatedSwitcher দিয়ে smooth transition
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isClassSelected
                    ? homeworkAsync.when(
                        // ✅ FIX 2: ValueKey দিয়ে Flutter কে বলা হচ্ছে এটা আলাদা widget
                        data: (homework) => ListView(
                          key: const ValueKey('class_list'),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [_buildClassHomework(homework)],
                        ),
                        loading: () =>
                            const _LoadingList(key: ValueKey('class_loading')),
                        error: (err, stack) => _ErrorList(
                          key: const ValueKey('class_error'),
                          error: err,
                        ),
                      )
                    : groupWorkAsync.when(
                        data: (groupWork) => ListView(
                          key: const ValueKey('group_list'),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [_buildGroupsHomework(groupWork)],
                        ),
                        loading: () =>
                            const _LoadingList(key: ValueKey('group_loading')),
                        error: (err, stack) => _ErrorList(
                          key: const ValueKey('group_error'),
                          error: err,
                        ),
                      ),
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

  Widget _buildClassHomework(List<HomeworkModel> homework) {
    final activeHomework = homework.where((h) => h.archived == false).toList();
    final archivedHomework = homework.where((h) => h.archived == true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            (h) => _buildHomeworkCard(
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
            (h) => _buildHomeworkCard(
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
      ],
    );
  }

  Widget _buildGroupsHomework(List<GroupWorkModel> groupWork) {
    // ✅ FIX 3: Center এর বদলে Column — Center unbounded height এর কারণে crash করে
    if (groupWork.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SizedBox(height: 40),
          Icon(Icons.group_outlined, size: 48, color: Color(0xFFCCCCCC)),
          SizedBox(height: 16),
          Text(
            "No group assignments found.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupWork.map((gw) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gw.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            if (gw.description != null)
              Text(
                gw.description!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            const SizedBox(height: 16),

            // ✅ FIX 4: Duplicate const সরানো হয়েছে
            const Text(
              "Group Members",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            ...gw.members.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMemberCard(m.username, m.avatar),
              ),
            ),

            const SizedBox(height: 20),

            _buildHomeworkCard(
              title: "Assignment Details",
              description: gw.description ?? "No additional description.",
              dueDate: gw.dueDate != null
                  ? "Due: ${gw.dueDate.toString().split(' ')[0]}"
                  : (gw.createdAt != null
                        ? "Created: ${gw.createdAt.toString().split(' ')[0]}"
                        : "Assigned: N/A"),
            ),
            const Divider(height: 40),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMemberCard(String name, String? avatarUrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : const AssetImage('assets/images/classes/student_image.png')
                      as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard({
    required String title,
    required String description,
    required String dueDate,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  dueDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // ✅ FIX 5: mounted check করা হচ্ছে — dispose হয়ে গেলে crash এড়ানো
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Submission feature coming soon!'),
                      backgroundColor: AppColors.primaryMid,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMid,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("SUBMIT"),
              ),
            ],
          ),
        ],
      ),
    );
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

// ✅ FIX 6: Loading ও Error কে আলাদা const widget বানানো হয়েছে
// এতে করে rebuild এ নতুন instance তৈরি হয় না — semantics stable থাকে
class _LoadingList extends StatelessWidget {
  const _LoadingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

class _ErrorList extends StatelessWidget {
  final Object error;
  const _ErrorList({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Center(child: Text('Error: $error')),
        ),
      ],
    );
  }
}
