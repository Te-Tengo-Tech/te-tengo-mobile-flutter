import 'dart:async';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

/// Every test runs on a phone in Spanish (Peru), the app's default language, unless it sets
/// another one with [usarIdioma] (test/apoyo/idioma.dart). Without this, `flutter test` would
/// report the host's `en_US` and the app would follow it into English.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .localesTestValue = const [
      Locale('es', 'PE'),
    ];
  });
  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .clearLocalesTestValue();
  });
  await testMain();
}
