import '../../../core/ui/iconos.dart';
import '../../../l10n/l10n.dart';

/// One section of the informed consent (`CONSENT_SEC` in the prototype): the same text feeds the
/// folded summary of the consent screen and the full document.
class SeccionConsentimiento {
  const SeccionConsentimiento({
    required this.icono,
    required this.titulo,
    required this.resumen,
    required this.texto,
  });

  final Ico icono;
  final String titulo;

  /// One line shown while the section is folded.
  final String resumen;
  final String texto;
}

/// The consent text, in the language of [l]. The live-view clause goes first: the checkbox
/// mentions it. Only the displayed text is translated: nothing of it is sent to the backend.
///
/// Video is analysed on the household PC (docs `04-arquitectura/decision-procesamiento-en-pc.md`).
/// The prototype's words are kept; the sentences it does not have, and the ones naming
/// Microsoft Azure (Azure Blob Storage, Chile Central; Cloudflare R2 until 2026-10-31) and the
/// cross-border flow, are pending legal review (docs/BLOCKERS.md), as is the English translation.
List<SeccionConsentimiento> seccionesConsentimiento(AppLocalizations l) => [
  SeccionConsentimiento(
    icono: Ico.eye,
    titulo: l.consentimientoSeccionVivoTitulo,
    resumen: l.consentimientoSeccionVivoResumen,
    texto: l.consentimientoSeccionVivoTexto,
  ),
  SeccionConsentimiento(
    icono: Ico.cam,
    titulo: l.consentimientoSeccionHacemosTitulo,
    resumen: l.consentimientoSeccionHacemosResumen,
    texto: l.consentimientoSeccionHacemosTexto,
  ),
  SeccionConsentimiento(
    icono: Ico.eyeOff,
    titulo: l.consentimientoSeccionNoHacemosTitulo,
    resumen: l.consentimientoSeccionNoHacemosResumen,
    texto: l.consentimientoSeccionNoHacemosTexto,
  ),
  SeccionConsentimiento(
    icono: Ico.video,
    titulo: l.consentimientoSeccionGuardamosTitulo,
    resumen: l.consentimientoSeccionGuardamosResumen,
    texto: l.consentimientoSeccionGuardamosTexto,
  ),
  SeccionConsentimiento(
    icono: Ico.shield,
    titulo: l.consentimientoSeccionDerechosTitulo,
    resumen: l.consentimientoSeccionDerechosResumen,
    texto: l.consentimientoSeccionDerechosTexto,
  ),
];

/// A titled section of a legal document, with one or more paragraphs.
typedef SeccionDocumento = (String titulo, List<String> parrafos);

/// «Términos de uso»: only facts the app already shows.
List<SeccionDocumento> seccionesTerminos(AppLocalizations l) => [
  (l.legalTerminosQueEsTitulo, [l.legalTerminosQueEsTexto]),
  (
    l.legalTerminosCuentaTitulo,
    [l.legalTerminosCuentaTexto1, l.legalTerminosCuentaTexto2],
  ),
  (l.legalTerminosInvitadosTitulo, [l.legalTerminosInvitadosTexto]),
  (
    l.legalTerminosConsentimientoTitulo,
    [l.legalTerminosConsentimientoTexto1, l.legalTerminosConsentimientoTexto2],
  ),
  (l.legalTerminosAlertasTitulo, [l.legalTerminosAlertasTexto]),
  (
    l.legalTerminosLimitesTitulo,
    [l.legalTerminosLimitesTexto1, l.legalTerminosLimitesTexto2],
  ),
];

/// «Política de privacidad»: what is stored, who sees it and for how long.
List<SeccionDocumento> seccionesPolitica(AppLocalizations l) => [
  (
    l.legalPoliticaDatosTitulo,
    [
      l.legalPoliticaDatosTexto1,
      l.legalPoliticaDatosTexto2,
      l.legalPoliticaDatosTexto3,
    ],
  ),
  (
    l.legalPoliticaVideoTitulo,
    [
      l.legalPoliticaVideoTexto1,
      l.legalPoliticaVideoTexto2,
      l.legalPoliticaVideoTexto3,
    ],
  ),
  (
    l.legalPoliticaMovimientosTitulo,
    [l.legalPoliticaMovimientosTexto1, l.legalPoliticaMovimientosTexto2],
  ),
  (l.legalPoliticaDondeTitulo, [l.legalPoliticaDondeTexto]),
  (l.legalPoliticaQuienTitulo, [l.legalPoliticaQuienTexto]),
  (l.legalPoliticaRevocarTitulo, [l.legalPoliticaRevocarTexto]),
  (l.legalPoliticaDerechosTitulo, [l.legalPoliticaDerechosTexto]),
];

/// Last section of the full consent document.
SeccionDocumento seccionRegistroConsentimiento(AppLocalizations l) =>
    (l.consentimientoRegistroTitulo, [l.consentimientoRegistroTexto]);
