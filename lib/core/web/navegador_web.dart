import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'entorno.dart';

/// Message that `web/firebase-messaging-sw.js` posts to an open window when a notification is
/// tapped: `{tipo: 'tt-push-abierta', datos: {tipo, alertaId?, …}}`.
const _pushAbierta = 'tt-push-abierta';

/// Query parameter with the push data when the tap had to open a new window.
const _parametroPush = 'tt_push';

bool _tiene(JSObject objeto, String propiedad) => objeto.has(propiedad);

EntornoNavegador leerEntornoNavegador() {
  final ventana = web.window;
  final navegador = ventana.navigator;
  final agente = navegador.userAgent;
  final esIos =
      RegExp('iPhone|iPad|iPod').hasMatch(agente) ||
      // iPadOS asks for the desktop site and reports a Mac with a touch screen.
      (agente.contains('Macintosh') && navegador.maxTouchPoints > 1);
  final instalada =
      ventana.matchMedia('(display-mode: standalone)').matches ||
      // Safari's own flag for home-screen web apps.
      navegador.getProperty<JSAny?>('standalone'.toJS)?.dartify() == true;
  return EntornoNavegador(
    esWeb: true,
    esIos: esIos,
    instalada: instalada,
    pushDisponible:
        _tiene(ventana, 'Notification') &&
        _tiene(ventana, 'PushManager') &&
        _tiene(navegador, 'serviceWorker'),
  );
}

/// Registers the app's only service worker (offline cache and FCM web push) at the base href scope,
/// and removes Flutter's deprecated worker if an earlier build left it there.
Future<void> registrarTrabajadorServicio(String url) async {
  final navegador = web.window.navigator;
  if (!_tiene(navegador, 'serviceWorker')) return;
  try {
    final trabajadores = navegador.serviceWorker;
    for (final r in (await trabajadores.getRegistrations().toDart).toDart) {
      final script = (r.active ?? r.waiting ?? r.installing)?.scriptURL ?? '';
      if (script.contains('flutter_service_worker.js')) {
        await r.unregister().toDart;
      }
    }
    await trabajadores.register(url.toJS).toDart;
  } on Object catch (e) {
    debugPrint('Sin service worker: $e');
  }
}

String? permisoNotificacionesNavegador() =>
    _tiene(web.window, 'Notification') ? web.Notification.permission : null;

/// Must run inside the tap that asks for it: Safari ignores a request without a user gesture.
Future<String?> pedirPermisoNotificacionesNavegador() async {
  if (!_tiene(web.window, 'Notification')) return null;
  try {
    return (await web.Notification.requestPermission().toDart).toDart;
  } on Object catch (e) {
    debugPrint('Sin permiso de notificaciones: $e');
    return null;
  }
}

Map<String, Object?>? _comoMapa(Object? valor) => valor is Map
    ? valor.map((k, v) => MapEntry('$k', v is String ? v : v?.toString()))
    : null;

/// Notifications tapped while a window of the app is open.
Stream<Map<String, Object?>> pushAbiertasNavegador() {
  final navegador = web.window.navigator;
  if (!_tiene(navegador, 'serviceWorker')) return const Stream.empty();
  return web.EventStreamProviders.messageEvent
      .forTarget(navegador.serviceWorker)
      .map((e) => e.data.dartify())
      .where((d) => d is Map && d['tipo'] == _pushAbierta)
      .map((d) => _comoMapa((d as Map)['datos']))
      .where((d) => d != null)
      .cast<Map<String, Object?>>();
}

/// The push whose tap opened this window (`?tt_push=`). It is removed from the address, so a reload
/// does not open it again.
Map<String, Object?>? tomarPushInicialNavegador() {
  final actual = Uri.base;
  final texto = actual.queryParameters[_parametroPush];
  if (texto == null) return null;
  final resto = Map.of(actual.queryParameters)..remove(_parametroPush);
  final limpia = resto.isEmpty
      ? actual.replace(query: '')
      : actual.replace(queryParameters: resto);
  try {
    web.window.history.replaceState(
      web.window.history.state,
      '',
      limpia.toString().replaceFirst(RegExp(r'\?(?=#|$)'), ''),
    );
  } on Object {
    // The address keeps the parameter; nothing else depends on it.
  }
  try {
    return _comoMapa(jsonDecode(texto));
  } on FormatException {
    return null;
  }
}

/// Downloads through a link: the pre-signed URL answers with `Content-Disposition: attachment`
/// (`descarga=true`), so the browser saves the file instead of leaving the app.
void descargarEnNavegador(Uri url, String nombre) {
  final enlace = web.HTMLAnchorElement()
    ..href = url.toString()
    ..download = nombre
    ..rel = 'noopener';
  web.document.body?.append(enlace);
  enlace.click();
  enlace.remove();
}

/// The Fullscreen API exists and is allowed. False in Safari on iPhone, which only offers it on iPad
/// (MDN browser-compat-data for `Document.fullscreenEnabled` and `Element.requestFullscreen`: «Only
/// available on iPad, not on iPhone»). Safari before 16.4 has only the `webkit` prefix.
bool pantallaCompletaDisponibleNavegador() {
  final documento = web.document;
  bool verdadero(String propiedad) =>
      documento.getProperty<JSAny?>(propiedad.toJS)?.dartify() == true;
  return verdadero('fullscreenEnabled') || verdadero('webkitFullscreenEnabled');
}

/// Puts the whole page in full screen. Must run inside the tap that asks for it: the Fullscreen API
/// needs transient user activation (MDN, `Element.requestFullscreen()`, «Security»). An installed
/// PWA may lock the orientation to portrait (manifest), so the orientation is released while in full
/// screen where the browser allows it (`ScreenOrientation.lock()` needs full screen in Chrome).
void entrarPantallaCompletaNavegador() {
  final raiz = web.document.documentElement;
  if (raiz == null) return;
  final metodo = raiz.has('requestFullscreen')
      ? 'requestFullscreen'
      : raiz.has('webkitRequestFullscreen')
      ? 'webkitRequestFullscreen'
      : null;
  if (metodo == null) return;
  try {
    final resultado = raiz.callMethod<JSAny?>(metodo.toJS);
    if (resultado != null && resultado.isA<JSPromise>()) {
      (resultado as JSPromise).toDart.then(
        (_) => _liberarOrientacion(),
        onError: (Object e) => debugPrint('Sin pantalla completa: $e'),
      );
    }
  } on Object catch (e) {
    debugPrint('Sin pantalla completa: $e');
  }
}

void _liberarOrientacion() {
  try {
    web.window.screen.orientation
        .lock('any')
        .toDart
        .then((_) {}, onError: (Object _) {});
  } on Object {
    // Safari has no `lock()`; the page keeps the browser's orientation.
  }
}

JSAny? _elementoEnPantallaCompleta() {
  final documento = web.document;
  return documento.getProperty<JSAny?>('fullscreenElement'.toJS) ??
      documento.getProperty<JSAny?>('webkitFullscreenElement'.toJS);
}

void salirPantallaCompletaNavegador() {
  final documento = web.document;
  if (_elementoEnPantallaCompleta() == null) return;
  try {
    web.window.screen.orientation.unlock();
  } on Object {
    // Nothing was locked.
  }
  final metodo = documento.has('exitFullscreen')
      ? 'exitFullscreen'
      : documento.has('webkitExitFullscreen')
      ? 'webkitExitFullscreen'
      : null;
  if (metodo == null) return;
  try {
    final resultado = documento.callMethod<JSAny?>(metodo.toJS);
    if (resultado != null && resultado.isA<JSPromise>()) {
      (resultado as JSPromise).toDart.then((_) {}, onError: (Object _) {});
    }
  } on Object catch (e) {
    debugPrint('No se pudo salir de pantalla completa: $e');
  }
}

/// True when the page enters full screen, false when it leaves it (also by Esc or a swipe).
Stream<bool> cambiosPantallaCompletaNavegador() {
  Stream<bool> de(String evento) => web.EventStreamProvider<web.Event>(
    evento,
  ).forTarget(web.document).map((_) => _elementoEnPantallaCompleta() != null);
  return _unir([de('fullscreenchange'), de('webkitfullscreenchange')]);
}

/// The system's full-screen video player for one `<video>` element: WebKit's
/// `HTMLVideoElement.webkitEnterFullscreen()`, valid once the metadata has loaded
/// (`webkitSupportsFullscreen`) and only from a user action (Apple, «Safari HTML5 Audio and Video
/// Guide», Controlling Media with JavaScript). On iOS it shows the default controls only.
///
/// The plugin does not expose its element, so it is found by its source, [url].
bool videoAPantallaCompletaNavegador(String url) {
  final videos = web.document.querySelectorAll('video');
  web.HTMLVideoElement? video;
  for (var i = 0; i < videos.length; i++) {
    final v = videos.item(i);
    if (v != null && v.isA<web.HTMLVideoElement>()) {
      final candidato = v as web.HTMLVideoElement;
      if (candidato.src == url || candidato.currentSrc == url) {
        video = candidato;
      }
    }
  }
  if (video == null || !video.has('webkitEnterFullscreen')) return false;
  if (video.getProperty<JSAny?>('webkitSupportsFullscreen'.toJS)?.dartify() !=
      true) {
    return false;
  }
  try {
    video.callMethod<JSAny?>('webkitEnterFullscreen'.toJS);
    return true;
  } on Object catch (e) {
    debugPrint('Sin pantalla completa del video: $e');
    return false;
  }
}

/// Merges broadcast streams without `package:async`.
Stream<T> _unir<T>(List<Stream<T>> flujos) {
  final suscripciones = <StreamSubscription<T>>[];
  late final StreamController<T> salida;
  salida = StreamController<T>.broadcast(
    onListen: () {
      for (final f in flujos) {
        suscripciones.add(f.listen(salida.add));
      }
    },
    onCancel: () {
      for (final s in suscripciones) {
        s.cancel();
      }
      suscripciones.clear();
    },
  );
  return salida.stream;
}
