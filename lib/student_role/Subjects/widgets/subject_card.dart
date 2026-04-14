import 'package:flutter/material.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:opalmer_education/student_role/Subjects/subject_detail_screen.dart';

class SubjectCard extends StatelessWidget {
  final String subjectName;
  final String attendance;
  final String performance;
  final String date;
  final String teacherName;
  final String teacherImage;
  final double? width;

  const SubjectCard({
    Key? key,
    this.subjectName = "Science",
    this.attendance = "92%",
    this.performance = "85%",
    this.date = "06-03-25",
    this.teacherName = "Olivia Carter",
    this.teacherImage = 'assets/images/profile /olivia.png',
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailScreen(subjectName: subjectName),
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
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  attendance,
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
                  performance,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(teacherImage),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacherName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
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
