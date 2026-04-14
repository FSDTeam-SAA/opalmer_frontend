import 'package:flutter/material.dart';
import 'package:opalmer_education/core/widgets/learning_tip_card.dart';
import 'package:opalmer_education/parent_role/LearningTipsScreen/models/learning_tip.dart';
import 'package:opalmer_education/parent_role/LearningTipsScreen/learning_tip_detail_screen.dart';

class LearningTipsScreen extends StatelessWidget {
  const LearningTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Repeated mock logic to populate the list as seen in design
    // Using the shared mock data from core/models/learning_tip.dart

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header matching design exactly
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF871DAD),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Learning Tips",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                ],
              ),
            ),

            // Reusable Tips List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: mockLearningTips.length,
                itemBuilder: (context, index) {
                  final tip = mockLearningTips[index];
                  return LearningTipCard(
                    title: tip.title,
                    imageUrl: tip.imageUrl,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LearningTipDetailScreen(tip: tip),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
