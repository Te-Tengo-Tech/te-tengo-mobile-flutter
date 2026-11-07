import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../familia/domain/familiar.dart';
import '../../../l10n/l10n.dart';
import '../domain/alerta.dart';
import 'textos_alerta.dart';

/// «Carmen (principal)», «Luis»: who receives each alert.
List<String> avisadosDe(AppLocalizations l, List<MiembroFamilia> miembros) => [
  for (final m in miembros)
    m.papel == PapelAviso.principal
        ? l.alertaAvisadoPrincipal(m.familiar.nombrePila)
        : m.familiar.nombrePila,
];

/// Full name of the secondary contact, if any.
String? secundarioDe(List<MiembroFamilia> miembros) => miembros
    .where((m) => m.papel == PapelAviso.secundario)
    .firstOrNull
    ?.familiar
    .nombre;

/// Wait before escalating (CA-10.3 default while loading).
int esperaDe(WidgetRef ref) =>
    ref.watch(avisoProvider).value?.esperaMinutos ??
    ConfiguracionAviso.esperaPredeterminada;

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
  AppLocalizations l,
  Alerta a, {
  required String nombreAdultoMayor,
  List<String> avisados = const [],
  String? secundario,
  int esperaMinutos = 5,
}) {
  final caida = a.esCaida;
  final avisadosTexto = avisados.isEmpty
      ? l.alertaLineaLaFamilia
      : l.formato.enumerar(avisados);
  final notificada = a.notificadaEn;
  return [
    ItemLinea(
      a.ocurridaEn,
      tipoEnHabitacion(l, a.tipo, a.habitacion),
      caida ? PuntoLinea.caida : PuntoLinea.inestable,
    ),
    // Only what the backend says (`estadoAviso`): «reintentando» only while it does.
    if (notificada == null && a.avisoReintentando)
      ItemLinea(a.ocurridaEn, l.alertaLineaReintentando)
    else if (notificada == null && a.avisoNoEntregado)
      ItemLinea(a.ocurridaEn, l.alertaLineaNoEntregada)
    else if (notificada != null)
      ItemLinea(
        notificada,
        l.alertaLineaAviso(
          avisadosTexto,
          notificada.difference(a.ocurridaEn).inSeconds,
        ),
      ),
    if (a.esCaida && a.confirmada)
      ItemLinea(a.confirmadaEn, l.alertaLineaConfirmada, PuntoLinea.caida),
    if (a.recuperadaEn case final r?)
      ItemLinea(r, l.alertaLineaSeLevanto(nombreAdultoMayor), PuntoLinea.ok),
    if (a.escaladaEn case final e?)
      ItemLinea(
        e,
        secundario != null
            ? l.alertaLineaEscaladaA(esperaMinutos, secundario.split(' ').first)
            : l.alertaLineaSinSecundario(esperaMinutos),
        PuntoLinea.escalada,
      ),
    if (a.estado == EstadoAlerta.atendida && a.atendidaEn != null)
      ItemLinea(
        a.atendidaEn!,
        l.alertaLineaAtendidaPor((a.atendidaPor ?? '').split(' ').first),
        PuntoLinea.ok,
      ),
    if (a.estado == EstadoAlerta.atendida &&
        a.escaladaEn == null &&
        secundario != null &&
        a.atendidaEn != null &&
        a.atendidaEn!.difference(a.ocurridaEn).inMinutes < esperaMinutos)
      ItemLinea(a.atendidaEn!, l.alertaLineaAntesDeEscalar(esperaMinutos)),
    if (a.estado == EstadoAlerta.falsaAlarma && a.atendidaEn != null)
      ItemLinea(
        a.atendidaEn!,
        l.alertaLineaFalsaAlarma((a.atendidaPor ?? '').split(' ').first),
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
                // «10:42 AM» in English needs more room than «10:42».
                width: context.l10n.localeName == 'en' ? 76 : 54,
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    context.formato.hora(items[i].momento),
                    style: estiloMono(
                      tamano: 14,
                      peso: 400,
                      color: context.colores.tinta2,
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
                      Expanded(
                        child: VerticalDivider(
                          width: 2,
                          thickness: 2,
                          color: context.colores.linea,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    items[i].texto,
                    style: estiloTexto(15.5, 400, color: context.colores.tinta),
                  ),
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
      PuntoLinea.neutro => context.colores.tinta3,
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
