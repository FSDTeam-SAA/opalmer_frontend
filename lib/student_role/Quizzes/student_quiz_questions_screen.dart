import 'package:flutter/material.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:opalmer_education/student_role/Quizzes/student_quiz_result_screen.dart';

class StudentQuizQuestionsScreen extends StatefulWidget {
  const StudentQuizQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<StudentQuizQuestionsScreen> createState() => _StudentQuizQuestionsScreenState();
}

class _StudentQuizQuestionsScreenState extends State<StudentQuizQuestionsScreen> {
  final Map<int, int> _answers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                _buildQuizInfoCard(),
                const SizedBox(height: 24),
                _buildQuestionCard(
                  1,
                  "Convert the fraction to a decimal: 3/4",
                  ["0.25", "0.5", "0.75", "1.25"],
                ),
                _buildQuestionCard(
                  2,
                  "Which of these is the smallest?",
                  ["1/2", "0.4", "3/5", "0.75"],
                ),
                _buildQuestionCard(
                  3,
                  "What is 15% of 200?",
                  ["20", "25", "30", "35"],
                ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
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
              decoration: const BoxDecoration(color: AppColors.primaryMid, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
      title: const Text(
        "Questions",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildQuizInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4AA678),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow("Quiz Name", "Fraction and Decimals"),
          const SizedBox(height: 12),
          _buildInfoRow("Total Questions", "10"),
          const SizedBox(height: 12),
          _buildInfoRow("Created By", "John Martin"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuestionCard(int number, String question, List<String> options) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number. $question",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.4),
          ),
          const SizedBox(height: 16),
          ...options.asMap().entries.map((entry) {
            int idx = entry.key;
            String text = entry.value;
            bool isSelected = _answers[number] == idx;

            return GestureDetector(
              onTap: () => setState(() => _answers[number] = idx),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isSelected ? AppColors.primaryMid : Colors.grey.shade300, width: 2),
                      ),
                      child: isSelected ? Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.primaryMid, shape: BoxShape.circle))) : null,
                    ),
                    const SizedBox(width: 12),
                    Text(text, style: TextStyle(fontSize: 15, color: isSelected ? AppColors.primaryMid : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentQuizResultScreen())),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMid,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("COMPLETE QUIZ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}
