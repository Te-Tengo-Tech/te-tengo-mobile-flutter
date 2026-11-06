import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/tarjeta.dart';
import '../../../l10n/l10n.dart';
import '../../hogar/data/hogar_repositorio.dart';
import 'textos_legales.dart';

/// A legal document (`docPage`): an optional one-line intro and short sections (an 18 px title and
/// 16 px paragraphs), readable at any text size.
class PantallaDocumento extends StatelessWidget {
  const PantallaDocumento({
    super.key,
    required this.titulo,
    this.introduccion,
    required this.secciones,
    this.pie,
  });

  final String titulo;
  final String? introduccion;
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
          if (introduccion case final i?)
            Text(i, style: Theme.of(context).textTheme.bodyMedium),
          for (final (n, (titulo, parrafos)) in secciones.indexed) ...[
            SizedBox(height: n == 0 && introduccion == null ? 8 : 24),
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
    titulo: context.l10n.legalTerminosTitulo,
    secciones: seccionesTerminos(context.l10n),
    pie: Align(
      alignment: Alignment.centerLeft,
      child: Enlace(
        context.l10n.legalVerPolitica,
        alTocar: () => context.push(Rutas.politica),
      ),
    ),
  );
}

/// «Política de privacidad» (screen 06): opened from sign-up and from Ajustes › Privacidad.
class PantallaPolitica extends StatelessWidget {
  const PantallaPolitica({super.key});

  @override
  Widget build(BuildContext context) => PantallaDocumento(
    titulo: context.l10n.legalPoliticaTitulo,
    secciones: seccionesPolitica(context.l10n),
  );
}

/// The full consent document (screen 20): the same text as the folded summary, how it is recorded
/// and, once given, the certificate. Opened from «Leer el documento completo» and the certificate.
class PantallaDocumentoConsentimiento extends ConsumerWidget {
  const PantallaDocumentoConsentimiento({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final formato = context.formato;
    final hogar = ref.watch(hogarProvider).value;
    final nombre =
        hogar?.adultoMayor.nombrePila ?? l.consentimientoPersonaGenerica;
    final c = hogar != null && hogar.conConsentimiento
        ? hogar.consentimiento
        : null;
    return PantallaDocumento(
      titulo: l.consentimientoTitulo,
      introduccion: l.consentimientoDocumentoIntro(nombre),
      secciones: [
        for (final s in seccionesConsentimiento(l)) (s.titulo, [s.texto]),
        seccionRegistroConsentimiento(l),
      ],
      pie: c == null
          ? null
          : TarjetaBanda(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.consentimientoConstancia,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DatosTarjeta([
                    // The values are the record as the backend stored it.
                    FilaDato(
                      clave: l.consentimientoOtorgadoPor,
                      valor: c.otorgadoPor,
                    ),
                    FilaDato(
                      clave: l.consentimientoRegistradoPor,
                      valor: c.registradoPor,
                    ),
                    FilaDato(
                      clave: l.consentimientoFecha,
                      valor: formato.fechaConAnio(c.otorgadoEn),
                    ),
                    FilaDato(
                      clave: l.consentimientoHora,
                      valor: formato.hora(c.otorgadoEn),
                      mono: true,
                    ),
                  ]),
                ],
              ),
            ),
    );
  }
}
