import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opalmer_education/core/models/user_model.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/providers/teacher_provider.dart';
import 'package:opalmer_education/core/services/api_client.dart';
import 'package:opalmer_education/core/widgets/notification_preferences_screen.dart';

class PreferenceApi implements ApiClient {
  Map<String, bool> saved = {};
  String? savedPath;
  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async => Response(
    requestOptions: RequestOptions(path: path),
    data: {
      'data': {'notificationPreferences': saved},
    },
  );
  @override
  Future<Response> put(String path, {dynamic data}) async {
    savedPath = path;
    saved = Map<String, bool>.from(data['notificationPreferences']);
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'notification choices save to the signed-in account and reload from the server',
    (tester) async {
      final api = PreferenceApi();
      Widget screen() => ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          authStateProvider.overrideWith(
            (ref) => UserModel(
              id: 'parent-1',
              username: 'Parent',
              role: 'user',
              type: 'parent',
            ),
          ),
        ],
        child: const MaterialApp(home: NotificationPreferencesScreen()),
      );
      await tester.pumpWidget(screen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();
      expect(api.saved, isEmpty);
    await tester.scrollUntilVisible(find.text('Save preferences'), 300);
      await tester.tap(find.text('Save preferences'));
      await tester.pumpAndSettle();
      expect(api.savedPath, '/users/parent-1');
      expect(api.saved['message'], false);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(screen());
      await tester.pumpAndSettle();
      final tile = find.ancestor(
        of: find.text('Messages'),
        matching: find.byType(SwitchListTile),
      );
      final toggle = find.descendant(of: tile, matching: find.byType(Switch));
      expect(tester.widget<Switch>(toggle).value, false);
      expect(tester.takeException(), isNull);
    },
  );
}
