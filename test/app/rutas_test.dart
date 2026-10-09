import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';

import '../apoyo/datos.dart';

void main() {
  group('sin sesión', () {
    test('lleva a la bienvenida desde una pantalla privada', () {
      expect(Rutas.redirigir(null, Rutas.inicio), Rutas.bienvenida);
      expect(Rutas.redirigir(null, Rutas.ajustes), Rutas.bienvenida);
    });

    test('deja ver la bienvenida, el registro y el inicio de sesión', () {
      expect(Rutas.redirigir(null, Rutas.bienvenida), isNull);
      expect(Rutas.redirigir(null, Rutas.registro), isNull);
      expect(Rutas.redirigir(null, Rutas.iniciarSesion), isNull);
      expect(Rutas.redirigir(null, Rutas.enlaceEnviado), isNull);
    });

    test('deja abrir los enlaces de recuperación e invitación', () {
      expect(Rutas.redirigir(null, Rutas.nuevaContrasena), isNull);
      expect(Rutas.redirigir(null, '${Rutas.invitacion}/abc'), isNull);
    });

    test('deja ver cómo instalar la app web en el iPhone', () {
      expect(Rutas.redirigir(null, Rutas.instalar), isNull);
      expect(Rutas.redirigir(sesionSinHogar, Rutas.instalar), isNull);
      expect(Rutas.redirigir(sesionTitular, Rutas.instalar), isNull);
    });
  });

  group('sesión sin hogar', () {
    test('lleva a la configuración inicial', () {
      expect(
        Rutas.redirigir(sesionSinHogar, Rutas.inicio),
        Rutas.configPersona,
      );
      expect(
        Rutas.redirigir(sesionSinHogar, Rutas.bienvenida),
        Rutas.configPersona,
      );
    });

    test('deja ver la cuenta creada y los datos de la persona', () {
      expect(Rutas.redirigir(sesionSinHogar, Rutas.cuentaCreada), isNull);
      expect(Rutas.redirigir(sesionSinHogar, Rutas.configPersona), isNull);
    });
  });

  group('sesión con hogar', () {
    test('salta las pantallas de acceso al inicio', () {
      expect(Rutas.redirigir(sesionTitular, Rutas.bienvenida), Rutas.inicio);
      expect(Rutas.redirigir(sesionTitular, Rutas.iniciarSesion), Rutas.inicio);
      expect(Rutas.redirigir(sesionTitular, '/'), Rutas.inicio);
    });

    test('deja navegar por la app', () {
      expect(Rutas.redirigir(sesionTitular, Rutas.inicio), isNull);
      expect(
        Rutas.redirigir(sesionTitular, Rutas.configConsentimiento),
        isNull,
      );
    });
  });

  test('el arranque siempre se muestra', () {
    expect(Rutas.redirigir(null, Rutas.arranque), isNull);
    expect(Rutas.redirigir(sesionTitular, Rutas.arranque), isNull);
  });
}
