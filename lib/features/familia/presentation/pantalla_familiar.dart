import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/tema.dart';
import '../../../core/dispositivo/llamada.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/dialogo.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../l10n/l10n.dart';
import '../../alertas/data/alertas_repositorio.dart';
import '../../alertas/domain/alerta.dart';
import '../../camaras/domain/camara.dart';
import '../../perfil/data/fotos.dart';
import '../../vivo/data/registro_accesos.dart';
import '../data/familia_repositorio.dart';
import '../domain/familiar.dart';
import 'fila_miembro.dart';

/// The alerts a member marked, newest first, among the latest 100 of the household.
final alertasMarcadasProvider = FutureProvider.autoDispose
    .family<List<Alerta>, String>((ref, usuarioId) async {
      final p = await ref
          .watch(alertasRepositorioProvider)
          .listar(const FiltroAlertas(tamano: FiltroAlertas.tamanoMaximo));
      return [
        for (final a in p.elementos)
          if (a.atendidaPorId == usuarioId && a.estado != EstadoAlerta.activa)
            a,
      ];
    });

/// «Familiar» / «Tu perfil en la familia» (screens 76, 77, 231 to 236): the member's contact, their
/// role in the alerts and what they did; the owner changes the role or removes the access
/// (CA-08.3). Every member opens it; the invited one reads it.
class PantallaFamiliar extends ConsumerWidget {
  const PantallaFamiliar({super.key, required this.usuarioId});

  final String usuarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miembros = ref.watch(miembrosProvider);
    final yo = ref.watch(sesionControllerProvider)?.usuario.id == usuarioId;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          yo
              ? context.l10n.familiaTuPerfilTitulo
              : context.l10n.familiaFamiliarTitulo,
        ),
      ),
      body: switch (miembros) {
        AsyncData(value: final lista) => () {
          final i = lista.indexWhere((m) => m.familiar.usuarioId == usuarioId);
          if (i < 0) return const SizedBox.shrink();
          return _Detalle(miembro: lista[i], indice: i, yo: yo);
        }(),
        AsyncError(:final error) => ErrorDePantalla(
          error: error,
          alReintentar: () async => ref.invalidate(familiaresProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Detalle extends ConsumerWidget {
  const _Detalle({
    required this.miembro,
    required this.indice,
    required this.yo,
  });

  final MiembroFamilia miembro;
  final int indice;
  final bool yo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = miembro.familiar;
    final texto = Theme.of(context).textTheme;
    final l = context.l10n;
    final formato = context.formato;
    final titular = ref.watch(esTitularProvider);
    final espera =
        ref.watch(avisoProvider).value?.esperaMinutos ??
        ConfiguracionAviso.esperaPredeterminada;
    final hoy = ref.watch(relojProvider)();
    final marcadas = ref.watch(alertasMarcadasProvider(f.usuarioId)).value;
    final accesos = [
      for (final a
          in ref.watch(registroAccesosProvider).value ?? const <Acceso>[])
        if (a.usuarioId == f.usuarioId) a,
    ];
    final ultimaMarcada = marcadas?.firstOrNull;
    final ultimoAcceso = accesos.firstOrNull;
    final opciones = [
      if (miembro.papel != PapelAviso.principal)
        FilaLista(
          inicio: const IconoFila(Ico.swap),
          titulo: l.familiaHacerPrincipal,
          subtitulo: l.familiaHacerPrincipalDetalle,
          chevron: false,
          alTocar: () => _cambiarPapel(context, ref, PapelAviso.principal),
        ),
      // The family always keeps a principal contact: it changes by choosing another one.
      if (miembro.papel == PapelAviso.familiar)
        FilaLista(
          inicio: const IconoFila(Ico.users),
          titulo: l.familiaHacerSecundario,
          subtitulo: l.familiaHacerSecundarioDetalle(espera),
          chevron: false,
          alTocar: () => _cambiarPapel(context, ref, PapelAviso.secundario),
        ),
      if (!yo && miembro.papel != PapelAviso.principal)
        FilaLista(
          inicio: const IconoFila(Ico.trash, peligro: true),
          titulo: l.familiaRetirarAcceso,
          peligro: true,
          chevron: false,
          alTocar: () => _retirar(context, ref),
        ),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Center(
          child: Avatar(
            Avatar.inicialesDe(f.nombre),
            tono: tonoDe(indice),
            tamano: 96,
            foto: ref.watch(fotoDeUsuarioProvider(f.usuarioId)) ?? f.foto,
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            yo ? l.familiaNombreTu(f.nombre) : f.nombre,
            textAlign: TextAlign.center,
            style: texto.titleLarge,
          ),
        ),
        if (f.parentesco != null || f.esTitular)
          Text(
            f.parentesco == null
                ? l.familiaTitularCuenta
                : resumenMiembro(l, f)!,
            textAlign: TextAlign.center,
            style: texto.bodyMedium,
          ),
        const SizedBox(height: 8),
        Center(child: EtiquetaPapel(miembro.papel)),
        EncabezadoSeccion(l.familiaContacto, arriba: 20),
        ListaTarjeta(
          children: [
            if (f.telefono case final telefono?)
              FilaLista(
                inicio: const IconoFila(Ico.phone),
                titulo: telefono,
                subtitulo: l.familiaTelefono,
                fin: yo
                    ? null
                    : Boton(
                        l.familiaLlamar,
                        estilo: EstiloBoton.secundario,
                        pequeno: true,
                        alPresionar: () => ref.read(llamarProvider)(telefono),
                      ),
              ),
            FilaLista(
              inicio: const IconoFila(Ico.mail),
              titulo: f.correo,
              subtitulo: l.familiaCorreo,
            ),
          ],
        ),
        EncabezadoSeccion(l.familiaEnLasAlertas),
        ListaTarjeta(
          children: [
            FilaLista(
              inicio: IconoFila(switch (miembro.papel) {
                PapelAviso.principal => Ico.bell,
                PapelAviso.secundario => Ico.clock,
                PapelAviso.familiar => Ico.users,
              }),
              titulo: miembro.papel.etiqueta(l),
              subtitulo: switch (miembro.papel) {
                PapelAviso.principal => l.familiaPapelPrincipalDetalle,
                PapelAviso.secundario => l.familiaPapelSecundarioDetalle(
                  espera,
                ),
                PapelAviso.familiar => l.familiaPapelFamiliarDetalle,
              },
            ),
          ],
        ),
        EncabezadoSeccion(l.familiaActividad),
        ListaTarjeta(
          children: [
            if (ultimaMarcada != null)
              FilaLista(
                inicio: const IconoFila(Ico.check),
                titulo: l.familiaAlertasMarcadas(marcadas!.length),
                subtituloRico: TextSpan(
                  children: [
                    TextSpan(
                      text: l.familiaUltimaMarcada(
                        ultimaMarcada.tipo == TipoAlerta.caida
                            ? 'caida'
                            : 'inestable',
                        ultimaMarcada.habitacion,
                        conArticulo(ultimaMarcada.habitacion),
                        formato.fechaCorta(
                          ultimaMarcada.atendidaEn ?? ultimaMarcada.ocurridaEn,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: formato.hora(
                        ultimaMarcada.atendidaEn ?? ultimaMarcada.ocurridaEn,
                      ),
                      style: estiloCifras,
                    ),
                  ],
                ),
                alTocar: () =>
                    context.push(Rutas.detalleAlerta(ultimaMarcada.id)),
              )
            else
              FilaLista(
                inicio: const IconoFila(Ico.check),
                titulo: l.familiaSinMarcadas,
              ),
            if (ultimoAcceso != null)
              FilaLista(
                inicio: const IconoFila(Ico.eye),
                titulo: l.familiaAccesosCamara(accesos.length),
                subtituloRico: TextSpan(
                  children: [
                    TextSpan(
                      text: l.familiaUltimoAcceso(
                        mismoDia(ultimoAcceso.inicio, hoy)
                            ? l.familiaHoy
                            : formato.fechaCorta(ultimoAcceso.inicio),
                      ),
                    ),
                    TextSpan(
                      text: formato.hora(ultimoAcceso.inicio),
                      style: estiloCifras,
                    ),
                    TextSpan(
                      text:
                          ' · ${formato.duracion(Duration(seconds: ultimoAcceso.duracionSegundos))}',
                    ),
                  ],
                ),
                alTocar: () => context.push(Rutas.accesos),
              )
            else
              FilaLista(
                inicio: const IconoFila(Ico.eye),
                titulo: l.familiaSinAccesos,
              ),
          ],
        ),
        if (titular) ...[
          if (yo || miembro.papel == PapelAviso.principal) ...[
            const SizedBox(height: 16),
            Aviso(
              tono: TonoAviso.neutral,
              icono: Ico.info,
              texto: yo
                  ? l.familiaAvisoDejarPrincipal
                  : l.familiaAvisoRetirarPrincipal,
            ),
          ],
          if (opciones.isNotEmpty) ...[
            EncabezadoSeccion(l.familiaOpciones),
            ListaTarjeta(children: opciones),
          ],
        ] else ...[
          const SizedBox(height: 20),
          AvisoSoloLectura(
            titular: ref.watch(nombreTitularProvider) ?? '',
            accion: l.familiaSoloLecturaPapel,
          ),
        ],
      ],
    );
  }

  Future<void> _cambiarPapel(
    BuildContext context,
    WidgetRef ref,
    PapelAviso papel,
  ) async {
    final f = miembro.familiar;
    final l = context.l10n;
    final actual = await ref.read(avisoProvider.future);
    final nuevo = papel == PapelAviso.principal
        // The old principal takes the place the new one leaves (secondary or none).
        ? ConfiguracionAviso(
            principalId: f.usuarioId,
            secundarioId: actual.secundarioId == f.usuarioId
                ? actual.principalId
                : actual.secundarioId,
            esperaMinutos: actual.esperaMinutos,
          )
        : actual.con(secundarioId: f.usuarioId);
    try {
      await ref.read(familiaRepositorioProvider).guardarAviso(nuevo);
      ref.invalidate(avisoProvider);
      if (!context.mounted) return;
      mostrarToast(
        context,
        titulo: l.familiaAhoraEsContacto(
          f.nombrePila,
          papel == PapelAviso.principal ? 'principal' : 'secundario',
        ),
        texto: l.familiaOrdenActualizado,
        icono: Ico.users,
      );
    } on ProblemaApi catch (e) {
      if (context.mounted) _error(context, e);
    }
  }

  Future<void> _retirar(BuildContext context, WidgetRef ref) async {
    final f = miembro.familiar;
    final secundario = miembro.papel == PapelAviso.secundario;
    final l = context.l10n;
    final si = await confirmar(
      context,
      icono: Ico.trash,
      titulo: l.familiaRetirarTitulo(f.nombre),
      texto: secundario
          ? l.familiaRetirarTextoSecundario
          : l.familiaRetirarTexto,
      aceptar: l.familiaRetirarAcceso,
      cancelar: l.familiaCancelar,
      peligro: true,
    );
    if (!si || !context.mounted) return;
    try {
      await ref.read(familiaRepositorioProvider).retirar(f.usuarioId);
      if (!context.mounted) return;
      final router = GoRouter.of(context);
      mostrarToast(
        context,
        titulo: l.familiaYaNoRecibe(f.nombrePila),
        texto: secundario ? l.familiaQuedasteSinSecundario : null,
      );
      if (router.canPop()) router.pop();
      ref
        ..invalidate(familiaresProvider)
        ..invalidate(avisoProvider);
    } on ProblemaApi catch (e) {
      if (context.mounted) _error(context, e);
    }
  }

  void _error(BuildContext context, ProblemaApi e) => mostrarToast(
    context,
    titulo: e.detalle,
    icono: Ico.warn,
    tono: TonoAviso.advertencia,
  );
}
