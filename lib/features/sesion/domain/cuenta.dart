/// Account created with `POST /api/cuentas`.
class Cuenta {
  const Cuenta({required this.id, required this.correo, required this.nombre});

  final String id;
  final String correo;
  final String nombre;

  factory Cuenta.desdeJson(Map<String, dynamic> json) => Cuenta(
    id: json['id'] as String,
    correo: json['correo'] as String,
    nombre: json['nombre'] as String,
  );
}
