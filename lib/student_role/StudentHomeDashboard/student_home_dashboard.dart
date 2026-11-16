import '../../core/widgets/dashboard_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/notification_provider.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/core/providers/navigation_provider.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:opalmer_education/student_role/Subjects/widgets/subject_card.dart';
import 'package:opalmer_education/notification/notification.dart';
import '../Quizzes/quiz_summary_card.dart';

class StudentHomeDashboard extends ConsumerWidget {
  final VoidCallback? onOpenMenu;
  const StudentHomeDashboard({super.key, this.onOpenMenu});

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
            _buildHeader(
              context,
              studentName,
              ref.watch(unreadNotificationCountProvider),
            ),
            const SizedBox(height: 10),
            _buildSectionHeader(context, ref, "Classes"),
            const SizedBox(height: 16),
            _buildClassesList(ref),
            const SizedBox(height: 18),
            _buildSectionHeader(context, ref, "Quizzes"),
            const SizedBox(height: 16),
            _buildQuizzesList(ref),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String studentName, int unread) =>
      DashboardHeader(
        name: studentName,
        unreadCount: unread,
        workspace: 'Student workspace',
        subtitle: 'Ready to learn something new today?',
        onOpenMenu: onOpenMenu,
        onNotifications: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const NotificationScreen())),
      );

  Widget _buildSectionHeader(
    BuildContext context,
    WidgetRef ref,
    String title,
  ) {
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
              if (title == "Classes") {
                ref.read(studentTabIndexProvider.notifier).state = 1;
              } else if (title == "Quizzes") {
                ref.read(studentTabIndexProvider.notifier).state = 3;
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

  Widget _buildClassesList(WidgetRef ref) {
    final classesAsync = ref.watch(studentClassesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: classesAsync.when(
        data: (classes) {
          if (classes.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  "No classes found",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }
          return Column(
            children: [
              for (final studentClass in classes.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SubjectCard(
                    width: double.infinity,
                    studentClass: studentClass,
                    subjectName: studentClass.subject,
                  ),
                ),
            ],
          );
        },
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) {
          if (err.toString().contains('401')) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 28),
                  const SizedBox(height: 8),
                  const Text(
                    'Session expired. Please log in again.',
                    style: TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(authServiceProvider).logout();
                      ref.read(authStateProvider.notifier).state = null;
                    },
                    child: const Text('Log Out'),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Failed to load classes. Please try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizzesList(WidgetRef ref) {
    final quizzesAsync = ref.watch(studentQuizzesProvider);
    final resultsAsync = ref.watch(studentQuizResultsProvider);

    return quizzesAsync.when(
      data: (quizzes) {
        if (quizzes.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                "No quizzes available",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final results = resultsAsync.asData?.value ?? [];

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quizzes.length > 3 ? 3 : quizzes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final quiz = quizzes[index];

            // Only released results are exposed by this provider.
            final quizResult = results.cast<QuizResultModel?>().firstWhere(
              (r) => r?.quizId == quiz.id,
              orElse: () => null,
            );

            return QuizSummaryCard(quiz: quiz, result: quizResult);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) {
        if (err.toString().contains('401')) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 28),
                  const SizedBox(height: 8),
                  const Text(
                    'Session expired. Please log in again.',
                    style: TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(authServiceProvider).logout();
                      ref.read(authStateProvider.notifier).state = null;
                    },
                    child: const Text('Log Out'),
                  ),
                ],
              ),
            ),
          );
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Failed to load quizzes. Please try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        );
      },
    );
  }

}
