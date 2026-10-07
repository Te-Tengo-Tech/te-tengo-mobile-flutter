import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/formato.dart';
import '../../../core/ui/aviso.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../familia/domain/familiar.dart';
import '../../hogar/domain/hogar.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../sesion/presentation/cerrar_sesion.dart';

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
    final camara = ref.watch(camarasProvider).value?.firstOrNull;
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
            texto:
                'Ves las mismas alertas, clips e historial que $duena. Lo '
                'marcado con candado solo lo puede cambiar $duena (titular).',
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
            if (camara != null && hogar != null)
              FilaLista(
                inicio: const IconoFila(Ico.cam),
                titulo: 'Cámara · ${camara.nombreHabitacion}',
                subtitulo: camara
                    .estadoVisible(conConsentimiento: hogar.conConsentimiento)
                    .texto,
                alTocar: () => context.push(Rutas.camara(camara.id)),
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
              inicio: const IconoFila(Ico.shield),
              titulo: 'Privacidad y consentimiento',
              subtitulo: consentimiento != null && consentimiento.vigente
                  ? 'Vigente desde el ${fechaConAnio(consentimiento.otorgadoEn)}'
                  : 'Sin consentimiento',
              fin: soloVer,
              chevron: titular,
              alTocar: () => context.push(Rutas.privacidad),
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
          'Te Tengo 1.0 · prueba piloto',
          textAlign: TextAlign.center,
          style: texto.bodySmall,
        ),
      ],
    );
  }
}
