import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/student_role/Subjects/subject_detail_screen.dart';

class SubjectCard extends ConsumerWidget {
  final String subjectName;
  final double? width;
  final LessonModel? lesson;

  const SubjectCard({
    Key? key,
    this.subjectName = "Science",
    this.width,
    this.lesson,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String attendanceVal = "0%";
    String progressVal = "0%";
    String dateStr = "N/A";

    final attendanceAsync = ref.watch(studentAttendanceProvider);
    final quizResultsAsync = ref.watch(studentQuizResultsProvider);

    attendanceAsync.whenData((records) {
      if (records.isNotEmpty) {
        final presentCount = records.where((r) => r.status.toLowerCase() == "present").length;
        attendanceVal = "${((presentCount / records.length) * 100).toInt()}%";
      }
    });

    quizResultsAsync.whenData((results) {
      if (results.isNotEmpty) {
        final avg = results.fold<double>(0, (sum, res) => sum + res.percentage) / results.length;
        progressVal = "${(avg * 100).toInt()}%";
      }
    });

    if (lesson?.createdAt != null) {
      dateStr = "${lesson!.createdAt!.day.toString().padLeft(2, '0')}-${lesson!.createdAt!.month.toString().padLeft(2, '0')}-${lesson!.createdAt!.year.toString().substring(2)}";
    }

    final teacher = lesson?.teacher;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailScreen(
              subjectName: subjectName,
              lesson: lesson,
            ),
          ),
        );
      },
      child: Container(
        width: width ?? 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryMid,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monitor_heart_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subjectName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  attendanceVal,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.orange,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  progressVal,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryMid.withValues(alpha: 0.1),
                  backgroundImage: teacher?.avatar != null && teacher!.avatar!.isNotEmpty
                      ? NetworkImage(teacher.avatar!) as ImageProvider
                      : null,
                  child: teacher?.avatar == null || teacher!.avatar!.isEmpty
                      ? const Icon(Icons.person, color: AppColors.primaryMid, size: 20)
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher?.username ?? "N/A",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectDetailScreen(
                          subjectName: subjectName,
                          lesson: lesson,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMid,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text("View", style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
