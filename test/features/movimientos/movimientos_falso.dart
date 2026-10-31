import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/features/movimientos/data/movimientos_repositorio.dart';
import 'package:te_tengo/features/movimientos/domain/movimientos.dart';

final constanciaRosa = ConstanciaMovimientos(
  otorgadoEn: DateTime(2026, 8, 24, 10, 15),
  otorgadoPor: 'Rosa Huamán',
  representante: false,
  registradoPor: 'Carmen Huamán',
  versionTexto: '1',
);

class MovimientosRepositorioFalso implements MovimientosRepositorio {
  MovimientosRepositorioFalso({
    this.vigente = false,
    this.retencion,
    this.constanciaInicial,
  });

  bool vigente;
  int? retencion;
  ConstanciaMovimientos? constanciaInicial;
  DateTime? datosDesde = DateTime(2026, 8, 24);
  EliminacionMovimientos? eliminacion;
  final registros = <(String, bool, String)>[];
  final retenciones = <int?>[];
  int revocaciones = 0;
  ProblemaApi? errorRegistrar;
  ProblemaApi? errorRetencion;

  ConsentimientoMovimientos get _actual => ConsentimientoMovimientos(
    vigente: vigente,
    versionTextoVigente: '3',
    constancia: registros.isNotEmpty
        ? ConstanciaMovimientos(
            otorgadoEn: DateTime(2026, 9, 23, 10, 42),
            otorgadoPor: registros.last.$1,
            representante: registros.last.$2,
            registradoPor: 'Carmen Huamán',
            versionTexto: registros.last.$3,
          )
        : vigente
        ? constanciaInicial ?? constanciaRosa
        : null,
    eliminacion: eliminacion,
  );

  @override
  Future<ConsentimientoMovimientos> consentimiento() async => _actual;

  @override
  Future<ConsentimientoMovimientos> registrar({
    required String otorgadoPor,
    required bool representante,
    required String versionTexto,
  }) async {
    if (errorRegistrar != null) throw errorRegistrar!;
    registros.add((otorgadoPor, representante, versionTexto));
    vigente = true;
    return _actual;
  }

  @override
  Future<int?> revocar() async {
    revocaciones++;
    vigente = false;
    retencion = null;
    eliminacion = EliminacionMovimientos(
      terminada: false,
      archivos: 3,
      programadaEn: DateTime(2026, 9, 23, 10, 42),
    );
    return 3;
  }

  @override
  Future<MovimientosEnLaNube> nube() async => MovimientosEnLaNube(
    retencionDias: vigente ? retencion : null,
    opciones: const [7, 30, 90, 365],
    maximoRecomendadoDias: 365,
    mbMinimo: 40,
    mbMaximo: 80,
    consentimientoVigente: vigente,
    datosDesde: vigente && retencion != null ? datosDesde : null,
  );

  @override
  Future<MovimientosEnLaNube> cambiarRetencion(int? dias) async {
    if (errorRetencion != null) throw errorRetencion!;
    retenciones.add(dias);
    retencion = dias;
    return nube();
  }
}
