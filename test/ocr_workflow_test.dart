import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/scan_document.dart';
import 'package:opalmer_education/teacher_role/Classes_Screen/ocr_result_screen.dart';

void main() {
  for (final denied in [false, true]) {
    testWidgets(
      'camera ${denied ? 'access failure' : 'absence'} keeps gallery available and allows retry',
      (tester) async {
        var loads = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: ScanDocumentScreen(
              loadCameras: () async {
                loads++;
                  if (denied) {
                    throw CameraException('CameraAccessDenied', 'Test denial');
                  }
                return [];
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining(
            denied ? 'Camera access is unavailable' : 'No camera available',
          ),
          findsOneWidget,
        );
        expect(
          tester.widget<IconButton>(find.byWidgetPredicate((w) => w is IconButton && w.tooltip == 'Switch camera')).onPressed,
          isNull,
        );
        expect(
          tester
              .widget<IconButton>(find.byWidgetPredicate((w) => w is IconButton && w.tooltip == 'Capture document'))
              .onPressed,
          isNull,
        );
        expect(
          tester.widget<IconButton>(find.byWidgetPredicate((w) => w is IconButton && w.tooltip == 'Choose image')).onPressed,
          isNotNull,
        );
        expect(find.byType(CircularProgressIndicator), findsNothing);
        await tester.tap(find.text('Retry camera'));
        await tester.pumpAndSettle();
        expect(loads, 2);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('late camera loading is ignored after closing the scanner', (
    tester,
  ) async {
    final pending = Completer<List<CameraDescription>>();
    await tester.pumpWidget(
      MaterialApp(home: ScanDocumentScreen(loadCameras: () => pending.future)),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete([]);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'finishing a scan copies edited text and returns it to the caller',
    (tester) async {
      String? copied, returned;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = call.arguments['text'] as String;
            }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  returned = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OCRResultScreen(
                        imagePath: 'missing-qa-scan.png',
                        text: 'Original fractions text',
                      ),
                    ),
                  );
                },
                child: const Text('Open scan'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open scan'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit recognized text'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(TextFormField));
      await tester.enterText(
        find.byType(TextFormField),
        'Reviewed: 1/2 = 2/4.',
      );
      await tester.tap(find.text('COPY TEXT & FINISH'));
      await tester.pumpAndSettle();
      expect(copied, 'Reviewed: 1/2 = 2/4.');
      expect(returned, copied);
      expect(find.text('Open scan'), findsOneWidget);
    },
  );
}
