import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/navigation/app_navigator.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/notification_provider.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'notification.dart';

/// Keeps the notification stream alive for the whole signed-in session.
///
/// Without this the notification provider (and its socket) was only created
/// when the Notification screen opened, so new notifications never reached the
/// bell badge and nothing told the user something arrived.
class AppNotificationListener extends ConsumerStatefulWidget {
  final Widget child;
  const AppNotificationListener({super.key, required this.child});

  @override
  ConsumerState<AppNotificationListener> createState() =>
      _AppNotificationListenerState();
}

class _AppNotificationListenerState
    extends ConsumerState<AppNotificationListener>
    with WidgetsBindingObserver {
  String? _loadedFor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Catch anything that arrived while the app was in the background.
    if (state == AppLifecycleState.resumed && _loadedFor != null) {
      ref.read(notificationsProvider.notifier).load(silent: true);
    }
  }

  void _loadFor(String? userId) {
    if (userId == null || userId.isEmpty) {
      _loadedFor = null;
      return;
    }
    if (_loadedFor == userId) return;
    _loadedFor = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(notificationsProvider.notifier).load(silent: true);
    });
  }

  void _showToast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryMid,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () => appNavigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    if (user != null) {
      // Creating the provider connects the notification socket.
      ref.watch(notificationsProvider);
      _loadFor(user.id);
    } else {
      _loadFor(null);
    }

    ref.listen<NotificationState>(notificationsProvider, (previous, next) {
      if (previous == null || previous.loading || next.items.isEmpty) return;
      final newest = next.items.first;
      final isNew =
          !newest.isViewed && previous.items.every((n) => n.id != newest.id);
      // A full reload replaces the list; only a pushed item lands at the top
      // while the previous list was already populated.
      if (isNew && next.items.length == previous.items.length + 1) {
        _showToast(newest.message);
      }
    });

    return widget.child;
  }
}
