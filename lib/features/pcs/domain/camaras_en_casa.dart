import '../../../l10n/l10n.dart';
import '../../camaras/domain/camara.dart';
import 'pc.dart';

/// A camera of the household with its PC and the state the family sees (`camState`).
class CamaraEnCasa {
  const CamaraEnCasa({required this.camara, required this.estado, this.pc});

  final Camara camara;
  final Pc? pc;
  final EstadoVisible estado;

  String get habitacion => camara.nombreHabitacion;

  /// It does not watch its room now: unplugged, its PC offline, paused or unreliable
  /// («Necesitan atención»).
  bool get necesitaAtencion => switch (estado) {
    EstadoVisible.desconectada ||
    EstadoVisible.sinConexion ||
    EstadoVisible.enPausa ||
    EstadoVisible.noConfiable => true,
    _ => false,
  };

  /// It does not answer: unplugged or its PC offline.
  bool get noResponde =>
      estado == EstadoVisible.desconectada ||
      estado == EstadoVisible.sinConexion;

  /// It watches its room and detects falls.
  bool get funciona => estado == EstadoVisible.enLinea;

  /// The live view can open (CA-23.3, CA-23.4, CA-05.2; a PC offline is like a camera offline).
  bool get vivoDisponible =>
      estado == EstadoVisible.enLinea || estado == EstadoVisible.noConfiable;
}

/// The household's cameras with their PC and state, in the order of [camaras].
List<CamaraEnCasa> camarasEnCasa(
  List<Camara> camaras,
  List<Pc> pcs, {
  required bool conConsentimiento,
}) => [
  for (final c in camaras)
    () {
      final pc = pcs.where((p) => p.id == c.pcId).firstOrNull;
      return CamaraEnCasa(
        camara: c,
        pc: pc,
        estado: c.estadoVisible(
          conConsentimiento: conConsentimiento,
          pcSinConexion: pc?.sinConexion ?? false,
        ),
      );
    }(),
];

/// The home card's line (`camTileLine`): «4 de 4 funcionan», «Funciona · Sala», «Sin cámaras»,
/// «Detenidas».
String lineaTarjetaCamaras(
  AppLocalizations l,
  List<CamaraEnCasa> camaras, {
  required bool conConsentimiento,
}) {
  final n = camaras.length;
  if (n == 0) return l.pcsLineaSinCamaras;
  if (!conConsentimiento) return l.pcsDetenidas;
  if (n == 1) {
    final c = camaras.single;
    return c.funciona ? l.pcsLineaFunciona(c.habitacion) : c.estado.texto(l);
  }
  final ok = camaras.where((c) => c.funciona).length;
  return l.pcsLineaFuncionan(ok, n);
}

/// The Cámaras page's summary (`camSummary`): «4 cámaras · todas funcionan bien».
({bool ok, String cuantas, String estado}) resumenCamaras(
  AppLocalizations l,
  List<CamaraEnCasa> camaras, {
  required bool conConsentimiento,
}) {
  final n = camaras.length;
  final ok = camaras.where((c) => c.funciona).length;
  final cuantas = l.pcsNCamaras(n);
  if (n == 0) {
    return (ok: false, cuantas: l.pcsResumenSinCamaras, estado: '');
  }
  if (!conConsentimiento) {
    return (ok: false, cuantas: cuantas, estado: l.pcsResumenDetenidas);
  }
  if (ok == n) {
    return (
      ok: true,
      cuantas: cuantas,
      estado: n == 1 ? l.pcsResumenFuncionaBien : l.pcsResumenTodasBien,
    );
  }
  return (
    ok: false,
    cuantas: cuantas,
    estado: n == 1
        ? l.pcsResumenNoFunciona
        : ok == 0
        ? l.pcsResumenNingunaFunciona
        : l.pcsResumenAlgunasBien(ok),
  );
}
