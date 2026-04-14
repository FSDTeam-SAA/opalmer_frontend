import 'package:flutter/material.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:opalmer_education/student_role/Quizzes/student_quiz_questions_screen.dart';

class StudentQuizListScreen extends StatelessWidget {
  const StudentQuizListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildQuizCard(
            context,
            "Fraction and Decimals",
            "10 Questions · 5 min",
            0.93,
            const Color(0xFF4AA678),
          ),
          _buildQuizCard(
            context,
            "Photosynthesis",
            "10 Questions · 5 min",
            0.83,
            const Color(0xFFFEBD43),
          ),
          _buildQuizCard(
            context,
            "Fraction and Decimals",
            "10 Questions · 5 min",
            0.73,
            const Color(0xFF4A90E2),
          ),
          _buildQuizCard(
            context,
            "Fraction and Decimals",
            "10 Questions · 5 min",
            0.93,
            const Color(0xFF4AA678),
          ),
          _buildQuizCard(
            context,
            "Fraction and Decimals",
            "10 Questions · 5 min",
            0.83,
            const Color(0xFFFEBD43),
          ),
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
        "Quizzes",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildQuizCard(
    BuildContext context,
    String title,
    String subtitle,
    double progress,
    Color barColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/science_icon.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    width: 44,
                    height: 44,
                    child: const Icon(Icons.quiz_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "0%",
                style: TextStyle(
                  fontSize: 11,
                  color: barColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 11,
                  color: barColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentQuizQuestionsScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMid,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Start Learning",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
