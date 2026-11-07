/// Date, time, duration and list formats in the app's languages (`context.formato`).
///
/// Spanish (Peru) keeps the prototype's own formats (`dShort`, `dLong`, `dYear`, `fmtDur`); English
/// follows US usage (`10:42 AM`, `Wed Sep 23`, `Sep 23, 2026`). Written out by hand, with no locale
/// data to load, so they also work without a `BuildContext` (pushes, the home-screen widget). The
/// backend sends UTC; callers pass local times (`DateTime.toLocal()`).
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

const _daysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _days = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _dos(int n) => n.toString().padLeft(2, '0');

/// The formats of one language: [idioma] is the language code (`es`, `en`); any other is Spanish.
class Formato {
  const Formato(this.idioma);

  /// Spanish (Peru), the app's default.
  static const es = Formato('es');

  final String idioma;

  bool get _en => idioma == 'en';

  /// `10:42` (`10:42 AM` in English, with a non-breaking space so it never wraps).
  String hora(DateTime t) => _en
      ? '${t.hour % 12 == 0 ? 12 : t.hour % 12}:${_dos(t.minute)} ${t.hour < 12 ? 'AM' : 'PM'}'
      : '${_dos(t.hour)}:${_dos(t.minute)}';

  /// `10:41:52` (`10:41:52 AM`).
  String horaConSegundos(DateTime t) => _en
      ? '${hora(t).split(' ').first}:${_dos(t.second)}'
            ' ${t.hour < 12 ? 'AM' : 'PM'}'
      : '${_dos(t.hour)}:${_dos(t.minute)}:${_dos(t.second)}';

  /// Short weekday (`mié`, `Wed`).
  String diaSemanaCorto(DateTime t) =>
      (_en ? _daysShort : _diasCortos)[t.weekday - 1];

  /// `mié 23 sep` (`Wed Sep 23`).
  String fechaCorta(DateTime t) => _en
      ? '${_daysShort[t.weekday - 1]} ${nombreMesCorto(t.month)} ${t.day}'
      : '${_diasCortos[t.weekday - 1]} ${t.day} ${_mesesCortos[t.month - 1]}';

  /// `miércoles 23 de septiembre` (`Wednesday, September 23`).
  String fechaLarga(DateTime t) => _en
      ? '${_days[t.weekday - 1]}, ${_months[t.month - 1]} ${t.day}'
      : '${_dias[t.weekday - 1]} ${t.day} de ${_meses[t.month - 1]}';

  /// `23 sep 2026` (`Sep 23, 2026`).
  String fechaConAnio(DateTime t) => _en
      ? '${nombreMesCorto(t.month)} ${t.day}, ${t.year}'
      : '${t.day} ${_mesesCortos[t.month - 1]} ${t.year}';

  /// Month name (`septiembre`, `September`).
  String nombreMes(int mes) => _en ? _months[mes - 1] : _meses[mes - 1];

  /// Short month name (`sep`, `Sep`).
  String nombreMesCorto(int mes) =>
      _en ? _months[mes - 1].substring(0, 3) : _mesesCortos[mes - 1];

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
