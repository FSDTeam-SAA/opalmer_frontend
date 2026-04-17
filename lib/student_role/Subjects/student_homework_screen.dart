import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';

class StudentHomeworkScreen extends ConsumerStatefulWidget {
  const StudentHomeworkScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StudentHomeworkScreen> createState() => _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends ConsumerState<StudentHomeworkScreen> {
  bool isClassSelected = true;

  @override
  Widget build(BuildContext context) {
    final homeworkAsync = ref.watch(studentHomeworkProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildTabToggle(),
          const SizedBox(height: 24),
          Expanded(
            child: homeworkAsync.when(
              data: (homework) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: isClassSelected 
                    ? _buildClassHomework(homework) 
                    : _buildGroupsHomework(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
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
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
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
                    color: isClassSelected ? AppColors.primaryMid : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Class",
                    style: TextStyle(
                      color: isClassSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: isClassSelected ? FontWeight.bold : FontWeight.w500,
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
                    color: !isClassSelected ? AppColors.primaryMid : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Groups",
                    style: TextStyle(
                      color: !isClassSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: !isClassSelected ? FontWeight.bold : FontWeight.w500,
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

  Widget _buildClassHomework(List<dynamic> homework) {
    final activeHomework = homework.where((h) => h['archived'] == false).toList();
    final archivedHomework = homework.where((h) => h['archived'] == true).toList();

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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("No homework for today", style: TextStyle(color: Colors.grey)),
          )
        else
          ...activeHomework.map((h) => _buildHomeworkCard(
                title: h['title'] ?? "N/A",
                description: "Attached files: ${h['file']?.length ?? 0}",
                dueDate: h['created_at'] != null 
                  ? "Created: ${h['created_at'].toString().split('T')[0]}" 
                  : "N/A",
              )),
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
            Icon(Icons.calendar_month_outlined, color: AppColors.primaryMid, size: 24),
          ],
        ),
        const SizedBox(height: 16),
        if (archivedHomework.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("No archived homework", style: TextStyle(color: Colors.grey)),
          )
        else
          ...archivedHomework.map((h) => _buildHomeworkCard(
                title: h['title'] ?? "N/A",
                description: "Attached files: ${h['file']?.length ?? 0}",
                dueDate: h['created_at'] != null 
                  ? h['created_at'].toString().split('T')[0] 
                  : "N/A",
              )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGroupsHomework() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Alpha Group (4)",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildMemberCard("Mia johnson"),
        const SizedBox(height: 12),
        _buildMemberCard("Mia johnson"),
        const SizedBox(height: 12),
        _buildMemberCard("Mia johnson"),
        const SizedBox(height: 12),
        _buildMemberCard("Mia johnson"),
        const SizedBox(height: 32),
        const Text(
          "Today's Homework",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildHomeworkCard(
          title: "Fractions Practice",
          description: "Solve question 1-10 on page 42 of the textbook.",
          dueDate: "Due: June 13,2025",
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
            Icon(Icons.calendar_month_outlined, color: AppColors.primaryMid, size: 24),
          ],
        ),
        const SizedBox(height: 16),
        _buildHomeworkCard(
          title: "Fractions Practice",
          description: "Solve question 1-10 on page 42 of the textbook.",
          dueDate: "Due: June 13,2025",
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMemberCard(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/classes/student_image.png'),
          ),
          const SizedBox(width: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
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
            color: Colors.black.withOpacity(0.04),
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
          Text(
            dueDate,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
