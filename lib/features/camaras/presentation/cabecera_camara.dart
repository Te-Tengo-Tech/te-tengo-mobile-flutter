import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/ui/tarjeta.dart';
import '../domain/camara.dart';
import 'estado_camara.dart';

/// Camera header (`camHead`): state icon, room name and state, then the camera data.
class CabeceraCamara extends StatelessWidget {
  const CabeceraCamara({
    super.key,
    required this.camara,
    required this.estado,
    required this.ahora,
  });

  final Camara camara;
  final EstadoVisible estado;
  final DateTime ahora;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return TarjetaBanda(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconoEstadoCamara(estado: estado, tamano: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(camara.nombreHabitacion, style: texto.titleLarge),
                    EstadoCamara(estado: estado),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1),
          ),
          DatosTarjeta(datosCamara(camara, estado, ahora)),
        ],
      ),
    );
  }
}

/// `hace 6 s`, `hace 3 min`.
String haceTiempo(DateTime momento, DateTime ahora) {
  final d = ahora.difference(momento);
  if (d.inMinutes < 1) return 'hace ${d.inSeconds.clamp(1, 59)} s';
  if (d.inHours < 1) return 'hace ${d.inMinutes} min';
  return 'hace ${d.inHours} h';
}

/// Rows of the camera data (`camKv`).
List<Widget> datosCamara(Camara c, EstadoVisible estado, DateTime ahora) {
  final senal = c.ultimaSenal;
  return [
    if (estado == EstadoVisible.detenida)
      const FilaDato(clave: 'Envío de video', valor: 'Detenido')
    else if (senal != null)
      FilaDato(
        clave: 'Última señal',
        valor: '',
        valorRico: estado == EstadoVisible.desconectada
            ? TextSpan(
                children: [
                  const TextSpan(text: 'a las '),
                  TextSpan(text: hora(senal), style: _mono),
                ],
              )
            : TextSpan(
                children: [
                  TextSpan(text: hora(senal), style: _mono),
                  TextSpan(text: ' · ${haceTiempo(senal, ahora)}'),
                ],
              ),
      ),
    const FilaDato(clave: 'Conectada a', valor: 'PC de la casa'),
    if (c.instaladaEn case final f?)
      FilaDato(clave: 'Instalada el', valor: fechaConAnio(f)),
    const FilaDato(clave: 'Instalada por', valor: 'Equipo del proyecto'),
    FilaDato(
      clave: 'Detección de caídas',
      valor: switch (estado) {
        EstadoVisible.enLinea => 'Activa',
        EstadoVisible.noConfiable => 'No confiable',
        _ => 'Detenida',
      },
    ),
  ];
}

const _mono = TextStyle(fontFamily: 'AtkinsonHyperlegibleMono');
