import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

/// The live view, previews and replays in one log, newest first. A backend without replays
/// (an older API) answers only the live view.
final registroAccesosProvider = FutureProvider<List<Acceso>>((ref) async {
  final vivo = await ref.watch(accesosVivoProvider.future);
  var repeticiones = const <AccesoRepeticion>[];
  try {
    repeticiones = await ref.watch(accesosRepeticionesProvider.future);
  } on Object {
    // Only the live view.
  }
  return [
    for (final a in vivo) Acceso.vivo(a),
    for (final a in repeticiones) Acceso.repeticion(a),
  ]..sort((x, y) => y.inicio.compareTo(x.inicio));
});
