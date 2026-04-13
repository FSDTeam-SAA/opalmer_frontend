import 'package:flutter/material.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';

class ChildProfile {
  final String name;
  final String gradeAge;
  final double progress;
  final String tagText;
  final Color tagColor;
  final Color barColor;
  final Color leftBorderColor;
  final String imageUrl;

  const ChildProfile({
    required this.name,
    required this.gradeAge,
    required this.progress,
    required this.tagText,
    required this.tagColor,
    required this.barColor,
    required this.leftBorderColor,
    required this.imageUrl,
  });
}

// Dummy data to use across screens
final List<ChildProfile> mockChildProfiles = [
  ChildProfile(
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
  ChildProfile(
    name: "Alex Johnson",
    gradeAge: "Grade 4 - Age 10",
    progress: 0.85,
    tagText: "Good",
    tagColor: const Color(0xFFF4B84F),
    barColor: AppColors.primaryMid,
    leftBorderColor: const Color(0xFFF4B84F),
    imageUrl:
        "https://images.unsplash.com/photo-1503919545889-aef636e10ad4?auto=format&fit=crop&w=150&q=80",
  ),
  ChildProfile(
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
];
