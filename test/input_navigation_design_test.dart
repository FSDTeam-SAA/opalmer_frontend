import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/chat/screens/chat_dashboard.dart';
import 'package:opalmer_education/chat/widgets/chat_dashboard_header.dart';
import 'package:opalmer_education/chat/widgets/send_to_search_bar.dart';
import 'package:opalmer_education/core/models/teacher_class_model.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/grading_provider.dart';
import 'package:opalmer_education/core/providers/teacher_provider.dart';
import 'package:opalmer_education/core/theme/app_theme.dart';
import 'package:opalmer_education/core/widgets/app_back_button.dart';
import 'package:opalmer_education/core/widgets/app_dropdown_field.dart';
import 'package:opalmer_education/teacher_role/Quiz_Screen/create_quiz.dart';
import 'package:opalmer_education/teacher_role/Quiz_Screen/grading_tool.dart';

const _previewKey = ValueKey('input-navigation-preview');
final _classes = [
  TeacherClassModel(
    id: 'math',
    teacherId: 'teacher',
    grade: 6,
    subject: 'Mathematics',
    section: 'A',
  ),
  TeacherClassModel(
    id: 'science',
    teacherId: 'teacher',
    grade: 7,
    subject: 'Environmental Science and Technology',
    section: 'SECOND PERIOD',
  ),
];

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

Future<void> _capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('DESIGN_PREVIEWS')) return;
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_previewKey),
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

Future<void> _open(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => null),
        teacherClassesProvider.overrideWith((ref) async => _classes),
        teacherSessionsProvider(null).overrideWith((ref) async => []),
      ],
      child: RepaintBoundary(
        key: _previewKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute<void>(builder: (_) => page)),
                  child: const Text('Open page'),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open page'));
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    for (final path in [
      'assets/images/Home_dashboard_header.png',
      'assets/images/home_dashboard/call_icons.png',
      'assets/images/home_dashboard/notification.png',
    ]) {
      await precacheImage(
        AssetImage(path),
        tester.element(find.byType(Scaffold).last),
      );
    }
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
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

  testWidgets(
    'quiz dropdown fits a narrow phone, selects a class and preserves validation',
    (tester) async {
      _phone(tester, width: 320);
      await _open(tester, const CreateQuizScreen());
      await tester.tap(find.text('DRAFT'));
      await tester.pumpAndSettle();
      expect(find.text('Please select a class'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppDropdownField<String>));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _capture(tester, 'quiz-class-menu');
      await tester.tap(
        find
            .text(
              'Environmental Science and Technology · Grade 7 · SECOND PERIOD',
            )
            .last,
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DropdownButtonFormField<String>>(
              find.byType(DropdownButtonFormField<String>),
            )
            .initialValue,
        'science',
      );
      await tester.tap(find.text('DRAFT'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a quiz title'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).at(0),
        'Fractions practice',
      );
      await tester.enterText(find.byType(TextField).at(1), '15');
      await tester.enterText(
        find.byType(TextField).at(2),
        'Create five fraction questions.',
      );
      await tester.tap(find.text('DRAFT'));
      await tester.pumpAndSettle();
      expect(find.text('No questions generated'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('quiz form has a readable selected class and safe footer', (
    tester,
  ) async {
    _phone(tester);
    await _open(tester, const CreateQuizScreen());
    await tester.tap(find.byType(AppDropdownField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mathematics · Grade 6 · A').last);
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(find.text('PUBLISH')).dy, lessThan(820));
    await _capture(tester, 'create-quiz');
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(find.text('PUBLISH')).dy, lessThan(544));
    expect(tester.takeException(), isNull);
  });

  for (final entry in <String, Widget>{
    'chat': const ChatDashboard(),
    'grading': const GradingToolScreen(),
  }.entries) {
    testWidgets('${entry.key} header returns to the previous page', (
      tester,
    ) async {
      _phone(tester);
      await _open(tester, entry.value);
      expect(find.byTooltip('Back'), findsOneWidget);
      await _capture(tester, '${entry.key}-back');
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open page'), findsOneWidget);
      expect(find.byType(entry.value.runtimeType), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tab root does not offer a back route into authentication', (
    tester,
  ) async {
    _phone(tester);
    await _open(
      tester,
      AppShellRoot(
        child: Scaffold(
          body: ChatDashboardHeader(
            onOpenCallHistory: () {},
            onOpenNotifications: () {},
          ),
        ),
      ),
    );
    expect(find.byTooltip('Back'), findsNothing);
  });

  testWidgets('shared back control respects an unsaved form pop guard', (
    tester,
  ) async {
    _phone(tester);
    var guardedPop = false;
    await _open(
      tester,
      PopScope<void>(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => guardedPop = !didPop,
        child: const Scaffold(body: AppBackButton(color: Colors.purple)),
      ),
    );
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(guardedPop, isTrue);
    expect(find.byTooltip('Back'), findsOneWidget);
  });

  testWidgets('contact search keeps one field surface and forwards typing', (
    tester,
  ) async {
    _phone(tester);
    var query = '';
    await _open(
      tester,
      Scaffold(
        appBar: AppBar(title: const Text('Send To')),
        body: SendToSearchBar(onChanged: (value) => query = value),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Jordan');
    expect(query, 'Jordan');
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    await _capture(tester, 'contact-search');
    expect(tester.takeException(), isNull);
  });
}
