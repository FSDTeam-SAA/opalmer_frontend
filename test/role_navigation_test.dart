import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/core/models/user_model.dart';
import 'package:opalmer_education/core/navigation/role_navigation.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/widgets/app_back_button.dart';
import 'package:opalmer_education/core/theme/app_theme.dart';
import 'package:opalmer_education/core/widgets/app_home_button.dart';
import 'package:opalmer_education/core/navigation/role_menu.dart';
import 'package:opalmer_education/teacher_role/navigation/teacher_menu.dart';
import 'package:opalmer_education/teacher_role/navigation/teacher_workspace.dart';
import 'package:opalmer_education/core/models/teacher_class_model.dart';
import 'package:opalmer_education/core/providers/teacher_provider.dart';
import 'package:opalmer_education/custom_bottom_navigation_bar/custom_bottom_navigation_bar.dart';
import 'package:opalmer_education/core/widgets/dashboard_header.dart';

const captureKey = ValueKey('role-navigation-capture');

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('DESIGN_PREVIEWS')) return;
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(captureKey),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/design-preview').create(recursive: true);
    await File(
      'build/design-preview/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> openShell(
  WidgetTester tester,
  String role,
  VoidCallback onHome, {
  bool guarded = false,
}) async {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  void closeMenu() => scaffoldKey.currentState?.closeDrawer();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith(
          (ref) =>
              UserModel(id: 'user', username: 'Test', role: 'user', type: role),
        ),
      ],
      child: RepaintBoundary(
        key: captureKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          navigatorObservers: [roleNavigation],
          home: AppShellRoot(
            role: role,
            onHome: onHome,
            child: Builder(
              builder: (context) => Scaffold(
                key: scaffoldKey,
                drawer: role == 'teacher'
                    ? Drawer(
                        child: TeacherMenuScreen(
                          inDrawer: true,
                          onClose: closeMenu,
                          onOpenPage: (page) {
                            closeMenu();
                            Navigator.of(
                              context,
                            ).push(MaterialPageRoute(builder: (_) => page));
                          },
                        ),
                      )
                    : RoleMenuDrawer(
                        role: role,
                        currentTab: 0,
                        onClose: closeMenu,
                        onSelectTab: (_) => closeMenu(),
                        onOpenPage: (page) {
                          closeMenu();
                          Navigator.of(
                            context,
                          ).push(MaterialPageRoute(builder: (_) => page));
                        },
                      ),
                appBar: AppBar(
                  title: const Text('Dashboard'),
                  actions: [
                    IconButton(
                      tooltip: 'Open menu',
                      onPressed: () => scaffoldKey.currentState?.openDrawer(),
                      icon: const Icon(Icons.menu),
                    ),
                  ],
                  automaticallyImplyLeading: false,
                ),
                body: Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => PopScope<void>(
                          canPop: !guarded,
                          child: Scaffold(
                            appBar: AppBar(
                              title: const Text('Details'),
                              actions: const [AppHomeButton()],
                            ),
                            body: Center(
                              child: TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => Scaffold(
                                      appBar: AppBar(
                                        actions: const [AppHomeButton()],
                                      ),
                                      body: const Center(
                                        child: Text('Nested page'),
                                      ),
                                    ),
                                  ),
                                ),
                                child: const Text('Open nested page'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    child: Text('$role dashboard'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (!const bool.fromEnvironment('DESIGN_PREVIEWS')) return;
    var directory = File(Platform.resolvedExecutable).parent;
    Directory? fonts;
    while (directory.parent.path != directory.path) {
      final candidate = Directory(
        '${directory.path}/bin/cache/artifacts/material_fonts',
      );
      if (candidate.existsSync()) {
        fonts = candidate;
        break;
      }
      directory = directory.parent;
    }
    if (fonts == null) throw StateError('Flutter material fonts not found');
    for (final family in ['SF Pro Display', 'Roboto']) {
      final loader = FontLoader(family);
      for (final name in [
        'roboto-regular.ttf',
        'roboto-medium.ttf',
        'roboto-bold.ttf',
      ]) {
        loader.addFont(
          File('${fonts.path}/$name').readAsBytes().then(ByteData.sublistView),
        );
      }
      await loader.load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final role in ['parent', 'student', 'teacher']) {
    testWidgets(
      '$role returns through nested routes, confirms cancellation and selects its existing Home tab',
      (tester) async {
        var selected = 0;
        await openShell(tester, role, () => selected++);
        await tester.tap(find.text('$role dashboard'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open nested page'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Home'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Stay here'));
        await tester.pumpAndSettle();
        expect(find.text('Nested page'), findsOneWidget);
        expect(selected, 0);
        await tester.tap(find.byTooltip('Home'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Go Home'));
        await tester.pumpAndSettle();
        expect(find.text('$role dashboard'), findsOneWidget);
        expect(selected, 1);
        expect(find.byTooltip('Home'), findsNothing);
        expect(find.text('Return to Home?'), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        expect(roleNavigation.available, false);
      },
    );

    testWidgets(
      '$role guide is available on a narrow phone without navigation overflow',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await openShell(tester, role, () {});
        expect(find.text('How to use'), findsNothing);
        expect(find.byTooltip('Home'), findsNothing);
        await tester.tap(find.byTooltip('Open menu'));
        await tester.pumpAndSettle();
        expect(find.text('AchieverPlus'), findsNothing);
        expect(find.text('Test'), findsOneWidget);
        expect(find.text('${role[0].toUpperCase()}${role.substring(1)} workspace'), findsNothing);
        await capture(tester, '$role-sidebar');
        await tester.enterText(find.byType(TextField), 'How to use');
        await tester.pumpAndSettle();
        await tester.tap(find.text('How to use').last);
        await tester.pumpAndSettle();
        expect(
          find.text('${role[0].toUpperCase()}${role.substring(1)} guide'),
          findsOneWidget,
        );
        expect(find.text('Sign in'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (const bool.fromEnvironment('DESIGN_PREVIEWS')) {
          await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(captureKey),
            );
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await Directory('build/design-preview').create(recursive: true);
            await File(
              'build/design-preview/$role-access-guide.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }

  testWidgets('Home respects an active assessment or form PopScope', (
    tester,
  ) async {
    var selected = false;
    await openShell(tester, 'student', () => selected = true, guarded: true);
    await tester.tap(find.text('student dashboard'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go Home'));
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsOneWidget);
    expect(selected, false);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  test(
    'parent and student sidebars include their features with valid destinations',
    () {
      for (final role in ['parent', 'student']) {
        final items = roleMenuItems(role);
        expect(items.map((item) => item.label).toSet().length, items.length);
        for (final label in [
          'Home',
          'Attendance',
          'Lessons',
          'Academic Documents',
          'Messages',
          'Notifications',
          'How to use',
          'Profile & settings',
        ]) {
          expect(
            items.any((item) => item.label == label),
            isTrue,
            reason: '$role: $label',
          );
        }
        for (final item in items) {
          expect((item.tab != null) != (item.page != null), isTrue);
          if (item.page != null) expect(item.page!(), isA<Widget>());
        }
      }
      expect(
        roleMenuItems('parent').any((item) => item.label == 'My Students'),
        isTrue,
      );
      expect(
        roleMenuItems('student').any((item) => item.label == 'My Students'),
        isFalse,
      );
      expect(
        roleMenuItems('student').any((item) => item.label == 'Quizzes'),
        isTrue,
      );
    },
  );

  testWidgets(
    'Grades has one Home action in its top right and no extra bottom bar',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var selected = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => UserModel(
                id: 'teacher',
                username: 'Teacher',
                role: 'user',
                type: 'teacher',
              ),
            ),
            teacherClassesProvider.overrideWith(
              (ref) async => [
                TeacherClassModel(
                  id: 'math',
                  teacherId: 'teacher',
                  grade: 6,
                  subject: 'Math',
                  section: 'A',
                ),
              ],
            ),
          ],
          child: RepaintBoundary(
            key: captureKey,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              navigatorObservers: [roleNavigation],
              home: Scaffold(
                body: AppShellRoot(
                  role: 'teacher',
                  onHome: () => selected = true,
                  child: const TeacherClassPicker(
                    feature: TeacherFeature.grades,
                    embedded: true,
                  ),
                ),
                bottomNavigationBar: CustomBottomNavigationBar(
                  currentIndex: 3,
                  onTap: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppHomeButton), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('How to use'), findsNothing);
      expect(tester.getTopLeft(find.byType(AppHomeButton)).dy, lessThan(100));
      expect(
        tester.getTopLeft(find.byType(AppHomeButton)).dx,
        greaterThan(280),
      );
      await capture(tester, 'grades-header-home');
      await tester.tap(find.byType(AppHomeButton));
      await tester.pumpAndSettle();
      expect(selected, isTrue);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
  for (final role in ['Parent', 'Student', 'Teacher']) {
    testWidgets(
      '$role dashboard header has matched controls and a full width greeting',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var menuTaps = 0, notificationTaps = 0;
        await tester.pumpWidget(
          RepaintBoundary(
            key: captureKey,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Column(
                  children: [
                    DashboardHeader(
                      name: 'Sozib Hossain',
                      workspace: '$role workspace',
                      subtitle: role == 'Parent'
                          ? "Stay connected with your child's learning."
                          : 'Ready for a productive day?',
                      onOpenMenu: () => menuTaps++,
                      onNotifications: () => notificationTaps++,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Your dashboard'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byTooltip('Open menu')),
          tester.getSize(find.byTooltip('Notifications')),
        );
        expect(
          tester.getTopLeft(find.text('Hi, Sozib Hossain')).dy,
          greaterThan(tester.getBottomLeft(find.byTooltip('Open menu')).dy),
        );
        await tester.tap(find.byTooltip('Open menu'));
        await tester.tap(find.byTooltip('Notifications'));
        expect(menuTaps, 1);
        expect(notificationTaps, 1);
        await tester.pumpAndSettle();
        await capture(tester, '${role.toLowerCase()}-dashboard-header');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
