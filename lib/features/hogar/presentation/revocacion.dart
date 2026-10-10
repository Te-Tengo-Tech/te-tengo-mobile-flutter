import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/hogar.dart';

/// Progress of a consent revocation (screens 100 and 101): started on this phone, or rebuilt from
/// `GET /api/hogar` `eliminacion` when the screen opens without it (the app restarted, the PWA was
/// reloaded).
class Revocacion {
  const Revocacion({
    required this.capturaDetenida,
    required this.clips,
    this.eliminadasEn,
  });

  /// When capture stopped (the `202` of the revocation, or `programadaEn`).
  final DateTime capturaDetenida;

  /// Recordings the revocation deletes; null when unknown (an older backend that does not say,
  /// and the alerts could not be counted), so the screen shows no count instead of a wrong one.
  final int? clips;

  /// When the recordings were deleted: the push `DATOS_ELIMINADOS` or `eliminacion.terminadaEn`
  /// (CA-09.3), whichever arrived first.
  final DateTime? eliminadasEn;

  bool get terminada => eliminadasEn != null;
}

class RevocacionEnCurso extends Notifier<Revocacion?> {
  @override
  Revocacion? build() => null;

  void iniciar(DateTime cuando, int? clips) =>
      state = Revocacion(capturaDetenida: cuando, clips: clips);

  /// The backend finished deleting the recordings. Only the first call counts (push and polling
  /// may both tell it); [clips], when known, is what the backend deleted.
  void terminar(DateTime cuando, {int? clips}) {
    final r = state;
    if (r == null || r.terminada) return;
    state = Revocacion(
      capturaDetenida: r.capturaDetenida,
      clips: clips ?? r.clips,
      eliminadasEn: cuando,
    );
  }

  /// What the backend says about the latest revocation's deletion (`GET /api/hogar`
  /// `eliminacion`): it rebuilds a lost revocation and completes one under way.
  void sincronizar(Eliminacion eliminacion) {
    final terminadaEn = eliminacion.terminada
        ? eliminacion.terminadaEn ?? eliminacion.programadaEn
        : null;
    if (state == null) {
      state = Revocacion(
        capturaDetenida: eliminacion.programadaEn,
        clips: eliminacion.clips,
        eliminadasEn: terminadaEn,
      );
      return;
    }
    if (terminadaEn != null) terminar(terminadaEn, clips: eliminacion.clips);
  }

  void olvidar() => state = null;
}

final revocacionProvider = NotifierProvider<RevocacionEnCurso, Revocacion?>(
  RevocacionEnCurso.new,
);
