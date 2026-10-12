import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/movimientos/data/fuente_fotogramas.dart';
import 'package:te_tengo/features/movimientos/domain/fotogramas.dart';

import '../../apoyo/app_de_prueba.dart';
import '../alertas/alertas_falso.dart';
import '../alertas/apoyo_alertas.dart';

class _FuenteFalsa implements FuenteFotogramas {
  _FuenteFalsa({this.falla = false});

  final bool falla;
  final cargadas = <String>[];

  @override
  Future<List<Fotograma>> cargar(String url, {String? sha256Esperado}) async {
    cargadas.add(url);
    if (falla) throw const FormatException('dañado');
    return [
      Fotograma(
        en: DateTime(2026, 9, 23, 10, 41, 40),
        puntos: List.filled(17, const Offset(0.5, 0.5)),
      ),
    ];
  }
}

void main() {
  Future<void> abrir(
    WidgetTester tester,
    EnlaceClip enlace, {
    FuenteFotogramas? fuente,
  }) async {
    final alertas = AlertasRepositorioFalso([
      caidaSala(estado: EstadoAlerta.atendida),
    ])..enlaces.add(enlace);
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.detalleAlerta('a-1'),
      alertas: alertas,
      overrides: [
        if (fuente != null) fuenteFotogramasProvider.overrideWithValue(fuente),
      ],
    );
    // The bottom of the clip card.
    await verHasta(
      tester,
      ayudaCon('El clip dura 12 s: 6 s antes y 6 s después de la alerta.'),
    );
  }

  Switch interruptor(WidgetTester tester) => tester.widget(find.byType(Switch));

  testWidgets('CA-36.2: sin el permiso de movimientos dice por qué', (
    tester,
  ) async {
    await abrir(
      tester,
      const EnlaceClip(
        url: 'https://clips/a-1.mp4',
        puntosNoDisponibles: 'SIN_CONSENTIMIENTO',
      ),
    );
    expect(find.text('Puntos del cuerpo'), findsOneWidget);
    expect(interruptor(tester).onChanged, isNull);
    expect(
      find.text(
        'No disponibles: falta el permiso de Rosa para guardar movimientos.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('CA-36.2: un clip sin puntos lo dice', (tester) async {
    await abrir(
      tester,
      const EnlaceClip(
        url: 'https://clips/a-1.mp4',
        puntosNoDisponibles: 'SIN_ARCHIVO',
      ),
    );
    expect(
      find.text('No disponibles: este clip no los tiene.'),
      findsOneWidget,
    );
  });

  testWidgets('una PC anterior que no subió el archivo ligero lo dice', (
    tester,
  ) async {
    final fuente = _FuenteFalsa();
    await abrir(
      tester,
      const EnlaceClip(
        url: 'https://clips/a-1.mp4',
        puntos: 'https://puntos/a-1.parquet',
      ),
      fuente: fuente,
    );
    expect(fuente.cargadas, isEmpty); // never the Parquet file
    expect(interruptor(tester).onChanged, isNull);
    expect(
      find.text('No disponibles: este clip no los tiene.'),
      findsOneWidget,
    );
  });

  testWidgets('si no se pudieron cargar lo dice', (tester) async {
    await abrir(
      tester,
      const EnlaceClip(
        url: 'https://clips/a-1.mp4',
        puntos: 'https://puntos/a-1.parquet',
        puntosLigeros: 'https://puntos/a-1.ttmov',
      ),
      fuente: _FuenteFalsa(falla: true),
    );
    expect(interruptor(tester).onChanged, isNull);
    expect(find.text('No disponibles: no se pudieron cargar.'), findsOneWidget);
  });

  testWidgets('un backend sin el campo no muestra el interruptor', (
    tester,
  ) async {
    await abrir(tester, const EnlaceClip(url: 'https://clips/a-1.mp4'));
    expect(find.text('Puntos del cuerpo'), findsNothing);
  });

  testWidgets('CA-36.1: se dibujan desde el archivo ligero y se apagan', (
    tester,
  ) async {
    final fuente = _FuenteFalsa();
    await abrir(
      tester,
      const EnlaceClip(
        url: 'https://clips/a-1.mp4',
        puntos: 'https://puntos/a-1.parquet',
        puntosLigeros: 'https://puntos/a-1.ttmov',
      ),
      fuente: fuente,
    );
    expect(fuente.cargadas, ['https://puntos/a-1.ttmov']);
    expect(interruptor(tester).value, isTrue);
    expect(find.textContaining('No disponibles'), findsNothing);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(interruptor(tester).value, isFalse);
  });

  test('el enlace del clip lee los puntos', () {
    final e = EnlaceClip.desdeJson({
      'url': 'u',
      'expiraEn': '2026-09-23T15:50:00Z',
      'puntos': {
        'url': 'p',
        'expiraEn': '2026-09-23T15:50:00Z',
        'ligero': {'url': 'l'},
      },
      'puntosNoDisponibles': null,
    });
    expect(e.puntos, 'p');
    expect(e.puntosLigeros, 'l');
    expect(
      EnlaceClip.desdeJson({
        'url': 'u',
        'puntos': {'url': 'p', 'ligero': null},
      }).puntosLigeros,
      isNull,
    );
    expect(
      EnlaceClip.desdeJson({
        'url': 'u',
        'puntos': null,
        'puntosNoDisponibles': 'SIN_ARCHIVO',
      }).puntosNoDisponibles,
      'SIN_ARCHIVO',
    );
  });
}
