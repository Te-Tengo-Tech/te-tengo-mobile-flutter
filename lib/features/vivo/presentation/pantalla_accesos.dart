import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/chips.dart';
import '../../../core/ui/ilustraciones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../l10n/l10n.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../familia/presentation/fila_miembro.dart';
import '../../repeticion/data/repeticiones_repositorio.dart';
import '../data/registro_accesos.dart';
import '../data/vista_en_vivo_repositorio.dart';
import '../../../core/foto.dart';
import '../../perfil/data/fotos.dart';

/// The chips of the log (screens 213, 214).
enum FiltroAccesos { todo, vivo, repeticiones }

/// «Hoy», «Ayer» or «lun 21 sep».
String diaDeAcceso(DateTime dia, DateTime hoy, AppLocalizations l) =>
    mismoDia(dia, hoy)
    ? l.camaraHoy
    : mismoDia(dia, hoy.subtract(const Duration(days: 1)))
    ? l.camaraAyer
    : l.formato.fechaCorta(dia);

/// The access log (screens 42, 43, 213, 214): who watched the live view or a preview, or replayed
/// a moment, when and for how long, newest first (CA-24.2, CA-39.3), or «Aún no hay accesos
/// registrados» (CA-24.3). A replay opens again in the camera's player.
class PantallaAccesos extends ConsumerStatefulWidget {
  const PantallaAccesos({super.key});

  @override
  ConsumerState<PantallaAccesos> createState() => _PantallaAccesosState();
}

class _PantallaAccesosState extends ConsumerState<PantallaAccesos> {
  var _filtro = FiltroAccesos.todo;

  @override
  Widget build(BuildContext context) {
    final accesos = ref.watch(registroAccesosProvider);
    final hoy = ref.watch(relojProvider)();
    final texto = Theme.of(context).textTheme;
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.accesosTitulo)),
      body: RefreshIndicator(
        onRefresh: () {
          // The sources too: replays watched on a PC arrive from elsewhere.
          ref
            ..invalidate(accesosVivoProvider)
            ..invalidate(accesosRepeticionesProvider)
            ..invalidate(repeticionesEnPcProvider);
          return ref.refresh(registroAccesosProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            Text(l.accesosIntro, style: texto.bodyMedium),
            ...switch (accesos) {
              AsyncData(value: final lista) when lista.isEmpty => [
                EstadoVacio(
                  ilustracion: IlustracionVacio.ojo,
                  titulo: l.accesosVacio,
                ),
              ],
              AsyncData(value: final lista) => [
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (f, t) in [
                      (FiltroAccesos.todo, l.accesosTodo),
                      (FiltroAccesos.vivo, l.accesosVistaEnVivo),
                      (FiltroAccesos.repeticiones, l.accesosRepeticiones),
                    ])
                      ChipOpcion(
                        texto: t,
                        elegido: _filtro == f,
                        alTocar: () => setState(() => _filtro = f),
                      ),
                  ],
                ),
                for (final (dia, grupo) in _porDia([
                  for (final a in lista)
                    if (switch (_filtro) {
                      FiltroAccesos.todo => true,
                      FiltroAccesos.vivo => a.tipo != TipoAcceso.repeticion,
                      FiltroAccesos.repeticiones =>
                        a.tipo == TipoAcceso.repeticion,
                    })
                      a,
                ])) ...[
                  EncabezadoDia(diaDeAcceso(dia, hoy, l)),
                  ListaTarjeta(
                    children: [for (final a in grupo) FilaAcceso(a)],
                  ),
                ],
              ],
              AsyncError(:final error) => [
                const SizedBox(height: 16),
                MensajeProblema(error),
              ],
              _ => const [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            },
          ],
        ),
      ),
    );
  }

  /// Accesses grouped by local day, keeping the newest-first order.
  static List<(DateTime, List<Acceso>)> _porDia(List<Acceso> lista) {
    final grupos = <(DateTime, List<Acceso>)>[];
    for (final a in lista) {
      if (grupos.isEmpty || !mismoDia(grupos.last.$1, a.inicio)) {
        grupos.add((a.inicio, [a]));
      } else {
        grupos.last.$2.add(a);
      }
    }
    return grupos;
  }
}

/// A row (`accRow`): the avatar with the kind's badge, «Vista en vivo · Sala», «Vista previa al
/// elegir cámaras · Webcam USB HD» or «Repetición · Sala, 15/09 07:54», and «Carmen (tú) · 21:46 ·
/// 2 min 10 s». A replay opens again («Abrir de nuevo»).
class FilaAcceso extends ConsumerWidget {
  const FilaAcceso(this.acceso, {super.key});

  final Acceso acceso;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = acceso;
    final yo = ref.watch(sesionControllerProvider)?.usuario.id == a.usuarioId;
    final miembros = ref.watch(miembrosProvider).value ?? const [];
    final i = miembros.indexWhere((m) => m.familiar.usuarioId == a.usuarioId);
    final camaras = ref.watch(camarasProvider).value ?? const <Camara>[];
    final camara =
        camaras.where((c) => c.id == a.camaraId).firstOrNull ??
        (a.camaraId == null ? camaras.firstOrNull : null);
    final habitacion = a.habitacion ?? camara?.nombreHabitacion ?? '';
    final l = context.l10n;
    final f = l.formato;
    final quien = a.enPc
        ? nombrePc(a, l)
        : yo
        ? l.accesosNombreTu(a.nombre.split(' ').first)
        : a.nombre.split(' ').first;
    String habitacionDe(String id) =>
        camaras.where((c) => c.id == id).firstOrNull?.nombreHabitacion ?? '';
    final titulo = switch (a.tipo) {
      // «Carmen (tú) vio Sala, Cocina y Pasillo» (CA-41.6); a removed camera has no name left.
      TipoAcceso.mosaico => switch ([
        for (final id in a.camaraIds) habitacionDe(id),
      ].where((h) => h.isNotEmpty).toList()) {
        final List<String> vistas when vistas.isNotEmpty => l.accesosVio(
          quien,
          f.enumerar(vistas),
        ),
        _ => l.accesosVariasCamaras,
      },
      TipoAcceso.vivo =>
        habitacion.isEmpty
            ? l.accesosVistaEnVivo
            : l.accesosVistaEnVivoDe(habitacion),
      TipoAcceso.vistaPrevia => switch (camara?.nombreDispositivo) {
        final d? => l.accesosVistaPreviaDe(d),
        null => l.accesosVistaPrevia,
      },
      TipoAcceso.repeticion => l.accesosRepeticion(
        habitacion,
        diaMes(a.momento!, f),
        f.hora(a.momento!),
      ),
    };
    final repeticion = a.tipo == TipoAcceso.repeticion;
    final colorEnlace = context.colores.moradoTinta;
    return FilaLista(
      inicio: _AvatarConInsignia(
        nombre: a.nombre,
        foto: ref.watch(fotoDeUsuarioProvider(a.usuarioId)),
        tono: tonoDe(i < 0 ? 0 : i),
        tipo: a.tipo,
        enPc: a.enPc,
      ),
      titulo: titulo,
      subtituloRico: TextSpan(
        children: [
          TextSpan(
            text: a.tipo == TipoAcceso.mosaico
                ? '${l.accesosVariasCamaras} · '
                : '$quien · ',
          ),
          TextSpan(text: f.hora(a.inicio), style: estiloCifras),
          TextSpan(
            text: ' · ${f.duracion(Duration(seconds: a.duracionSegundos))}',
          ),
        ],
      ),
      debajo: a.desdeAlerta
          ? Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: context.colores.fondo2,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l.accesosDesdeAlerta,
                  style: estiloTexto(13, 800, color: context.colores.tinta2),
                ),
              ),
            )
          : repeticion
          ? Padding(
              padding: const EdgeInsets.only(top: 6),
              child: ExcludeSemantics(
                child: Text(
                  l.accesosAbrirDeNuevo,
                  style: estiloTexto(15, 700, color: colorEnlace).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: colorEnlace,
                  ),
                ),
              ),
            )
          : null,
      alTocar: repeticion && a.camaraId != null && a.camaraId!.isNotEmpty
          ? () => context.push(Rutas.camaraEn(a.camaraId!, a.momento!))
          : null,
    );
  }
}

class _AvatarConInsignia extends StatelessWidget {
  const _AvatarConInsignia({
    required this.nombre,
    required this.foto,
    required this.tono,
    required this.tipo,
    this.enPc = false,
  });

  final String nombre;
  final Foto? foto;
  final TonoAvatar tono;
  final TipoAcceso tipo;

  /// A replay watched on a PC: the PC's icon instead of a member's avatar.
  final bool enPc;

  @override
  Widget build(BuildContext context) {
    final repeticion = tipo == TipoAcceso.repeticion;
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        children: [
          if (enPc)
            const IconoFila(Ico.pc)
          else
            Avatar(Avatar.inicialesDe(nombre), tono: tono, foto: foto),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: repeticion ? Colores.coral : Colores.morado,
                shape: BoxShape.circle,
                border: Border.all(color: context.colores.tarjeta, width: 2),
              ),
              child: Icono(
                switch (tipo) {
                  TipoAcceso.vivo => Ico.video,
                  TipoAcceso.mosaico => Ico.grid,
                  TipoAcceso.vistaPrevia => Ico.cam,
                  TipoAcceso.repeticion => Ico.replay,
                },
                tamano: 12,
                color: repeticion ? context.colores.tinta : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// «PC de la casa» or «PC Cocina-Rosa»: who watched a replay on a PC.
String nombrePc(Acceso a, AppLocalizations l) {
  final pc = a.pc ?? '';
  return pc.isEmpty ? l.camaraPcDeLaCasa : l.camaraPcNombre(pc);
}

/// «Luis · hoy 08:15», «Tú · lun 21 sep 12:06» or «Sin accesos» (the camera's settings).
String resumenUltimoAcceso(
  Acceso? a, {
  String? yo,
  required DateTime hoy,
  required AppLocalizations l,
}) {
  if (a == null) return l.accesosSinAccesos;
  final quien = a.enPc
      ? nombrePc(a, l)
      : a.usuarioId == yo
      ? l.accesosTu
      : a.nombre.split(' ').first;
  final dia = mismoDia(a.inicio, hoy)
      ? l.accesosHoyMinuscula
      : l.formato.fechaCorta(a.inicio);
  return l.accesosResumen(quien, dia, l.formato.hora(a.inicio));
}

/// `15/09` (`09/15` in English): a day of this year.
String diaMes(DateTime t, Formato f) {
  String dos(int n) => n.toString().padLeft(2, '0');
  return f.idioma == 'en'
      ? '${dos(t.month)}/${dos(t.day)}'
      : '${dos(t.day)}/${dos(t.month)}';
}
