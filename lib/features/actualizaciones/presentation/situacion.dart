import '../../../core/ui/aviso.dart';
import '../../../core/ui/iconos.dart';
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
String textoActualizar(InfoApp info, {bool largo = false}) =>
    info.canal == Canal.ios
    ? (largo ? 'Abrir ${info.tiendaIos.nombre}' : 'Abrir')
    : 'Actualizar';

/// Null when there is nothing to say.
Situacion? situacionDe(EstadoActualizacion e) {
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
        titulo: 'Descargando $version',
        texto: p == null ? null : '${(p * 100).floor()} %',
        textoMono: true,
        progreso: p,
        indeterminado: p == null,
        // Google Play's download cannot be stopped from here.
        accion: info.canal == Canal.apk ? AccionActualizacion.cancelar : null,
        textoAccion: 'Cancelar',
        accionPrincipal: false,
      );
    case FaseActualizacion.comprobando:
      return const Situacion(
        nueva: false,
        icono: Ico.shield,
        titulo: 'Comprobando la descarga…',
        indeterminado: true,
      );
    case FaseActualizacion.quieta ||
        FaseActualizacion.buscando ||
        FaseActualizacion.esperando ||
        FaseActualizacion.instalando ||
        FaseActualizacion.recargando:
      break;
  }
  const reintentar = (AccionActualizacion.actualizar, 'Reintentar', false);
  final actual = info.version;
  final error = switch (e.error) {
    ErrorActualizacion.sinInternet => (
      TonoAviso.advertencia,
      Ico.wifiOff,
      'Sin internet',
      'No se pudo descargar.',
      null,
      reintentar,
    ),
    ErrorActualizacion.descarga => (
      TonoAviso.advertencia,
      Ico.warn,
      'No se pudo descargar',
      'Sigues con la $actual.',
      null,
      reintentar,
    ),
    ErrorActualizacion.verificacion => (
      TonoAviso.advertencia,
      Ico.warn,
      'No se pudo verificar la descarga',
      'La borramos. Sigues con la $actual.',
      'No coincide con la versión publicada. Para cuidar tu celular, no se '
          'instala.',
      reintentar,
    ),
    ErrorActualizacion.cancelada => (
      TonoAviso.info,
      Ico.info,
      'No se instaló',
      'Cancelaste la instalación.',
      null,
      (AccionActualizacion.actualizar, 'Actualizar', true),
    ),
    ErrorActualizacion.instalacion => (
      TonoAviso.info,
      Ico.info,
      'No se instaló',
      null,
      null,
      (AccionActualizacion.actualizar, 'Actualizar', true),
    ),
    ErrorActualizacion.sinPermiso => (
      TonoAviso.info,
      Ico.lock,
      'Falta el permiso de Android',
      'Sin él no se instala.',
      null,
      (AccionActualizacion.actualizar, 'Actualizar', true),
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
        ? 'Hay una versión nueva ($version)'
        : 'Hay una versión nueva',
    texto: info.canal == Canal.ios ? info.tiendaIos.nombre : null,
    accion: AccionActualizacion.actualizar,
    textoAccion: textoActualizar(info),
  );
}
