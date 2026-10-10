// Te Tengo service worker: the web app's only worker (docs/WEB_PWA.md).
//
// - Registered from Dart (lib/core/web/navegador_web.dart) at the base href scope: / on
//   https://app.tetengo.reqsai.tech/. Flutter's own flutter_service_worker.js
//   is deprecated and not registered (web/flutter_bootstrap.js).
// - Offline: network first for the app files, falling back to the last copy kept.
// - Push: FCM web push when the URL carries the Firebase web config
//   (`firebase-messaging-sw.js?apiKey=…&appId=…&messagingSenderId=…&projectId=…`), built from the
//   --dart-define values. Without it the worker only caches.
// - Every push shows a notification, also while a window of the app is visible (see the `push`
//   listener below).

'use strict';

// Firebase JS SDK version of FlutterFire's firebase_core_web (supportedFirebaseJsSdkVersion).
// Keep it equal to the version in pubspec.lock's firebase_core_web when upgrading FlutterFire.
const FIREBASE_SDK = '12.19.0';

const CACHE = 'te-tengo-app-v1';
const ALCANCE = self.registration.scope;

// The app shell, so the second visit already works offline.
const NUCLEO = [
  './',
  'flutter_bootstrap.js',
  'main.dart.js',
  'manifest.json',
  'favicon.png',
  'icons/Icon-192.png',
];

self.addEventListener('install', (evento) => {
  evento.waitUntil(
    caches
      .open(CACHE)
      .then((cache) =>
        Promise.allSettled(NUCLEO.map((ruta) => cache.add(new URL(ruta, ALCANCE)))),
      )
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (evento) => {
  evento.waitUntil(
    caches
      .keys()
      .then((nombres) =>
        Promise.all(nombres.filter((n) => n !== CACHE).map((n) => caches.delete(n))),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (evento) => {
  const pedido = evento.request;
  if (pedido.method !== 'GET' || pedido.headers.has('range')) return;
  if (!pedido.url.startsWith(ALCANCE)) return; // API, Firebase, CDN: never cached here.
  if (new URL(pedido.url).pathname.endsWith('firebase-messaging-sw.js')) return;
  evento.respondWith(redPrimero(evento));
});

async function redPrimero(evento) {
  const pedido = evento.request;
  const cache = await caches.open(CACHE);
  try {
    const respuesta = await fetch(pedido);
    if (respuesta.ok && respuesta.type === 'basic') {
      evento.waitUntil(cache.put(pedido, respuesta.clone()));
    }
    return respuesta;
  } catch (error) {
    const guardada = await cache.match(pedido, { ignoreSearch: pedido.mode === 'navigate' });
    if (guardada) return guardada;
    // Any address inside the app (?tt_push=…) opens the same page.
    if (pedido.mode === 'navigate') {
      const inicio = await cache.match(ALCANCE);
      if (inicio) return inicio;
    }
    throw error;
  }
}

// Every push shows a notification, with the backend's `tag` (the alert's id; API contract §7), so
// a later notice of the same alert replaces the earlier one. Registered before Firebase's own
// handler, which shows nothing while a window of the app is visible (it hands the push to the page)
// and, when none is, shows its own copy with the same tag, which just replaces this one. A fall
// must reach the screen even when the PWA is open in the background or on another tab, and WebKit
// may revoke the push subscription of a Home Screen app after pushes that show nothing.
// Notice types that stay on screen until dismissed (`TipoAviso.urgente()` in the backend).
const URGENTES = new Set([
  'ALERTA_CAIDA',
  'ALERTA_MOVIMIENTO_INESTABLE',
  'ALERTA_ACTUALIZADA_A_CAIDA',
  'CAIDA_CONFIRMADA',
  'ALERTA_ESCALADA',
  'SIN_CONTACTO_SECUNDARIO',
]);

self.addEventListener('push', (evento) => {
  let carga;
  try {
    carga = evento.data ? evento.data.json() : null;
  } catch (_) {
    carga = null;
  }
  if (!carga || typeof carga !== 'object') return;
  const datos = carga.data || {};
  const aviso = carga.notification || {};
  const tag = aviso.tag || datos.alertaId || datos.tipo || undefined;
  const urgente = aviso.requireInteraction === true || URGENTES.has(datos.tipo);
  evento.waitUntil(
    self.registration.showNotification(aviso.title || 'Te Tengo', {
      body: aviso.body || '',
      icon: aviso.icon || new URL('icons/Icon-192.png', ALCANCE).href,
      tag,
      // A later notice of the same alert (confirmed fall, escalation) alerts again.
      renotify: Boolean(tag) && urgente,
      requireInteraction: urgente,
      data: { FCM_MSG: carga },
    }),
  );
});

// A tapped notification opens the app on its screen. Registered before Firebase's own handler,
// which only opens `fcmOptions.link`; the route is chosen in Dart (rutaDePush in lib/app/push.dart).
self.addEventListener('notificationclick', (evento) => {
  const mensaje = evento.notification.data && evento.notification.data.FCM_MSG;
  if (!mensaje) return;
  evento.stopImmediatePropagation();
  evento.notification.close();
  evento.waitUntil(abrirApp(mensaje.data || {}));
});

async function abrirApp(datos) {
  const ventanas = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
  const ventana = ventanas.find((v) => v.url.startsWith(ALCANCE));
  if (ventana) {
    try {
      await ventana.focus();
    } catch (_) {
      // Some browsers refuse focus; the message still opens the screen.
    }
    ventana.postMessage({ tipo: 'tt-push-abierta', datos });
    return;
  }
  const url = new URL(ALCANCE);
  if (Object.keys(datos).length > 0) url.searchParams.set('tt_push', JSON.stringify(datos));
  await self.clients.openWindow(url.href);
}

const parametros = new URL(self.location.href).searchParams;
const configuracion = {
  apiKey: parametros.get('apiKey'),
  appId: parametros.get('appId'),
  messagingSenderId: parametros.get('messagingSenderId'),
  projectId: parametros.get('projectId'),
};
if (parametros.get('authDomain')) configuracion.authDomain = parametros.get('authDomain');
if (parametros.get('storageBucket')) configuracion.storageBucket = parametros.get('storageBucket');

if (Object.values(configuracion).every(Boolean)) {
  importScripts(
    `https://www.gstatic.com/firebasejs/${FIREBASE_SDK}/firebase-app-compat.js`,
    `https://www.gstatic.com/firebasejs/${FIREBASE_SDK}/firebase-messaging-compat.js`,
  );
  firebase.initializeApp(configuracion);
  const mensajeria = firebase.messaging();

  // The `push` listener above already showed this push; nothing more to show here.
  mensajeria.onBackgroundMessage(() => undefined);
}
