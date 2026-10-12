import 'dart:async';

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../../core/formato.dart';
import '../domain/estado_widget.dart';

/// The App Group the iOS widget extension shares with the app (docs/BLOCKERS.md: it needs the Apple
/// account's capability before it can be signed).
const grupoAppIos = 'group.tech.tetengo.teTengo';

/// Names of the Android `AppWidgetProvider`s (4 × 2 and 2 × 2) and of the iOS widget kind.
const widgetAndroidGrande = 'tech.tetengo.te_tengo.WidgetTeTengoGrande';
const widgetAndroidPequeno = 'tech.tetengo.te_tengo.WidgetTeTengoPequeno';
const widgetIos = 'TeTengoWidget';

/// What the widget's taps send to the app (the Android `PendingIntent`s and the iOS `widgetURL`):
/// `tetengo-widget://abrir?ir=/alerta/a-1`, or `…?ir=/inicio&vivo=1` for «Ver en vivo».
const esquemaWidget = 'tetengo-widget';

/// The home-screen widget of the phone (US-44): the app writes its state, the system draws it.
/// Replaceable in tests; the web has none.
abstract interface class WidgetDelSistema {
  bool get disponible;

  /// Saves [estado] with the time it was read, and asks the system to redraw the widgets.
  Future<void> mostrar(EstadoWidget estado, DateTime actualizado);

  /// The older adult's photo (`avatar()` of `widgetData`), a JPEG or PNG as the backend stores it;
  /// null brings the initials back.
  Future<void> mostrarFoto(Uint8List? imagen);

  /// The state last saved, for an alert push with the app closed.
  Future<EstadoWidget?> leer();

  /// The tap that launched the app, if it was the widget.
  Future<Uri?> abiertaDesde();

  /// Taps on the widget while the app runs.
  Stream<Uri?> get toques;
}

class WidgetNoDisponible implements WidgetDelSistema {
  const WidgetNoDisponible();

  @override
  bool get disponible => false;

  @override
  Future<void> mostrar(EstadoWidget estado, DateTime actualizado) async {}

  @override
  Future<void> mostrarFoto(Uint8List? imagen) async {}

  @override
  Future<EstadoWidget?> leer() async => null;

  @override
  Future<Uri?> abiertaDesde() async => null;

  @override
  Stream<Uri?> get toques => const Stream.empty();
}

/// Android (`AppWidgetProvider`s reading the plugin's shared preferences) and iOS (a WidgetKit
/// extension reading the App Group's defaults), through `home_widget`.
class WidgetHomeWidget implements WidgetDelSistema {
  WidgetHomeWidget() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      unawaited(HomeWidget.setAppGroupId(grupoAppIos).catchError((_) => null));
    }
  }

  static const _prefijo = 'tt_';

  @override
  bool get disponible => true;

  @override
  Future<void> mostrar(EstadoWidget estado, DateTime actualizado) async {
    try {
      final datos = {...estado.aDatos(), 'actualizado': hora(actualizado)};
      for (final MapEntry(:key, :value) in datos.entries) {
        await HomeWidget.saveWidgetData<String>('$_prefijo$key', value);
      }
      await Future.wait([
        HomeWidget.updateWidget(
          qualifiedAndroidName: widgetAndroidGrande,
          iOSName: widgetIos,
        ),
        if (defaultTargetPlatform == TargetPlatform.android)
          HomeWidget.updateWidget(qualifiedAndroidName: widgetAndroidPequeno),
      ]);
    } on Object catch (e) {
      // No widget on the home screen, or a platform without one: nothing to draw.
      debugPrint('Widget no actualizado: $e');
    }
  }

  @override
  Future<void> mostrarFoto(Uint8List? imagen) async {
    try {
      if (imagen == null) {
        // Also deletes the file the plugin wrote.
        await HomeWidget.saveWidgetData<String>('${_prefijo}foto', null);
      } else {
        await HomeWidget.saveFile(
          '${_prefijo}foto',
          await fotoRedonda(imagen),
          extension: 'png',
        );
      }
      await Future.wait([
        HomeWidget.updateWidget(
          qualifiedAndroidName: widgetAndroidGrande,
          iOSName: widgetIos,
        ),
        if (defaultTargetPlatform == TargetPlatform.android)
          HomeWidget.updateWidget(qualifiedAndroidName: widgetAndroidPequeno),
      ]);
    } on Object catch (e) {
      debugPrint('Foto del widget no actualizada: $e');
    }
  }

  @override
  Future<EstadoWidget?> leer() async {
    try {
      Future<String?> v(String k) =>
          HomeWidget.getWidgetData<String>('$_prefijo$k');
      final tono = await v('tono');
      if (tono == null) return null;
      return EstadoWidget(
        tono: TonoWidget.values.firstWhere(
          (t) => t.name == tono,
          orElse: () => TonoWidget.pausa,
        ),
        titulo: await v('titulo') ?? '',
        linea: await v('linea') ?? '',
        destino: await v('destino') ?? '/inicio',
        iniciales: await v('iniciales') ?? '',
        nombre: await v('nombre') ?? '',
        conSesion: await v('conSesion') != 'no',
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<Uri?> abiertaDesde() async {
    try {
      return await HomeWidget.initiallyLaunchedFromHomeWidget();
    } on Object {
      return null;
    }
  }

  @override
  Stream<Uri?> get toques => HomeWidget.widgetClicked;
}

final widgetDelSistemaProvider = Provider<WidgetDelSistema>(
  (ref) =>
      kIsWeb ||
          (defaultTargetPlatform != TargetPlatform.android &&
              defaultTargetPlatform != TargetPlatform.iOS)
      ? const WidgetNoDisponible()
      : WidgetHomeWidget(),
);

/// [imagen] cut to a circle of [lado] px as a PNG: Android's `RemoteViews` cannot round an image.
Future<Uint8List> fotoRedonda(Uint8List imagen, {int lado = 168}) async {
  final codec = await ui.instantiateImageCodec(
    imagen,
    targetWidth: lado,
    targetHeight: lado,
  );
  final cuadro = (await codec.getNextFrame()).image;
  final grabador = ui.PictureRecorder();
  final area = Rect.fromLTWH(0, 0, lado.toDouble(), lado.toDouble());
  ui.Canvas(grabador)
    ..clipPath(Path()..addOval(area))
    ..drawImageRect(
      cuadro,
      Rect.fromLTWH(0, 0, cuadro.width.toDouble(), cuadro.height.toDouble()),
      area,
      Paint()..filterQuality = FilterQuality.high,
    );
  final redonda = await grabador.endRecording().toImage(lado, lado);
  final datos = await redonda.toByteData(format: ui.ImageByteFormat.png);
  cuadro.dispose();
  redonda.dispose();
  codec.dispose();
  return datos!.buffer.asUint8List();
}
