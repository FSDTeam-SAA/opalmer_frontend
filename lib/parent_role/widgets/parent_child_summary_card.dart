import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/data_avatar.dart';
import '../../core/widgets/pressable_card.dart';
import '../ChildsProfilesScreen/models/child_profile.dart';

/// Full-width summary card for one linked child on the parent home screen.
class ParentChildSummaryCard extends StatelessWidget {
  final ChildProfile profile;
  final VoidCallback onTap;
  const ParentChildSummaryCard({
    super.key,
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => PressableCard(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryMid.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMid.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryMid.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: DataAvatar(url: profile.imageUrl, radius: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.gradeAge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: profile.tagColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.tagText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: profile.tagColor,
                    ),
                  ),
                ),
                if (profile.hasProgress) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: profile.progress,
                          minHeight: 6,
                          color: profile.barColor,
                          backgroundColor: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Progress ${(profile.progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryMid.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_right,
              color: AppColors.primaryMid,
              size: 20,
            ),
          ),
        ],
      ),
    ),
  );
}
