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
import '../../../l10n/l10n.dart';
import '../../familia/data/familia_repositorio.dart';
import 'piezas_pc.dart';

/// Where the PC's installer is downloaded. The prototype says «tetengo.pe/captura», which does not
/// exist yet; the landing's downloads are the real page (docs/BLOCKERS.md).
const paginaDescargaCaptura = 'tetengo.reqsai.tech';

/// «Vincula la PC de la casa» (screens 22, 120 and 121): how to install Te Tengo Captura, then scan
/// its QR or type its code (CA-28.1, CA-28.2). Only the owner links a PC (CA-28.5).
class PantallaVincularPc extends ConsumerWidget {
  const PantallaVincularPc({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texto = Theme.of(context).textTheme;
    final titular = ref.watch(esTitularProvider);
    final sinInternet = ref.watch(sinInternetProvider).value ?? false;
    final deshabilitado = sinInternet || !titular;
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.pcsAgregarPc)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          const HeroePc(),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(l.pcsVinculaTitulo, style: texto.titleLarge),
          ),
          const SizedBox(height: 16),
          if (sinInternet) ...[
            Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.wifiOff,
              titulo: l.pcsSinInternet,
              texto: l.pcsRevisaConexion,
            ),
            const SizedBox(height: 16),
          ],
          if (!titular) ...[
            AvisoSoloLectura(
              titular: ref.watch(nombreTitularProvider) ?? '',
              accion: l.pcsAccionAgregarPc,
            ),
            const SizedBox(height: 16),
          ],
          PasosNumerados([
            (l.pcsPasoInstalar, l.pcsPasoInstalarDesde(paginaDescargaCaptura)),
            (l.pcsPasoAbrir, null),
            (l.pcsPasoEscanear, null),
          ]),
          const SizedBox(height: 20),
          Boton(
            l.pcsEscanearQr,
            icono: Ico.scan,
            alPresionar: deshabilitado
                ? null
                : () => context.push(Rutas.escanear),
          ),
          const SizedBox(height: 12),
          Boton(
            l.pcsEscribirCodigo,
            icono: Ico.keyboard,
            estilo: EstiloBoton.secundario,
            alPresionar: deshabilitado
                ? null
                : () => context.push(Rutas.escribirCodigo),
          ),
        ],
      ),
    );
  }
}
