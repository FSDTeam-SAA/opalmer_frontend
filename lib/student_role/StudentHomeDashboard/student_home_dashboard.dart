import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:opalmer_education/student_role/Subjects/subjects_screen.dart';
import 'package:opalmer_education/student_role/Subjects/widgets/subject_card.dart';
import 'package:opalmer_education/notification/notification.dart';

class StudentHomeDashboard extends ConsumerWidget {
  const StudentHomeDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final studentName = user?.username ?? "Student";

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, studentName),
            const SizedBox(height: 10),
            _buildSectionHeader(context, "Subjects"),
            const SizedBox(height: 16),
            _buildSubjectsList(ref),
            const SizedBox(height: 32),
            _buildSectionHeader(context, "Quizzes"),
            const SizedBox(height: 16),
            _buildQuizzesList(ref),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String studentName) {
    return Stack(
      children: [
        // Wave Background
        Container(
          width: double.infinity,
          height: 220,
          child: Image.asset(
            'assets/images/Home_dashboard_header.png',
            fit: BoxFit.cover,
          ),
        ),

        // Gradient overlay to match the image precisely if needed,
        // but the asset should already have it.
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, $studentName 👋",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Your learning starts here.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                // Notification Bell
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          TextButton(
            onPressed: () {
              if (title == "Subjects") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubjectsScreen()),
                );
              }
            },
            child: const Text(
              "View All",
              style: TextStyle(
                color: AppColors.primaryMid,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList(WidgetRef ref) {
    final lessonsAsync = ref.watch(studentLessonsProvider);

    return SizedBox(
      height: 150,
      child: lessonsAsync.when(
        data: (lessons) {
          if (lessons.isEmpty) {
            return const Center(child: Text("No subjects found"));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: lessons.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return SubjectCard(
                subjectName: lesson['title'] ?? "N/A",
                teacherName: lesson['teacher']?['username'] ?? "N/A",
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }


  Widget _buildQuizzesList(WidgetRef ref) {
    final quizzesAsync = ref.watch(studentQuizzesProvider);

    return quizzesAsync.when(
      data: (quizzes) {
        if (quizzes.isEmpty) {
          return const Center(child: Text("No quizzes available"));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quizzes.length > 3 ? 3 : quizzes.length, // Show top 3 on dashboard
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            final colors = [
              const Color(0xFF2E9B5B),
              const Color(0xFFE8A317),
              Colors.blue,
            ];
            return _buildQuizCard(
              title: quiz['title'] ?? "N/A",
              color: colors[index % colors.length],
              progress: 0.0, // Progress needs a specific API to track
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildQuizCard({required String title, required Color color, required double progress}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade100,
                  child: Image.asset(
                    'assets/images/classes/book_icon.png', // Using an existing asset
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "10 Questions · 5 min",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                "0%",
                style: TextStyle(fontSize: 11, color: AppColors.primaryMid),
              ),
              const Spacer(),
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(fontSize: 11, color: AppColors.primaryMid),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMid,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Start Learning",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
