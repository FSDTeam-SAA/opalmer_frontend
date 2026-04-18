import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:opalmer_education/student_role/Subjects/student_homework_screen.dart';
import 'package:opalmer_education/student_role/Subjects/student_attendance_screen.dart';
import 'package:opalmer_education/student_role/Subjects/student_lessons_screen.dart';
import 'package:opalmer_education/student_role/Subjects/student_academic_notes_screen.dart';
import 'package:opalmer_education/student_role/Subjects/student_grading_progress_screen.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/student_role/Chat_Screen/chat_screen.dart';

class SubjectDetailScreen extends ConsumerStatefulWidget {
  final String subjectName;
  final LessonModel? lesson;

  const SubjectDetailScreen({
    Key? key,
    this.subjectName = "Science",
    this.lesson,
  }) : super(key: key);

  @override
  ConsumerState<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen> {
  String _filterPeriod = "Weekly";

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(studentAttendanceProvider);
    final quizResultsAsync = ref.watch(studentQuizResultsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildStatCards(attendanceAsync, quizResultsAsync),
            const SizedBox(height: 32),
            const Text(
              "Teacher Profile",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTeacherProfile(),
            const SizedBox(height: 32),
            _buildProgressSection(quizResultsAsync),
            const SizedBox(height: 32),
            _buildOptionsList(context),
            const SizedBox(height: 40),
          ],
        ),
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
      title: Text(
        widget.lesson?.objective ?? widget.subjectName,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatCards(
    AsyncValue<List<AttendanceRecord>> attendanceAsync,
    AsyncValue<List<QuizResultModel>> quizResultsAsync,
  ) {
    String attendanceVal = "0%";
    String progressVal = "0%";

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

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: "Attendance",
            value: attendanceVal,
            emoji: "😊",
            color: const Color(0xFF4AA678),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            label: "Progress",
            value: progressVal,
            color: const Color(0xFFFEBD43),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    String? emoji,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (emoji != null) ...[
                const SizedBox(width: 4),
                Text(emoji, style: const TextStyle(fontSize: 20)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherProfile() {
    final teacher = widget.lesson?.teacher;
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryMid.withValues(alpha: 0.1),
          backgroundImage: teacher?.avatar != null && teacher!.avatar!.isNotEmpty
              ? NetworkImage(teacher.avatar!) as ImageProvider
              : null,
          child: teacher?.avatar == null || teacher!.avatar!.isEmpty
              ? const Icon(Icons.person, color: AppColors.primaryMid)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                teacher?.username ?? "No Teacher Assigned",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            if (teacher != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    name: teacher.username,
                    imageUrl: teacher.avatar ?? '',
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No teacher assigned to this lesson")),
              );
            }
          },
          child: _buildCircleActionIcon(Icons.chat_bubble_outline_rounded),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Calling ${teacher?.username ?? 'Teacher'}...")),
          ),
          child: _buildCircleActionIcon(Icons.call_outlined),
        ),
      ],
    );
  }

  Widget _buildCircleActionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppColors.primaryMid,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildProgressSection(AsyncValue<List<QuizResultModel>> quizResultsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _filterPeriod = _filterPeriod == "Weekly" ? "Monthly" : "Weekly";
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryMid),
                ),
                child: Row(
                  children: [
                    Text(
                      _filterPeriod,
                      style: const TextStyle(
                        color: AppColors.primaryMid,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryMid,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
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
          child: quizResultsAsync.when(
            data: (results) {
              // Map weekly data (0 = Sun, 6 = Sat)
              Map<int, double> weeklySpots = {};
              for (var res in results) {
                if (res.createdAt != null) {
                  // Only include results from the last 7 days for "Weekly"
                  if (_filterPeriod == "Weekly" &&
                      DateTime.now().difference(res.createdAt!).inDays > 7) continue;
                  
                  int weekday = res.createdAt!.weekday % 7; // Sunday = 0
                  // Keep the highest score for that day or average? Let's take latest.
                  weeklySpots[weekday] = res.percentage * 100;
                }
              }

              List<FlSpot> spots = [];
              for (int i = 0; i < 7; i++) {
                spots.add(FlSpot(i.toDouble(), weeklySpots[i] ?? 0));
              }

              return LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                          if (value >= 0 && value < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[value.toInt()],
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value % 20 == 0) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primaryMid,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          // Highlight latest result day
                          if (results.isNotEmpty && 
                              spot.x == (results.first.createdAt?.weekday ?? -1) % 7) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: Colors.orange,
                            );
                          }
                          return FlDotCirclePainter(radius: 0);
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryMid.withValues(alpha: 0.35),
                            AppColors.primaryMid.withValues(alpha: 0.01),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsList(BuildContext context) {
    final options = [
      {"title": "Home Work", "icon": Icons.home_work_outlined},
      {"title": "Attendance", "icon": Icons.calendar_today_outlined},
      {"title": "Lessons", "icon": Icons.book_outlined},
      {"title": "Academic Notes", "icon": Icons.note_alt_outlined},
      {"title": "Grading Progress", "icon": Icons.grade_outlined},
    ];

    return Column(
      children: options
          .map((opt) => _buildOptionTile(context, opt["title"] as String))
          .toList(),
    );
  }

  Widget _buildOptionTile(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          if (title == "Home Work") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentHomeworkScreen(),
              ),
            );
          } else if (title == "Attendance") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentAttendanceScreen(),
              ),
            );
          } else if (title == "Lessons") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentLessonsScreen(),
              ),
            );
          } else if (title == "Academic Notes") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentAcademicNotesScreen(),
              ),
            );
          } else if (title == "Grading Progress") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentGradingProgressScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}
