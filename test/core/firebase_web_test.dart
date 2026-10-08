import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/core/notificaciones/firebase_web.dart';
import 'package:te_tengo/core/notificaciones/notificaciones_push.dart';

const _completa = ConfiguracionFirebaseWeb(
  apiKey: 'clave',
  appId: '1:2:web:3',
  messagingSenderId: '2',
  projectId: 'proyecto',
  vapidKey: 'vapid',
  authDomain: 'proyecto.firebaseapp.com',
);

void main() {
  group('ConfiguracionFirebaseWeb', () {
    test('sin los defines no hay push en la web', () {
      const vacia = ConfiguracionFirebaseWeb(
        apiKey: '',
        appId: '',
        messagingSenderId: '',
        projectId: '',
        vapidKey: '',
      );
      expect(vacia.completa, isFalse);
      expect(vacia.opciones, isNull);
      // The worker still caches the app.
      expect(vacia.urlTrabajador, 'firebase-messaging-sw.js');
    });

    test('sin la clave VAPID tampoco', () {
      const sinVapid = ConfiguracionFirebaseWeb(
        apiKey: 'clave',
        appId: '1:2:web:3',
        messagingSenderId: '2',
        projectId: 'proyecto',
        vapidKey: '',
      );
      expect(sinVapid.completa, isFalse);
    });

    test('con la configuración da las opciones de Firebase', () {
      final o = _completa.opciones!;
      expect(o.apiKey, 'clave');
      expect(o.appId, '1:2:web:3');
      expect(o.messagingSenderId, '2');
      expect(o.projectId, 'proyecto');
      expect(o.authDomain, 'proyecto.firebaseapp.com');
      expect(o.storageBucket, isNull);
    });

    test('el worker es relativo al base href y lleva la configuración', () {
      final url = Uri.parse(_completa.urlTrabajador);
      expect(url.hasScheme, isFalse);
      expect(url.path, 'firebase-messaging-sw.js');
      expect(url.queryParameters, {
        'apiKey': 'clave',
        'appId': '1:2:web:3',
        'messagingSenderId': '2',
        'projectId': 'proyecto',
        'authDomain': 'proyecto.firebaseapp.com',
      });
      // The VAPID key is only used by the page (getToken), never put in the worker URL.
      expect(_completa.urlTrabajador, isNot(contains('vapid')));
    });
  });

  group('NotificacionesFirebase en la web', () {
    test('registra el celular con la plataforma WEB', () {
      expect(NotificacionesFirebase(esWeb: true).plataforma, 'WEB');
    });

    test('sin permiso del navegador no pide el token', () async {
      // Without a browser there is no granted permission: no prompt, no Firebase.
      expect(
        await NotificacionesFirebase(esWeb: true, web: _completa).token(),
        isNull,
      );
    });
  });
}
