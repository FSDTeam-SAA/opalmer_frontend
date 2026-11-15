import 'package:opalmer_education/core/widgets/app_home_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'quiz_summary_card.dart';

class StudentQuizListScreen extends ConsumerWidget {
  const StudentQuizListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(studentQuizzesProvider);
    final results =
        ref.watch(studentQuizResultsProvider).valueOrNull ??
        <QuizResultModel>[];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: quizzesAsync.when(
        data: (quizzes) {
          if (quizzes.isEmpty) {
            return const Center(
              child: Text("No quizzes available at the moment."),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              final matches = results.where((r) => r.quizId == quiz.id);
              return QuizSummaryCard(
                quiz: quiz,
                result: matches.isEmpty ? null : matches.first,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      actions: [const AppHomeButton()],
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
        "Quizzes",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
