import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../actividad/data/actividad_repositorio.dart';
import '../../actividad/presentation/pantalla_actividad.dart';
import '../../../app/rutas.dart';
import '../../../core/reloj.dart';
import '../../../core/dispositivo/permiso_notificaciones.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/formato.dart';
import '../../../core/ui/aviso.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../../pcs/data/pcs_repositorio.dart';
import '../../pcs/domain/pc.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../familia/domain/familiar.dart';
import '../../hogar/domain/hogar.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../sesion/presentation/cerrar_sesion.dart';
import '../data/apariencia.dart';
import 'hoja_apariencia.dart';

/// `78 años · Vive solo(a)` (the age only when the backend sends it).
String resumenAdultoMayor(AdultoMayor a) => [
  if (a.edad != null) '${a.edad} años',
  switch (a.convivencia) {
    Convivencia.solo => 'Vive solo(a)',
    Convivencia.conFamiliar => 'Vive contigo',
    Convivencia.conCuidador => 'Vive con otro cuidador',
    null => '',
  },
].where((t) => t.isNotEmpty).join(' · ');

/// Ajustes tab (screens 79 and 94). An invited member sees what only the owner can change with
/// the lock and «Solo ver» (CA-08.4).
class PantallaAjustes extends ConsumerWidget {
  const PantallaAjustes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(sesionControllerProvider);
    final hogar = ref.watch(hogarProvider).value;
    final titular = sesion?.esTitular ?? false;
    final soloVer = titular ? null : const EtiquetaSoloVer();
    final texto = Theme.of(context).textTheme;
    final duena = ref.watch(nombreTitularProvider) ?? '';
    final miembros = ref.watch(miembrosProvider).value ?? const [];
    final aviso = ref.watch(avisoProvider).value;
    String? nombreCon(PapelAviso papel) => miembros
        .where((m) => m.papel == papel)
        .firstOrNull
        ?.familiar
        .nombrePila;
    final principal = nombreCon(PapelAviso.principal);
    final secundario = nombreCon(PapelAviso.secundario);
    final espera =
        aviso?.esperaMinutos ?? ConfiguracionAviso.esperaPredeterminada;
    final consentimiento = hogar?.consentimiento;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Semantics(
            header: true,
            child: Text('Ajustes', style: texto.headlineMedium),
          ),
        ),
        if (!titular) ...[
          Aviso(
            tono: TonoAviso.info,
            icono: Ico.users,
            titulo: 'Eres familiar invitado',
            texto: 'Lo que tiene candado solo lo cambia $duena.',
          ),
          const SizedBox(height: 16),
        ],
        if (hogar != null) ...[
          ListaTarjeta(
            children: [
              FilaLista(
                inicio: Avatar(
                  Avatar.inicialesDe(hogar.adultoMayor.nombre),
                  tono: TonoAvatar.rosa,
                ),
                titulo: hogar.adultoMayor.nombre,
                subtitulo: resumenAdultoMayor(hogar.adultoMayor),
                fin: soloVer,
                chevron: titular,
                alTocar: () => context.push(Rutas.personaCuidada),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        ListaTarjeta(
          children: [
            FilaLista(
              inicio: const IconoFila(Ico.cam),
              titulo: 'Cámaras y PCs',
              subtitulo: _resumenCamaras(
                ref.watch(pcsProvider).value,
                ref.watch(camarasProvider).value,
              ),
              alTocar: () => context.push(Rutas.pcs),
            ),
            if (principal != null)
              FilaLista(
                inicio: const IconoFila(Ico.swap),
                titulo: 'Orden de aviso y espera',
                subtitulo:
                    '$principal'
                    '${secundario == null ? ' · sin secundario' : ' → $secundario'}'
                    ' · $espera min',
                fin: soloVer,
                chevron: titular,
                alTocar: () => context.push(Rutas.ordenAviso),
              ),
            FilaLista(
              inicio: const IconoFila(Ico.bell),
              titulo: 'Notificaciones',
              subtitulo: switch (ref.watch(notificacionesActivasProvider)) {
                AsyncData(value: true) => 'Activadas',
                AsyncData(value: false) => 'Desactivadas',
                _ => null,
              },
              alTocar: () => context.push(Rutas.notificaciones),
            ),
            // This phone's setting, so the invited member changes it too.
            FilaLista(
              inicio: const IconoFila(Ico.sun),
              titulo: 'Apariencia',
              subtitulo: ref.watch(aparienciaProvider).texto,
              alTocar: () => elegirApariencia(context),
            ),
            FilaLista(
              inicio: const IconoFila(Ico.shield),
              titulo: 'Privacidad y consentimiento',
              subtitulo: consentimiento != null && consentimiento.vigente
                  ? 'Vigente · ${fechaConAnio(consentimiento.otorgadoEn)}'
                  : 'Sin consentimiento',
              fin: soloVer,
              chevron: titular,
              alTocar: () => context.push(Rutas.privacidad),
            ),
            FilaLista(
              inicio: const IconoFila(Ico.list),
              titulo: 'Actividad',
              subtitulo: switch (ref.watch(ultimaActividadProvider)) {
                AsyncData(value: final a) => resumenUltimoCambio(
                  a,
                  ref.watch(relojProvider)(),
                ),
                _ => null,
              },
              alTocar: () => context.push(Rutas.actividad),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListaTarjeta(
          children: [
            FilaLista(
              inicio: const IconoFila(Ico.user),
              titulo:
                  'Tu cuenta · ${titular ? 'Titular' : 'Familiar invitado'}',
              subtitulo: sesion?.usuario.correo,
            ),
            FilaLista(
              inicio: const IconoFila(Ico.logout, peligro: true),
              titulo: 'Cerrar sesión',
              peligro: true,
              chevron: false,
              alTocar: () => cerrarSesion(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Te Tengo 1.0',
          textAlign: TextAlign.center,
          style: texto.bodySmall,
        ),
      ],
    );
  }
}

/// «4 cámaras · 2 PCs», «Cocina-Rosa sin conexión» or «Aún no hay una PC vinculada» (screen 167).
String? _resumenCamaras(List<Pc>? pcs, List<Camara>? camaras) {
  if (pcs == null) {
    return camaras == null ? null : contar(camaras.length, 'cámara', 'cámaras');
  }
  if (pcs.isEmpty) return 'Aún no hay una PC vinculada';
  final sinConexion = pcs.where((p) => p.sinConexion).firstOrNull;
  if (sinConexion != null) return '${sinConexion.nombre} sin conexión';
  final n = camaras?.length ?? pcs.fold<int>(0, (t, p) => t + p.camaras.length);
  return '${contar(n, 'cámara', 'cámaras')} · ${contar(pcs.length, 'PC', 'PCs')}';
}
