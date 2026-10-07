import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/ui/piezas.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/presentation/pantalla_camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import '../vivo/vivo_falso.dart';

void main() {
  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion sesion = sesionInvitado,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        overrides: [
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          alertasRepositorioProvider.overrideWithValue(
            AlertasRepositorioFalso([caidaSala(estado: EstadoAlerta.atendida)]),
          ),
          vistaEnVivoRepositorioProvider.overrideWithValue(
            VistaEnVivoRepositorioFalso(),
          ),
          relojProvider.overrideWithValue(
            () => DateTime(2026, 9, 23, 10, 42, 6),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('CA-08.4: en Ajustes el invitado ve lo que solo cambia la '
      'titular con candado', (tester) async {
    await abrir(tester, Rutas.ajustes);
    expect(find.text('Eres familiar invitado'), findsOneWidget);
    expect(
      find.text(
        'Ves las mismas alertas, clips e historial que Carmen. Lo marcado con '
        'candado solo lo puede cambiar Carmen (titular).',
      ),
      findsOneWidget,
    );
    expect(find.text('Cámara · Sala'), findsOneWidget);
    expect(find.text('En línea'), findsOneWidget);
    expect(find.text('Carmen → Luis · 5 min'), findsOneWidget);
    expect(find.text('Vigente desde el 3 ago 2026'), findsOneWidget);
    // Profile, alert order and privacy: «Solo ver».
    expect(find.byType(EtiquetaSoloVer), findsNWidgets(3));
    await verHasta(tester, find.text('Tu cuenta · Familiar invitado'));
    expect(find.text('luis.huaman.r@gmail.com'), findsOneWidget);
  });

  testWidgets('la titular ve las mismas filas sin candado', (tester) async {
    await abrir(tester, Rutas.ajustes, sesion: sesionTitular);
    expect(find.text('Eres familiar invitado'), findsNothing);
    expect(find.byType(EtiquetaSoloVer), findsNothing);
    expect(find.text('Orden de aviso y espera'), findsOneWidget);
    await tocar(tester, find.text('Cámara · Sala'));
    expect(find.byType(PantallaCamara), findsOneWidget);
  });

  testWidgets('CA-08.4: el invitado abre en solo lectura los datos de Rosa, el '
      'orden de aviso y la privacidad', (tester) async {
    await abrir(tester, Rutas.ajustes);
    await tocar(tester, find.text('Rosa Huamán'));
    expect(
      find.text('Solo Carmen (titular) puede cambiar los datos de Rosa.'),
      findsOneWidget,
    );
    expect(find.text('Guardar cambios'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Orden de aviso y espera'));
    expect(find.textContaining('Solo Carmen (titular) puede'), findsWidgets);
    expect(find.text('Guardar orden'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Privacidad y consentimiento'));
    expect(find.text('Revocar consentimiento'), findsNothing);
  });

  testWidgets('CA-08.4: el invitado ve el mismo historial', (tester) async {
    await abrir(tester, Rutas.historial);
    expect(find.text('ATENDIDA'), findsOneWidget);
  });

  testWidgets('CA-08.4: el invitado puede pausar la cámara, pero no '
      'renombrarla', (tester) async {
    await abrir(tester, Rutas.camara('c1'));
    expect(find.text('Pausar esta cámara'), findsOneWidget);
    await verHasta(tester, find.text('Nombre que aparece en las alertas'));
    expect(find.byType(EtiquetaSoloVer), findsOneWidget);
  });
}
