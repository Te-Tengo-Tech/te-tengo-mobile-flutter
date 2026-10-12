import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/features/actualizaciones/domain/estado_actualizacion.dart';
import 'package:te_tengo/features/actualizaciones/domain/versiones.dart';

void main() {
  group('comparar versiones (contrato §12)', () {
    test('numéricamente por MAJOR.MINOR.PATCH', () {
      expect(esAnterior('0.5.0', '0.6.0'), isTrue);
      expect(esAnterior('0.9.0', '0.10.0'), isTrue);
      expect(esAnterior('0.5.10', '0.5.9'), isFalse);
      expect(esAnterior('1.0.0', '0.99.99'), isFalse);
      expect(esAnterior('0.6.0', '0.6.0'), isFalse);
    });

    test('sin el sufijo de compilación', () {
      expect(NumeroVersion.leer('0.5.3+12'), const NumeroVersion(0, 5, 3));
      expect(esAnterior('0.5.3+12', '0.5.3'), isFalse);
      expect(esAnterior('0.5.3+99', '0.5.4'), isTrue);
      expect(NumeroVersion.leer('0.6.0-rc.1'), const NumeroVersion(0, 6, 0));
    });

    test('una versión ilegible nunca es anterior', () {
      expect(NumeroVersion.leer(''), isNull);
      expect(NumeroVersion.leer('beta'), isNull);
      expect(NumeroVersion.leer('1.2.3.4'), isNull);
      expect(esAnterior(null, '0.6.0'), isFalse);
      expect(esAnterior('0.5.0', null), isFalse);
      expect(NumeroVersion.leer('1.2'), const NumeroVersion(1, 2, 0));
    });

    test('versión nueva y versión mínima', () {
      const v = VersionPublicada(version: '0.6.0', versionMinima: '0.5.1');
      expect(v.hayNuevaPara('0.5.0'), isTrue);
      expect(v.esObligatoriaPara('0.5.0'), isTrue);
      expect(v.esObligatoriaPara('0.5.1'), isFalse);
      expect(v.hayNuevaPara('0.6.0'), isFalse);
      const sinMinima = VersionPublicada(version: '0.6.0');
      expect(sinMinima.esObligatoriaPara('0.1.0'), isFalse);
    });
  });

  test('Versiones desde el JSON del contrato', () {
    final v = Versiones.desdeJson({
      'windows': {
        'version': '0.5.0',
        'versionMinima': null,
        'url': 'https://tetengo.example/captura.exe',
        'sha256': 'AB' * 32,
        'tamanoBytes': 52000000,
        'publicadaEn': '2026-10-10T15:00:00Z',
        'notas': ['Detecta mejor de noche.', ''],
      },
      'mac': null,
      'apk': {'version': '0.6.0', 'notas': []},
      'play': null,
      'ios': null,
      'pwa': {'version': 'no es versión'},
      'paginaDescargas': 'https://tetengo.reqsai.tech/descargas',
    });
    expect(v.windows!.sha256, 'ab' * 32);
    expect(v.windows!.notas, ['Detecta mejor de noche.']);
    expect(v.windows!.publicadaEn!.toUtc(), DateTime.utc(2026, 10, 10, 15));
    expect(v.apk!.version, '0.6.0');
    expect(v.pwa, isNull);
    expect(v.de(Canal.apk), same(v.apk));
    expect(v.captura('Windows 10 Pro'), same(v.windows));
    expect(v.captura('macOS 14'), isNull);
    expect(v.captura(null), isNull);
  });

  test('versión de Te Tengo Captura de una PC (CA-43.7)', () {
    const v = Versiones(
      windows: VersionPublicada(version: '0.5.0'),
      mac: VersionPublicada(version: '0.4.0'),
    );
    EstadoVersionPc estado(String? ver, String? so) =>
        estadoVersionPc(v, versionAgente: ver, sistemaOperativo: so);
    expect(estado('0.4.3', 'Windows 10 Pro'), EstadoVersionPc.anterior);
    expect(estado('0.5.0', 'Windows 11 Home'), EstadoVersionPc.alDia);
    expect(estado('0.4.0', 'macOS Sonoma'), EstadoVersionPc.alDia);
    expect(estado(null, 'Windows 10'), EstadoVersionPc.desconocido);
    expect(estado('0.4.3', null), EstadoVersionPc.desconocido);
    expect(
      estadoVersionPc(
        null,
        versionAgente: '0.4.3',
        sistemaOperativo: 'Windows',
      ),
      EstadoVersionPc.desconocido,
    );
  });

  group('canal (contrato §12, «Which channel»)', () {
    test('la web es pwa', () {
      expect(canalPara(web: true, android: true, ios: false), Canal.pwa);
    });
    test('Android instalado por Google Play es play; si no, apk', () {
      expect(
        canalPara(
          web: false,
          android: true,
          ios: false,
          instalador: 'com.android.vending',
        ),
        Canal.play,
      );
      expect(canalPara(web: false, android: true, ios: false), Canal.apk);
      expect(
        canalPara(
          web: false,
          android: true,
          ios: false,
          instalador: 'com.google.android.packageinstaller',
        ),
        Canal.apk,
      );
    });
    test('el iPhone es ios, con TestFlight o App Store', () {
      expect(canalPara(web: false, android: false, ios: true), Canal.ios);
      expect(tiendaIosPara('com.apple.testflight'), TiendaIos.testflight);
      expect(tiendaIosPara('com.apple'), TiendaIos.appStore);
      expect(tiendaIosPara(null), TiendaIos.appStore);
    });
    test('otro sistema no tiene canal', () {
      expect(canalPara(web: false, android: false, ios: false), isNull);
    });
    test('plataforma de «Acerca de»', () {
      const play = InfoApp(version: '0.5.0', canal: Canal.play);
      const ios = InfoApp(
        version: '0.5.0',
        canal: Canal.ios,
        tiendaIos: TiendaIos.testflight,
      );
      expect(play.plataforma, 'Android · Google Play');
      expect(ios.plataforma, 'iPhone · TestFlight');
      expect(ios.tienda, 'TestFlight');
      expect(const InfoApp(version: '0.5.0', canal: Canal.apk).tienda, isNull);
    });
  });

  group('cuándo buscar', () {
    final ahora = DateTime(2026, 10, 11, 10, 42);
    test('al abrir, a mano y una vez al día, siempre', () {
      for (final m in [
        MotivoBusqueda.abrir,
        MotivoBusqueda.manual,
        MotivoBusqueda.diaria,
      ]) {
        expect(PlanBusqueda.debeBuscar(m, ahora, ahora), isTrue);
      }
    });
    test('al volver, solo si la última respuesta tiene 5 minutos', () {
      expect(
        PlanBusqueda.debeBuscar(MotivoBusqueda.reanudar, ahora, null),
        isTrue,
      );
      expect(
        PlanBusqueda.debeBuscar(
          MotivoBusqueda.reanudar,
          ahora,
          ahora.subtract(const Duration(minutes: 4)),
        ),
        isFalse,
      );
      expect(
        PlanBusqueda.debeBuscar(
          MotivoBusqueda.reanudar,
          ahora,
          ahora.subtract(const Duration(minutes: 5)),
        ),
        isTrue,
      );
    });
  });

  test('tamaño de la descarga', () {
    expect(tamanoLegible(8400000), '8,4 MB');
    expect(tamanoLegible(1000), '0,1 MB');
  });
}
