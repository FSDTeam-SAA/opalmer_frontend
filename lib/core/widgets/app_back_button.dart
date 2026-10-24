import 'package:flutter/material.dart';

/// Marks tab content so a previous authentication route is never a tab's back target.
class AppShellRoot extends InheritedWidget {
  const AppShellRoot({super.key, required super.child});

  @override
  bool updateShouldNotify(AppShellRoot oldWidget) => false;
}

/// Shows back navigation for pushed pages and respects each route's PopScope.
class AppBackButton extends StatelessWidget {
  final Color color;
  const AppBackButton({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    if (context.dependOnInheritedWidgetOfExactType<AppShellRoot>() != null ||
        !Navigator.of(context).canPop()) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: Icon(Icons.arrow_back_rounded, color: color, size: 24),
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.all(10),
          backgroundColor: color == Colors.white
              ? Colors.white.withValues(alpha: 0.12)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
