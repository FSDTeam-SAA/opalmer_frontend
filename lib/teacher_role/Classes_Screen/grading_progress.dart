import 'package:opalmer_education/core/widgets/app_home_button.dart';
import 'package:flutter/material.dart';
import 'scan_document.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/teacher_provider.dart';

class GradingProgressScreen extends ConsumerStatefulWidget {
  final String studentId;
  final String classId;
  const GradingProgressScreen({
    super.key,
    required this.studentId,
    required this.classId,
  });

  @override
  ConsumerState<GradingProgressScreen> createState() =>
      _GradingProgressScreenState();
}

class _GradingProgressScreenState extends ConsumerState<GradingProgressScreen> {
  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(
      studentQuizResultsProvider(widget.studentId),
    );
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF871DAD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ),
        title: const Text(
          "Grading Progress",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          const AppHomeButton(),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScanDocumentScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF871DAD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons
                        .center_focus_strong_outlined, // closest to the scan/focus icon
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: resultsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: TextButton(
              onPressed: () =>
                  ref.invalidate(studentQuizResultsProvider(widget.studentId)),
              child: const Text('Unable to load grading results. Retry'),
            ),
          ),
          data: (results) {
            final reviewed = results.where((result) {
              final quiz = result['quizId'];
              final progress = result['progress'];
              return quiz is Map &&
                  quiz['classId']?.toString() == widget.classId &&
                  progress is Map &&
                  progress['status'] == 'completed' &&
                  ['reviewed', 'released'].contains(result['gradeStatus']) &&
                  result['percentage'] is num &&
                  (result['percentage'] as num).isFinite &&
                  result['percentage'] >= 0 &&
                  result['percentage'] <= 100;
            }).toList();
            if (reviewed.isEmpty)
              return const Center(
                child: Text(
                  'No reviewed grading results for this student in this class.',
                ),
              );
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(studentQuizResultsProvider(widget.studentId));
                await ref.read(
                  studentQuizResultsProvider(widget.studentId).future,
                );
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: reviewed.length,
                itemBuilder: (context, index) {
                  final result = reviewed[index];
                  final date = DateTime.tryParse(
                    result['submittedAt']?.toString() ??
                        result['updatedAt']?.toString() ??
                        '',
                  );
                  return _buildProgressCard(
                    title:
                        result['quizId']['title']?.toString() ??
                        'Untitled assessment',
                    date: date == null
                        ? 'Date unavailable'
                        : DateFormat('dd/MM/yyyy').format(date.toLocal()),
                    progress: (result['percentage'] as num).toDouble() / 100,
                    indicatorColor: const Color(0xFF4AA678),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required String title,
    required String date,
    required double progress,
    required Color indicatorColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          "0%",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF871DAD),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF871DAD),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF871DAD),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
