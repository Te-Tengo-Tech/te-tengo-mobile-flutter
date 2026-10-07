import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/camaras_repositorio.dart';
import '../domain/camara.dart';
import 'cabecera_camara.dart';

/// Setup step 3 of 4 (screens 19 and 22): the camera installed by the project team. Without consent
/// it is installed but sends no video, and the app asks to complete the consent (CA-05.2, CA-06.1).
class PantallaCamaraLista extends ConsumerWidget {
  const PantallaCamaraLista({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camaras = ref.watch(camarasProvider);
    final hogar = ref.watch(hogarProvider);
    Future<void> recargar() async {
      ref
        ..invalidate(camarasProvider)
        ..invalidate(hogarProvider);
    }

    return Scaffold(
      appBar: const CabeceraConfiguracion(paso: 3, titulo: 'Cámara'),
      body: switch ((camaras, hogar)) {
        (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
          ErrorDePantalla(error: error, alReintentar: recargar),
        (AsyncData(value: final lista), AsyncData(value: final h)) =>
          lista.isEmpty
              ? const SizedBox.shrink()
              : _Contenido(
                  camara: lista.first,
                  conConsentimiento: h.conConsentimiento,
                  nombre: h.adultoMayor.nombrePila,
                  ahora: ref.watch(relojProvider)(),
                ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.camara,
    required this.conConsentimiento,
    required this.nombre,
    required this.ahora,
  });

  final Camara camara;
  final bool conConsentimiento;
  final String nombre;
  final DateTime ahora;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final habitacion = camara.nombreHabitacion;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      children: [
        if (conConsentimiento) ...[
          Row(
            children: [
              const IconoGrande(
                icono: Ico.check,
                fondo: Colores.calmaSuave,
                color: Colores.calmaTinta,
                tamano: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    'Tu cámara ya está lista',
                    style: texto.titleLarge,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'El equipo del proyecto la instaló y la configuró en la PC de la '
            'casa de $nombre. No tienes que conectar nada: ya estamos '
            'detectando caídas ${enHabitacion(habitacion)}.',
            style: texto.bodyMedium,
          ),
        ] else ...[
          Semantics(
            header: true,
            child: Text(
              'La cámara está instalada, pero no envía video',
              style: texto.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sin el consentimiento de $nombre, la cámara '
            '${deHabitacion(habitacion)} no captura nada y no podemos detectar '
            'caídas.',
            style: texto.bodyMedium,
          ),
          const SizedBox(height: 16),
          Aviso(
            tono: TonoAviso.error,
            icono: Ico.lock,
            titulo: 'Falta el consentimiento informado',
            texto:
                'Se registra solo si $nombre lo acepta. Cuando lo registres, la '
                'cámara empezará a enviar video.',
            accion: Boton(
              'Completar el consentimiento',
              pequeno: true,
              alPresionar: () => context.go(Rutas.configConsentimiento),
            ),
          ),
        ],
        const SizedBox(height: 16),
        CabeceraCamara(
          camara: camara,
          estado: camara.estadoVisible(conConsentimiento: conConsentimiento),
          ahora: ahora,
        ),
        const EncabezadoSeccion('Nombre de la habitación'),
        Text(
          'Lo definió el equipo al instalarla y aparece en cada alerta. Si en '
          'casa la llaman de otra forma, cámbialo.',
          style: texto.bodyMedium,
        ),
        const SizedBox(height: 12),
        Boton(
          'Cambiar el nombre',
          estilo: EstiloBoton.secundario,
          icono: Ico.pin,
          alPresionar: () => context.push(
            Uri(
              path: Rutas.configNombreCamara,
              queryParameters: {'id': camara.id, 'actual': habitacion},
            ).toString(),
          ),
        ),
        const SizedBox(height: 20),
        if (conConsentimiento)
          Boton('Continuar', alPresionar: () => context.go(Rutas.configFamilia))
        else ...[
          Boton(
            'Continuar sin consentimiento',
            estilo: EstiloBoton.fantasma,
            alPresionar: () => context.go(Rutas.configFamilia),
          ),
          const SizedBox(height: 8),
          Text(
            'Podrás registrarlo después desde Inicio o Ajustes.',
            textAlign: TextAlign.center,
            style: texto.bodySmall,
          ),
        ],
      ],
    );
  }
}
