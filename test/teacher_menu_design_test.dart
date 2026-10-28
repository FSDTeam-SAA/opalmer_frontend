import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/custom_bottom_navigation_bar/main_shell.dart';
import 'package:opalmer_education/core/models/student_models.dart';
import 'package:opalmer_education/core/models/teacher_class_model.dart';
import 'package:opalmer_education/core/models/user_model.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/navigation_provider.dart';
import 'package:opalmer_education/core/providers/teacher_provider.dart';
import 'package:opalmer_education/core/theme/app_theme.dart';
import 'package:opalmer_education/core/widgets/brand_logo.dart';
import 'package:opalmer_education/teacher_role/navigation/teacher_activity.dart';
import 'package:opalmer_education/teacher_role/navigation/teacher_workspace.dart';

final _class = TeacherClassModel(
  id: 'class-a',
  teacherId: 'teacher',
  grade: 6,
  subject: 'Mathematics',
  section: 'A',
  schedule: 'Mon / Wed / Fri, 9:30 AM',
);
const _previewKey = ValueKey('teacher-design-preview');

Future<void> _capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('DESIGN_PREVIEWS')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_previewKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/design-preview');
    await directory.create(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void _phone(WidgetTester tester, {double width = 390}) {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  addTearDown(tester.view.resetViewPadding);
}

Future<void> _shell(WidgetTester tester, {VoidCallback? onActivityLoad}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith(
          (ref) => UserModel(
            id: 'teacher',
            username: 'Ozzie Palmer',
            role: 'user',
            type: 'teacher',
          ),
        ),
        teacherClassesProvider.overrideWith((ref) async => [_class]),
        teacherQuizzesProvider.overrideWith(
          (ref) async => [
            QuizModel.fromJson({
              '_id': 'quiz',
              'title': 'Fractions check-in',
              'questionCount': 10,
              'time': 15,
              'status': 'published',
            }),
          ],
        ),
        classStudentsProvider('class-a').overrideWith(
          (ref) async => [
            {
              'studentId': {
                '_id': 'student',
                'username': 'Jordan',
                'Id': 'TEST-1001',
              },
            },
            {
              'studentId': {
                '_id': 'student-b',
                'username': 'Alex',
                'Id': 'TEST-1002',
              },
            },
          ],
        ),
        classDetailsAttendanceProvider(
          'class|class-a',
        ).overrideWith((ref) async => 96),
        classPerformanceProvider('class-a').overrideWith((ref) async => 84),
        teacherActivityProvider.overrideWith((ref) async {
          onActivityLoad?.call();
          return {};
        }),
      ],
      child: RepaintBoundary(
        key: _previewKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const MainShell(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final context = tester.element(find.byType(MainShell));
    await precacheImage(
      const AssetImage('assets/images/Home_dashboard_header.png'),
      context,
    );
    if (context.mounted) {
      await precacheImage(
        const AssetImage('assets/images/classes/book_icon.png'),
        context,
      );
    }
    if (context.mounted) {
      await precacheImage(
        const AssetImage('assets/images/achieverplus-logo.png'),
        context,
      );
    }
  });
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Use Flutter's cached fonts so exported previews match normal app text.
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
      for (final file in [
        'roboto-regular.ttf',
        'roboto-medium.ttf',
        'roboto-bold.ttf',
      ]) {
        loader.addFont(
          File('${fonts.path}/$file').readAsBytes().then(ByteData.sublistView),
        );
      }
      await loader.load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  testWidgets('home stays focused and header menu lazily opens activity', (
    tester,
  ) async {
    _phone(tester);
    var activityLoads = 0;
    await _shell(tester, onActivityLoad: () => activityLoads++);
    expect(find.text('Quick actions'), findsNothing);
    expect(find.text('Recent activity'), findsNothing);
    expect(find.text('Unable to load activity. Retry'), findsNothing);
    expect(activityLoads, 0);
    expect(tester.getTopLeft(find.text('Class Stats')).dy, lessThan(270));
    await _capture(tester, 'teacher-home');

    await tester.tap(find.byKey(const ValueKey('teacher-header-menu')));
    await tester.pumpAndSettle();
    expect(find.text('AchieverPlus'), findsNothing);
    expect(find.byType(BrandLogo), findsNothing);
    expect(find.byKey(const ValueKey('teacher-nav-Menu')), findsNothing);
    expect(find.text('TEACHING'), findsOneWidget);
    expect(activityLoads, 0);
    await _capture(tester, 'teacher-menu');

    await tester.enterText(
      find.byKey(const ValueKey('teacher-menu-search')),
      'activity',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('teacher-menu-Activity')));
    await tester.pumpAndSettle();
    expect(find.byType(TeacherActivityScreen), findsOneWidget);
    expect(activityLoads, 1);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(TeacherActivityScreen), findsNothing);
    expect(find.text('Class Stats'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets(
    'drawer edge swipe preserves the selected tab and search routes correctly',
    (tester) async {
      _phone(tester, width: 360);
      await _shell(tester);
      await tester.tap(find.byKey(const ValueKey('teacher-nav-Grades')));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MainShell)),
      );
      expect(container.read(teacherTabIndexProvider), 3);
      await tester.dragFrom(const Offset(0, 220), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(container.read(teacherTabIndexProvider), 3);
      await tester.enterText(
        find.byKey(const ValueKey('teacher-menu-search')),
        'attendance',
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('teacher-menu-Resources')),
        findsNothing,
      );
      await _capture(tester, 'teacher-menu-search');
      await tester.tap(find.byKey(const ValueKey('teacher-menu-Attendance')));
      await tester.pumpAndSettle();
      expect(find.text('Take and review attendance'), findsOneWidget);
      expect(find.text('Select a class'), findsWidgets);
      expect(container.read(teacherTabIndexProvider), 3);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    },
  );

  testWidgets(
    'create menu offers direct actions and opens the assignment class selector',
    (tester) async {
      _phone(tester);
      await _shell(tester);
      await tester.tap(find.byKey(const ValueKey('teacher-header-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create new'));
      await tester.pumpAndSettle();
      expect(find.text('New assignment'), findsOneWidget);
      expect(find.text('Take attendance'), findsOneWidget);
      await _capture(tester, 'teacher-menu-create');
      await tester.tap(find.text('New assignment'));
      await tester.pumpAndSettle();
      expect(find.text('Choose the class for this assignment'), findsOneWidget);
      final picker = tester
          .widgetList<TeacherClassPicker>(find.byType(TeacherClassPicker))
          .where((page) => page.feature == TeacherFeature.newAssignment);
      expect(picker, hasLength(1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    },
  );
}
