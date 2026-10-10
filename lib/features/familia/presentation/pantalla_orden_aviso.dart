import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../data/familia_repositorio.dart';
import '../domain/familiar.dart';

/// US-10, screens 63–65 and 81: primary and secondary contact and the wait before escalating
/// (3, 5 by default or 10 minutes). Only the owner changes them (CA-08.4).
class PantallaOrdenAviso extends ConsumerWidget {
  const PantallaOrdenAviso({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miembros = ref.watch(miembrosProvider);
    final aviso = ref.watch(avisoProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Orden de aviso')),
      body: switch ((miembros, aviso)) {
        (AsyncData(value: final m), AsyncData(value: final a)) => _Orden(
          miembros: m,
          aviso: a,
        ),
        (AsyncError(:final error), _) ||
        (_, AsyncError(:final error)) => ErrorDePantalla(
          error: error,
          alReintentar: () async {
            ref
              ..invalidate(familiaresProvider)
              ..invalidate(avisoProvider);
          },
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// Saves the alert order and refreshes the family.
Future<bool> guardarAviso(
  BuildContext context,
  WidgetRef ref,
  ConfiguracionAviso nuevo, {
  required String titulo,
  required String texto,
  Ico icono = Ico.users,
}) async {
  try {
    await ref.read(familiaRepositorioProvider).guardarAviso(nuevo);
    ref.invalidate(avisoProvider);
    if (context.mounted) {
      mostrarToast(context, titulo: titulo, texto: texto, icono: icono);
    }
    return true;
  } on ProblemaApi catch (e) {
    if (context.mounted) {
      mostrarToast(
        context,
        titulo: e.detalle,
        icono: Ico.warn,
        tono: TonoAviso.advertencia,
      );
    }
    return false;
  }
}

class _Orden extends ConsumerWidget {
  const _Orden({required this.miembros, required this.aviso});

  final List<MiembroFamilia> miembros;
  final ConfiguracionAviso aviso;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texto = Theme.of(context).textTheme;
    final titular = ref.watch(esTitularProvider);
    final yo = ref.watch(sesionControllerProvider)?.usuario.id;
    MiembroFamilia? con(PapelAviso p) =>
        miembros.where((m) => m.papel == p).firstOrNull;
    final principal = con(PapelAviso.principal);
    final secundario = con(PapelAviso.secundario);
    final puedeCambiar = titular && miembros.length > 1;
    String nombre(MiembroFamilia m) => m.familiar.usuarioId == yo
        ? '${m.familiar.nombre} (tú)'
        : m.familiar.nombre;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        if (!titular) ...[
          AvisoSoloLectura(
            titular: ref.watch(nombreTitularProvider) ?? '',
            accion: 'cambiar el orden de aviso y el tiempo de espera',
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'Todos reciben cada alerta. Si el principal no la marca a tiempo, '
          'avisamos al secundario.',
          style: texto.bodyMedium,
        ),
        const EncabezadoSeccion('Quién responde', arriba: 16),
        ListaTarjeta(
          children: [
            _Puesto(
              numero: 1,
              titulo: principal == null ? '' : nombre(principal),
              detalle: 'Contacto principal',
              alCambiar: puedeCambiar && principal != null
                  ? () => _elegir(context, ref, PapelAviso.principal)
                  : null,
            ),
            _Puesto(
              numero: 2,
              vacio: secundario == null,
              titulo: secundario == null
                  ? 'Sin contacto secundario'
                  : nombre(secundario),
              detalle: secundario == null
                  ? 'Si nadie atiende, no habrá a quién más avisar.'
                  : 'Contacto secundario · a los ${aviso.esperaMinutos} min',
              alCambiar: puedeCambiar && secundario != null
                  ? () => _elegir(context, ref, PapelAviso.secundario)
                  : null,
            ),
          ],
        ),
        if (secundario == null && titular) ...[
          const SizedBox(height: 12),
          Boton(
            'Invitar a un familiar',
            estilo: EstiloBoton.secundario,
            icono: Ico.plus,
            alPresionar: () => context.push(Rutas.invitar),
          ),
        ],
        const EncabezadoSeccion('Tiempo de espera'),
        Text('Antes de avisar al secundario.', style: texto.bodyMedium),
        const SizedBox(height: 12),
        for (final m in ConfiguracionAviso.esperas)
          OpcionRadio<int>(
            valor: m,
            seleccion: aviso.esperaMinutos,
            titulo: '$m minutos',
            subtitulo: m == ConfiguracionAviso.esperaPredeterminada
                ? 'Predeterminado'
                : null,
            alElegir: titular
                ? (v) => guardarAviso(
                    context,
                    ref,
                    aviso.con(esperaMinutos: v),
                    titulo: 'Tiempo de espera: $v minutos',
                    texto: 'Se aplicará en las próximas alertas.',
                    icono: Ico.clock,
                  )
                : null,
          ),
        const SizedBox(height: 16),
        if (secundario != null)
          Aviso(
            tono: TonoAviso.info,
            icono: Ico.clock,
            contenido: TextSpan(
              children: [
                const TextSpan(text: 'Ejemplo: si llega una alerta a las '),
                TextSpan(text: '10:42', style: estiloMono(tamano: 15.5)),
                TextSpan(
                  text:
                      ' y nadie la atiende, avisamos a '
                      '${secundario.familiar.nombrePila} a las ',
                ),
                TextSpan(
                  text: hora(
                    DateTime(2026, 1, 1, 10, 42 + aviso.esperaMinutos),
                  ),
                  style: estiloMono(tamano: 15.5),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          )
        else
          const Aviso(
            tono: TonoAviso.neutral,
            icono: Ico.info,
            texto: 'Este tiempo se usará cuando tengas un contacto secundario.',
          ),
      ],
    );
  }

  Future<void> _elegir(
    BuildContext context,
    WidgetRef ref,
    PapelAviso puesto,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        _ElegirContacto(puesto: puesto, miembros: miembros, aviso: aviso),
  );
}

/// Numbered slot (`.order-n`) with «Cambiar».
class _Puesto extends StatelessWidget {
  const _Puesto({
    required this.numero,
    required this.titulo,
    required this.detalle,
    this.vacio = false,
    this.alCambiar,
  });

  final int numero;
  final String titulo;
  final String detalle;
  final bool vacio;
  final VoidCallback? alCambiar;

  @override
  Widget build(BuildContext context) => FilaLista(
    inicio: Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: vacio ? context.colores.fondo2 : context.colores.inversa,
        shape: BoxShape.circle,
        border: vacio
            ? Border.all(color: context.colores.linea2, width: 1.5)
            : null,
      ),
      child: Text(
        '$numero',
        style: estiloTexto(
          15,
          800,
          color: vacio ? context.colores.tinta3 : context.colores.sobreInversa,
        ),
      ),
    ),
    titulo: titulo,
    subtitulo: detalle,
    fin: alCambiar == null
        ? null
        : Semantics(
            label:
                'Cambiar contacto ${numero == 1 ? 'principal' : 'secundario'}',
            excludeSemantics: true,
            child: Enlace('Cambiar', alTocar: alCambiar),
          ),
  );
}

/// Screen 64: who is the primary or the secondary contact.
class _ElegirContacto extends ConsumerWidget {
  const _ElegirContacto({
    required this.puesto,
    required this.miembros,
    required this.aviso,
  });

  final PapelAviso puesto;
  final List<MiembroFamilia> miembros;
  final ConfiguracionAviso aviso;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texto = Theme.of(context).textTheme;
    final yo = ref.watch(sesionControllerProvider)?.usuario.id;
    final esPrincipal = puesto == PapelAviso.principal;
    final actual = esPrincipal ? aviso.principalId : aviso.secundarioId;
    final nombrePuesto = esPrincipal ? 'principal' : 'secundario';
    Future<void> elegir(MiembroFamilia m) async {
      final id = m.familiar.usuarioId;
      final navegador = Navigator.of(context);
      if (id == actual) return navegador.pop();
      final ConfiguracionAviso nuevo;
      if (esPrincipal) {
        // The new primary leaves its secondary place to the former primary.
        nuevo = aviso.con(
          principalId: id,
          secundarioId: aviso.secundarioId == id ? aviso.principalId : null,
        );
      } else if (id == aviso.principalId) {
        navegador.pop();
        mostrarToast(
          context,
          titulo: 'Primero elige otro principal',
          texto: '${m.familiar.nombrePila} ya es el contacto principal.',
          icono: Ico.warn,
          tono: TonoAviso.advertencia,
        );
        return;
      } else {
        nuevo = aviso.con(secundarioId: id);
      }
      navegador.pop();
      await guardarAviso(
        context,
        ref,
        nuevo,
        titulo: '${m.familiar.nombrePila} es contacto $nombrePuesto',
        texto: 'Usaremos este orden en las próximas alertas.',
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                '¿Quién será el contacto $nombrePuesto?',
                style: texto.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              esPrincipal
                  ? 'Recibe cada alerta y es quien debe atenderla primero.'
                  : 'Le avisamos si nadie marca la alerta en '
                        '${aviso.esperaMinutos} minutos.',
              style: texto.bodyMedium,
            ),
            const SizedBox(height: 16),
            for (final m in miembros)
              OpcionRadio<String>(
                valor: m.familiar.usuarioId,
                seleccion: actual,
                titulo: m.familiar.usuarioId == yo
                    ? '${m.familiar.nombre} (tú)'
                    : m.familiar.nombre,
                subtitulo: 'ahora: ${m.papel.etiqueta.toLowerCase()}',
                alElegir: (_) => elegir(m),
              ),
            if (!esPrincipal && aviso.secundarioId != null)
              Boton(
                'Quitar contacto secundario',
                estilo: EstiloBoton.fantasma,
                alPresionar: () async {
                  Navigator.of(context).pop();
                  await guardarAviso(
                    context,
                    ref,
                    aviso.con(sinSecundario: true),
                    titulo: 'Sin contacto secundario',
                    texto:
                        'Nadie más será avisado si no se atiende una alerta.',
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
