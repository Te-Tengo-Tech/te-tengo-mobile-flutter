import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Progress of a consent revocation started on this phone (screens 100 and 101).
class Revocacion {
  const Revocacion({
    required this.capturaDetenida,
    required this.clips,
    this.eliminadasEn,
  });

  /// When capture stopped (the `202` of the revocation).
  final DateTime capturaDetenida;

  /// Clips stored before the deletion.
  final int clips;

  /// When the push `DATOS_ELIMINADOS` arrived (CA-09.3).
  final DateTime? eliminadasEn;

  bool get terminada => eliminadasEn != null;
}

class RevocacionEnCurso extends Notifier<Revocacion?> {
  @override
  Revocacion? build() => null;

  void iniciar(DateTime cuando, int clips) =>
      state = Revocacion(capturaDetenida: cuando, clips: clips);

  /// The backend finished deleting the recordings.
  void terminar(DateTime cuando) {
    final r = state;
    if (r == null || r.terminada) return;
    state = Revocacion(
      capturaDetenida: r.capturaDetenida,
      clips: r.clips,
      eliminadasEn: cuando,
    );
  }

  void olvidar() => state = null;
}

final revocacionProvider = NotifierProvider<RevocacionEnCurso, Revocacion?>(
  RevocacionEnCurso.new,
);
