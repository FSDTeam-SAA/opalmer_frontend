import 'package:flutter/material.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:opalmer_education/core/widgets/animated_wave_header.dart';
import 'package:opalmer_education/core/widgets/pressable_card.dart';
import 'package:opalmer_education/notification/notification.dart';
import 'package:opalmer_education/parent_role/ChildsProfilesScreen/add_child.dart';
import 'package:opalmer_education/parent_role/SubjectsScreen/subjects_screen.dart';
import 'package:opalmer_education/parent_role/ChildsProfilesScreen/models/child_profile.dart';

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
                              child: Image.asset(
                                'assets/images/home_dashboard/notification.png',
                                height: 24,
                                width: 24,
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
                  children: mockChildProfiles.map((profile) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildProfileCard(
                        context: context,
                        profile: profile,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'child_profiles_fab',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddChildDialog(),
          );
        },
        backgroundColor: AppColors.primaryMid,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildProfileCard({
    required BuildContext context,
    required ChildProfile profile,
  }) {
    return PressableCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SubjectsScreen()),
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
                color: profile.leftBorderColor,
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
              backgroundImage: NetworkImage(profile.imageUrl),
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
                                profile.name,
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
                                profile.gradeAge,
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
                            color: profile.tagColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            profile.tagText,
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
                          "${(profile.progress * 100).toInt()}%",
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
                      value: profile.progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        profile.barColor,
                      ),
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
