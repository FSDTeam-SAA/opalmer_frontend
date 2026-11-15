import 'package:flutter/material.dart';
import '../../core/widgets/data_avatar.dart';
import '../../core/widgets/pressable_card.dart';
import '../ChildsProfilesScreen/models/child_profile.dart';

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
      width: 290,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          DataAvatar(url: profile.imageUrl, radius: 24),
          const SizedBox(width: 12),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  profile.gradeAge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.tagText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: profile.tagColor),
                ),
                if (profile.hasProgress) ...[
                  Text(
                    'Progress ${(profile.progress * 100).round()}%',
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: profile.progress,
                    color: profile.barColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black45, size: 18),
        ],
      ),
    ),
  );
}
