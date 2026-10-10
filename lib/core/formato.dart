/// Spanish (Peru) date and time formats used by the prototype (`dShort`, `dLong`, `dYear`, `fmtDur`).
///
/// The backend sends UTC; callers pass local times (`DateTime.toLocal()`).
library;

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

/// `10:42`.
String hora(DateTime t) => '${_dos(t.hour)}:${_dos(t.minute)}';

/// `mié 23 sep`.
String fechaCorta(DateTime t) =>
    '${_diasCortos[t.weekday - 1]} ${t.day} ${_mesesCortos[t.month - 1]}';

/// `miércoles 23 de septiembre`.
String fechaLarga(DateTime t) =>
    '${_dias[t.weekday - 1]} ${t.day} de ${_meses[t.month - 1]}';

/// `23 sep 2026`.
String fechaConAnio(DateTime t) =>
    '${t.day} ${_mesesCortos[t.month - 1]} ${t.year}';

/// Month name (`septiembre`).
String nombreMes(int mes) => _meses[mes - 1];

/// Short month name (`sep`).
String nombreMesCorto(int mes) => _mesesCortos[mes - 1];

/// Days from [desde] to [hasta] (`rng` in the prototype): `21 – 27 septiembre` within a month
/// (`21 – 27 sep` when [corto]), and `31 ago – 6 sep` when the range crosses a month.
String rangoDias(DateTime desde, DateTime hasta, {bool corto = false}) =>
    desde.month == hasta.month
    ? '${desde.day} – ${hasta.day} '
          '${corto ? nombreMesCorto(hasta.month) : nombreMes(hasta.month)}'
    : '${desde.day} ${nombreMesCorto(desde.month)} – '
          '${hasta.day} ${nombreMesCorto(hasta.month)}';

/// Capitalizes the first letter (`Miércoles 23 de septiembre`).
String mayusculaInicial(String texto) =>
    texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);

/// `2 min 5 s`, `48 s` (non-breaking spaces between number and unit, as in the prototype).
String duracion(Duration d) {
  final s = d.inSeconds < 1 ? 1 : d.inSeconds;
  final m = s ~/ 60;
  final r = s % 60;
  if (m == 0) return '$r s';
  return r == 0 ? '$m min' : '$m min $r s';
}

/// True when both times fall on the same local day.
bool mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Parses an ISO-8601 UTC time from the backend into local time.
DateTime? fechaDesdeJson(Object? valor) =>
    valor == null ? null : DateTime.parse(valor as String).toLocal();
