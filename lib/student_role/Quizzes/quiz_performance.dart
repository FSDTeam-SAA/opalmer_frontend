import '../../core/models/student_models.dart';

/// Daily averages of released results. A missing day is not a zero score.
List<({DateTime date, double? percentage})> quizPerformance(
  List<QuizResultModel> results, {
  required DateTime now,
  required int days,
}) {
  final today = DateTime(now.year, now.month, now.day);
  return List.generate(days, (index) {
    final date = DateTime(
      today.year,
      today.month,
      today.day - days + 1 + index,
    );
    final scores = results
        .where((result) {
          final completed = result.createdAt?.toLocal();
          return completed != null &&
              completed.year == date.year &&
              completed.month == date.month &&
              completed.day == date.day;
        })
        .map((result) => result.percentage * 100);
    return (
      date: date,
      percentage: scores.isEmpty
          ? null
          : scores.reduce((a, b) => a + b) / scores.length,
    );
  });
}
