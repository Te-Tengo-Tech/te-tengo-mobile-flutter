import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';

import '../../../app/tema/colores.dart';
import '../../../core/formato.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/tarjeta.dart';
import '../domain/hogar.dart';

/// Consent certificate (DESIGN.md): green band, who granted it, who recorded it, date and time, the
/// mention of Law No. 29733 (CA-05.3) and a link to the full consent document.
class TarjetaConstancia extends StatelessWidget {
  const TarjetaConstancia({
    super.key,
    required this.consentimiento,
    this.enlace = 'Ver la constancia completa',
  });

  final Consentimiento consentimiento;

  /// Text of the link to the full document.
  final String enlace;

  @override
  Widget build(BuildContext context) {
    final c = consentimiento;
    final texto = Theme.of(context).textTheme;
    return TarjetaBanda(
      banda: Banda.calma,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icono(Ico.shield, tamano: 26, color: Colores.calmaTinta),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Constancia de consentimiento',
                  style: texto.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DatosTarjeta([
            FilaDato(clave: 'Otorgado por', valor: c.otorgadoPor),
            FilaDato(clave: 'Registrado por', valor: c.registradoPor),
            FilaDato(clave: 'Fecha', valor: fechaConAnio(c.otorgadoEn)),
            FilaDato(clave: 'Hora', valor: hora(c.otorgadoEn), mono: true),
          ]),
          const SizedBox(height: 8),
          Text(
            'Constancia exigida por la Ley N.° 29733.',
            style: texto.bodySmall,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Enlace(
              enlace,
              alTocar: () => context.push(Rutas.documentoConsentimiento),
            ),
          ),
        ],
      ),
    );
  }
}
