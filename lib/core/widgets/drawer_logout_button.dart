import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/role_provider.dart';
import '../../user_role_screen/user_role_screen.dart';

class DrawerLogoutButton extends ConsumerStatefulWidget {
  const DrawerLogoutButton({super.key});

  @override
  ConsumerState<DrawerLogoutButton> createState() => _DrawerLogoutButtonState();
}

class _DrawerLogoutButtonState extends ConsumerState<DrawerLogoutButton> {
  bool _busy = false;

  Future<void> _logout() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(authServiceProvider);
    final auth = ref.read(authStateProvider.notifier);
    final role = ref.read(roleProvider.notifier);
    final studentTab = ref.read(studentTabIndexProvider.notifier);
    final teacherTab = ref.read(teacherTabIndexProvider.notifier);
    setState(() => _busy = true);
    try {
      await service.logout();
      auth.state = null;
      role.setRole(UserRole.guest);
      studentTab.state = 0;
      teacherTab.state = 0;
      if (!navigator.mounted) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const UserRoleScreen()),
        (_) => false,
      );
    } catch (_) {
      if (messenger.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Unable to log out. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 8),
        ListTile(
          key: const ValueKey('drawer-logout'),
          enabled: !_busy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFD34848),
                  size: 21,
                ),
          title: Text(
            _busy ? 'Logging out...' : 'Logout',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD34848),
            ),
          ),
          onTap: _busy ? null : _logout,
        ),
      ],
    ),
  );
}
