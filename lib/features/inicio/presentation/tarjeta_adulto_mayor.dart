import 'package:flutter/material.dart';

import '../../../app/tema/paleta.dart';
import '../../../core/formato.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/tarjeta.dart';
import '../../alertas/domain/alerta.dart';
import '../../camaras/domain/camara.dart';
import '../../hogar/domain/hogar.dart';
import '../../pcs/domain/camaras_en_casa.dart';

/// What the older adult status card says (`seniorCard`).
class EstadoTarjeta {
  const EstadoTarjeta({
    required this.banda,
    required this.icono,
    required this.color,
    required this.titulo,
    required this.texto,
  });

  final Banda banda;
  final Ico icono;
  final Color color;
  final String titulo;
  final String texto;
}

/// Status of the home card (`seniorCard`) from the household, its cameras and the active alert, in
/// [paleta]. With several cameras the card tells the problems (management by exception): which
/// rooms do not answer, while the others keep watching. [hayPc]: a PC is linked, so without cameras
/// it is their choice that is missing.
EstadoTarjeta estadoTarjeta(
  Hogar hogar,
  List<CamaraEnCasa> camaras, {
  Alerta? alerta,
  bool hayPc = false,
  Paleta paleta = Paleta.clara,
}) {
  final nombre = hogar.adultoMayor.nombrePila;
  if (alerta != null) {
    final caida = alerta.esCaida;
    return EstadoTarjeta(
      banda: caida ? Banda.caida : Banda.inestable,
      icono: caida ? Ico.fall : Ico.unsteady,
      color: caida ? paleta.caidaTinta : paleta.inestableTinta,
      titulo: !caida
          ? 'Movimiento inestable activo'
          : alerta.sigueEnElSuelo
          ? 'Caída confirmada'
          : 'Alerta de caída activa',
      texto:
          '${alerta.tipo.nombre} ${enHabitacion(alerta.habitacion)} a las '
          '${hora(alerta.ocurridaEn)}. Nadie la marcó aún.',
    );
  }
  if (!hogar.conConsentimiento) {
    return EstadoTarjeta(
      banda: Banda.pausa,
      icono: Ico.lock,
      color: paleta.pausa,
      titulo: 'Detección detenida',
      texto: hogar.consentimiento != null
          ? 'Revocaste el consentimiento. No hay captura ni alertas.'
          : 'Falta el consentimiento de $nombre. La cámara no envía video.',
    );
  }
  final n = camaras.length;
  if (n == 0) {
    return EstadoTarjeta(
      banda: Banda.pausa,
      icono: Ico.lock,
      color: paleta.pausa,
      titulo: 'Sin cámaras',
      texto: hayPc
          ? 'Falta elegir las cámaras de la PC de la casa.'
          : 'Aún no hay una PC vinculada. Sin ella no detectamos caídas.',
    );
  }
  final caidas = camaras.where((c) => c.noResponde).toList();
  if (caidas.isNotEmpty && n > 1) {
    final rooms = [for (final c in caidas) enHabitacion(c.habitacion)];
    return EstadoTarjeta(
      banda: Banda.aviso,
      icono: Ico.wifiOff,
      color: paleta.aviso,
      titulo: caidas.length == 1
          ? '1 cámara no responde · ${caidas.single.habitacion}'
          : '${caidas.length} cámaras no responden',
      texto:
          'Sin ella${caidas.length > 1 ? 's' : ''} no detectamos caídas '
          '${enumerar(rooms)}. Las demás siguen cuidando.',
    );
  }
  final c = camarasQueImportan(camaras).first;
  final habitacion = c.habitacion;
  return switch (c.estado) {
    EstadoVisible.desconectada || EstadoVisible.sinConexion => EstadoTarjeta(
      banda: Banda.aviso,
      icono: Ico.wifiOff,
      color: paleta.aviso,
      titulo: 'La cámara está desconectada',
      texto: 'Sin ella no detectamos caídas ${enHabitacion(habitacion)}.',
    ),
    EstadoVisible.noConfiable => EstadoTarjeta(
      banda: Banda.aviso,
      icono: Ico.eyeOff,
      color: paleta.aviso,
      titulo: 'La detección no es confiable',
      texto: 'Hace más de 5 min que no ve bien a $nombre.',
    ),
    EstadoVisible.enPausa => EstadoTarjeta(
      banda: Banda.pausa,
      icono: Ico.pause,
      color: paleta.pausa,
      titulo: 'Todo tranquilo, con una pausa',
      texto:
          'La cámara ${deHabitacion(habitacion)} está en pausa hasta las '
          '${hora(c.camara.pausadaHasta!)}.',
    ),
    _ => EstadoTarjeta(
      banda: Banda.calma,
      icono: Ico.sun,
      color: paleta.calmaTinta,
      titulo: 'Todo tranquilo',
      texto: '${n > 1 ? '$n cámaras cuidando. ' : ''}Sin eventos hoy.',
    ),
  };
}

/// The cameras in the order the card looks at them: one that does not answer, then unreliable,
/// then paused, then the rest.
List<CamaraEnCasa> camarasQueImportan(List<CamaraEnCasa> camaras) {
  int peso(CamaraEnCasa c) => switch (c.estado) {
    EstadoVisible.desconectada || EstadoVisible.sinConexion => 0,
    EstadoVisible.noConfiable => 1,
    EstadoVisible.enPausa => 2,
    _ => 3,
  };
  return [
    for (final p in [0, 1, 2, 3]) ...camaras.where((c) => peso(c) == p),
  ];
}

/// Older adult status card with the color band of the state (DESIGN.md, Components): name, age,
/// state and one line. The date and the address are not repeated here.
class TarjetaAdultoMayor extends StatelessWidget {
  const TarjetaAdultoMayor({
    super.key,
    required this.adulto,
    required this.estado,
    this.accion,
  });

  final AdultoMayor adulto;
  final EstadoTarjeta estado;

  /// Button under the text (register consent, see what to check, see the alert).
  final Boton? accion;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return TarjetaBanda(
      banda: estado.banda,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Avatar(Avatar.inicialesDe(adulto.nombre), tono: TonoAvatar.rosa),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  adulto.edad == null
                      ? adulto.nombre
                      : '${adulto.nombre}, ${adulto.edad} años',
                  style: texto.titleMedium?.copyWith(fontSize: 17),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Semantics(
            container: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icono(estado.icono, tamano: 28, color: estado.color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(estado.titulo, style: texto.titleLarge),
                      const SizedBox(height: 8),
                      Text(estado.texto, style: texto.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (accion != null) ...[const SizedBox(height: 12), accion!],
        ],
      ),
    );
  }
}
