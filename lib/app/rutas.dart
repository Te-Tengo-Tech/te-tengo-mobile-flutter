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
  static const configNombreCamara = '/configuracion/camara/nombre';
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
