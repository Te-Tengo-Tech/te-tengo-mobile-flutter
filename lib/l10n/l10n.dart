/// The app's languages: Spanish (Peru), the default, and English.
///
/// Texts live in `lib/l10n/app_es.arb` (the template) and `app_en.arb`; `flutter gen-l10n` (run by
/// `flutter pub get`) writes `app_localizations*.dart`. Widgets read them with `context.l10n` and
/// format dates, times and lists with `context.formato`; code without a [BuildContext] (push
/// handlers, the home-screen widget) uses [textosDelSistema].
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/formato.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// Spanish first: it is the fallback for any language the app does not have.
const idiomasDeLaApp = [Locale('es'), Locale('en')];

/// The app's texts plus Material's and Cupertino's own (dialog buttons, tooltips, pickers).
const delegadosDeTextos = <LocalizationsDelegate<Object>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// The language of the phone: the first of its preferred languages that the app has, Spanish for
/// any other (`MaterialApp.localeListResolutionCallback`).
Locale resolverIdioma(List<Locale>? preferidos, [Iterable<Locale>? _]) {
  for (final l in preferidos ?? const <Locale>[]) {
    for (final idioma in idiomasDeLaApp) {
      if (idioma.languageCode == l.languageCode) return idioma;
    }
  }
  return idiomasDeLaApp.first;
}

/// The texts in the phone's language, for code that runs without a [BuildContext] (also in a
/// background isolate). Reads the binding's dispatcher, which is the phone's own outside tests.
AppLocalizations textosDelSistema() => lookupAppLocalizations(
  resolverIdioma(
    WidgetsFlutterBinding.ensureInitialized().platformDispatcher.locales,
  ),
);

extension TextosDelContexto on BuildContext {
  /// The app's texts in the current language.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Dates, times, durations and lists in the current language.
  Formato get formato => Formato(AppLocalizations.of(this).localeName);
}

extension FormatoDeTextos on AppLocalizations {
  /// Dates, times, durations and lists in this language.
  Formato get formato => Formato(localeName);
}
