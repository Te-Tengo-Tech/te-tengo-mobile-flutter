import 'package:caregiver_app/core/red/problema_api.dart';
import 'package:caregiver_app/features/reportes/data/reportes_repositorio.dart';
import 'package:caregiver_app/features/reportes/domain/reporte_caida.dart';

class ReportesRepositorioFalso implements ReportesRepositorio {
  final enviados = <ReporteCaida>[];

  /// Thrown by the next sends, in order; null sends it.
  final errores = <ProblemaApi?>[];

  @override
  Future<ReporteRecibido> enviar(ReporteCaida reporte) async {
    if (errores.isNotEmpty) {
      final e = errores.removeAt(0);
      if (e != null) throw e;
    }
    enviados.add(reporte);
    return ReporteRecibido(
      id: 'r-${enviados.length}',
      recibidoEn: DateTime(2026, 9, 23, 10, 42),
      movimientosDisponibles: false,
    );
  }
}

const sinConexion = ProblemaApi(
  codigo: ProblemaApi.sinConexion,
  detalle: 'No hay conexión con Fall Alert. Revisa tu internet.',
);
