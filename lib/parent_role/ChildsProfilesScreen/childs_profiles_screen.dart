import 'package:flutter/material.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:opalmer_education/core/widgets/animated_wave_header.dart';
import 'package:opalmer_education/core/widgets/pressable_card.dart';
import 'package:opalmer_education/notification/notification.dart';
import 'package:opalmer_education/parent_role/SubjectsScreen/subjects_screen.dart';

class ChildsProfilesScreen extends StatelessWidget {
  const ChildsProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: Container(color: AppColors.primaryMid),
          ),
          Column(
            children: [
              // ── Wave Header ──
              Stack(
                children: [
                  const AnimatedWaveHeader(height: 140),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              if (Navigator.of(context).canPop())
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              const Text(
                                "Child's Profiles",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: AppColors.primaryMid,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 16),
              // ── Profiles List ──
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  children: [
                    _buildProfileCard(
                      context: context,
                      name: "Mia Johnson",
                      gradeAge: "Grade 6 - Age 12",
                      progress: 0.93,
                      tagText: "Excellent",
                      tagColor: const Color(0xFF4CB07D),
                      barColor: AppColors.primaryMid,
                      leftBorderColor: const Color(0xFF4CB07D),
                      imageUrl:
                          "https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?auto=format&fit=crop&w=150&q=80",
                    ),
                    const SizedBox(height: 16),
                    _buildProfileCard(
                      context: context,
                      name:
                          "Mia Johnson", // Same info as screenshot dummy repeated
                      gradeAge: "Grade 6 - Age 12",
                      progress: 0.93,
                      tagText: "Excellent",
                      tagColor: const Color(0xFF4CB07D),
                      barColor: AppColors.primaryMid,
                      leftBorderColor: const Color(0xFFF4B84F),
                      imageUrl:
                          "https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?auto=format&fit=crop&w=150&q=80",
                    ),
                    const SizedBox(height: 16),
                    _buildProfileCard(
                      context: context,
                      name: "Mia Johnson",
                      gradeAge: "Grade 6 - Age 12",
                      progress: 0.93,
                      tagText: "Excellent",
                      tagColor: const Color(0xFF4CB07D),
                      barColor: AppColors.primaryMid,
                      leftBorderColor: const Color(0xFF3892A8),
                      imageUrl:
                          "https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?auto=format&fit=crop&w=150&q=80",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'child_profiles_fab',
        onPressed: () {
          // Action for adding a new child profile
        },
        backgroundColor: AppColors.primaryMid,
        elevation: 4,
        shape: CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildProfileCard({
    required BuildContext context,
    required String name,
    required String gradeAge,
    required double progress,
    required String tagText,
    required Color tagColor,
    required Color barColor,
    required Color leftBorderColor,
    required String imageUrl,
  }) {
    return PressableCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SubjectsScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            // Colored Left Border strip
            Container(
              width: 8,
              height: 120,
              decoration: BoxDecoration(
                color: leftBorderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                gradeAge,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Top Right Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: tagColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tagText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    Row(
                      children: [
                        Text(
                          "Progress",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryMid,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryMid,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
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
