import 'package:flutter/material.dart';
import '../navigation/role_navigation.dart';

/// Marks tab content so a previous authentication route is never a tab's back target.
class AppShellRoot extends StatefulWidget {
  final Widget child;
  final String role;
  final VoidCallback onHome;
  const AppShellRoot({
    super.key,
    required this.child,
    required this.role,
    required this.onHome,
  });
  @override
  State<AppShellRoot> createState() => _AppShellRootState();
}

class _AppShellRootState extends State<AppShellRoot> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    roleNavigation.attach(
      this,
      ModalRoute.of(context)!,
      widget.role,
      widget.onHome,
    );
  }

  @override
  void dispose() {
    roleNavigation.detach(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ShellContent(child: widget.child);
}

class _ShellContent extends InheritedWidget {
  const _ShellContent({required super.child});
  @override
  bool updateShouldNotify(_ShellContent oldWidget) => false;
}

/// Shows back navigation for pushed pages and respects each route's PopScope.
class AppBackButton extends StatelessWidget {
  final Color color;
  const AppBackButton({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    if (context.dependOnInheritedWidgetOfExactType<_ShellContent>() != null ||
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
