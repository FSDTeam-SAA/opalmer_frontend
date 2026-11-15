import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:opalmer_education/parent_role/ChildsProfilesScreen/models/child_profile.dart';
import 'package:opalmer_education/parent_role/widgets/parent_child_summary_card.dart';

void main() {
  testWidgets('pending child card fits long names and larger text without loading an empty avatar URL', (tester) async {
    final profile = ChildProfile.fromJson({'username': 'An example student with a long name', 'gradeLevel': 4, 'age': 11, 'progress': null});
    await tester.pumpWidget(MaterialApp(home: MediaQuery(data: const MediaQueryData(textScaler: TextScaler.linear(1.5)), child: Scaffold(body: Center(child: SizedBox(height: 192, width: 290, child: ParentChildSummaryCard(profile: profile, onTap: () {})))))));
    expect(find.text('Awaiting grades'), findsOneWidget);
    expect(find.textContaining('0%'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  test('missing parent-facing grades are pending, while a published zero remains a real score', () {
    final pending = ChildProfile.fromJson({'username': 'Example', 'progress': null});
    expect(pending.hasProgress, false);
    expect(pending.tagText, 'Awaiting grades');
    final zero = ChildProfile.fromJson({'username': 'Example', 'progress': 0, 'tagText': 'Needs Work'});
    expect(zero.hasProgress, true);
    expect(zero.progress, 0);
    expect(zero.tagText, 'Needs Work');
  });
}
