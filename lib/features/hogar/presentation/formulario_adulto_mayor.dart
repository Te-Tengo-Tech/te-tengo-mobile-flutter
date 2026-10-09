import 'package:flutter/material.dart';

import '../../../core/ui/formulario.dart';
import '../domain/hogar.dart';

/// State of the older adult form, shared by the setup step and the profile screen.
class FormularioAdultoMayor {
  FormularioAdultoMayor([AdultoMayor? actual])
    : nombre = TextEditingController(text: actual?.nombre),
      edad = TextEditingController(text: actual?.edad?.toString()),
      direccion = TextEditingController(text: actual?.direccion),
      convivencia = actual?.convivencia,
      _telefono = actual?.telefono;

  final TextEditingController nombre;
  final TextEditingController edad;
  final TextEditingController direccion;
  Convivencia? convivencia;
  Map<String, String> errores = {};

  /// Kept as it is: the form has no phone field (docs/BLOCKERS.md).
  final String? _telefono;

  /// Age range of the prototype's profile form (2 or 3 digits, 50 to 120 years).
  static const edadMinima = 50;
  static const edadMaxima = 120;

  /// Client check with the prototype messages (CA-04.3). Returns true when complete.
  bool validar() {
    final textoEdad = edad.text.trim();
    final anios = int.tryParse(textoEdad);
    errores = {
      if (nombre.text.trim().isEmpty) 'nombre': 'Escribe su nombre y apellido.',
      if (textoEdad.isEmpty)
        'edad': 'Escribe su edad.'
      else if (!RegExp(r'^\d{2,3}$').hasMatch(textoEdad) ||
          anios! < edadMinima ||
          anios > edadMaxima)
        'edad': 'Escribe una edad válida, en años.',
      if (direccion.text.trim().isEmpty)
        'direccion': 'Escribe la dirección de la vivienda.',
      if (convivencia == null) 'convivencia': 'Elige una opción.',
    };
    return errores.isEmpty;
  }

  /// Field errors of `400 VALIDACION` (keys of the contract body).
  void erroresDelBackend(Map<String, String> campos) => errores = {
    for (final e in campos.entries) e.key.split('.').last: e.value,
  };

  AdultoMayor get valor => AdultoMayor(
    nombre: nombre.text.trim(),
    edad: int.tryParse(edad.text.trim()),
    direccion: direccion.text.trim(),
    convivencia: convivencia,
    telefono: _telefono,
  );

  void dispose() {
    nombre.dispose();
    edad.dispose();
    direccion.dispose();
  }
}

/// Fields of the older adult (`¿A quién vas a cuidar?`).
class CamposAdultoMayor extends StatelessWidget {
  const CamposAdultoMayor({
    super.key,
    required this.formulario,
    required this.alCambiar,
    this.habilitado = true,
  });

  final FormularioAdultoMayor formulario;
  final VoidCallback alCambiar;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    final f = formulario;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CampoTexto(
          etiqueta: 'Nombre y apellido',
          controlador: f.nombre,
          error: f.errores['nombre'],
          marcador: 'Ej.: Rosa Huamán',
          habilitado: habilitado,
          accionTeclado: TextInputAction.next,
        ),
        CampoTexto(
          etiqueta: 'Edad',
          controlador: f.edad,
          tipo: TipoCampo.numero,
          error: f.errores['edad'],
          habilitado: habilitado,
          longitudMaxima: 3,
          accionTeclado: TextInputAction.next,
        ),
        CampoTexto(
          etiqueta: 'Dirección de la vivienda',
          controlador: f.direccion,
          error: f.errores['direccion'],
          marcador: 'Calle, número y distrito',
          ayuda: 'Ej.: Jr. Los Pinos 482, San Miguel, Lima',
          habilitado: habilitado,
        ),
        const EtiquetaCampo('¿Con quién vive?'),
        for (final c in Convivencia.values)
          OpcionRadio<Convivencia>(
            valor: c,
            seleccion: f.convivencia,
            titulo: c.titulo,
            subtitulo: c.detalle,
            error: f.errores.containsKey('convivencia'),
            alElegir: habilitado
                ? (v) {
                    f.convivencia = v;
                    f.errores.remove('convivencia');
                    alCambiar();
                  }
                : null,
          ),
        if (f.errores['convivencia'] case final error?) MensajeCampo(error),
        const SizedBox(height: 8),
      ],
    );
  }
}
