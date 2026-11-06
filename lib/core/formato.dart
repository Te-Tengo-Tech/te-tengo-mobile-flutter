/// Date, time, duration and list formats in the app's languages (`context.formato`).
///
/// Spanish (Peru) keeps the prototype's own formats (`dShort`, `dLong`, `dYear`, `fmtDur`); English
/// uses `intl`'s patterns for `en`. The backend sends UTC; callers pass local times
/// (`DateTime.toLocal()`).
library;

import 'package:intl/intl.dart';

const _diasCortos = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
const _dias = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];
const _mesesCortos = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];
const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

String _dos(int n) => n.toString().padLeft(2, '0');

/// The formats of one language: [idioma] is the language code (`es`, `en`); any other is Spanish.
class Formato {
  const Formato(this.idioma);

  /// Spanish (Peru), the app's default.
  static const es = Formato('es');

  final String idioma;

  bool get _en => idioma == 'en';

  /// `10:42` (`10:42 AM` in English).
  String hora(DateTime t) => _en
      ? DateFormat('h:mm a', 'en').format(t)
      : '${_dos(t.hour)}:${_dos(t.minute)}';

  /// `mié 23 sep` (`Wed Sep 23`).
  String fechaCorta(DateTime t) => _en
      ? DateFormat('EEE MMM d', 'en').format(t)
      : '${_diasCortos[t.weekday - 1]} ${t.day} ${_mesesCortos[t.month - 1]}';

  /// `miércoles 23 de septiembre` (`Wednesday, September 23`).
  String fechaLarga(DateTime t) => _en
      ? DateFormat('EEEE, MMMM d', 'en').format(t)
      : '${_dias[t.weekday - 1]} ${t.day} de ${_meses[t.month - 1]}';

  /// `23 sep 2026` (`Sep 23, 2026`).
  String fechaConAnio(DateTime t) => _en
      ? DateFormat('MMM d, y', 'en').format(t)
      : '${t.day} ${_mesesCortos[t.month - 1]} ${t.year}';

  /// Month name (`septiembre`, `September`).
  String nombreMes(int mes) => _en
      ? DateFormat('MMMM', 'en').format(DateTime(2000, mes))
      : _meses[mes - 1];

  /// Short month name (`sep`, `Sep`).
  String nombreMesCorto(int mes) => _en
      ? DateFormat('MMM', 'en').format(DateTime(2000, mes))
      : _mesesCortos[mes - 1];

  /// Days from [desde] to [hasta] (`rng` in the prototype): `21 – 27 septiembre` within a month
  /// (`21 – 27 sep` when [corto]), and `31 ago – 6 sep` when the range crosses a month. English:
  /// `September 21 – 27`, `Sep 21 – 27`, `Aug 31 – Sep 6`.
  String rangoDias(DateTime desde, DateTime hasta, {bool corto = false}) {
    final mes = corto ? nombreMesCorto(hasta.month) : nombreMes(hasta.month);
    if (_en) {
      return desde.month == hasta.month
          ? '$mes ${desde.day} – ${hasta.day}'
          : '${nombreMesCorto(desde.month)} ${desde.day} – '
                '${nombreMesCorto(hasta.month)} ${hasta.day}';
    }
    return desde.month == hasta.month
        ? '${desde.day} – ${hasta.day} $mes'
        : '${desde.day} ${nombreMesCorto(desde.month)} – '
              '${hasta.day} ${nombreMesCorto(hasta.month)}';
  }

  /// `2 min 5 s`, `48 s` (non-breaking spaces between number and unit, as in the prototype); the
  /// same in English.
  String duracion(Duration d) {
    final s = d.inSeconds < 1 ? 1 : d.inSeconds;
    final m = s ~/ 60;
    final r = s % 60;
    if (m == 0) return '$r s';
    return r == 0 ? '$m min' : '$m min $r s';
  }

  /// `Sala`, `Sala y Cocina`, `Sala, Dormitorio y Pasillo` (`listJoin`); «and» in English.
  String enumerar(List<String> partes) => switch (partes.length) {
    0 => '',
    1 => partes.first,
    _ =>
      '${partes.sublist(0, partes.length - 1).join(', ')} '
          '${_en ? 'and' : 'y'} ${partes.last}',
  };

  /// `03/08/2026` (`dNum`); month first in English (`08/03/2026`).
  String fechaNumerica(DateTime t) => _en
      ? '${_dos(t.month)}/${_dos(t.day)}/${t.year}'
      : '${_dos(t.day)}/${_dos(t.month)}/${t.year}';
}

/// Capitalizes the first letter (`Miércoles 23 de septiembre`).
String mayusculaInicial(String texto) =>
    texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);

/// True when both times fall on the same local day.
bool mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Parses an ISO-8601 UTC time from the backend into local time.
DateTime? fechaDesdeJson(Object? valor) =>
    valor == null ? null : DateTime.parse(valor as String).toLocal();

// Spanish-only helpers kept while every caller moves to `context.formato` (lib/l10n/l10n.dart).

/// `10:42`.
String hora(DateTime t) => Formato.es.hora(t);

/// `mié 23 sep`.
String fechaCorta(DateTime t) => Formato.es.fechaCorta(t);

/// `miércoles 23 de septiembre`.
String fechaLarga(DateTime t) => Formato.es.fechaLarga(t);

/// `23 sep 2026`.
String fechaConAnio(DateTime t) => Formato.es.fechaConAnio(t);

/// Month name (`septiembre`).
String nombreMes(int mes) => Formato.es.nombreMes(mes);

/// Short month name (`sep`).
String nombreMesCorto(int mes) => Formato.es.nombreMesCorto(mes);

/// `21 – 27 septiembre`.
String rangoDias(DateTime desde, DateTime hasta, {bool corto = false}) =>
    Formato.es.rangoDias(desde, hasta, corto: corto);

/// `2 min 5 s`, `48 s`.
String duracion(Duration d) => Formato.es.duracion(d);

/// `Sala, Dormitorio y Pasillo`.
String enumerar(List<String> partes) => Formato.es.enumerar(partes);

/// `03/08/2026`.
String fechaNumerica(DateTime t) => Formato.es.fechaNumerica(t);

/// «1 cámara», «4 cámaras».
String contar(int n, String uno, String varios) =>
    '$n ${n == 1 ? uno : varios}';
