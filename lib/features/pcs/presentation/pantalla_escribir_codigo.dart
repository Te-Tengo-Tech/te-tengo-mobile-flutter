import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../data/pcs_repositorio.dart';
import '../domain/pc.dart';
import 'campo_codigo.dart';

/// «Escribe el código de la PC» (screens 128 to 133): the fallback when the QR cannot be scanned
/// (CA-28.2). Wrong codes (CA-28.6), expired or used ones (CA-28.3) and the 15-minute block are
/// told in place; a valid one opens the approval screen.
class PantallaEscribirCodigo extends ConsumerStatefulWidget {
  const PantallaEscribirCodigo({super.key, this.enConfiguracion = false});

  final bool enConfiguracion;

  @override
  ConsumerState<PantallaEscribirCodigo> createState() =>
      _PantallaEscribirCodigoState();
}

class _PantallaEscribirCodigoState
    extends ConsumerState<PantallaEscribirCodigo> {
  final _control = TextEditingController();
  final _foco = FocusNode();
  String _letras = '';
  bool _letrasAjenas = false;
  bool _consultando = false;
  ErrorDeCodigo? _error;
  DateTime? _bloqueadaHasta;
  Timer? _desbloqueo;

  bool get _bloqueado => _bloqueadaHasta != null;

  @override
  void dispose() {
    _desbloqueo?.cancel();
    _control.dispose();
    _foco.dispose();
    super.dispose();
  }

  Future<void> _continuar() async {
    if (_letras.length != largoDelCodigo || _bloqueado || _consultando) return;
    final codigo = formatoCodigo(_letras);
    final config = widget.enConfiguracion;
    // An invited member cannot look a code up: the approval screen tells them who can (CA-28.5).
    if (!ref.read(esTitularProvider)) {
      context.pushReplacement(Rutas.aprobarPc(codigo, config: config));
      return;
    }
    setState(() {
      _consultando = true;
      _error = null;
    });
    try {
      final consulta = await ref.read(pcsRepositorioProvider).consultar(codigo);
      if (!mounted) return;
      context.pushReplacement(
        Rutas.aprobarPc(consulta.codigo, config: config),
        extra: consulta,
      );
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      final error = ErrorDeCodigo.desde(e);
      if (error.tipo == TipoErrorCodigo.soloTitular) {
        context.pushReplacement(Rutas.aprobarPc(codigo, config: config));
        return;
      }
      setState(() {
        if (error.tipo == TipoErrorCodigo.bloqueado) {
          _bloquear(error.bloqueadaHasta);
        } else {
          _error = error;
        }
      });
    } finally {
      if (mounted) setState(() => _consultando = false);
    }
  }

  /// Code entry is blocked until [hasta] (CA-28.6); the field comes back on its own.
  void _bloquear(DateTime? hasta) {
    final ahora = ref.read(relojProvider)();
    _bloqueadaHasta = hasta ?? ahora.add(const Duration(minutes: 15));
    _foco.unfocus();
    _desbloqueo?.cancel();
    _desbloqueo = Timer(_bloqueadaHasta!.difference(ahora), () {
      if (mounted) setState(() => _bloqueadaHasta = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final error = _error;
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar PC')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Semantics(
            header: true,
            child: Text('Escribe el código de la PC', style: texto.titleLarge),
          ),
          const SizedBox(height: 16),
          if (_bloqueado) ...[
            Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.clock,
              titulo: 'Demasiados intentos',
              contenido: textoBloqueo(_bloqueadaHasta),
            ),
            const SizedBox(height: 16),
          ],
          const EtiquetaCampo('Código de 8 letras'),
          const SizedBox(height: 8),
          CampoCodigo(
            controlador: _control,
            foco: _foco,
            error: error != null,
            habilitado: !_bloqueado,
            alCambiar: (letras) => setState(() {
              _letras = letras;
              _error = null;
            }),
            alIgnorarLetras: () => setState(() => _letrasAjenas = true),
            alEnviar: _continuar,
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Semantics(
              liveRegion: true,
              child: _Linea(
                icono: Ico.warn,
                texto: error.texto,
                color: context.colores.caidaTinta,
              ),
            ),
          ],
          if (_letrasAjenas) ...[
            const SizedBox(height: 10),
            _Linea(
              icono: Ico.info,
              texto: 'El código solo lleva consonantes, sin números',
              color: context.colores.aviso,
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Son 8 letras. Lo ves debajo del código QR en Te Tengo Captura.',
            style: texto.bodySmall,
          ),
          const SizedBox(height: 20),
          Boton(
            'Continuar',
            cargando: _consultando,
            alPresionar: _letras.length == largoDelCodigo && !_bloqueado
                ? _continuar
                : null,
          ),
          if (!_bloqueado) ...[
            const SizedBox(height: 8),
            Boton(
              'Escanear el código QR',
              icono: Ico.scan,
              estilo: EstiloBoton.fantasma,
              alPresionar: () => context.pushReplacement(
                Rutas.enPaso(Rutas.escanear, config: widget.enConfiguracion),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A message line under the code: icon and text in one color.
class _Linea extends StatelessWidget {
  const _Linea({required this.icono, required this.texto, required this.color});

  final Ico icono;
  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icono(icono, tamano: 20, color: color),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(texto, style: estiloTexto(16, 400, color: color)),
      ),
    ],
  );
}
