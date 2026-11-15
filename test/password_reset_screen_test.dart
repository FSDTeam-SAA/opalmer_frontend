import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/Authentication_Screen/password_reset_screen.dart';
import 'package:opalmer_education/core/services/api_client.dart';

class ResetApi implements ApiClient {
  bool rejectCode = true;
  String? identifier;
  int resets = 0;
  @override Future<Response> post(String path, {dynamic data, Options? options}) async {
    identifier = data['Id'];
    if (path.endsWith('/reset-password')) {
      resets++;
      if (rejectCode) throw DioException(requestOptions: RequestOptions(path: path), response: Response(requestOptions: RequestOptions(path: path), statusCode: 400, data: {'message':'Invalid or expired reset code'}));
    }
    return Response(requestOptions: RequestOptions(path: path), statusCode: 200, data: {'success':true});
  }
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
void main() {
  testWidgets('reset validates confirmation, retains fields after a rejected code and returns to sign in after success', (tester) async {
    final api = ResetApi(); String? returned;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => Scaffold(body: TextButton(onPressed: () async {returned = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => PasswordResetScreen(initialIdentifier:'qa-otp',apiClient:api)));}, child: const Text('Open reset'))))));
    await tester.tap(find.text('Open reset'));await tester.pumpAndSettle();
    await tester.tap(find.text('Send reset code'));await tester.pumpAndSettle();
    expect(api.identifier,'qa-otp');
    await tester.enterText(find.byType(TextFormField).at(1),'12345678');
    await tester.enterText(find.byType(TextFormField).at(2),'ExampleNewPass1511!');
    await tester.enterText(find.byType(TextFormField).at(3),'different');
    await tester.scrollUntilVisible(find.widgetWithText(FilledButton,'Reset password'),150, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.widgetWithText(FilledButton,'Reset password'));await tester.pumpAndSettle();
    expect(find.text('Passwords do not match.'),findsOneWidget);expect(api.resets,0);
    await tester.enterText(find.byType(TextFormField).at(3),'ExampleNewPass1511!');
    await tester.ensureVisible(find.widgetWithText(FilledButton,'Reset password'));await tester.tap(find.widgetWithText(FilledButton,'Reset password'));await tester.pumpAndSettle();
    expect(find.text('Invalid or expired reset code'),findsOneWidget);expect(find.text('12345678'),findsOneWidget);
    api.rejectCode=false;
    await tester.ensureVisible(find.widgetWithText(FilledButton,'Reset password'));await tester.tap(find.widgetWithText(FilledButton,'Reset password'));await tester.pumpAndSettle();
    expect(returned,'qa-otp');expect(find.text('Open reset'),findsOneWidget);expect(api.resets,2);
  });
}
