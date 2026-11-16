import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/student_role/Subjects/subject_detail_screen.dart';

class SubjectCard extends ConsumerWidget {
  final String subjectName;
  final double? width;
  final StudentClassModel? studentClass;

  final LessonModel? lesson;

  const SubjectCard({
    super.key,
    this.subjectName = "Science",
    this.width,
    this.studentClass,
    this.lesson,
  });

  void _open(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SubjectDetailScreen(
        subjectName: studentClass?.subject ?? subjectName,
        studentClass: studentClass,
      ),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int perf = studentClass?.performancePercentage ?? 0;
    final int att = studentClass?.attendancePercentage ?? 0;
    final avatar = studentClass?.teacherAvatar;
    final hasAvatar = avatar != null && avatar.isNotEmpty;

    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        width: width ?? 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryMid.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryMid.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Title row ──
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9B2FC4), Color(0xFF6E17A0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentClass?.subject ?? subjectName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMid.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Grade ${studentClass?.grade ?? ''}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryMid,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMid.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primaryMid,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Stats ──
            Row(
              children: [
                Expanded(
                  child: _buildStat(
                    icon: Icons.calendar_today_rounded,
                    label: "Attendance",
                    percent: att,
                    color: const Color(0xFF4AA678),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStat(
                    icon: Icons.insights_rounded,
                    label: "Performance",
                    percent: perf,
                    color: const Color(0xFFE9A21B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 12),

            // ── Teacher + action ──
            Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
                  child: hasAvatar
                      ? null
                      : const Icon(Icons.person, color: Colors.grey, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Teacher",
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        studentClass?.teacherName ?? "N/A",
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _open(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMid,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 9,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    "View",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required int percent,
    required Color color,
  }) {
    final value = (percent.clamp(0, 100)) / 100;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "$percent%",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value,
            minHeight: 5,
            color: color,
            backgroundColor: Colors.white,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}
