import 'package:flutter/material.dart';

import '../../../app/tema/colores.dart';
import '../../../core/formato.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/tarjeta.dart';
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

/// Status of the home card from the household and its camera.
EstadoTarjeta estadoTarjeta(Hogar hogar, Camara? camara) {
  final nombre = hogar.adultoMayor.nombrePila;
  final habitacion = camara?.nombreHabitacion ?? '';
  if (!hogar.conConsentimiento) {
    return EstadoTarjeta(
      banda: Banda.pausa,
      icono: Ico.lock,
      color: Colores.pausa,
      titulo: 'Detección detenida',
      texto: hogar.consentimiento != null
          ? 'Revocaste el consentimiento. La cámara no captura y no recibirás '
                'alertas.'
          : 'Falta el consentimiento informado de $nombre. La cámara está '
                'instalada, pero no envía video.',
    );
  }
  final estado = camara?.estadoVisible(conConsentimiento: true);
  return switch (estado) {
    EstadoVisible.desconectada => EstadoTarjeta(
      banda: Banda.aviso,
      icono: Ico.wifiOff,
      color: Colores.aviso,
      titulo: 'La cámara está desconectada',
      texto:
          'Sin ella no podemos detectar caídas ${enHabitacion(habitacion)}. '
          'Revisa el cable de la cámara, que la PC esté encendida y el internet '
          'de la casa.',
    ),
    EstadoVisible.noConfiable => EstadoTarjeta(
      banda: Banda.aviso,
      icono: Ico.eyeOff,
      color: Colores.aviso,
      titulo: 'La detección no es confiable',
      texto:
          'Hace más de 5 minutos que la cámara no ve bien a $nombre '
          '${enHabitacion(habitacion)}. Revisa la luz y el encuadre.',
    ),
    EstadoVisible.enPausa => EstadoTarjeta(
      banda: Banda.pausa,
      icono: Ico.pause,
      color: Colores.pausa,
      titulo: 'Todo tranquilo, con una pausa',
      texto:
          'La cámara ${deHabitacion(habitacion)} está en pausa hasta las '
          '${hora(camara!.pausadaHasta!)}.',
    ),
    _ => EstadoTarjeta(
      banda: Banda.calma,
      icono: Ico.sun,
      color: Colores.calmaTinta,
      titulo: 'Todo tranquilo',
      texto: camara == null
          ? 'Sin eventos hoy.'
          : 'Sin eventos hoy. La cámara ${deHabitacion(habitacion)} está '
                'funcionando.',
    ),
  };
}

/// Older adult status card with the color band of the state (DESIGN.md, Components).
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
    final direccion = adulto.direccion.replaceAll(', Lima', '');
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adulto.edad == null
                          ? adulto.nombre
                          : '${adulto.nombre}, ${adulto.edad} años',
                      style: texto.titleMedium?.copyWith(fontSize: 17),
                    ),
                    if (direccion.isNotEmpty)
                      Text(direccion, style: texto.bodySmall),
                  ],
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
