import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/pcs/data/pcs_repositorio.dart';
import 'package:te_tengo/features/pcs/domain/pc.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/datos.dart';

const _camaraJson = {
  'id': 'c1',
  'nombreHabitacion': 'Sala',
  'estadoConexion': 'EN_LINEA',
  'ultimaSenal': '2026-09-23T15:42:00Z',
  'pausadaHasta': null,
  'deteccionConfiable': true,
  'instaladaEn': '2026-08-03T14:00:00Z',
  'noConfiableDesde': null,
  'pcId': 'pc-1',
  'ambienteId': 'a-1',
  'nombreDispositivo': 'Webcam USB HD',
};

const _pcJson = {
  'id': 'pc-1',
  'nombre': 'Sala-Rosa',
  'sistemaOperativo': 'Windows 11 Home',
  'versionAgente': '0.5.0',
  'estadoConexion': 'EN_LINEA',
  'ultimaSenal': '2026-09-23T15:42:00Z',
  'vinculadaEn': '2026-08-03T14:00:00Z',
  'vinculadaPor': {'id': 'u-carmen', 'nombre': 'Carmen'},
  'origen': 'VINCULACION',
  'camaras': [_camaraJson],
  'camarasSinUsar': 1,
};

void main() {
  late AdaptadorFalso http;
  late PcsRepositorio repo;

  setUp(() {
    http = AdaptadorFalso();
    final c = ProviderContainer(
      overrides: [
        almacenSesionProvider.overrideWithValue(
          AlmacenSesionMemoria(sesionTitular),
        ),
        adaptadorHttpProvider.overrideWithValue(http),
      ],
    );
    addTearDown(c.dispose);
    repo = c.read(pcsRepositorioProvider);
  });

  test('GET /api/pcs', () async {
    http.cuando('GET', '/api/pcs', const Respuesta(200, [_pcJson]));
    final pcs = await repo.listar();
    final pc = pcs.single;
    expect(pc.nombre, 'Sala-Rosa');
    expect(pc.programa, 'Te Tengo Captura 0.5.0');
    expect(pc.enLinea, isTrue);
    expect(pc.vinculadaPor?.nombre, 'Carmen');
    expect(pc.origen, OrigenPc.vinculacion);
    expect(pc.camarasSinUsar, 1);
    final c = pc.camaras.single;
    expect(c.pcId, 'pc-1');
    expect(c.ambienteId, 'a-1');
    expect(c.nombreDispositivo, 'Webcam USB HD');
  });

  test('POST /api/vinculaciones/consulta, /aprobacion y /rechazo', () async {
    http
      ..cuando(
        'POST',
        '/api/vinculaciones/consulta',
        const Respuesta(200, {
          'codigo': 'KQWT-MXHD',
          'nombrePc': 'Sala-Rosa',
          'sistemaOperativo': 'Windows 11 Home',
          'versionAgente': '0.5.0',
          'expiraEn': '2026-09-23T15:52:00Z',
        }),
      )
      ..cuando(
        'POST',
        '/api/vinculaciones/aprobacion',
        const Respuesta(201, _pcJson),
      )
      ..cuando('POST', '/api/vinculaciones/rechazo', const Respuesta(204));
    final consulta = await repo.consultar('KQWT-MXHD');
    expect(consulta.nombrePc, 'Sala-Rosa');
    expect(consulta.expiraEn!.toUtc(), DateTime.utc(2026, 9, 23, 15, 52));
    expect((await repo.aprobar('KQWT-MXHD')).id, 'pc-1');
    await repo.rechazar('KQWT-MXHD');
    expect(
      [for (final p in http.peticiones) p.data],
      [
        {'codigo': 'KQWT-MXHD'},
        {'codigo': 'KQWT-MXHD'},
        {'codigo': 'KQWT-MXHD'},
      ],
    );
  });

  test('un código incorrecto llega con los intentos que quedan', () async {
    http.cuando(
      'POST',
      '/api/vinculaciones/consulta',
      Respuesta.problema(
        404,
        'CODIGO_INCORRECTO',
        extras: {'intentosRestantes': 3},
      ),
    );
    expect(
      () => repo.consultar('KQWT-MXHB'),
      throwsA(
        isA<ProblemaApi>()
            .having((e) => e.codigo, 'codigo', 'CODIGO_INCORRECTO')
            .having((e) => e.extras['intentosRestantes'], 'intentos', 3),
      ),
    );
  });

  test('GET /api/pcs/{id}/camaras y POST busqueda-de-camaras', () async {
    http
      ..cuando(
        'GET',
        '/api/pcs/pc-1/camaras',
        const Respuesta(200, [
          {
            'id': 'w1',
            'pcId': 'pc-1',
            'nombreDispositivo': 'Logitech C920',
            'enUso': false,
            'conectada': true,
            'ambienteId': null,
            'nombreHabitacion': null,
            'estadoConexion': null,
            'pausadaHasta': null,
            'detectadaEn': '2026-09-23T15:40:00Z',
          },
        ]),
      )
      ..cuando(
        'POST',
        '/api/pcs/pc-1/busqueda-de-camaras',
        const Respuesta(202),
      );
    final w = (await repo.camaras('pc-1')).single;
    expect(w.nombreDispositivo, 'Logitech C920');
    expect(w.enUso, isFalse);
    expect(w.conectada, isTrue);
    await repo.buscarCamaras('pc-1');
    expect(
      http.hechas('POST', '/api/pcs/pc-1/busqueda-de-camaras'),
      hasLength(1),
    );
  });

  test('PUT y DELETE /api/camaras/{id}/ambiente', () async {
    http
      ..cuando(
        'PUT',
        '/api/camaras/w1/ambiente',
        const Respuesta(200, _camaraJson),
      )
      ..cuando('DELETE', '/api/camaras/w1/ambiente', const Respuesta(204));
    final c = await repo.usarCamara('w1', nombreAmbiente: 'Dormitorio');
    expect(c.estado, EstadoConexion.enLinea);
    await repo.usarCamara('w1', ambienteId: 'a-1');
    await repo.dejarDeUsar('w1');
    expect(http.peticiones[0].data, {'nombreAmbiente': 'Dormitorio'});
    expect(http.peticiones[1].data, {'ambienteId': 'a-1'});
    expect(http.peticiones[2].method, 'DELETE');
  });

  test('GET /api/ambientes', () async {
    http.cuando(
      'GET',
      '/api/ambientes',
      const Respuesta(200, [
        {
          'id': 'a-1',
          'nombre': 'Sala',
          'camaras': [
            {
              'id': 'c1',
              'pcId': 'pc-1',
              'pcNombre': 'Sala-Rosa',
              'nombreDispositivo': 'Webcam USB HD',
              'estadoConexion': 'EN_LINEA',
            },
          ],
        },
        {'id': 'a-2', 'nombre': 'Comedor', 'camaras': <Object>[]},
      ]),
    );
    final lista = await repo.ambientes();
    expect(lista.first.conCamara, isTrue);
    expect(lista.first.camaras.single.pcNombre, 'Sala-Rosa');
    expect(lista.last.conCamara, isFalse);
  });

  test(
    'POST /api/camaras/{id}/vista-previa abre una sesión de vista en vivo',
    () async {
      http.cuando(
        'POST',
        '/api/camaras/w1/vista-previa',
        const Respuesta(201, {
          'sesionId': 'vp-1',
          'urlTransmision':
              'https://api.tetengo.pe/vivo/camaras/w1/index.m3u8?token=t',
          'urlWebrtc': null,
          'expiraEn': '2026-09-23T15:44:00Z',
          'modo': 'VIDEO',
        }),
      );
      final s = await repo.vistaPrevia('w1');
      expect(s.sesionId, 'vp-1');
      expect(s.urlWebrtc, isNull);
    },
  );
}
