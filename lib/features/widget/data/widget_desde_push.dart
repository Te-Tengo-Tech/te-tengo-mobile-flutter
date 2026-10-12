import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

import '../domain/estado_widget.dart';
import 'widget_sistema.dart';

/// An alert push that arrives with the app closed or in the background (Android) redraws the widget
/// with the alert's room and time (CA-44.1), so the home screen does not say «Todo tranquilo» until
/// the app is opened. Runs in Firebase's background isolate: no providers, only the plugin.
@pragma('vm:entry-point')
Future<void> widgetDesdePushEnSegundoPlano(RemoteMessage mensaje) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    final sistema = WidgetHomeWidget();
    final nuevo = estadoDesdePush(mensaje.data, anterior: await sistema.leer());
    if (nuevo != null) await sistema.mostrar(nuevo, DateTime.now());
  } on Object catch (e) {
    debugPrint('Widget no actualizado desde el push: $e');
  }
}

/// Registers [widgetDesdePushEnSegundoPlano] on Android; without Firebase it does nothing.
void registrarWidgetDesdePush() {
  try {
    FirebaseMessaging.onBackgroundMessage(widgetDesdePushEnSegundoPlano);
  } on Object catch (e) {
    debugPrint('Sin actualización del widget desde el push: $e');
  }
}
