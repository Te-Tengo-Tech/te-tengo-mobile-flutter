import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/ilustraciones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../familia/presentation/fila_miembro.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/vista_en_vivo_repositorio.dart';
import '../domain/vista_en_vivo.dart';

/// Live view access log (screens 42 and 43): who watched, when it started and how long it lasted,
/// newest first (CA-24.2), or «Aún no hay accesos registrados» (CA-24.3).
class PantallaAccesos extends ConsumerWidget {
  const PantallaAccesos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accesos = ref.watch(accesosVivoProvider);
    final hogar = ref.watch(hogarProvider).value;
    final habitacion =
        ref.watch(camarasProvider).value?.firstOrNull?.nombreHabitacion ?? '';
    final yo = ref.watch(sesionControllerProvider)?.usuario.id;
    final miembros = ref.watch(miembrosProvider).value ?? const [];
    final hoy = ref.watch(relojProvider)();
    final consentimiento = hogar?.consentimiento;
    final texto = Theme.of(context).textTheme;
    TonoAvatar tono(String usuarioId) {
      final i = miembros.indexWhere((m) => m.familiar.usuarioId == usuarioId);
      return tonoDe(i < 0 ? 0 : i);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Registro de accesos')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(accesosVivoProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            Text(
              'Quién abrió la vista en vivo '
              '${habitacion.isEmpty ? '' : '${deHabitacion(habitacion)}, '}'
              'cuándo y cuánto duró. Toda la familia lo ve.',
              style: texto.bodyMedium,
            ),
            ...switch (accesos) {
              AsyncData(value: final lista) when lista.isEmpty => const [
                EstadoVacio(
                  ilustracion: IlustracionVacio.ojo,
                  titulo: 'Aún no hay accesos registrados',
                  texto: 'Aquí verás quién la abrió y cuánto duró.',
                ),
              ],
              AsyncData(value: final lista) => [
                for (final (dia, grupo) in _porDia(lista)) ...[
                  EncabezadoDia(
                    '${mismoDia(dia, hoy) ? 'Hoy, ' : ''}${fechaLarga(dia)}',
                  ),
                  ListaTarjeta(
                    children: [
                      for (final a in grupo)
                        _FilaAcceso(
                          acceso: a,
                          esYo: a.usuarioId == yo,
                          tono: tono(a.usuarioId),
                        ),
                    ],
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
            if (consentimiento != null && consentimiento.vigente) ...[
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icono(Ico.shield, tamano: 18, color: Colores.tinta3),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${hogar!.adultoMayor.nombrePila} autorizó la vista en '
                      'vivo en su consentimiento del '
                      '${fechaConAnio(consentimiento.otorgadoEn)}.',
                      style: texto.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Accesses grouped by local day, keeping the newest-first order.
  static List<(DateTime, List<AccesoVivo>)> _porDia(List<AccesoVivo> lista) {
    final grupos = <(DateTime, List<AccesoVivo>)>[];
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

class _FilaAcceso extends StatelessWidget {
  const _FilaAcceso({
    required this.acceso,
    required this.esYo,
    required this.tono,
  });

  final AccesoVivo acceso;
  final bool esYo;
  final TonoAvatar tono;

  @override
  Widget build(BuildContext context) {
    final a = acceso;
    return FilaLista(
      inicio: Avatar(Avatar.inicialesDe(a.nombre), tono: tono),
      titulo: esYo ? '${a.nombre} (tú)' : a.nombre,
      subtituloRico: TextSpan(
        children: [
          const TextSpan(text: 'Empezó a las '),
          TextSpan(
            text: hora(a.inicio),
            style: const TextStyle(fontFamily: fuenteMono),
          ),
          TextSpan(
            text: ' · duró ${duracion(Duration(seconds: a.duracionSegundos))}',
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
                  color: Colores.fondo2,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Desde una alerta',
                  style: estiloTexto(13, 800, color: Colores.tinta2),
                ),
              ),
            )
          : null,
    );
  }
}

/// «Último: tú, hoy a las 10:42 · 1 min 12 s» for the camera detail.
String resumenUltimoAcceso(AccesoVivo? a, {String? yo, required DateTime hoy}) {
  if (a == null) return 'Aún no hay accesos registrados';
  final quien = a.usuarioId == yo ? 'tú' : a.nombre.split(' ').first;
  final dia = mismoDia(a.inicio, hoy) ? 'hoy' : fechaCorta(a.inicio);
  return 'Último: $quien, $dia a las ${hora(a.inicio)} · '
      '${duracion(Duration(seconds: a.duracionSegundos))}';
}
