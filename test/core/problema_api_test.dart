import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/ui/aviso.dart';

import '../apoyo/app_de_prueba.dart';

DioException _error(int estado, Object? cuerpo) {
  final opciones = RequestOptions(path: '/api/x');
  return DioException.badResponse(
    statusCode: estado,
    requestOptions: opciones,
    response: Response(
      requestOptions: opciones,
      statusCode: estado,
      data: cuerpo,
    ),
  );
}

void main() {
  test('lee codigo, detail, campos y propiedades extra', () {
    final p = ProblemaApi.desde(
      _error(400, {
        'title': 'Datos inválidos',
        'status': 400,
        'detail': 'Revisa los campos.',
        'codigo': 'VALIDACION',
        'campos': {'correo': 'Escribe tu correo electrónico.'},
      }),
    );
    expect(p.codigo, 'VALIDACION');
    expect(p.detalle, 'Revisa los campos.');
    expect(p.estado, 400);
    expect(p.campos, {'correo': 'Escribe tu correo electrónico.'});

    final bloqueo = ProblemaApi.desde(
      _error(423, {
        'detail': 'Cuenta bloqueada.',
        'codigo': 'CUENTA_BLOQUEADA',
        'bloqueadaHasta': '2026-10-07T15:19:00Z',
      }),
    );
    expect(bloqueo.extras['bloqueadaHasta'], '2026-10-07T15:19:00Z');
  });

  test('sin respuesta del backend es SIN_CONEXION', () {
    final p = ProblemaApi.desde(
      DioException.connectionError(
        requestOptions: RequestOptions(path: '/api/x'),
        reason: 'offline',
      ),
    );
    expect(p.codigo, ProblemaApi.sinConexion);
  });

  testWidgets('MensajeProblema muestra el detalle del backend', (tester) async {
    await tester.pumpWidget(
      pantallaDePrueba(
        const Scaffold(
          body: MensajeProblema(
            ProblemaApi(codigo: 'X', detalle: 'La cámara no existe.'),
          ),
        ),
      ),
    );
    expect(find.text('La cámara no existe.'), findsOneWidget);
  });
}
