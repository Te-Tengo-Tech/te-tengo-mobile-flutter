import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/core/notificaciones/avisos_nativos.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const canal = MethodChannel(AvisosNativos.nombreCanal);
  final mensajero =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => mensajero.setMockMethodCallHandler(canal, null));

  test('tomarInicial devuelve los datos del toque que abrió la app', () async {
    mensajero.setMockMethodCallHandler(canal, (llamada) async {
      expect(llamada.method, 'tomarInicial');
      return {'tipo': 'ALERTA_CAIDA', 'alertaId': 'a-1'};
    });
    final datos = await AvisosNativos().tomarInicial();
    expect(MensajePush.desdeDatos(datos!)?.alertaId, 'a-1');
  });

  test('sin toque, o sin el lado nativo, tomarInicial es null', () async {
    mensajero.setMockMethodCallHandler(canal, (_) async => null);
    expect(await AvisosNativos().tomarInicial(), isNull);
    mensajero.setMockMethodCallHandler(
      canal,
      (_) async => throw PlatformException(code: 'x'),
    );
    expect(await AvisosNativos().tomarInicial(), isNull);
  });

  test('un toque con la app abierta llega por abiertas', () async {
    final avisos = AvisosNativos();
    final abiertas = avisos.abiertas.first;
    await mensajero.handlePlatformMessage(
      AvisosNativos.nombreCanal,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('abierto', {'tipo': 'SE_LEVANTO', 'alertaId': 'a-2'}),
      ),
      (_) {},
    );
    expect((await abiertas)['alertaId'], 'a-2');
  });
}
