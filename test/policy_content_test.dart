import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:opalmer_education/core/services/policy_content_service.dart';
import 'package:opalmer_education/core/widgets/policy_content_screen.dart';
import 'package:opalmer_education/core/widgets/brand_logo.dart';

void main() {
  test(
    'Historical plain text is escaped while published HTML is preserved',
    () {
      expect(
        PolicyContentDocument.fromJson({
          'description': 'First & second\nNext',
        }).html,
        '<p>First &amp; second<br>Next</p>',
      );
      expect(
        PolicyContentDocument.fromJson({
          'description': '<h2>Mission</h2><p><strong>Learn</strong></p>',
        }).html,
        '<h2>Mission</h2><p><strong>Learn</strong></p>',
      );
    },
  );
  testWidgets(
    'Published HTML appears on the app page and refresh loads updates',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            policyContentProvider(PolicyContentType.about).overrideWith((
              ref,
            ) async {
              calls++;
              return PolicyContentDocument(
                html:
                    '<h2>Our mission $calls</h2><p><strong>Learning together</strong></p><ul><li>Students</li></ul>',
              );
            }),
          ],
          child: const MaterialApp(
            home: PolicyContentScreen(type: PolicyContentType.about),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HtmlWidget), findsOneWidget);
      expect(find.text('Our mission 1', findRichText: true), findsOneWidget);
      await tester.tap(find.byTooltip('Refresh'));
      await tester.pumpAndSettle();
      expect(find.text('Our mission 2', findRichText: true), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Missing content and network failures have distinct states', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          policyContentProvider(
            PolicyContentType.terms,
          ).overrideWith((ref) async => null),
        ],
        child: const MaterialApp(
          home: PolicyContentScreen(type: PolicyContentType.terms),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Content has not been published yet.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          policyContentProvider(
            PolicyContentType.terms,
          ).overrideWith((ref) async => throw Exception('Offline')),
        ],
        child: const MaterialApp(
          home: PolicyContentScreen(type: PolicyContentType.terms),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
  });
  testWidgets('Brand logo fits a narrow screen without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 180, child: BrandLogo(size: 220)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(Image)).width, lessThanOrEqualTo(180));
    expect(tester.takeException(), isNull);
  });
}
