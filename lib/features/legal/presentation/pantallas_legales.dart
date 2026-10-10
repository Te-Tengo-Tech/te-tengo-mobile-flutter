import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/tarjeta.dart';
import '../../hogar/data/hogar_repositorio.dart';
import 'textos_legales.dart';

/// A legal document (`docPage`): a one-line intro and short sections (an 18 px title and 16 px
/// paragraphs), readable at any text size.
class PantallaDocumento extends StatelessWidget {
  const PantallaDocumento({
    super.key,
    required this.titulo,
    required this.introduccion,
    required this.secciones,
    this.pie,
  });

  final String titulo;
  final String introduccion;
  final List<SeccionDocumento> secciones;

  /// Shown after the sections (a link, the certificate).
  final Widget? pie;

  @override
  Widget build(BuildContext context) {
    final parrafo = estiloTexto(
      16,
      400,
      color: context.colores.tinta2,
    ).copyWith(height: 1.5);
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(introduccion, style: Theme.of(context).textTheme.bodyMedium),
          for (final (titulo, parrafos) in secciones) ...[
            const SizedBox(height: 24),
            Semantics(
              header: true,
              child: Text(
                titulo,
                style: estiloTexto(18, 800, color: context.colores.tinta),
              ),
            ),
            const SizedBox(height: 6),
            for (var i = 0; i < parrafos.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              Text(parrafos[i], style: parrafo),
            ],
          ],
          if (pie case final f?) ...[const SizedBox(height: 20), f],
        ],
      ),
    );
  }
}

/// «Términos de uso» (screen 05): opened from sign-up and from Ajustes › Privacidad.
class PantallaTerminos extends StatelessWidget {
  const PantallaTerminos({super.key});

  @override
  Widget build(BuildContext context) => PantallaDocumento(
    titulo: 'Términos de uso',
    introduccion: 'Las reglas para usar Te Tengo.',
    secciones: seccionesTerminos,
    pie: Align(
      alignment: Alignment.centerLeft,
      child: Enlace(
        'Ver la política de privacidad',
        alTocar: () => context.push(Rutas.politica),
      ),
    ),
  );
}

/// «Política de privacidad» (screen 06): opened from sign-up and from Ajustes › Privacidad.
class PantallaPolitica extends StatelessWidget {
  const PantallaPolitica({super.key});

  @override
  Widget build(BuildContext context) => const PantallaDocumento(
    titulo: 'Política de privacidad',
    introduccion:
        'Qué datos usamos, quién los ve y cuánto tiempo los guardamos.',
    secciones: seccionesPolitica,
  );
}

/// The full consent document (screen 20): the same text as the folded summary, how it is recorded
/// and, once given, the certificate. Opened from «Leer el documento completo» and the certificate.
class PantallaDocumentoConsentimiento extends ConsumerWidget {
  const PantallaDocumentoConsentimiento({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hogar = ref.watch(hogarProvider).value;
    final nombre = hogar?.adultoMayor.nombrePila ?? 'la persona cuidada';
    final c = hogar != null && hogar.conConsentimiento
        ? hogar.consentimiento
        : null;
    return PantallaDocumento(
      titulo: 'Consentimiento',
      introduccion:
          'Lo acepta $nombre o su representante legal antes de que la cámara '
          'envíe video.',
      secciones: [
        for (final s in seccionesConsentimiento) (s.titulo, [s.texto]),
        seccionRegistroConsentimiento,
      ],
      pie: c == null
          ? null
          : TarjetaBanda(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Constancia',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DatosTarjeta([
                    FilaDato(clave: 'Otorgado por', valor: c.otorgadoPor),
                    FilaDato(clave: 'Registrado por', valor: c.registradoPor),
                    FilaDato(clave: 'Fecha', valor: fechaConAnio(c.otorgadoEn)),
                    FilaDato(
                      clave: 'Hora',
                      valor: hora(c.otorgadoEn),
                      mono: true,
                    ),
                  ]),
                ],
              ),
            ),
    );
  }
}
