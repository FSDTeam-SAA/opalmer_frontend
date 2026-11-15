import 'package:flutter/material.dart';
import '../../core/models/student_models.dart';
import '../../core/theme/app_colors.dart';
import 'student_quiz_questions_screen.dart';

class QuizSummaryCard extends StatelessWidget {
  final QuizModel quiz;
  final QuizResultModel? result;
  const QuizSummaryCard({super.key, required this.quiz, this.result});

  @override
  Widget build(BuildContext context) {
    final percentage = result?.percentage;
    final submitted = quiz.attemptStatus == 'completed';
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              quiz.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (quiz.metaLine.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(quiz.metaLine, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 12),
            Text(
              percentage == null
                  ? (submitted
                        ? 'Submitted · Awaiting teacher release'
                        : quiz.attemptStatus == 'ongoing'
                        ? 'In progress'
                        : 'Not started')
                  : 'Released score: ${(percentage * 100).round()}%',
            ),
            if (percentage != null) ...[
              const SizedBox(height: 6),
              LinearProgressIndicator(value: percentage.clamp(0.0, 1.0)),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (result != null) {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(quiz.title),
                        content: Text(
                          'Released score: ${(result!.percentage * 100).round()}%\nPoints earned: ${result!.score}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  } else if (submitted) {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Assessment submitted'),
                        content: const Text(
                          'Your answers are saved. Your grade will appear after your teacher reviews and releases it.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentQuizQuestionsScreen(quiz: quiz),
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryMid,
                ),
                child: Text(
                  result != null
                      ? 'View result'
                      : submitted
                      ? 'View submission'
                      : quiz.attemptStatus == 'ongoing'
                      ? 'Resume assessment'
                      : 'Open assessment',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
