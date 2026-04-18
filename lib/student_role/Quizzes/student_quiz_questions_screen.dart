import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:opalmer_education/student_role/Quizzes/student_quiz_result_screen.dart';

class StudentQuizQuestionsScreen extends ConsumerStatefulWidget {
  final QuizModel quiz;
  const StudentQuizQuestionsScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  ConsumerState<StudentQuizQuestionsScreen> createState() =>
      _StudentQuizQuestionsScreenState();
}

class _StudentQuizQuestionsScreenState
    extends ConsumerState<StudentQuizQuestionsScreen> {
  final Map<int, int> _answers = {};
  bool _isSubmitting = false;

  Future<void> _submitQuiz(List<QuizQuestion> questions) async {
    final user = ref.read(authStateProvider);
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      int score = 0;
      for (int i = 0; i < questions.length; i++) {
        if (_answers.containsKey(i)) {
          final selectedOption = questions[i].options[_answers[i]!];
          if (selectedOption == questions[i].answer) {
            score++;
          }
        }
      }

      final success = await ref.read(studentServiceProvider).submitQuiz(
        widget.quiz.id,
        user.id,
        score,
        questions.length,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentQuizResultScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit quiz. Please try again.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizQAAsync = ref.watch(quizQAProvider(widget.quiz.id));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: quizQAAsync.when(
        data: (quizQA) {
          if (quizQA == null || quizQA.questions.isEmpty) {
            return const Center(child: Text("No questions found for this quiz."));
          }
          final questions = quizQA.questions;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  children: [
                    _buildQuizInfoCard(questions.length),
                    const SizedBox(height: 24),
                    ...questions.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final q = entry.value;
                      return _buildQuestionCard(
                        idx,
                        q.question,
                        q.options,
                      );
                    }).toList(),
                  ],
                ),
              ),
              _buildFooter(context, questions),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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
        "Questions",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildQuizInfoCard(int totalQuestions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4AA678),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow("Quiz Name", widget.quiz.title),
          const SizedBox(height: 12),
          _buildInfoRow("Total Questions", totalQuestions.toString()),
          const SizedBox(height: 12),
          _buildInfoRow("Teacher", widget.quiz.teacherName ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(int index, String question, List<String> options) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
            "${index + 1}. $question",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...options.asMap().entries.map((entry) {
            int optIdx = entry.key;
            String text = entry.value;
            bool isSelected = _answers[index] == optIdx;

            return GestureDetector(
              onTap: () => setState(() => _answers[index] = optIdx),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryMid
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryMid,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected
                              ? AppColors.primaryMid
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, List<QuizQuestion> questions) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : () => _submitQuiz(questions),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMid,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "COMPLETE QUIZ",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
