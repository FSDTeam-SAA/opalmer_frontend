import 'package:flutter/material.dart';

class RewardsBadgesScreen extends StatelessWidget {
  const RewardsBadgesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
            ),
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          "Rewards/Badges",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Earn badges for your performance, behavior, attendance, and participation!",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            _buildBadgeItem(
              icon: "⭐",
              title: "Star Student",
              isEarned: true,
              description:
                  "Consistently striving for excellence in every subject. Your dedication shines bright every day!",
              progressColor: const Color(0xFFF04F4F),
              currentProgress: 0.6,
              targetText: "60%",
            ),
            _buildBadgeItem(
              icon: "🎯",
              title: "Perfect Attendance",
              isEarned: false,
              description:
                  "100% attendance and 100% dedication. Consistency is your superpower!",
              progressColor: const Color(0xFFF9A825),
              currentProgress: 0.75,
              targetText: "83%",
            ),
            _buildBadgeItem(
              icon: "🗣️",
              title: "Participation Pro",
              isEarned: false,
              description:
                  "Never afraid to raise your hand or help others. Your involvement lifts the whole classroom!",
              progressColor: const Color(0xFF4CAF50),
              currentProgress: 0.88,
              targetText: "93%",
            ),
            _buildBadgeItem(
              icon: "👏",
              title: "Role Model Behavior",
              isEarned: false,
              description:
                  "Your actions speak louder than words. Thank you for making our classroom a better place!",
              progressColor: const Color(0xFFFFB300),
              currentProgress: 0.75,
              targetText: "83%",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem({
    required String icon,
    required String title,
    required bool isEarned,
    required String description,
    required Color progressColor,
    required double currentProgress,
    required String targetText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isEarned
                      ? const Color(0xFFD4E1C6)
                      : const Color(0xFFFFC6D3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isEarned ? "Earned" : "Not Earned",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isEarned
                        ? const Color(0xFF5B8B4D)
                        : const Color(0xFFD34F70),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Custom Progress Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              // Target text and tick are positioned near the end (e.g. 90% of width)
              // To make it match the design nicely, we'll place the tick at 90% of the bar width.
              const double tickPositionRatio = 0.9;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      // 0% text
                      Text(
                        "0%",
                        style: TextStyle(
                          fontSize: 12,
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Target % text
                      Positioned(
                        left: width * tickPositionRatio - 12,
                        child: Text(
                          targetText,
                          style: TextStyle(
                            fontSize: 12,
                            color: progressColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Background Gray Bar
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Foreground Colored Bar
                      Container(
                        height: 4,
                        width: width * currentProgress,
                        decoration: BoxDecoration(
                          color: progressColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Purple Tick Mark
                      Positioned(
                        left: width * tickPositionRatio,
                        top: -4,
                        child: Container(
                          width: 3,
                          height: 12,
                          color: const Color(0xFF871DAD),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
