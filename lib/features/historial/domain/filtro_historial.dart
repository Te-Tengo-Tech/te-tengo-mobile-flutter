import '../../alertas/data/alertas_repositorio.dart';
import '../../alertas/domain/alerta.dart';

/// Date range of the history filter.
enum RangoFecha {
  siete('Últimos 7 días'),
  treinta('Últimos 30 días'),
  todo('Todo');

  const RangoFecha(this.texto);

  final String texto;
}

/// Filters of the history (CA-25.2): date range, kind and state.
class FiltroHistorial {
  const FiltroHistorial({this.rango = RangoFecha.todo, this.tipo, this.estado});

  final RangoFecha rango;
  final TipoAlerta? tipo;
  final EstadoAlerta? estado;

  static const vacio = FiltroHistorial();

  /// Number of active filters («Filtrar (2)»).
  int get activos =>
      (rango != RangoFecha.todo ? 1 : 0) +
      (tipo != null ? 1 : 0) +
      (estado != null ? 1 : 0);

  FiltroHistorial con({
    RangoFecha? rango,
    TipoAlerta? tipo,
    EstadoAlerta? estado,
    bool sinTipo = false,
    bool sinEstado = false,
  }) => FiltroHistorial(
    rango: rango ?? this.rango,
    tipo: sinTipo ? null : tipo ?? this.tipo,
    estado: sinEstado ? null : estado ?? this.estado,
  );

  /// Query of `GET /api/alertas`: the last 7 days include today and the 6 before.
  FiltroAlertas aConsulta(DateTime hoy, {int pagina = 0, int tamano = 50}) {
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    return FiltroAlertas(
      tipo: tipo,
      estado: estado,
      desde: switch (rango) {
        RangoFecha.siete => inicioHoy.subtract(const Duration(days: 6)),
        RangoFecha.treinta => inicioHoy.subtract(const Duration(days: 29)),
        RangoFecha.todo => null,
      },
      pagina: pagina,
      tamano: tamano,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FiltroHistorial &&
      other.rango == rango &&
      other.tipo == tipo &&
      other.estado == estado;

  @override
  int get hashCode => Object.hash(rango, tipo, estado);
}

/// Labels of the active filter chips.
String etiquetaTipo(TipoAlerta t) =>
    t == TipoAlerta.caida ? 'Caídas' : 'Movimientos inestables';

String etiquetaEstado(EstadoAlerta e) => switch (e) {
  EstadoAlerta.activa => 'Activas',
  EstadoAlerta.atendida => 'Atendidas',
  EstadoAlerta.falsaAlarma => 'Falsas alarmas',
};
