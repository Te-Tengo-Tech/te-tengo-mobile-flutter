import 'versiones.dart';

/// Where an iPhone app came from: the bar says «TestFlight» or «App Store» (CA-43.6).
enum TiendaIos {
  testflight('TestFlight'),
  appStore('App Store');

  const TiendaIos(this.nombre);

  final String nombre;
}

/// The running app: its version and how it updates (contract §12, «Which channel»).
class InfoApp {
  const InfoApp({
    required this.version,
    required this.canal,
    this.tiendaIos = TiendaIos.appStore,
  });

  /// `0.5.0` (a build suffix is ignored when comparing).
  final String version;
  final Canal canal;
  final TiendaIos tiendaIos;

  /// The platform line of «Acerca de»: «Android · Google Play», «iPhone · TestFlight»…
  String get plataforma => switch (canal) {
    Canal.pwa => 'Aplicación web',
    Canal.apk => 'Android',
    Canal.play => 'Android · Google Play',
    Canal.ios => 'iPhone · ${tiendaIos.nombre}',
  };

  /// «Google Play», «App Store» or «TestFlight»: the store that updates this app.
  String? get tienda => switch (canal) {
    Canal.play => 'Google Play',
    Canal.ios => tiendaIos.nombre,
    Canal.pwa || Canal.apk => null,
  };
}

/// The installer package of Google Play (`installerStore` on Android).
const instaladorGooglePlay = 'com.android.vending';

/// The channel of this app: the web app reads `pwa`; Android reads `play` when Google Play
/// installed it and `apk` otherwise; the iPhone reads `ios`. Null on other systems.
Canal? canalPara({
  required bool web,
  required bool android,
  required bool ios,
  String? instalador,
}) {
  if (web) return Canal.pwa;
  if (android) {
    return instalador == instaladorGooglePlay ? Canal.play : Canal.apk;
  }
  if (ios) return Canal.ios;
  return null;
}

/// TestFlight when the receipt says so (`com.apple.testflight`), the App Store otherwise.
TiendaIos tiendaIosPara(String? instalador) =>
    instalador == 'com.apple.testflight'
    ? TiendaIos.testflight
    : TiendaIos.appStore;

/// Why the app looks for a new version.
enum MotivoBusqueda {
  /// The app opened.
  abrir,

  /// The app came back from the background.
  reanudar,

  /// Once a day while the app stays open.
  diaria,

  /// «Buscar actualizaciones» in «Acerca de».
  manual,
}

/// How often the app asks `GET /api/versiones` **[implementation choice]**: when it opens, once a
/// day while it stays open, on «Buscar actualizaciones», and when it comes back from the
/// background if the last answer is older than the API's `max-age` (5 minutes).
abstract final class PlanBusqueda {
  static const cadaDia = Duration(days: 1);
  static const alReanudar = Duration(minutes: 5);

  static bool debeBuscar(
    MotivoBusqueda motivo,
    DateTime ahora,
    DateTime? ultima,
  ) => switch (motivo) {
    MotivoBusqueda.abrir ||
    MotivoBusqueda.manual ||
    MotivoBusqueda.diaria => true,
    MotivoBusqueda.reanudar =>
      ultima == null || ahora.difference(ultima) >= alReanudar,
  };
}

/// What the update is doing now.
enum FaseActualizacion {
  /// Nothing in progress.
  quieta,

  /// «Buscando actualizaciones…» (only for «Buscar actualizaciones»).
  buscando,

  /// «Descargando 0.6.0» · «42 %» (APK), or Google Play downloading.
  descargando,

  /// «Comprobando la descarga…» (SHA-256, APK).
  comprobando,

  /// The verified APK waits for an alert or a live view to close before the installer opens
  /// (CA-43.9).
  esperando,

  /// The Android installer is open.
  instalando,

  /// «Actualizando…»: the web app reloads.
  recargando,
}

/// What went wrong, shown by the bar and «Acerca de» until the next action.
enum ErrorActualizacion {
  /// «Sin internet» · «No pudimos buscar.» (only in «Acerca de»).
  sinInternetAlBuscar,

  /// «Sin internet» · «No se pudo descargar.»
  sinInternet,

  /// «No se pudo descargar» · «Sigues con la 0.5.0.»
  descarga,

  /// «No se pudo verificar la descarga» · «La borramos. Sigues con la 0.5.0.»
  verificacion,

  /// «No se instaló» · «Cancelaste la instalación.»
  cancelada,

  /// «Falta el permiso de Android» · «Sin él no se instala.»
  sinPermiso,

  /// The installer refused the file (another signature, too little space…): «No se instaló».
  instalacion,
}

/// State of the app's own update (US-43).
class EstadoActualizacion {
  const EstadoActualizacion({
    this.info,
    this.versiones,
    this.fase = FaseActualizacion.quieta,
    this.progreso,
    this.error,
    this.revisadoEn,
    this.apkVerificado,
    this.pedirPermiso = false,
  });

  /// This app; null while unknown (then nothing about updates is shown).
  final InfoApp? info;

  /// The last answer of `GET /api/versiones`; null when there is none (an older backend answers
  /// 404, or there was no connection).
  final Versiones? versiones;
  final FaseActualizacion fase;

  /// 0 to 1 while downloading; null when unknown.
  final double? progreso;
  final ErrorActualizacion? error;

  /// «Revisado hoy a las 10:42.»
  final DateTime? revisadoEn;

  /// The downloaded APK whose SHA-256 matched: «Actualizar» opens the installer with it again,
  /// without downloading (after «Cancelar» in the installer or a missing permission).
  final String? apkVerificado;

  /// The installer needs Android's permission: show «Permite instalar la actualización».
  final bool pedirPermiso;

  /// The published version of this app's channel.
  VersionPublicada? get publicada {
    final i = info;
    return i == null ? null : versiones?.de(i.canal);
  }

  /// The new version, when this app is older (CA-43.4 to CA-43.6).
  VersionPublicada? get nueva {
    final p = publicada;
    final i = info;
    return p != null && i != null && p.hayNuevaPara(i.version) ? p : null;
  }

  /// Below `versionMinima` (CA-43.8).
  bool get obligatoria {
    final p = publicada;
    final i = info;
    return p != null && i != null && p.esObligatoriaPara(i.version);
  }

  /// The download, its check, the installer or the reload is going on.
  bool get enCurso => switch (fase) {
    FaseActualizacion.descargando ||
    FaseActualizacion.comprobando ||
    FaseActualizacion.esperando ||
    FaseActualizacion.instalando ||
    FaseActualizacion.recargando => true,
    FaseActualizacion.quieta || FaseActualizacion.buscando => false,
  };

  EstadoActualizacion copiar({
    InfoApp? info,
    Versiones? Function()? versiones,
    FaseActualizacion? fase,
    double? Function()? progreso,
    ErrorActualizacion? Function()? error,
    DateTime? revisadoEn,
    String? Function()? apkVerificado,
    bool? pedirPermiso,
  }) => EstadoActualizacion(
    info: info ?? this.info,
    versiones: versiones == null ? this.versiones : versiones(),
    fase: fase ?? this.fase,
    progreso: progreso == null ? this.progreso : progreso(),
    error: error == null ? this.error : error(),
    revisadoEn: revisadoEn ?? this.revisadoEn,
    apkVerificado: apkVerificado == null ? this.apkVerificado : apkVerificado(),
    pedirPermiso: pedirPermiso ?? this.pedirPermiso,
  );
}
