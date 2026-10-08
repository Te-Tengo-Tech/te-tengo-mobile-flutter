import 'entorno.dart';

/// Not a browser: every flag is false.
EntornoNavegador leerEntornoNavegador() => const EntornoNavegador();

Future<void> registrarTrabajadorServicio(String url) async {}

/// `Notification.permission`; null when the browser has no notifications.
String? permisoNotificacionesNavegador() => null;

Future<String?> pedirPermisoNotificacionesNavegador() async => null;

Stream<Map<String, Object?>> pushAbiertasNavegador() => const Stream.empty();

Map<String, Object?>? tomarPushInicialNavegador() => null;

void descargarEnNavegador(Uri url, String nombre) =>
    throw UnsupportedError('Solo en la web');
