import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/ui/formulario.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/hogar/domain/hogar.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../familia/familia_falso.dart';
import 'hogar_falso.dart';

Finder campo(String etiqueta) => find.descendant(
  of: find.widgetWithText(CampoTexto, etiqueta),
  matching: find.byType(TextField),
);

void main() {
  late HogarRepositorioFalso repo;
  late AlmacenSesionMemoria almacen;

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion,
    Sesion sesion,
  ) async {
    usarTelefono(tester);
    almacen = AlmacenSesionMemoria(sesion);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        almacen: almacen,
        overrides: [
          hogarRepositorioProvider.overrideWithValue(repo),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => repo = HogarRepositorioFalso());

  group('paso 1 de la configuración', () {
    testWidgets(
      'CA-04.1: registra al adulto mayor y asocia el hogar a la cuenta',
      (tester) async {
        await abrir(tester, Rutas.configPersona, sesionSinHogar);
        expect(find.text('Paso 1 de 4'), findsOneWidget);
        await tester.enterText(campo('Nombre y apellido'), 'Rosa Huamán');
        await tester.enterText(campo('Edad'), '78');
        await tester.enterText(
          campo('Dirección de la vivienda'),
          'Jr. Los Pinos 482, San Miguel, Lima',
        );
        await tocar(tester, find.text('Vive solo(a)'));
        await tocar(tester, find.text('Guardar y continuar'));
        final creado = repo.creados.single;
        expect(creado.nombre, 'Rosa Huamán');
        expect(creado.edad, 78);
        expect(creado.direccion, 'Jr. Los Pinos 482, San Miguel, Lima');
        expect(creado.convivencia, Convivencia.solo);
        expect(almacen.actual?.hogarId, 'h-1');
        expect(find.text('Consentimiento'), findsOneWidget);
      },
    );

    testWidgets(
      'CA-04.2: si la cuenta ya tiene un adulto mayor, no permite otro',
      (tester) async {
        repo.errorCrear = const ProblemaApi(
          codigo: 'HOGAR_YA_REGISTRADO',
          detalle: 'Ya registrado.',
          estado: 409,
        );
        await abrir(tester, Rutas.configPersona, sesionSinHogar);
        await tester.enterText(campo('Nombre y apellido'), 'Rosa Huamán');
        await tester.enterText(campo('Edad'), '78');
        await tester.enterText(
          campo('Dirección de la vivienda'),
          'Jr. Los Pinos 482',
        );
        await tocar(tester, find.text('Vive conmigo'));
        await tocar(tester, find.text('Guardar y continuar'));
        expect(
          find.text('Cada cuenta cuida a una sola persona'),
          findsOneWidget,
        );
        expect(almacen.actual?.hogarId, isNull);
      },
    );

    testWidgets(
      'CA-04.3: con campos vacíos no guarda y resalta los faltantes',
      (tester) async {
        await abrir(tester, Rutas.configPersona, sesionSinHogar);
        await tester.enterText(campo('Nombre y apellido'), 'Rosa Huamán');
        await tocar(tester, find.text('Guardar y continuar'));
        expect(find.text('Faltan datos obligatorios'), findsOneWidget);
        expect(
          find.text('Escribe la dirección de la vivienda.'),
          findsOneWidget,
        );
        expect(find.text('Elige una opción.'), findsOneWidget);
        expect(find.text('Escribe su edad.'), findsOneWidget);
        expect(find.text('Escribe su nombre y apellido.'), findsNothing);
        expect(repo.creados, isEmpty);
      },
    );

    for (final edad in ['7', '49', '121']) {
      testWidgets('CA-04.3: rechaza la edad $edad', (tester) async {
        await abrir(tester, Rutas.configPersona, sesionSinHogar);
        await tester.enterText(campo('Nombre y apellido'), 'Rosa Huamán');
        await tester.enterText(campo('Edad'), edad);
        await tester.enterText(
          campo('Dirección de la vivienda'),
          'Jr. Los Pinos 482',
        );
        await tocar(tester, find.text('Vive solo(a)'));
        await tocar(tester, find.text('Guardar y continuar'));
        expect(find.text('Escribe una edad válida, en años.'), findsOneWidget);
        expect(repo.creados, isEmpty);
      });
    }

    testWidgets('CA-04.3: resalta la edad que rechaza el backend', (
      tester,
    ) async {
      repo.errorCrear = const ProblemaApi(
        codigo: 'VALIDACION',
        detalle: 'Revisa los datos.',
        estado: 400,
        campos: {'adultoMayor.edad': 'Escribe una edad válida, en años.'},
      );
      await abrir(tester, Rutas.configPersona, sesionSinHogar);
      await tester.enterText(campo('Nombre y apellido'), 'Rosa Huamán');
      await tester.enterText(campo('Edad'), '78');
      await tester.enterText(
        campo('Dirección de la vivienda'),
        'Jr. Los Pinos 482',
      );
      await tocar(tester, find.text('Vive solo(a)'));
      await tocar(tester, find.text('Guardar y continuar'));
      expect(find.text('Escribe una edad válida, en años.'), findsOneWidget);
    });
  });

  group('Ajustes › Persona cuidada', () {
    testWidgets('la titular cambia los datos', (tester) async {
      await abrir(tester, Rutas.ajustes, sesionTitular);
      expect(find.text('Rosa Huamán'), findsOneWidget);
      expect(find.text('Vive solo(a)'), findsOneWidget);
      await tocar(tester, find.text('Rosa Huamán'));
      expect(find.text('Persona cuidada'), findsOneWidget);
      await tester.enterText(
        campo('Dirección de la vivienda'),
        'Av. La Marina 100, San Miguel',
      );
      await tocar(tester, find.text('Guardar cambios'));
      expect(
        repo.actualizados.single.direccion,
        'Av. La Marina 100, San Miguel',
      );
      expect(repo.actualizados.single.edad, 78);
      expect(find.text('Cambios guardados'), findsOneWidget);
    });

    testWidgets('la titular cambia la edad y el teléfono se conserva', (
      tester,
    ) async {
      repo = HogarRepositorioFalso(
        Hogar(
          hogarId: 'h-1',
          adultoMayor: const AdultoMayor(
            nombre: 'Rosa Huamán',
            edad: 78,
            direccion: 'Jr. Los Pinos 482, San Miguel, Lima',
            convivencia: Convivencia.solo,
            telefono: '987 654 321',
          ),
          rol: Rol.titular,
          consentimiento: consentimientoVigente,
        ),
      );
      await abrir(tester, Rutas.personaCuidada, sesionTitular);
      expect(tester.widget<TextField>(campo('Edad')).controller!.text, '78');
      await tester.enterText(campo('Edad'), '79');
      await tocar(tester, find.text('Guardar cambios'));
      final guardado = repo.actualizados.single;
      expect(guardado.edad, 79);
      // The form has no phone field: the PUT sends the stored one back.
      expect(guardado.telefono, '987 654 321');
    });

    testWidgets('CA-04.2: indica que cada cuenta cuida a una sola persona', (
      tester,
    ) async {
      await abrir(tester, Rutas.personaCuidada, sesionTitular);
      await tocar(tester, find.text('Agregar otra persona'));
      expect(find.text('Cada cuenta cuida a una sola persona'), findsOneWidget);
    });

    testWidgets('un familiar invitado solo puede ver los datos', (
      tester,
    ) async {
      await abrir(tester, Rutas.personaCuidada, sesionInvitado);
      expect(
        find.text('Solo Carmen (titular) puede cambiar los datos de Rosa.'),
        findsOneWidget,
      );
      expect(find.text('Guardar cambios'), findsNothing);
      final campos = tester.widgetList<TextField>(find.byType(TextField));
      expect(campos.every((c) => c.enabled == false), isTrue);
    });
  });

  group('HogarRepositorioApi', () {
    ProviderContainer contenedor(AdaptadorFalso http) {
      final c = ProviderContainer(
        overrides: [
          almacenSesionProvider.overrideWithValue(
            AlmacenSesionMemoria(sesionTitular),
          ),
          adaptadorHttpProvider.overrideWithValue(http),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('POST /api/hogar envía adultoMayor y devuelve la Sesion', () async {
      final http = AdaptadorFalso()
        ..cuando('POST', '/api/hogar', Respuesta(201, sesionJson()));
      final s = await contenedor(
        http,
      ).read(hogarRepositorioProvider).crear(rosa);
      expect(s.hogarId, 'h-1');
      expect(http.peticiones.single.data, {
        'adultoMayor': {
          'nombre': 'Rosa Huamán',
          'edad': 78,
          'direccion': 'Jr. Los Pinos 482, San Miguel, Lima',
          'convivencia': 'SOLO',
          'telefono': null,
        },
      });
    });

    test('409 HOGAR_YA_REGISTRADO', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'POST',
          '/api/hogar',
          Respuesta.problema(409, 'HOGAR_YA_REGISTRADO'),
        );
      await expectLater(
        contenedor(http).read(hogarRepositorioProvider).crear(rosa),
        throwsA(
          isA<ProblemaApi>().having(
            (p) => p.codigo,
            'codigo',
            'HOGAR_YA_REGISTRADO',
          ),
        ),
      );
    });

    test('PUT /api/hogar/adulto-mayor', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'PUT',
          '/api/hogar/adulto-mayor',
          const Respuesta(200, {
            'nombre': 'Rosa Huamán',
            'edad': 79,
            'direccion': 'Av. 1',
            'convivencia': 'CON_CUIDADOR',
            'telefono': '987 654 321',
          }),
        );
      final a = await contenedor(http)
          .read(hogarRepositorioProvider)
          .actualizarAdultoMayor(
            const AdultoMayor(
              nombre: 'Rosa Huamán',
              edad: 79,
              direccion: 'Av. 1',
              convivencia: Convivencia.solo,
              telefono: '987 654 321',
            ),
          );
      expect(a.convivencia, Convivencia.conCuidador);
      expect(a.edad, 79);
      expect(a.telefono, '987 654 321');
      final cuerpo = http.peticiones.single.data as Map;
      expect(cuerpo['convivencia'], 'SOLO');
      expect(cuerpo['edad'], 79);
      expect(cuerpo['telefono'], '987 654 321');
    });

    test('GET /api/hogar lee el adulto mayor y el consentimiento', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'GET',
          '/api/hogar',
          const Respuesta(200, {
            'hogarId': 'h-1',
            'rol': 'TITULAR',
            'adultoMayor': {
              'nombre': 'Rosa Huamán',
              'edad': 78,
              'direccion': 'Jr. Los Pinos 482',
              'convivencia': 'CON_FAMILIAR',
              'telefono': '987 654 321',
            },
            'consentimiento': {
              'otorgadoEn': '2026-08-03T14:12:00Z',
              'otorgadoPor': 'Rosa Huamán',
              'registradoPor': {'id': 'u-carmen', 'nombre': 'Carmen Huamán'},
              'vistaEnVivoAceptada': true,
              'vigente': true,
            },
          }),
        );
      final h = await contenedor(http).read(hogarRepositorioProvider).obtener();
      expect(h.adultoMayor.nombrePila, 'Rosa');
      expect(h.adultoMayor.convivencia, Convivencia.conFamiliar);
      expect(h.adultoMayor.edad, 78);
      expect(h.adultoMayor.telefono, '987 654 321');
      expect(h.conConsentimiento, isTrue);
      expect(h.consentimiento!.registradoPor, 'Carmen Huamán');
    });
  });
}
