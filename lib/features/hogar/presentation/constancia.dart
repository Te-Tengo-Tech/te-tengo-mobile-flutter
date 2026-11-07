import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';

import '../../../app/tema/paleta.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/tarjeta.dart';
import '../../../l10n/l10n.dart';
import '../domain/hogar.dart';

/// Consent certificate (DESIGN.md): green band, who granted it, who recorded it, date and time, the
/// mention of Law No. 29733 (CA-05.3) and a link to the full consent document.
class TarjetaConstancia extends StatelessWidget {
  const TarjetaConstancia({
    super.key,
    required this.consentimiento,
    this.enlace,
  });

  final Consentimiento consentimiento;

  /// Text of the link to the full document; «Ver la constancia completa» when null.
  final String? enlace;

  @override
  Widget build(BuildContext context) {
    final c = consentimiento;
    return TarjetaBanda.construir(
      banda: Banda.calma,
      builder: (context) {
        final texto = Theme.of(context).textTheme;
        final l = context.l10n;
        final formato = context.formato;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icono(
                  Ico.shield,
                  tamano: 26,
                  color: context.colores.calmaTinta,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.consentimientoConstanciaTitulo,
                    style: texto.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DatosTarjeta([
              // The values are the record as the backend stored it.
              FilaDato(
                clave: l.consentimientoOtorgadoPor,
                valor: c.otorgadoPor,
              ),
              FilaDato(
                clave: l.consentimientoRegistradoPor,
                valor: c.registradoPor,
              ),
              FilaDato(
                clave: l.consentimientoFecha,
                valor: formato.fechaConAnio(c.otorgadoEn),
              ),
              FilaDato(
                clave: l.consentimientoHora,
                valor: formato.hora(c.otorgadoEn),
                mono: true,
              ),
            ]),
            const SizedBox(height: 8),
            Text(l.consentimientoConstanciaLey, style: texto.bodySmall),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Enlace(
                enlace ?? l.consentimientoVerConstancia,
                alTocar: () => context.push(Rutas.documentoConsentimiento),
              ),
            ),
          ],
        );
      },
    );
  }
}
