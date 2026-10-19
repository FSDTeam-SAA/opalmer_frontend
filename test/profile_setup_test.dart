import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opalmer_education/core/models/user_model.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/services/auth_service.dart';
import 'package:opalmer_education/core/theme/app_theme.dart';
import 'package:opalmer_education/teacher_role/profile_screen/profile_setup.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);
final _user = UserModel(
  id: 'teacher-id',
  username: 'Alex Teacher',
  role: 'user',
  type: 'teacher',
  gradeLevel: '6',
  locationState: 'Texas',
);

class _Picker extends ImagePicker {
  _Picker(this.result);
  final XFile? result;
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async => result;
}

class _Auth extends AuthService {
  Map<String, dynamic>? saved;
  Uint8List? photo;
  bool fail = true;
  @override
  Future<UserModel> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
    Uint8List? avatarBytes,
    String? avatarFilename,
  }) async {
    saved = updates;
    photo = avatarBytes;
    if (fail) throw Exception('Offline');
    return _user;
  }
}

Future<void> _open(
  WidgetTester tester, {
  double width = 390,
  double height = 844,
  double scale = 1,
  ImagePicker? picker,
  _Auth? auth,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => _user),
        if (auth != null) authServiceProvider.overrideWithValue(auth),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: ProfileSetupScreen(imagePicker: picker),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Empty avatar uses an upload placeholder and the complete form fits a narrow screen with larger text',
    (tester) async {
      await _open(tester, width: 320, scale: 1.4);
      expect(find.byType(Image), findsNothing);
      expect(find.text('Upload profile photo'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('Save changes'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Save changes').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Gallery selection previews the actual photo and saves multipart image plus teacher fields; failed saves keep the form',
    (tester) async {
      final auth = _Auth();
      await _open(
        tester,
        auth: auth,
        picker: _Picker(
          XFile.fromData(
            _png,
            path: 'profile.png',
            name: 'profile.png',
            mimeType: 'image/png',
          ),
        ),
      );
      await tester.tap(find.text('Upload profile photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Change profile photo'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Science'),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Science'));
      await tester.scrollUntilVisible(
        find.text('Save changes'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(auth.photo, _png);
      expect(auth.saved?['locationState'], 'Texas');
      expect(auth.saved?['gradeLevel'], 6);
      expect(auth.saved?['subjects'], ['Science']);
      expect(auth.saved?.containsKey('state'), isFalse);
      expect(
        find.textContaining('Your changes are still here'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Cancelling photo selection keeps the empty avatar; invalid name blocks saving',
    (tester) async {
      final auth = _Auth();
      await _open(tester, auth: auth, picker: _Picker(null));
      await tester.tap(find.text('Upload profile photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNothing);
      await tester.ensureVisible(find.byKey(const Key('profile-name')));
      await tester.enterText(find.byKey(const Key('profile-name')), '   ');
      tester.testTextInput.hide();
      await tester.scrollUntilVisible(
        find.text('Save changes'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(auth.saved, isNull);
      expect(find.text('Enter your name'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  for (final size in [const Size(768, 1024), const Size(844, 390)]) {
    testWidgets('Profile form remains usable at $size', (
      tester,
    ) async {
      await _open(tester, width: size.width, height: size.height, scale: 1.3);
      await tester.scrollUntilVisible(
        find.text('Save changes'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Save changes').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'Removing a selected photo clears the preview and sends an explicit removal',
    (tester) async {
      final auth = _Auth();
      await _open(
        tester,
        auth: auth,
        picker: _Picker(
          XFile.fromData(_png, path: 'profile.png', name: 'profile.png'),
        ),
      );
      await tester.tap(find.text('Upload profile photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change profile photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove photo'));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Save changes'),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(auth.saved?['removeAvatar'], isTrue);
      expect(auth.photo, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
