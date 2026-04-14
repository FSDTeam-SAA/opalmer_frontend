import 'package:flutter/material.dart';
import 'add_homework_screen.dart';
import 'group_detail_screen.dart';
import 'create_group_screen.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  bool isClassSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF871DAD),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Homework",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Tab Toggle ──
            Center(
              child: Container(
                width: 250,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isClassSelected = true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isClassSelected
                                ? const Color(0xFF871DAD)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
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
                                  : FontWeight.normal,
                              fontSize: 14,
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
                                ? const Color(0xFF871DAD)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
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
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: isClassSelected ? _buildClassTab() : _buildGroupsTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Homework
          const Text(
            "Today's Homework",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddHomeworkScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF871DAD),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                "ADD HOMEWORK",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Archived Homework Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Archived Homework",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Icon(
                Icons.calendar_month_outlined,
                color: const Color(0xFF871DAD),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Archived Homework List
          _buildHomeworkCard(
            title: "Fractions Practice",
            description: "Solve question 1-10 on page 42 of the textbook.",
            dueDate: "Due: June 13,2025",
            showOptions: true,
          ),
          _buildHomeworkCard(
            title: "Fractions Practice",
            description: "Solve question 1-10 on page 42 of the textbook.",
            dueDate: "Due: June 13,2025",
            showOptions: false,
          ),
          _buildHomeworkCard(
            title: "Fractions Practice",
            description: "Solve question 1-10 on page 42 of the textbook.",
            dueDate: "Due: June 13,2025",
            showOptions: false,
          ),
          _buildHomeworkCard(
            title: "Fractions Practice",
            description: "Solve question 1-10 on page 42 of the textbook.",
            dueDate: "Due: June 13,2025",
            showOptions: false,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF871DAD),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                "CREATE GROUP",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildGroupCard(groupName: "Alpha Group", memberCount: "4 Members"),
          _buildGroupCard(groupName: "Alpha 1 Group", memberCount: "6 Members"),
          _buildGroupCard(groupName: "Alpha 1 Group", memberCount: "6 Members"),
          _buildGroupCard(groupName: "Alpha 1 Group", memberCount: "6 Members"),
          _buildGroupCard(groupName: "Alpha 1 Group", memberCount: "6 Members"),
          _buildGroupCard(groupName: "Alpha 1 Group", memberCount: "6 Members"),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard({
    required String title,
    required String description,
    required String dueDate,
    required bool showOptions,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dueDate,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              if (showOptions)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF871DAD),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF871DAD),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFF94A4A),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFF94A4A),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard({
    required String groupName,
    required String memberCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  memberCount,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF94A4A),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GroupDetailScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF871DAD),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "View",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
