/// Client-side checks with the prototype messages; the backend validates again (`400 VALIDACION`).
/// The hint under new-password fields is `AppLocalizations.sesionAyudaContrasena`.
library;

import '../../../l10n/l10n.dart';

final _correo = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

/// Email: empty ([vacio], «Escribe tu correo electrónico.» by default) or incomplete.
String? validarCorreo(AppLocalizations l, String correo, {String? vacio}) {
  if (correo.isEmpty) return vacio ?? l.sesionErrorCorreoVacio;
  if (!_correo.hasMatch(correo)) return l.sesionErrorCorreoIncompleto;
  return null;
}

/// New password: at least 8 characters and a number. An empty one is only reported as empty
/// when [exigida].
String? validarContrasenaNueva(
  AppLocalizations l,
  String clave, {
  bool exigida = true,
}) {
  if (clave.isEmpty && exigida) return l.sesionErrorClaveVacia;
  if (clave.length < 8 || !clave.contains(RegExp(r'\d'))) {
    return l.sesionErrorClaveCorta;
  }
  return null;
}
