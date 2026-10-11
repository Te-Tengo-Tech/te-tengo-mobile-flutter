import '../core/sesion/sesion.dart';

/// App paths.
abstract final class Rutas {
  static const arranque = '/arranque';
  static const bienvenida = '/bienvenida';
  static const registro = '/registro';
  static const iniciarSesion = '/iniciar-sesion';
  static const recuperar = '/recuperar';
  static const enlaceEnviado = '/recuperar/enviado';

  /// Password reset deep link: `/nueva-contrasena?token=…`.
  static const nuevaContrasena = '/nueva-contrasena';
  static const enlaceVencido = '/nueva-contrasena/vencido';

  /// Invitation deep link: `/invitacion/{token}`.
  static const invitacion = '/invitacion';

  /// Legal documents: the terms and the privacy policy are reachable with or without a session.
  static const terminos = '/legal/terminos';
  static const politica = '/legal/privacidad';
  static const documentoConsentimiento = '/legal/consentimiento';

  /// Web app on an iPhone browser tab: how to add it to the home screen (docs/WEB_PWA.md).
  static const instalar = '/instalar';

  // Onboarding (a session without a household reaches only the first two).
  static const cuentaCreada = '/cuenta-creada';
  static const configPersona = '/configuracion/persona';
  static const configConsentimiento = '/configuracion/consentimiento';
  static const configConstancia = '/configuracion/constancia';
  static const configCamara = '/configuracion/camara';
  static const configFamilia = '/configuracion/familia';
  static const configAvisos = '/configuracion/avisos';
  static const configListo = '/configuracion/listo';

  // Tabs.
  static const inicio = '/inicio';
  static const historial = '/historial';
  static const familia = '/familia';
  static const ajustes = '/ajustes';

  // Screens on top of the tabs.
  static const accesoCreado = '/acceso-creado';
  static String camara(String id) => '/camara/$id';
  static String nombreCamara(String id) => '/camara/$id/nombre';
  static const vivo = '/vivo';
  static const accesos = '/accesos';
  static String alerta(String id) => '/alerta/$id';
  static String detalleAlerta(String id) => '/alertas/$id';
  static const ordenAviso = '/familia/orden';
  static const invitar = '/familia/invitar';
  static const personaCuidada = '/ajustes/persona';
  static const notificaciones = '/ajustes/notificaciones';
  static const privacidad = '/ajustes/privacidad';
  static const consentimiento = '/ajustes/consentimiento';
  static const constancia = '/ajustes/constancia';
  static const revocado = '/ajustes/privacidad/revocado';

  // Movement data (US-35, US-37).
  static const movimientos = '/ajustes/privacidad/movimientos';
  static const documentoMovimientos =
      '/ajustes/privacidad/movimientos/documento';
  static const movimientosBorrados = '/ajustes/privacidad/movimientos/borrando';
  static const nube = '/ajustes/privacidad/nube';

  // «¿Hubo una caída y no avisó?» (US-40).
  static const reporteCaida = '/reporte-de-caida';

  /// The report form, with the room and the moment already chosen when it comes from a camera
  /// or an unstable movement.
  static String reportar({String? habitacion, DateTime? cuando}) => Uri(
    path: reporteCaida,
    queryParameters: {
      'habitacion': ?habitacion,
      if (cuando != null) 'cuando': cuando.toIso8601String(),
    },
  ).toString();

  /// «Gracias…», or «Lo guardamos para enviarlo» with [guardado].
  static String reporteEnviado({bool guardado = false}) => Uri(
    path: '$reporteCaida/enviado',
    queryParameters: {if (guardado) 'guardado': '1'},
  ).toString();

  // Linking a PC (US-28) and choosing its cameras (US-29). `config=1` keeps them inside setup
  // step 3. The PC's QR opens `/vincular?codigo=…` (contract §9), on the web too (docs/WEB_PWA.md).
  static const vincular = '/vincular';
  static const escanear = '/vincular/escanear';
  static const escribirCodigo = '/vincular/codigo';

  /// The approval screen of a code (CA-28.4), also the PC QR's link.
  static String aprobarPc(String codigo, {bool config = false}) => Uri(
    path: vincular,
    queryParameters: {'codigo': codigo, if (config) 'config': '1'},
  ).toString();

  /// [ruta] with `config=1` when it runs inside setup step 3.
  static String enPaso(String ruta, {required bool config}) => config
      ? Uri(path: ruta, queryParameters: {'config': '1'}).toString()
      : ruta;

  /// «Cámaras» (Ajustes › «Cámaras y PCs»): the household's cameras by room and its PCs (US-30).
  static const pcs = '/pcs';
  static String pc(String id) => '/pcs/$id';
  static String pcVinculada(String id) => '/pcs/$id/vinculada';
  static String elegirCamaras(String id, {bool config = false}) =>
      enPaso('/pcs/$id/camaras', config: config);

  /// Reachable without a session.
  static const _publicas = [
    arranque,
    bienvenida,
    registro,
    iniciarSesion,
    recuperar,
    nuevaContrasena,
    invitacion,
  ];

  /// Reachable with a session that has no household yet.
  static const _sinHogar = [cuentaCreada, configPersona];

  /// Auth screens that a signed-in user skips.
  static const _soloSinSesion = [bienvenida, registro, iniciarSesion];

  static bool _bajo(String ubicacion, String ruta) =>
      ubicacion == ruta || ubicacion.startsWith('$ruta/');

  /// Router guards:
  /// - no session → welcome (public screens stay reachable);
  /// - session without household → onboarding (after registering, «Tu cuenta está lista»);
  /// - signed-in user on an auth screen → home.
  static String? redirigir(Sesion? sesion, String ubicacion) {
    if (_bajo(ubicacion, arranque) ||
        _bajo(ubicacion, instalar) ||
        _bajo(ubicacion, terminos) ||
        _bajo(ubicacion, politica)) {
      return null;
    }
    if (sesion == null) {
      return _publicas.any((r) => _bajo(ubicacion, r)) ? null : bienvenida;
    }
    if (_bajo(ubicacion, invitacion)) return null;
    if (!sesion.tieneHogar) {
      if (_sinHogar.any((r) => _bajo(ubicacion, r))) return null;
      // Just registered: confirm the account before the setup steps.
      return _bajo(ubicacion, registro) ? cuentaCreada : configPersona;
    }
    if (_soloSinSesion.any((r) => _bajo(ubicacion, r)) || ubicacion == '/') {
      return inicio;
    }
    return null;
  }
}
