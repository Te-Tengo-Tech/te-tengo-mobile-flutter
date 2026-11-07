import '../../../core/ui/aviso.dart';
import '../../../core/ui/iconos.dart';
import '../../../l10n/l10n.dart';
import '../domain/estado_actualizacion.dart';
import '../domain/versiones.dart';

/// What the single action of the bar or the card does.
enum AccionActualizacion { actualizar, cancelar }

/// What the update bar and «Acerca de» say now (the prototype's `updStatus`): the new version,
/// the download, its check or the error, with one action.
class Situacion {
  const Situacion({
    required this.nueva,
    required this.icono,
    required this.titulo,
    this.tono,
    this.texto,
    this.textoMono = false,
    this.progreso,
    this.indeterminado = false,
    this.ayuda,
    this.accion,
    this.textoAccion,
    this.accionPrincipal = true,
  });

  /// «Hay una versión nueva»: the bar adds «Qué cambió» and «Acerca de» the notes.
  final bool nueva;
  final Ico icono;
  final String titulo;

  /// Null: the purple bar; [TonoAviso.advertencia] or [TonoAviso.info] for the errors.
  final TonoAviso? tono;
  final String? texto;

  /// «42 %» is a figure.
  final bool textoMono;

  /// 0 to 1, with the bar's track.
  final double? progreso;

  /// A moving track (the check, or Google Play's download).
  final bool indeterminado;

  /// The «?» text.
  final String? ayuda;
  final AccionActualizacion? accion;
  final String? textoAccion;

  /// The action is the primary button (otherwise the secondary one).
  final bool accionPrincipal;

  bool get conPista => progreso != null || indeterminado;
}

/// «Actualizar», or «Abrir» on the iPhone.
String textoActualizar(
  AppLocalizations l,
  InfoApp info, {
  bool largo = false,
}) => info.canal == Canal.ios
    ? (largo
          ? l.actualizacionAbrirTienda(info.tiendaIos.nombre)
          : l.actualizacionAbrir)
    : l.actualizacionActualizar;

/// Null when there is nothing to say.
Situacion? situacionDe(AppLocalizations l, EstadoActualizacion e) {
  final info = e.info;
  final nueva = e.nueva ?? (e.obligatoria ? e.publicada : null);
  if (info == null || nueva == null) return null;
  final version = nueva.version;
  switch (e.fase) {
    case FaseActualizacion.descargando:
      final p = e.progreso;
      return Situacion(
        nueva: false,
        icono: Ico.download,
        titulo: l.actualizacionDescargando(version),
        texto: p == null ? null : l.actualizacionPorcentaje((p * 100).floor()),
        textoMono: true,
        progreso: p,
        indeterminado: p == null,
        // Google Play's download cannot be stopped from here.
        accion: info.canal == Canal.apk ? AccionActualizacion.cancelar : null,
        textoAccion: l.actualizacionCancelar,
        accionPrincipal: false,
      );
    case FaseActualizacion.comprobando:
      return Situacion(
        nueva: false,
        icono: Ico.shield,
        titulo: l.actualizacionComprobando,
        indeterminado: true,
      );
    case FaseActualizacion.quieta ||
        FaseActualizacion.buscando ||
        FaseActualizacion.esperando ||
        FaseActualizacion.instalando ||
        FaseActualizacion.recargando:
      break;
  }
  final reintentar = (
    AccionActualizacion.actualizar,
    l.actualizacionReintentar,
    false,
  );
  final actualizar = (
    AccionActualizacion.actualizar,
    l.actualizacionActualizar,
    true,
  );
  final actual = info.version;
  final error = switch (e.error) {
    ErrorActualizacion.sinInternet => (
      TonoAviso.advertencia,
      Ico.wifiOff,
      l.actualizacionSinInternet,
      l.actualizacionNoSePudoDescargarPunto,
      null,
      reintentar,
    ),
    ErrorActualizacion.descarga => (
      TonoAviso.advertencia,
      Ico.warn,
      l.actualizacionNoSePudoDescargar,
      l.actualizacionSigues(actual),
      null,
      reintentar,
    ),
    ErrorActualizacion.verificacion => (
      TonoAviso.advertencia,
      Ico.warn,
      l.actualizacionNoSePudoVerificar,
      l.actualizacionLaBorramos(actual),
      l.actualizacionNoCoincide,
      reintentar,
    ),
    ErrorActualizacion.cancelada => (
      TonoAviso.info,
      Ico.info,
      l.actualizacionNoSeInstalo,
      l.actualizacionCancelaste,
      null,
      actualizar,
    ),
    ErrorActualizacion.instalacion => (
      TonoAviso.info,
      Ico.info,
      l.actualizacionNoSeInstalo,
      null,
      null,
      actualizar,
    ),
    ErrorActualizacion.sinPermiso => (
      TonoAviso.info,
      Ico.lock,
      l.actualizacionFaltaPermiso,
      l.actualizacionSinPermiso,
      null,
      actualizar,
    ),
    ErrorActualizacion.sinInternetAlBuscar || null => null,
  };
  if (error case (
    final tono,
    final icono,
    final titulo,
    final texto,
    final ayuda,
    (final accion, final textoAccion, final principal),
  )) {
    return Situacion(
      nueva: false,
      tono: tono,
      icono: icono,
      titulo: titulo,
      texto: texto,
      ayuda: ayuda,
      accion: accion,
      textoAccion: textoAccion,
      accionPrincipal: principal,
    );
  }
  return Situacion(
    nueva: true,
    icono: Ico.refresh,
    titulo: info.canal == Canal.apk
        ? l.actualizacionHayNuevaVersion(version)
        : l.actualizacionHayNueva,
    texto: info.canal == Canal.ios ? info.tiendaIos.nombre : null,
    accion: AccionActualizacion.actualizar,
    textoAccion: textoActualizar(l, info),
  );
}
