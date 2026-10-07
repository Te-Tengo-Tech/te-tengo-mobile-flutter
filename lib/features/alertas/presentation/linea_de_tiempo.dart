import 'package:flutter/material.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../camaras/domain/camara.dart';
import '../domain/alerta.dart';

/// Kind of dot of a timeline item (`.tl li.c-*`).
enum PuntoLinea { neutro, caida, inestable, ok, escalada }

class ItemLinea {
  const ItemLinea(this.momento, this.texto, [this.punto = PuntoLinea.neutro]);

  final DateTime momento;
  final String texto;
  final PuntoLinea punto;
}

/// Events of an alert («Registro»): detection, notification, confirmation, recovery, escalation and
/// who marked it (`timeline`).
List<ItemLinea> itemsDeAlerta(
  Alerta a, {
  required String nombreAdultoMayor,
  List<String> avisados = const [],
  String? secundario,
  int esperaMinutos = 5,
}) {
  final caida = a.esCaida;
  final avisadosTexto = switch (avisados.length) {
    0 => 'la familia',
    1 => avisados.first,
    _ =>
      '${avisados.sublist(0, avisados.length - 1).join(', ')} y ${avisados.last}',
  };
  final notificada = a.notificadaEn;
  return [
    ItemLinea(
      a.ocurridaEn,
      '${caida ? 'Caída detectada' : 'Movimiento inestable detectado'} '
      '${enHabitacion(a.habitacion)}',
      caida ? PuntoLinea.caida : PuntoLinea.inestable,
    ),
    if (notificada == null)
      ItemLinea(
        a.ocurridaEn,
        'La notificación no se pudo entregar; reintentando el envío',
      )
    else
      ItemLinea(
        notificada,
        'Aviso enviado a $avisadosTexto, '
        '${notificada.difference(a.ocurridaEn).inSeconds} s después '
        '${caida ? 'de la caída' : 'del movimiento'}',
      ),
    if (a.esCaida && a.confirmada)
      ItemLinea(
        a.confirmadaEn,
        'Sigue en el suelo tras 30 s: caída confirmada',
        PuntoLinea.caida,
      ),
    if (a.recuperadaEn case final r?)
      ItemLinea(r, '$nombreAdultoMayor se levantó', PuntoLinea.ok),
    if (a.escaladaEn case final e?)
      ItemLinea(
        e,
        secundario != null
            ? 'Sin respuesta en $esperaMinutos min: aviso urgente a '
                  '$secundario (secundario)'
            : 'Sin respuesta en $esperaMinutos min: no hay contacto '
                  'secundario a quién avisar',
        PuntoLinea.escalada,
      ),
    if (a.estado == EstadoAlerta.atendida && a.atendidaEn != null)
      ItemLinea(
        a.atendidaEn!,
        'Marcada como atendida por ${a.atendidaPor ?? ''}',
        PuntoLinea.ok,
      ),
    if (a.estado == EstadoAlerta.atendida &&
        a.escaladaEn == null &&
        secundario != null &&
        a.atendidaEn != null &&
        a.atendidaEn!.difference(a.ocurridaEn).inMinutes < esperaMinutos)
      ItemLinea(
        a.atendidaEn!,
        'Se atendió antes de los $esperaMinutos min: no hizo falta avisar a '
        '${secundario.split(' ').first} (secundario)',
      ),
    if (a.estado == EstadoAlerta.falsaAlarma && a.atendidaEn != null)
      ItemLinea(
        a.atendidaEn!,
        'Marcada como falsa alarma por ${a.atendidaPor ?? ''}',
      ),
  ];
}

/// Timeline of an alert (`.tl`): time, dot and text.
class LineaDeTiempo extends StatelessWidget {
  const LineaDeTiempo(this.items, {super.key});

  final List<ItemLinea> items;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < items.length; i++)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 54,
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    hora(items[i].momento),
                    style: estiloMono(
                      tamano: 14,
                      peso: 400,
                      color: Colores.tinta2,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 26,
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    _Punto(items[i].punto),
                    if (i < items.length - 1)
                      const Expanded(
                        child: VerticalDivider(
                          width: 2,
                          thickness: 2,
                          color: Colores.linea,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(items[i].texto, style: estiloTexto(15.5, 400)),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _Punto extends StatelessWidget {
  const _Punto(this.punto);

  final PuntoLinea punto;

  @override
  Widget build(BuildContext context) {
    final color = switch (punto) {
      PuntoLinea.caida => Colores.caida,
      PuntoLinea.inestable => Colores.inestableProfundo,
      PuntoLinea.ok => Colores.calma,
      PuntoLinea.escalada => Colores.morado,
      PuntoLinea.neutro => Colores.tinta3,
    };
    final rombo = punto == PuntoLinea.inestable;
    final marca = Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: rombo ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: rombo ? BorderRadius.circular(2) : null,
      ),
    );
    return rombo ? Transform.rotate(angle: 0.785398, child: marca) : marca;
  }
}
