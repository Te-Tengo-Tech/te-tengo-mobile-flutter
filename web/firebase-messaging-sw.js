// Te Tengo service worker: the web app's only worker (docs/WEB_PWA.md).
//
// - Registered from Dart (lib/core/web/navegador_web.dart) at the base href scope: / on
//   https://app.tetengo.reqsai.tech/. Flutter's own flutter_service_worker.js
//   is deprecated and not registered (web/flutter_bootstrap.js).
// - Offline: network first for the app files, falling back to the last copy kept.
// - Push: FCM web push when the URL carries the Firebase web config
//   (`firebase-messaging-sw.js?apiKey=…&appId=…&messagingSenderId=…&projectId=…`), built from the
//   --dart-define values. Without it the worker only caches.

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

  // Pushes with a `notification` block are shown by the SDK. A data-only push still needs a
  // visible notification: browsers (and iOS) revoke the subscription of silent pushes. Its text
  // must come from the backend (docs/BLOCKERS.md); the app name is the fallback.
  mensajeria.onBackgroundMessage((mensaje) => {
    if (mensaje.notification) return undefined;
    return self.registration.showNotification('Te Tengo', {
      icon: new URL('icons/Icon-192.png', ALCANCE).href,
      tag: (mensaje.data && mensaje.data.alertaId) || undefined,
      data: { FCM_MSG: mensaje },
    });
  });
}
