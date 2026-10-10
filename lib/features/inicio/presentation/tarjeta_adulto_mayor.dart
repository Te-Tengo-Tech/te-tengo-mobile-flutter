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

/// Status of the home card from the household, its camera and the active alert, in [paleta].
EstadoTarjeta estadoTarjeta(
  Hogar hogar,
  Camara? camara, {
  Alerta? alerta,
  Paleta paleta = Paleta.clara,
}) {
  final nombre = hogar.adultoMayor.nombrePila;
  final habitacion = camara?.nombreHabitacion ?? '';
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
  final estado = camara?.estadoVisible(conConsentimiento: true);
  return switch (estado) {
    EstadoVisible.desconectada => EstadoTarjeta(
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
          '${hora(camara!.pausadaHasta!)}.',
    ),
    _ => EstadoTarjeta(
      banda: Banda.calma,
      icono: Ico.sun,
      color: paleta.calmaTinta,
      titulo: 'Todo tranquilo',
      texto: 'Sin eventos hoy.',
    ),
  };
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
