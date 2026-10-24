import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.people_outline_rounded, Icons.people_rounded, 'Classes'),
    (Icons.assignment_outlined, Icons.assignment_rounded, 'Assignments'),
    (Icons.fact_check_outlined, Icons.fact_check_rounded, 'Grades'),
  ];

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      border: const Border(top: BorderSide(color: Color(0xFFEDE9F0))),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2E183E).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: List.generate(_items.length, (index) {
            final selected = currentIndex == index;
            final item = _items[index];
            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                label: item.$3,
                excludeSemantics: true,
                child: Tooltip(
                  message: item.$3,
                  child: InkWell(
                    key: ValueKey('teacher-nav-${item.$3}'),
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 46,
                            height: 30,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryVeryLight
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              selected ? item.$2 : item.$1,
                              size: 21,
                              color: selected
                                  ? AppColors.primaryMid
                                  : const Color(0xFF92909B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.$3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? AppColors.primaryMid
                                  : const Color(0xFF92909B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}
