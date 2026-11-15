import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/core/widgets/support_content_screen.dart';

void main() {
  testWidgets(
    'help displays published content and refreshes instead of showing mock FAQs',
    (tester) async {
      var loads = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supportContentProvider.overrideWith((ref) async {
              loads++;
              return {
                'features': <Map<String, dynamic>>[],
                'faqs': [
                  {
                    '\u005fid': 'grade-release',
                    'question': 'When are grades visible?',
                    'answer': 'After teacher release. Revision $loads',
                  },
                ],
              };
            }),
          ],
          child: const MaterialApp(home: SupportContentScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No features have been published yet.'), findsOneWidget);
      expect(find.text('Support Randolph'), findsNothing);
      await tester.tap(find.text('When are grades visible?'));
      await tester.pumpAndSettle();
      expect(find.text('After teacher release. Revision 1'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(loads, 2);
      expect(find.text('After teacher release. Revision 2'), findsOneWidget);
    },
  );
}
