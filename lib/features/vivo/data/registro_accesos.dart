import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../actividad/data/actividad_repositorio.dart';
import '../../actividad/domain/actividad.dart';
import '../../repeticion/data/repeticiones_repositorio.dart';
import '../../repeticion/domain/repeticion.dart';
import '../domain/vista_en_vivo.dart';
import 'vista_en_vivo_repositorio.dart';

/// Kind of an access (the access log's chips and badges).
enum TipoAcceso { vivo, vistaPrevia, repeticion }

/// One entry of the access log (US-24, CA-39.3): the live view, a webcam's preview or a replay.
class Acceso {
  const Acceso({
    required this.tipo,
    required this.usuarioId,
    required this.nombre,
    required this.inicio,
    required this.duracionSegundos,
    this.camaraId,
    this.habitacion,
    this.desdeAlerta = false,
    this.momento,
    this.pc,
  });

  factory Acceso.vivo(AccesoVivo a) => Acceso(
    tipo: a.vistaPrevia ? TipoAcceso.vistaPrevia : TipoAcceso.vivo,
    usuarioId: a.usuarioId,
    nombre: a.nombre,
    inicio: a.inicio,
    duracionSegundos: a.duracionSegundos,
    camaraId: a.camaraId,
    desdeAlerta: a.desdeAlerta,
  );

  factory Acceso.repeticion(AccesoRepeticion a) => Acceso(
    tipo: TipoAcceso.repeticion,
    usuarioId: a.usuarioId,
    nombre: a.nombre,
    inicio: a.inicio,
    duracionSegundos: a.duracionSegundos,
    camaraId: a.camaraId,
    habitacion: a.habitacion,
    momento: a.momentoDesde,
  );

  /// A replay watched on a PC (`REPETICION_VISTA` of the activity log, CA-39.3): who watched it
  /// on the PC is not known, so the entry names the PC.
  static Acceso? repeticionEnPc(Actividad a) {
    final momento = a.momentoRepetido;
    if (momento == null) return null;
    final pc = a.pc ?? '';
    return Acceso(
      tipo: TipoAcceso.repeticion,
      usuarioId: '',
      nombre: pc.isEmpty ? 'PC de la casa' : 'PC $pc',
      inicio: a.ocurridaEn,
      duracionSegundos: a.segundosVistos ?? 0,
      camaraId: a.camaraId,
      habitacion: a.objeto,
      momento: momento.$1,
      pc: pc,
    );
  }

  final TipoAcceso tipo;
  final String usuarioId;
  final String nombre;
  final DateTime inicio;
  final int duracionSegundos;
  final String? camaraId;

  /// The replay's room as it was then.
  final String? habitacion;
  final bool desdeAlerta;

  /// The replayed moment.
  final DateTime? momento;

  /// The PC's name when the replay was watched on a PC; null in the app.
  final String? pc;

  bool get enPc => pc != null;
}

/// The replays watched on a PC (`GET /api/actividad?tipo=REPETICION_VISTA`), the latest 100.
final repeticionesEnPcProvider = FutureProvider<List<Actividad>>((ref) async {
  final p = await ref
      .watch(actividadRepositorioProvider)
      .listar(tipo: 'REPETICION_VISTA', tamano: 100);
  return p.elementos;
});

/// The live view, previews and replays (in the app and on a PC) in one log, newest first. A
/// backend without replays (an older API) answers only the live view.
final registroAccesosProvider = FutureProvider<List<Acceso>>((ref) async {
  final vivo = await ref.watch(accesosVivoProvider.future);
  var repeticiones = const <AccesoRepeticion>[];
  var enPc = const <Actividad>[];
  try {
    repeticiones = await ref.watch(accesosRepeticionesProvider.future);
  } on Object {
    // Only the live view.
  }
  try {
    enPc = await ref.watch(repeticionesEnPcProvider.future);
  } on Object {
    // An API without `REPETICION_VISTA` refuses the type: no PC replays.
  }
  return [
    for (final a in vivo) Acceso.vivo(a),
    for (final a in repeticiones) Acceso.repeticion(a),
    for (final a in enPc) ?Acceso.repeticionEnPc(a),
  ]..sort((x, y) => y.inicio.compareTo(x.inicio));
});
