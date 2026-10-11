import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/features/repeticion/data/repeticiones_repositorio.dart';
import 'package:te_tengo/features/repeticion/domain/repeticion.dart';

class RepeticionesRepositorioFalso implements RepeticionesRepositorio {
  final creadas = <(String, DateTime, DateTime)>[];
  final pedidas = <(String, DateTime, DateTime)>[];
  final cerradas = <String>[];
  List<AccesoRepeticion> lista = [];
  ProblemaApi? errorCrear;
  ProblemaApi? errorArchivos;
  DateTime? disponiblesDesde = DateTime(2026, 8, 24);

  /// Files of 5 minutes covering each window, except [sinArchivos].
  List<(DateTime, DateTime)> sinArchivos = [];

  /// Files whose PC uploaded no light file (an older Te Tengo Captura).
  bool sinLigeros = false;

  Repeticion _repeticion(String camaraId, DateTime desde, DateTime hasta) {
    final archivos = <ArchivoMovimientos>[];
    var t = desde;
    var i = 0;
    while (t.isBefore(hasta)) {
      final f = t.add(const Duration(minutes: 5));
      final hueco = sinArchivos.any((h) => t.isBefore(h.$2) && f.isAfter(h.$1));
      if (!hueco) {
        archivos.add(
          ArchivoMovimientos(
            id: 'f${i++}-${t.millisecondsSinceEpoch}',
            desde: t,
            hasta: f.isAfter(hasta) ? hasta : f,
            url:
                'https://movimientos.tetengo.pe/$camaraId/${t.millisecondsSinceEpoch}.parquet',
            sha256: 'abc',
            ligero: sinLigeros
                ? null
                : ArchivoLigero(
                    url:
                        'https://movimientos.tetengo.pe/$camaraId/${t.millisecondsSinceEpoch}.ttmov',
                    sha256: 'def',
                  ),
          ),
        );
      }
      t = f;
    }
    return Repeticion(
      id: 'rp-1',
      camaraId: camaraId,
      habitacion: 'Sala',
      desde: desde,
      hasta: hasta,
      disponiblesDesde: disponiblesDesde,
      archivos: archivos,
    );
  }

  @override
  Future<Repeticion> crear(
    String camaraId,
    DateTime desde,
    DateTime hasta,
  ) async {
    if (errorCrear != null) throw errorCrear!;
    creadas.add((camaraId, desde, hasta));
    return _repeticion(camaraId, desde, hasta);
  }

  @override
  Future<Repeticion> archivos(String id, DateTime desde, DateTime hasta) async {
    if (errorArchivos != null) throw errorArchivos!;
    pedidas.add((id, desde, hasta));
    return _repeticion('c1', desde, hasta);
  }

  @override
  Future<void> cerrar(String id) async => cerradas.add(id);

  @override
  Future<List<AccesoRepeticion>> accesos() async => lista;
}
