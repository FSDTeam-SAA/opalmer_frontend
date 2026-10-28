import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/core/models/user_model.dart';
import 'package:opalmer_education/core/navigation/role_menu.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/navigation_provider.dart';
import 'package:opalmer_education/core/providers/role_provider.dart';
import 'package:opalmer_education/core/services/auth_service.dart';
import 'package:opalmer_education/teacher_role/navigation/teacher_menu.dart';
import 'package:opalmer_education/user_role_screen/user_role_screen.dart';

class LogoutAuth extends AuthService {
  int calls = 0;
  @override
  Future<void> logout() async {
    calls++;
  }
}

void main() {
  for (final role in ['parent', 'student', 'teacher']) {
    testWidgets('$role drawer logout signs out and removes dashboard history', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = LogoutAuth();
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWith((ref) => service),
            authStateProvider.overrideWith(
              (ref) => UserModel(
                id: 'user',
                username: 'Test',
                role: 'user',
                type: role,
              ),
            ),
            studentTabIndexProvider.overrideWith((ref) => 4),
            teacherTabIndexProvider.overrideWith((ref) => 3),
          ],
          child: MaterialApp(
            navigatorKey: key,
            home: Scaffold(
              body: role == 'teacher'
                  ? TeacherMenuScreen(inDrawer: true, onClose: () {})
                  : RoleMenuDrawer(
                      role: role,
                      currentTab: 0,
                      onClose: () {},
                      onSelectTab: (_) {},
                      onOpenPage: (_) {},
                    ),
            ),
          ),
        ),
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      container.read(roleProvider.notifier).setRoleFromString(role);
      await tester.pumpAndSettle();
      expect(find.text('Logout'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('drawer-logout')));
      await tester.pumpAndSettle();
      expect(service.calls, 1);
      expect(container.read(authStateProvider), isNull);
      expect(container.read(roleProvider), UserRole.guest);
      expect(container.read(studentTabIndexProvider), 0);
      expect(container.read(teacherTabIndexProvider), 0);
      expect(find.byType(UserRoleScreen), findsOneWidget);
      expect(key.currentState!.canPop(), isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
