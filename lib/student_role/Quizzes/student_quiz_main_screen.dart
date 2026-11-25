import 'package:opalmer_education/core/responsive/responsive.dart';
import 'package:opalmer_education/core/widgets/app_home_button.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/app_back_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:opalmer_education/core/providers/notification_provider.dart';
import 'package:opalmer_education/notification/notification.dart';
import 'package:opalmer_education/student_role/Quizzes/student_quiz_list_screen.dart';
import 'quiz_summary_card.dart';
import 'quiz_performance.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class StudentQuizMainScreen extends ConsumerStatefulWidget {
  const StudentQuizMainScreen({super.key});

  @override
  ConsumerState<StudentQuizMainScreen> createState() =>
      _StudentQuizMainScreenState();
}

class _StudentQuizMainScreenState extends ConsumerState<StudentQuizMainScreen> {
  String _filterPeriod = "Weekly";

  @override
  Widget build(BuildContext context) {
    final quizzesAsync = ref.watch(studentQuizzesProvider);
    final quizResultsAsync = ref.watch(studentQuizResultsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(studentQuizzesProvider);
          ref.invalidate(studentQuizResultsProvider);
          await Future.wait([
            ref.read(studentQuizzesProvider.future),
            ref.read(studentQuizResultsProvider.future),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildQuizSection(context, ref, quizzesAsync, quizResultsAsync),
              const SizedBox(height: 32),
              _buildStatsSection(quizResultsAsync),
              const SizedBox(height: 32),
              _buildProgressSection(quizResultsAsync),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.statusBarStyle,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF871DAD), Color(0xFF9D39C3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          Responsive.gutter(context, base: 24),
          60,
          Responsive.gutter(context, base: 24),
          32,
        ),
        child: AppPageHeader(
          homeColor: Colors.white,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppBackButton(),
            const Expanded(
              child: Text(
                "Quizzes",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            _NotificationBell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<QuizModel>> quizzesAsync,
    AsyncValue<List<QuizResultModel>> quizResultsAsync,
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.gutter(context, base: 24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Quizzes",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudentQuizListScreen(),
                  ),
                ),
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
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 210,
          child: quizzesAsync.when(
            data: (quizzes) {
              if (quizzes.isEmpty) {
                return const Center(child: Text("No quizzes available"));
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.gutter(context, base: 16),
                ),
                scrollDirection: Axis.horizontal,
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  final matches =
                      (quizResultsAsync.valueOrNull ?? <QuizResultModel>[])
                          .where((r) => r.quizId == quiz.id);
                  return SizedBox(
                    width: 280,
                    child: QuizSummaryCard(
                      quiz: quiz,
                      result: matches.isEmpty ? null : matches.first,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(
    AsyncValue<List<QuizResultModel>> quizResultsAsync,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.gutter(context, base: 24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Stats",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          quizResultsAsync.when(
            data: (results) {
              final int completed = results.length;
              final bool hasResults = completed > 0;

              final double correctAvg = hasResults
                  ? results.fold<double>(
                          0,
                          (sum, res) => sum + res.percentage,
                        ) /
                        completed
                  : 0;
              final int correctPct = (correctAvg * 100).round();
              final int wrongPct = hasResults ? (100 - correctPct) : 0;

              String bestSubject = "N/A";
              if (hasResults) {
                bestSubject = results
                    .reduce((a, b) => a.percentage > b.percentage ? a : b)
                    .quizTitle;
                if (bestSubject.length > 20) {
                  bestSubject = '${bestSubject.substring(0, 20)}...';
                }
              }

              return GridView.count(
                // Four tiles in a single row when there is room (tablets).
                crossAxisCount:
                    MediaQuery.sizeOf(context).width -
                            2 * Responsive.gutter(context, base: 24) >=
                        560
                    ? 4
                    : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatTile(
                    "Released results",
                    completed.toString(),
                    const Color(0xFFFEBD43),
                  ),
                  _buildStatTile(
                    "Average score",
                    hasResults ? "$correctPct%" : "N/A",
                    const Color(0xFF4AA678),
                  ),
                  _buildStatTile(
                    "Points to improve",
                    hasResults ? "$wrongPct%" : "N/A",
                    const Color(0xFF4AA678).withValues(alpha: 0.85),
                  ),
                  _buildStatTile(
                    "Best assessment",
                    bestSubject,
                    const Color(0xFFFEBD43),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(
    AsyncValue<List<QuizResultModel>> quizResultsAsync,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.gutter(context, base: 24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Progress",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 220,
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
            child: quizResultsAsync.when(
              data: (results) {
                final days = _filterPeriod == 'Weekly' ? 7 : 30;
                final daily = quizPerformance(
                  results,
                  now: DateTime.now(),
                  days: days,
                );
                final spots = [
                  for (var i = 0; i < daily.length; i++)
                    daily[i].percentage == null
                        ? FlSpot.nullSpot
                        : FlSpot(i.toDouble(), daily[i].percentage!),
                ];

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Progress",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryMid,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _filterPeriod = _filterPeriod == "Weekly"
                                  ? "Monthly"
                                  : "Weekly";
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
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
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.primaryMid,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.shade100,
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.round();
                                  if (index >= 0 &&
                                      index < daily.length &&
                                      value == index.toDouble()) {
                                    if (days == 30 &&
                                        index % 7 != 0 &&
                                        index != 29) {
                                      return const SizedBox.shrink();
                                    }
                                    final date = daily[index].date;
                                    return Text(
                                      '${date.day}/${date.month}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
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
                                reservedSize: 25,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: (days - 1).toDouble(),
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: false,
                              color: AppColors.primaryMid,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryMid.withValues(alpha: 0.2),
                                    AppColors.primaryMid.withValues(alpha: 0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends ConsumerWidget {
  final VoidCallback onTap;
  const _NotificationBell({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (unread > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D4F),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  unread > 99 ? '99+' : unread.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
