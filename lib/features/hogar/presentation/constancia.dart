import 'package:flutter/material.dart';

import '../../../app/tema/colores.dart';
import '../../../core/formato.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/tarjeta.dart';
import '../domain/hogar.dart';

/// Consent certificate (DESIGN.md): green band, who granted it, who recorded it, date and time, and
/// the mention of Law No. 29733 (CA-05.3).
class TarjetaConstancia extends StatelessWidget {
  const TarjetaConstancia({
    super.key,
    required this.consentimiento,
    required this.nombreAdultoMayor,
  });

  final Consentimiento consentimiento;

  /// First name of the older adult.
  final String nombreAdultoMayor;

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
            'Guardamos la fecha y la hora como constancia de que '
            '$nombreAdultoMayor autorizó el monitoreo, como lo exige la Ley N.° '
            '29733 de Protección de Datos Personales.',
            style: texto.bodySmall,
          ),
        ],
      ),
    );
  }
}
