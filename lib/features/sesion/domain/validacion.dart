/// Client-side checks with the prototype messages; the backend validates again (`400 VALIDACION`).
library;

final _correo = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

/// Email: empty or incomplete.
String? validarCorreo(
  String correo, {
  String vacio = 'Escribe tu correo electrónico.',
}) {
  if (correo.isEmpty) return vacio;
  if (!_correo.hasMatch(correo)) return 'Revisa el correo: parece incompleto.';
  return null;
}

/// New password: at least 8 characters and a number.
String? validarContrasenaNueva(
  String clave, {
  String? vacio = 'Crea una contraseña.',
}) {
  if (clave.isEmpty && vacio != null) return vacio;
  if (clave.length < 8 || !clave.contains(RegExp(r'\d'))) {
    return 'Usa al menos 8 caracteres y un número.';
  }
  return null;
}

/// Hint under new-password fields.
const ayudaContrasena = 'Mínimo 8 caracteres, con al menos un número.';
