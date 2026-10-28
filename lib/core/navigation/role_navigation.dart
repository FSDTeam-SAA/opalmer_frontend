import 'package:flutter/material.dart';

final roleNavigation = RoleNavigation();

/// Keeps the existing dashboard route and returns through normal pop guards.
class RoleNavigation extends NavigatorObserver {
  final changed = ValueNotifier<int>(0);
  final List<Route<dynamic>> _routes = [];
  Object? _owner;
  Route<dynamic>? _shell;
  String? role;
  VoidCallback? _selectHome;
  bool _returning = false;

  bool get available => _shell != null && _routes.contains(_shell);
  bool get dialogOpen => _routes.isNotEmpty && _routes.last is PopupRoute;

  void _notify() => WidgetsBinding.instance.addPostFrameCallback((_) {
    changed.value++;
  });

  void attach(
    Object owner,
    Route<dynamic> route,
    String value,
    VoidCallback select,
  ) {
    _owner = owner;
    _shell = route;
    role = value;
    _selectHome = select;
    _notify();
  }

  void detach(Object owner) {
    if (_owner != owner) return;
    _owner = null;
    _shell = null;
    _selectHome = null;
    role = null;
    _notify();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute == null) _routes.clear();
    _routes.add(route);
    _notify();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    _notify();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    _notify();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = _routes.indexOf(oldRoute!);
    if (index >= 0 && newRoute != null) _routes[index] = newRoute;
    _notify();
  }

  Future<void> goHome() async {
    if (_returning || !available || dialogOpen) return;
    _returning = true;
    final shell = _shell;
    final nav = navigator!;
    try {
      if (_routes.last != shell) {
        final leave = await showDialog<bool>(
          context: nav.context,
          builder: (context) => AlertDialog(
            title: const Text('Return to Home?'),
            content: const Text(
              'Unsaved changes on open pages may be lost. Save your work before returning home.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay here'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Go Home'),
              ),
            ],
          ),
        );
        if (leave != true) return;
      }
      while (available && _shell == shell && _routes.last != shell) {
        final top = _routes.last;
        if (!await nav.maybePop()) return;
        // A PopScope may consume the pop without removing its route.
        if (_routes.last == top) return;
      }
      if (available && _shell == shell) _selectHome?.call();
    } finally {
      _returning = false;
    }
  }
}
