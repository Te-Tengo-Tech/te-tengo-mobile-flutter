import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/legal/presentation/pantallas_legales.dart';
import 'package:te_tengo/features/legal/presentation/textos_legales.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';

void main() {
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
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
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
    for (final s in seccionesConsentimiento) {
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
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Política de privacidad'));
    expect(find.byType(PantallaPolitica), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Términos de uso'));
    expect(find.byType(PantallaTerminos), findsOneWidget);
  });

  test('los textos dicen que el video se analiza en la PC de la casa', () {
    final consentimiento = seccionesConsentimiento
        .map((s) => s.texto)
        .join(' ');
    final politica = seccionesPolitica.expand((s) => s.$2).join(' ');
    final terminos = seccionesTerminos.expand((s) => s.$2).join(' ');
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

  test('las páginas legales se abren con o sin sesión', () {
    expect(Rutas.redirigir(null, Rutas.terminos), isNull);
    expect(Rutas.redirigir(null, Rutas.politica), isNull);
    expect(Rutas.redirigir(sesionTitular, Rutas.politica), isNull);
  });
}
