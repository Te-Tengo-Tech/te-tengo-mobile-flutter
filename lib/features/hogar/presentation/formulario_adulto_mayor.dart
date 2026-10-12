import 'package:flutter/material.dart';

import '../../../core/ui/formulario.dart';
import '../domain/hogar.dart';

/// State of the older adult form, shared by the setup step and the profile screen.
class FormularioAdultoMayor {
  FormularioAdultoMayor([AdultoMayor? actual])
    : nombre = TextEditingController(text: actual?.nombre),
      edad = TextEditingController(text: actual?.edad?.toString()),
      direccion = TextEditingController(text: actual?.direccion),
      telefono = TextEditingController(text: actual?.telefono),
      convivencia = actual?.convivencia,
      _actual = actual;

  final TextEditingController nombre;
  final TextEditingController edad;
  final TextEditingController direccion;

  /// «Teléfono de Rosa»: only the profile screen shows it; the setup step keeps it as it is.
  final TextEditingController telefono;
  Convivencia? convivencia;
  Map<String, String> errores = {};

  final AdultoMayor? _actual;

  /// The phone the prototype accepts: digits and spaces, an optional leading `+`.
  static final telefonoValido = RegExp(r'^\+?[\d ]{7,15}$');

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
      if (telefono.text.trim().isNotEmpty &&
          !telefonoValido.hasMatch(telefono.text.trim()))
        'telefono': 'Revisa el teléfono: solo números.',
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
    telefono: telefono.text.trim().isEmpty ? null : telefono.text.trim(),
    foto: _actual?.foto,
    admiteFoto: _actual?.admiteFoto ?? false,
  );

  void dispose() {
    nombre.dispose();
    edad.dispose();
    direccion.dispose();
    telefono.dispose();
  }
}

/// Fields of the older adult (`¿A quién vas a cuidar?`).
class CamposAdultoMayor extends StatelessWidget {
  const CamposAdultoMayor({
    super.key,
    required this.formulario,
    required this.alCambiar,
    this.habilitado = true,
    this.conTelefono = false,
  });

  final FormularioAdultoMayor formulario;
  final VoidCallback alCambiar;
  final bool habilitado;

  /// «Teléfono de Rosa» (screen 105), which «Llamar a Rosa» dials.
  final bool conTelefono;

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
        if (conTelefono)
          CampoTexto(
            etiqueta: 'Teléfono de ${_pila(f.nombre.text)}',
            controlador: f.telefono,
            tipo: TipoCampo.telefono,
            error: f.errores['telefono'],
            ayuda: habilitado
                ? 'Lo usa «Llamar a ${_pila(f.nombre.text)}».'
                : null,
            habilitado: habilitado,
            longitudMaxima: 20,
            accionTeclado: TextInputAction.next,
          ),
        CampoTexto(
          etiqueta: 'Dirección de la vivienda',
          controlador: f.direccion,
          error: f.errores['direccion'],
          marcador: 'Calle, número y distrito',
          habilitado: habilitado,
        ),
        const EtiquetaCampo('¿Con quién vive?'),
        for (final c in Convivencia.values)
          OpcionRadio<Convivencia>(
            valor: c,
            seleccion: f.convivencia,
            titulo: c.titulo,
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

String _pila(String nombre) => nombre.trim().split(RegExp(r'\s+')).first;
