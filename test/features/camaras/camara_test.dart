import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';

void main() {
  test('lee la cámara tal como la devuelve el backend', () {
    final camara = Camara.desdeJson({
      'id': '0192f6e4-0000-7000-8000-000000000001',
      'nombreHabitacion': 'Sala',
      'estadoConexion': 'EN_LINEA',
      'ultimaSenal': '2026-10-07T15:04:31Z',
    });
    expect(camara.nombreHabitacion, 'Sala');
    expect(camara.estado, EstadoConexion.enLinea);
    expect(camara.ultimaSenal, isNotNull);
  });

  test('sin señal y desconectada', () {
    final camara = Camara.desdeJson({
      'id': 'x',
      'nombreHabitacion': 'Dormitorio',
      'estadoConexion': 'DESCONECTADA',
      'ultimaSenal': null,
    });
    expect(camara.estado, EstadoConexion.desconectada);
    expect(camara.ultimaSenal, isNull);
  });
}
