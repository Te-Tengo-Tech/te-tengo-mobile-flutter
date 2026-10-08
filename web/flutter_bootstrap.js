{{flutter_js}}
{{flutter_build_config}}

// No `serviceWorkerSettings`: Flutter's own service worker (flutter_service_worker.js) is deprecated
// (flutter/flutter#156910) and would compete with ours for the same scope. The app registers a
// single worker, firebase-messaging-sw.js, from Dart: it caches the app for offline use and receives
// FCM web push (lib/core/web/, docs/WEB_PWA.md).
_flutter.loader.load();
