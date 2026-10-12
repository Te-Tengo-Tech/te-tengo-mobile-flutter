import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/dispositivo/conectividad.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../../familia/data/familia_repositorio.dart';
import '../data/pcs_repositorio.dart';
import 'pantalla_pc_vinculada.dart';
import 'piezas_pc.dart';

/// Where the PC's installer is downloaded. The prototype says «tetengo.pe/captura», which does not
/// exist yet; the landing's downloads are the real page (docs/BLOCKERS.md).
const paginaDescargaCaptura = 'tetengo.reqsai.tech';

/// Setup step 3 of 5, «PC de la casa» (screens 22, 25, 142 and 143): link the PC, or, once it is
/// linked, choose its cameras.
class PantallaPcDeLaCasa extends ConsumerWidget {
  const PantallaPcDeLaCasa({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pcs = ref.watch(pcsProvider);
    return switch (pcs) {
      AsyncData(value: final lista) when lista.isNotEmpty =>
        PantallaPcVinculada(pcId: lista.first.id, enConfiguracion: true),
      AsyncData() => const PantallaVincularPc(enConfiguracion: true),
      AsyncError(:final error) => Scaffold(
        appBar: CabeceraConfiguracion(
          paso: 3,
          titulo: 'PC de la casa',
          escala: MediaQuery.textScalerOf(context),
        ),
        body: ErrorDePantalla(
          error: error,
          alReintentar: () async => ref.invalidate(pcsProvider),
        ),
      ),
      _ => Scaffold(
        appBar: CabeceraConfiguracion(
          paso: 3,
          titulo: 'PC de la casa',
          escala: MediaQuery.textScalerOf(context),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

/// «Vincula la PC de la casa» (screens 22, 120 and 121): how to install Te Tengo Captura, then scan
/// its QR or type its code (CA-28.1, CA-28.2). Only the owner links a PC (CA-28.5).
class PantallaVincularPc extends ConsumerWidget {
  const PantallaVincularPc({super.key, this.enConfiguracion = false});

  /// Step 3 of 5 of the setup.
  final bool enConfiguracion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texto = Theme.of(context).textTheme;
    final titular = ref.watch(esTitularProvider);
    final sinInternet = ref.watch(sinInternetProvider).value ?? false;
    final deshabilitado = sinInternet || !titular;
    return Scaffold(
      appBar: enConfiguracion
          ? CabeceraConfiguracion(
              paso: 3,
              titulo: 'PC de la casa',
              escala: MediaQuery.textScalerOf(context),
            )
          : AppBar(title: const Text('Agregar PC')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, enConfiguracion ? 0 : 4, 20, 28),
        children: [
          const HeroePc(),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text('Vincula la PC de la casa', style: texto.titleLarge),
          ),
          const SizedBox(height: 16),
          if (sinInternet) ...[
            const Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.wifiOff,
              titulo: 'Sin internet',
              texto: 'Revisa tu conexión y vuelve a intentarlo.',
            ),
            const SizedBox(height: 16),
          ],
          if (!titular) ...[
            AvisoSoloLectura(
              titular: ref.watch(nombreTitularProvider) ?? '',
              accion: 'agregar una PC',
            ),
            const SizedBox(height: 16),
          ],
          const PasosNumerados([
            (
              'Instala Te Tengo Captura en la PC',
              'Desde $paginaDescargaCaptura',
            ),
            ('Ábrelo: muestra un código QR', null),
            ('Escanea el QR con este celular', null),
          ]),
          const SizedBox(height: 20),
          Boton(
            'Escanear el código QR',
            icono: Ico.scan,
            alPresionar: deshabilitado
                ? null
                : () => context.push(
                    Rutas.enPaso(Rutas.escanear, config: enConfiguracion),
                  ),
          ),
          const SizedBox(height: 12),
          Boton(
            'Escribir el código',
            icono: Ico.keyboard,
            estilo: EstiloBoton.secundario,
            alPresionar: deshabilitado
                ? null
                : () => context.push(
                    Rutas.enPaso(Rutas.escribirCodigo, config: enConfiguracion),
                  ),
          ),
          if (enConfiguracion) ...[
            const SizedBox(height: 8),
            Boton(
              'Hacerlo después',
              estilo: EstiloBoton.fantasma,
              alPresionar: () => context.go(Rutas.configFamilia),
            ),
            const SizedBox(height: 8),
            Text(
              'Sin una PC vinculada no detectamos caídas.',
              textAlign: TextAlign.center,
              style: texto.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
