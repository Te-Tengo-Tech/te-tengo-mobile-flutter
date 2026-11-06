import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

/// The phone's language for this test (Spanish by default, test/flutter_test_config.dart).
void usarIdioma(WidgetTester tester, Locale idioma) {
  tester.platformDispatcher.localesTestValue = [idioma];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
}

/// An English (US) phone.
void usarIngles(WidgetTester tester) =>
    usarIdioma(tester, const Locale('en', 'US'));
