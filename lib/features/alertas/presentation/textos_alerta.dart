import 'package:flutter/painting.dart';

import '../../../core/ui/piezas.dart';
import '../../../l10n/l10n.dart';
import '../../camaras/domain/camara.dart';
import '../domain/alerta.dart';

/// «Caída en la Sala» («Fall in Sala»).
String tipoEnHabitacion(
  AppLocalizations l,
  TipoAlerta tipo,
  String habitacion,
) => l.alertaTipoEnHabitacion(
  tipo.nombre(l),
  conArticulo(habitacion),
  habitacion,
);

/// A translated message with its time ([horaTexto], already inside it) in the mono font, as
/// [conHora] does: «A las ⟨10:42⟩ en la Sala.». With [estilo], the time takes that style instead.
TextSpan textoConHora(String mensaje, String horaTexto, {TextStyle? estilo}) {
  final i = mensaje.indexOf(horaTexto);
  if (i < 0) return TextSpan(text: mensaje);
  final antes = mensaje.substring(0, i);
  final despues = mensaje.substring(i + horaTexto.length);
  if (estilo == null) return conHora(antes, horaTexto, despues);
  return TextSpan(
    children: [
      if (antes.isNotEmpty) TextSpan(text: antes),
      TextSpan(text: horaTexto, style: estilo),
      if (despues.isNotEmpty) TextSpan(text: despues),
    ],
  );
}
