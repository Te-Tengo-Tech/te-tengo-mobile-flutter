/// Alert counts of a week by kind (contract §6).
class Conteos {
  const Conteos({
    this.caidas = 0,
    this.movimientosInestables = 0,
    this.falsasAlarmas = 0,
  });

  final int caidas;
  final int movimientosInestables;
  final int falsasAlarmas;

  int get total => caidas + movimientosInestables + falsasAlarmas;

  factory Conteos.desdeJson(Map<String, dynamic>? json) => Conteos(
    caidas: (json?['caidas'] as num?)?.toInt() ?? 0,
    movimientosInestables:
        (json?['movimientosInestables'] as num?)?.toInt() ?? 0,
    falsasAlarmas: (json?['falsasAlarmas'] as num?)?.toInt() ?? 0,
  );
}

/// How a kind changed against the previous week (CA-27.3).
enum Tendencia {
  aumento,
  igual,
  disminucion;

  static Tendencia desde(Object? valor) => switch (valor) {
    'AUMENTO' => aumento,
    'DISMINUCION' => disminucion,
    _ => igual,
  };
}

/// `GET /api/resumen-semanal` (CA-27.1 to CA-27.3). A week without events is all zeros (CA-27.2).
class ResumenSemanal {
  const ResumenSemanal({
    required this.semana,
    required this.conteos,
    required this.semanaAnterior,
    this.tendenciaCaidas = Tendencia.igual,
    this.tendenciaInestables = Tendencia.igual,
    this.tendenciaFalsas = Tendencia.igual,
  });

  final String semana;
  final Conteos conteos;
  final Conteos semanaAnterior;
  final Tendencia tendenciaCaidas;
  final Tendencia tendenciaInestables;
  final Tendencia tendenciaFalsas;

  factory ResumenSemanal.desdeJson(Map<String, dynamic> json) {
    final t = json['tendencia'] as Map<String, dynamic>? ?? const {};
    return ResumenSemanal(
      semana: json['semana'] as String? ?? '',
      conteos: Conteos.desdeJson(json['conteos'] as Map<String, dynamic>?),
      semanaAnterior: Conteos.desdeJson(
        json['semanaAnterior'] as Map<String, dynamic>?,
      ),
      tendenciaCaidas: Tendencia.desde(t['caidas']),
      tendenciaInestables: Tendencia.desde(t['movimientosInestables']),
      tendenciaFalsas: Tendencia.desde(t['falsasAlarmas']),
    );
  }
}

/// Monday of the week of [d] (local date).
DateTime lunesDe(DateTime d) =>
    DateTime(d.year, d.month, d.day - d.weekday + 1);

/// ISO week of [d] as the contract writes it: `2026-W38`.
String semanaIso(DateTime d) {
  final dia = DateTime.utc(d.year, d.month, d.day);
  final jueves = dia.add(Duration(days: DateTime.thursday - dia.weekday));
  final numero = jueves.difference(DateTime.utc(jueves.year)).inDays ~/ 7 + 1;
  return '${jueves.year}-W${numero.toString().padLeft(2, '0')}';
}
