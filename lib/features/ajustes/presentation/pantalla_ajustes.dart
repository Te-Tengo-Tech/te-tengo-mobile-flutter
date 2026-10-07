import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
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

/// Ajustes tab (screen 94).
class PantallaAjustes extends ConsumerWidget {
  const PantallaAjustes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(sesionControllerProvider);
    final hogar = ref.watch(hogarProvider).value;
    final titular = sesion?.esTitular ?? false;
    final soloVer = titular ? null : const EtiquetaSoloVer();
    final texto = Theme.of(context).textTheme;
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
