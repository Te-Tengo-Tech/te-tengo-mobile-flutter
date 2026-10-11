import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/dialogo.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../alertas/data/alertas_repositorio.dart';
import '../../alertas/domain/alerta.dart';
import '../../camaras/domain/camara.dart';
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
      appBar: AppBar(title: Text(yo ? 'Tu perfil en la familia' : 'Familiar')),
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
          titulo: 'Hacer contacto principal',
          subtitulo: 'Recibirá cada alerta primero',
          chevron: false,
          alTocar: () => _cambiarPapel(context, ref, PapelAviso.principal),
        ),
      // The family always keeps a principal contact: it changes by choosing another one.
      if (miembro.papel == PapelAviso.familiar)
        FilaLista(
          inicio: const IconoFila(Ico.users),
          titulo: 'Hacer contacto secundario',
          subtitulo: 'Recibe la alerta si nadie atiende en $espera min',
          chevron: false,
          alTocar: () => _cambiarPapel(context, ref, PapelAviso.secundario),
        ),
      if (!yo && miembro.papel != PapelAviso.principal)
        FilaLista(
          inicio: const IconoFila(Ico.trash, peligro: true),
          titulo: 'Retirar acceso',
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
            tamano: 80,
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            yo ? '${f.nombre} (tú)' : f.nombre,
            textAlign: TextAlign.center,
            style: texto.titleLarge,
          ),
        ),
        if (f.esTitular)
          Text(
            'Titular de la cuenta',
            textAlign: TextAlign.center,
            style: texto.bodyMedium,
          ),
        const SizedBox(height: 8),
        Center(child: EtiquetaPapel(miembro.papel)),
        const EncabezadoSeccion('Contacto', arriba: 20),
        ListaTarjeta(
          children: [
            FilaLista(
              inicio: const IconoFila(Ico.mail),
              titulo: f.correo,
              subtitulo: 'Correo',
            ),
          ],
        ),
        const EncabezadoSeccion('En las alertas'),
        ListaTarjeta(
          children: [
            FilaLista(
              inicio: IconoFila(switch (miembro.papel) {
                PapelAviso.principal => Ico.bell,
                PapelAviso.secundario => Ico.clock,
                PapelAviso.familiar => Ico.users,
              }),
              titulo: miembro.papel.etiqueta,
              subtitulo: switch (miembro.papel) {
                PapelAviso.principal => 'Recibe cada alerta primero',
                PapelAviso.secundario =>
                  'Le avisamos si nadie atiende en $espera min',
                PapelAviso.familiar => 'Se entera de todo, sin escalamiento',
              },
            ),
          ],
        ),
        const EncabezadoSeccion('Actividad'),
        ListaTarjeta(
          children: [
            if (ultimaMarcada != null)
              FilaLista(
                inicio: const IconoFila(Ico.check),
                titulo: contar(
                  marcadas!.length,
                  'alerta marcada',
                  'alertas marcadas',
                ),
                subtituloRico: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          'Última: ${ultimaMarcada.tipo == TipoAlerta.caida ? 'Caída' : 'Inestable'} '
                          '${enHabitacion(ultimaMarcada.habitacion)} · '
                          '${fechaCorta(ultimaMarcada.atendidaEn ?? ultimaMarcada.ocurridaEn)} · ',
                    ),
                    TextSpan(
                      text: hora(
                        ultimaMarcada.atendidaEn ?? ultimaMarcada.ocurridaEn,
                      ),
                      style: const TextStyle(fontFamily: fuenteMono),
                    ),
                  ],
                ),
                alTocar: () =>
                    context.push(Rutas.detalleAlerta(ultimaMarcada.id)),
              )
            else
              const FilaLista(
                inicio: IconoFila(Ico.check),
                titulo: 'Aún no marcó alertas',
              ),
            if (ultimoAcceso != null)
              FilaLista(
                inicio: const IconoFila(Ico.eye),
                titulo:
                    '${contar(accesos.length, 'acceso', 'accesos')} a la '
                    'cámara',
                subtituloRico: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          'Último: ${mismoDia(ultimoAcceso.inicio, hoy) ? 'hoy' : fechaCorta(ultimoAcceso.inicio)} ',
                    ),
                    TextSpan(
                      text: hora(ultimoAcceso.inicio),
                      style: const TextStyle(fontFamily: fuenteMono),
                    ),
                    TextSpan(
                      text:
                          ' · ${duracion(Duration(seconds: ultimoAcceso.duracionSegundos))}',
                    ),
                  ],
                ),
                alTocar: () => context.push(Rutas.accesos),
              )
            else
              const FilaLista(
                inicio: IconoFila(Ico.eye),
                titulo: 'Aún no abrió la vista en vivo',
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
                  ? 'Para dejar de ser principal, elige a otro contacto.'
                  : 'Para retirar su acceso, primero elige a otro contacto '
                        'principal.',
            ),
          ],
          if (opciones.isNotEmpty) ...[
            const EncabezadoSeccion('Opciones'),
            ListaTarjeta(children: opciones),
          ],
        ] else ...[
          const SizedBox(height: 20),
          AvisoSoloLectura(
            titular: ref.watch(nombreTitularProvider) ?? '',
            accion: 'cambiar el papel de un familiar o retirar su acceso',
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
        titulo:
            '${f.nombrePila} ahora es contacto '
            '${papel == PapelAviso.principal ? 'principal' : 'secundario'}',
        texto: 'El orden de aviso se actualizó.',
        icono: Ico.users,
      );
    } on ProblemaApi catch (e) {
      if (context.mounted) _error(context, e);
    }
  }

  Future<void> _retirar(BuildContext context, WidgetRef ref) async {
    final f = miembro.familiar;
    final secundario = miembro.papel == PapelAviso.secundario;
    final si = await confirmar(
      context,
      icono: Ico.trash,
      titulo: '¿Retirar el acceso de ${f.nombre}?',
      texto:
          'Dejará de recibir alertas y de ver el historial.'
          '${secundario ? ' Te quedarás sin contacto secundario.' : ''}',
      aceptar: 'Retirar acceso',
      cancelar: 'Cancelar',
      peligro: true,
    );
    if (!si || !context.mounted) return;
    try {
      await ref.read(familiaRepositorioProvider).retirar(f.usuarioId);
      if (!context.mounted) return;
      final router = GoRouter.of(context);
      mostrarToast(
        context,
        titulo: '${f.nombrePila} ya no recibe alertas',
        texto: secundario ? 'Te quedaste sin contacto secundario.' : null,
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
