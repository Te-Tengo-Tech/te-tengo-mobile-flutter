import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/legal/presentation/pantallas_legales.dart';
import 'package:te_tengo/features/legal/presentation/textos_legales.dart';
import 'package:te_tengo/l10n/l10n.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/idioma.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';

void main() {
  final es = lookupAppLocalizations(const Locale('es'));

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion? sesion = sesionTitular,
    bool consentimiento = true,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        overrides: [
          hogarRepositorioProvider.overrideWithValue(
            HogarRepositorioFalso(hogarDeRosa(consentimiento: consentimiento)),
          ),
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          relojProvider.overrideWithValue(() => DateTime(2026, 9, 23, 10, 42)),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('al crear la cuenta se leen los términos y la política', (
    tester,
  ) async {
    await abrir(tester, Rutas.registro, sesion: null);
    await tocar(tester, find.text('Términos'));
    expect(find.byType(PantallaTerminos), findsOneWidget);
    expect(find.text('Las reglas para usar Te Tengo.'), findsNothing);
    expect(find.text('Qué es Te Tengo'), findsOneWidget);
    await verHasta(tester, find.text('Límites del servicio'));
    await tocar(tester, find.text('Ver la política de privacidad'));
    expect(find.byType(PantallaPolitica), findsOneWidget);
    await verHasta(tester, find.text('Tus derechos'));
    expect(find.textContaining('privacidad@tetengo.pe'), findsOneWidget);
    await volver(tester);
    await tester.pumpAndSettle();
    await volver(tester);
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Privacidad'));
    expect(find.byType(PantallaPolitica), findsOneWidget);
  });

  testWidgets('el resumen del consentimiento abre el documento completo', (
    tester,
  ) async {
    await abrir(tester, Rutas.consentimiento, consentimiento: false);
    await tocar(tester, find.text('Leer el documento completo'));
    expect(find.byType(PantallaDocumentoConsentimiento), findsOneWidget);
    expect(
      find.text(
        'Lo acepta Rosa o su representante legal antes de que la cámara '
        'envíe video.',
      ),
      findsOneWidget,
    );
    // The same text as the folded summary, one section each.
    for (final s in seccionesConsentimiento(es)) {
      await verHasta(tester, find.text(s.texto));
    }
    await verHasta(tester, find.text('Cómo se registra'));
    // Not given yet: no certificate.
    expect(find.text('Constancia'), findsNothing);
  });

  testWidgets('desde Privacidad se abren el documento aceptado y las reglas', (
    tester,
  ) async {
    await abrir(tester, Rutas.privacidad);
    await tocar(tester, find.text('Ver el documento aceptado'));
    expect(find.byType(PantallaDocumentoConsentimiento), findsOneWidget);
    await verHasta(tester, find.text('Constancia'));
    expect(find.text('Otorgado por'), findsOneWidget);
    await volver(tester);
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Política de privacidad'));
    expect(find.byType(PantallaPolitica), findsOneWidget);
    await volver(tester);
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Términos de uso'));
    expect(find.byType(PantallaTerminos), findsOneWidget);
  });

  test('los textos dicen que el video se analiza en la PC de la casa', () {
    final consentimiento = seccionesConsentimiento(
      es,
    ).map((s) => s.texto).join(' ');
    final politica = seccionesPolitica(es).expand((s) => s.$2).join(' ');
    final terminos = seccionesTerminos(es).expand((s) => s.$2).join(' ');
    for (final texto in [consentimiento, politica]) {
      expect(texto, isNot(contains('envía video a Te Tengo')));
      expect(texto, contains('PC de la casa'));
      expect(texto, contains('Microsoft Azure'));
      expect(texto, isNot(contains('Cloudflare R2')));
      expect(texto, contains('flujo transfronterizo'));
    }
    expect(
      consentimiento,
      contains('El video continuo nunca sale de la casa.'),
    );
    expect(politica, contains('con el consentimiento vigente'));
    expect(politica, contains('cada repetición'));
    expect(terminos, contains('permiso aparte'));
    expect(terminos, contains('la PC de la casa apagada'));
  });

  testWidgets('en inglés, los documentos legales están traducidos', (
    tester,
  ) async {
    usarIngles(tester);
    await abrir(tester, Rutas.privacidad);
    expect(find.text('Privacy'), findsOneWidget);
    await tocar(tester, find.text('View the accepted document'));
    expect(find.byType(PantallaDocumentoConsentimiento), findsOneWidget);
    expect(
      find.text(
        'Accepted by Rosa or their legal representative before the camera '
        'sends video.',
      ),
      findsOneWidget,
    );
    await verHasta(tester, find.text('Record'));
    expect(find.text('Given by'), findsOneWidget);
    // The record is shown as the backend stored it.
    expect(find.text('Rosa Huamán'), findsOneWidget);
    expect(find.text('Aug 3, 2026'), findsOneWidget);
    expect(find.text('9:12\u00a0AM'), findsOneWidget);
    await volver(tester);
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Terms of use'));
    expect(find.text('What Te Tengo is'), findsOneWidget);
    await verHasta(tester, find.text('View the privacy policy'));
  });

  test(
    'cada documento legal tiene las mismas secciones en los dos idiomas',
    () {
      final en = lookupAppLocalizations(const Locale('en'));
      expect(seccionesConsentimiento(en), hasLength(5));
      for (final f in [seccionesTerminos, seccionesPolitica]) {
        expect(
          [for (final s in f(en)) s.$2.length],
          [for (final s in f(es)) s.$2.length],
        );
      }
      expect(
        seccionesPolitica(en).last.$2.single,
        contains('privacidad@tetengo.pe'),
      );
    },
  );

  test('las páginas legales se abren con o sin sesión', () {
    expect(Rutas.redirigir(null, Rutas.terminos), isNull);
    expect(Rutas.redirigir(null, Rutas.politica), isNull);
    expect(Rutas.redirigir(sesionTitular, Rutas.politica), isNull);
  });
}
