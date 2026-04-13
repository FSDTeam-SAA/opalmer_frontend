import 'package:flutter/material.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';

class StudentLessonOverviewScreen extends StatelessWidget {
  const StudentLessonOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topic Section
            const Text(
              "Topic",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Photosynthesis",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "16/06/2025",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // PDF Material Section
            const Text(
              "PDF Material",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: AppColors.primaryMid,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Photosynthesis PDF",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.download_for_offline_rounded,
                    color: AppColors.primaryMid,
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Description Section
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF333333),
                  height: 1.6,
                ),
                children: [
                  const TextSpan(
                    text: "Workbook Task: ",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                  ),
                  TextSpan(
                    text: "Complete page 42, Questions 1-5\n\n",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const TextSpan(
                    text: "Questions to Think About:\n",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                  ),
                  TextSpan(
                    text: "  • What is the main purpose of photosynthesis?\n"
                        "  • Why is sunlight important?\n"
                        "  • How do plants store energy?",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
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
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
      title: const Text(
        "Lessons Overview",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
