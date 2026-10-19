import 'package:flutter/material.dart';
import 'package:opalmer_education/core/widgets/assignment_details_screen.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';

class HomeworkCard extends StatelessWidget {
  final String? homeworkId;
  final String title;
  final String description;
  final String dueDate;
  const HomeworkCard({
    super.key,
    this.homeworkId,
    required this.title,
    required this.description,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: homeworkId == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssignmentDetailsScreen(homeworkId: homeworkId!))), child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 14),
          // Using a more resilient layout for the bottom row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dueDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
