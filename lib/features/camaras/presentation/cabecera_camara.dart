import 'package:flutter/widgets.dart' show Locale;

import '../../../l10n/l10n.dart';

/// `hace 6 s`, `hace 3 min` (`6 s ago` in English). Without [l], Spanish.
String haceTiempo(DateTime momento, DateTime ahora, [AppLocalizations? l]) {
  final t = l ?? lookupAppLocalizations(const Locale('es'));
  final d = ahora.difference(momento);
  if (d.inMinutes < 1) return t.camaraHaceSegundos(d.inSeconds.clamp(1, 59));
  if (d.inHours < 1) return t.camaraHaceMinutos(d.inMinutes);
  return t.camaraHaceHoras(d.inHours);
}
