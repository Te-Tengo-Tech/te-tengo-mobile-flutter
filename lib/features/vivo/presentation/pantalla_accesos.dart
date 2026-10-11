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
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../familia/presentation/fila_miembro.dart';
import '../data/registro_accesos.dart';

/// The chips of the log (screens 213, 214).
enum FiltroAccesos { todo, vivo, repeticiones }

/// «Hoy», «Ayer» or «lun 21 sep».
String diaDeAcceso(DateTime dia, DateTime hoy) => mismoDia(dia, hoy)
    ? 'Hoy'
    : mismoDia(dia, hoy.subtract(const Duration(days: 1)))
    ? 'Ayer'
    : fechaCorta(dia);

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
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de accesos')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(registroAccesosProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            Text(
              'Quién miró, cuándo y cuánto. Toda la familia lo ve.',
              style: texto.bodyMedium,
            ),
            ...switch (accesos) {
              AsyncData(value: final lista) when lista.isEmpty => const [
                EstadoVacio(
                  ilustracion: IlustracionVacio.ojo,
                  titulo: 'Aún no hay accesos registrados',
                ),
              ],
              AsyncData(value: final lista) => [
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (f, t) in const [
                      (FiltroAccesos.todo, 'Todo'),
                      (FiltroAccesos.vivo, 'Vista en vivo'),
                      (FiltroAccesos.repeticiones, 'Repeticiones'),
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
                  EncabezadoDia(diaDeAcceso(dia, hoy)),
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
    final titulo = switch (a.tipo) {
      TipoAcceso.vivo =>
        habitacion.isEmpty ? 'Vista en vivo' : 'Vista en vivo · $habitacion',
      TipoAcceso.vistaPrevia => switch (camara?.nombreDispositivo) {
        final d? => 'Vista previa al elegir cámaras · $d',
        null => 'Vista previa al elegir cámaras',
      },
      TipoAcceso.repeticion =>
        'Repetición · $habitacion, '
            '${_diaMes(a.momento!)} ${hora(a.momento!)}',
    };
    final repeticion = a.tipo == TipoAcceso.repeticion;
    final colorEnlace = context.colores.moradoTinta;
    return FilaLista(
      inicio: _AvatarConInsignia(
        nombre: a.nombre,
        tono: tonoDe(i < 0 ? 0 : i),
        tipo: a.tipo,
      ),
      titulo: titulo,
      subtituloRico: TextSpan(
        children: [
          TextSpan(text: '${a.nombre.split(' ').first}${yo ? ' (tú)' : ''} · '),
          TextSpan(
            text: hora(a.inicio),
            style: const TextStyle(fontFamily: fuenteMono),
          ),
          TextSpan(
            text: ' · ${duracion(Duration(seconds: a.duracionSegundos))}',
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
                  'Desde una alerta',
                  style: estiloTexto(13, 800, color: context.colores.tinta2),
                ),
              ),
            )
          : repeticion
          ? Padding(
              padding: const EdgeInsets.only(top: 6),
              child: ExcludeSemantics(
                child: Text(
                  'Abrir de nuevo',
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

  static String _diaMes(DateTime t) =>
      '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}';
}

class _AvatarConInsignia extends StatelessWidget {
  const _AvatarConInsignia({
    required this.nombre,
    required this.tono,
    required this.tipo,
  });

  final String nombre;
  final TonoAvatar tono;
  final TipoAcceso tipo;

  @override
  Widget build(BuildContext context) {
    final repeticion = tipo == TipoAcceso.repeticion;
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        children: [
          Avatar(Avatar.inicialesDe(nombre), tono: tono),
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

/// «Luis · hoy 08:15», «Tú · lun 21 sep 12:06» or «Sin accesos» (the camera's settings).
String resumenUltimoAcceso(Acceso? a, {String? yo, required DateTime hoy}) {
  if (a == null) return 'Sin accesos';
  final quien = a.usuarioId == yo ? 'Tú' : a.nombre.split(' ').first;
  final dia = mismoDia(a.inicio, hoy) ? 'hoy' : fechaCorta(a.inicio);
  return '$quien · $dia ${hora(a.inicio)}';
}
