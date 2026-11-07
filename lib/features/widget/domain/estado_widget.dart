import '../../../app/rutas.dart';
import '../../../core/formato.dart';
import '../../alertas/domain/alerta.dart';
import '../../pcs/domain/camaras_en_casa.dart';
import '../../../l10n/l10n.dart';

/// Color of the home-screen widget (`.wg.calma`, `.caida`…), always with its icon and text.
enum TonoWidget {
  /// «Todo tranquilo»: white, green badge.
  calma,

  /// A possible fall: the alert's red.
  caida,

  /// Unstable movement: mustard.
  inestable,

  /// A camera does not answer: amber with a dashed border.
  aviso,

  /// No cameras, no consent or no session: neutral.
  pausa,
}

/// What the home-screen widget shows (US-44, `widgetData`): the state of the household, never an
/// image of it (CA-44.1), and where a tap opens the app (CA-44.2).
class EstadoWidget {
  const EstadoWidget({
    required this.tono,
    required this.titulo,
    required this.linea,
    required this.destino,
    this.iniciales = '',
    this.nombre = '',
    this.conSesion = true,
  });

  /// Signed out (CA-44.3): no data of the household. In the phone's language.
  static EstadoWidget get sinSesion => sinSesionEn(textosDelSistema());

  /// [sinSesion] in [l]'s language.
  static EstadoWidget sinSesionEn(AppLocalizations l) => EstadoWidget(
    tono: TonoWidget.pausa,
    titulo: l.appTitulo,
    linea: l.widgetAbreLaApp,
    destino: Rutas.inicio,
    conSesion: false,
  );

  final TonoWidget tono;
  final String titulo;
  final String linea;

  /// The older adult's initials (the widget never shows a photo of the home) and first name.
  final String iniciales;
  final String nombre;

  /// The app's route a tap on the widget opens: the active alert, «Cámaras» or Inicio.
  final String destino;
  final bool conSesion;

  Map<String, String> aDatos() => {
    'tono': tono.name,
    'titulo': titulo,
    'linea': linea,
    'iniciales': iniciales,
    'nombre': nombre,
    'destino': destino,
    'conSesion': conSesion ? 'si' : 'no',
  };

  @override
  bool operator ==(Object other) =>
      other is EstadoWidget &&
      other.tono == tono &&
      other.titulo == titulo &&
      other.linea == linea &&
      other.iniciales == iniciales &&
      other.nombre == nombre &&
      other.destino == destino &&
      other.conSesion == conSesion;

  @override
  int get hashCode =>
      Object.hash(tono, titulo, linea, iniciales, nombre, destino, conSesion);
}

/// The widget's state (`widgetData`): an active alert first, then no cameras, no consent, cameras
/// that do not answer, and «Todo tranquilo». Its texts are in [l]'s language, the phone's by
/// default (the widget may be drawn from a background isolate).
EstadoWidget estadoDelHogar({
  required Alerta? alerta,
  required List<CamaraEnCasa> camaras,
  required bool conConsentimiento,
  required String nombreAdulto,
  AppLocalizations? l,
}) {
  final t = l ?? textosDelSistema();
  final iniciales = nombreAdulto
      .split(' ')
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p[0].toUpperCase())
      .join();
  final nombre = nombreAdulto.split(' ').first;
  EstadoWidget estado(
    TonoWidget tono,
    String titulo,
    String linea,
    String destino,
  ) => EstadoWidget(
    tono: tono,
    titulo: titulo,
    linea: linea,
    destino: destino,
    iniciales: iniciales,
    nombre: nombre,
  );
  if (alerta != null) {
    final caida = alerta.tipo == TipoAlerta.caida;
    return estado(
      caida ? TonoWidget.caida : TonoWidget.inestable,
      t.widgetTituloAlerta(
        caida
            ? (alerta.confirmada && alerta.recuperadaEn == null
                  ? 'confirmada'
                  : 'caida')
            : 'inestable',
      ),
      '${alerta.habitacion} · ${t.formato.hora(alerta.ocurridaEn)}',
      Rutas.alerta(alerta.id),
    );
  }
  if (camaras.isEmpty) {
    return estado(
      TonoWidget.pausa,
      t.widgetSinCamaras,
      t.widgetAbreTeTengo,
      Rutas.inicio,
    );
  }
  if (!conConsentimiento) {
    return estado(
      TonoWidget.pausa,
      t.widgetDeteccionDetenida,
      t.widgetFaltaConsentimiento,
      Rutas.inicio,
    );
  }
  final caidas = camaras.where((c) => c.noResponde).toList();
  if (caidas.isNotEmpty) {
    return estado(
      TonoWidget.aviso,
      t.widgetCamarasNoResponden(caidas.length),
      t.formato.enumerar([for (final c in caidas) c.habitacion]),
      Rutas.pcs,
    );
  }
  return estado(
    TonoWidget.calma,
    t.widgetTodoTranquilo,
    t.widgetCamaras(camaras.length),
    Rutas.inicio,
  );
}

/// The state from an alert push received with the app closed (Android): the push carries the room
/// and the time (contract §7), enough to show the alert until the app opens and reads the rest.
EstadoWidget? estadoDesdePush(
  Map<String, Object?> datos, {
  required EstadoWidget? anterior,
  AppLocalizations? l,
}) {
  final tipo = datos['tipo'];
  final caida = switch (tipo) {
    'ALERTA_CAIDA' ||
    'ALERTA_ACTUALIZADA_A_CAIDA' ||
    'CAIDA_CONFIRMADA' => true,
    'ALERTA_MOVIMIENTO_INESTABLE' => false,
    _ => null,
  };
  if (caida == null || anterior == null || !anterior.conSesion) return null;
  final habitacion = datos['habitacion'] as String? ?? '';
  final cuando = fechaDesdeJson(datos['ocurridaEn']);
  final alertaId = datos['alertaId'] as String?;
  final t = l ?? textosDelSistema();
  return EstadoWidget(
    tono: caida ? TonoWidget.caida : TonoWidget.inestable,
    titulo: t.widgetTituloAlerta(
      tipo == 'CAIDA_CONFIRMADA'
          ? 'confirmada'
          : caida
          ? 'caida'
          : 'inestable',
    ),
    linea: [
      if (habitacion.isNotEmpty) habitacion,
      if (cuando != null) t.formato.hora(cuando),
    ].join(' · '),
    destino: alertaId == null ? Rutas.inicio : Rutas.alerta(alertaId),
    iniciales: anterior.iniciales,
    nombre: anterior.nombre,
  );
}
