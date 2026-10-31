# Novedades

«Qué cambió» of each version of the Te Tengo app, as the family reads it when the app says «Hay una versión nueva» (US-43). When a version reaches production, `produccion.yml` publishes the lines of its section with the version for the apps (`versiones/pwa.json`, `apk.json`, `play.json` and `ios.json`, read by `GET /api/versiones`; docs/RELEASES.md).

- One section per version, `## [x.y.z]`, written on the release branch before merging it (rename `[Unreleased]`).
- Each line starts with `- `: one short sentence in Spanish for a family member, at most 10 lines of 200 characters; what changed for them, not how (the CHANGELOG is the technical record).
- The lines are copy: they need the same approval as any other label (docs/BLOCKERS.md). A version without a section is published without notes, and the apps hide «Qué cambió».

## [Unreleased]

## [0.9.0]

- Crear tu cuenta es más corto: solo 2 pasos, los datos de tu familiar y su consentimiento.
- Al terminar te pedimos activar las notificaciones. La PC y otros familiares se agregan después desde Inicio, Familia o Ajustes.
- La pantalla de bienvenida ahora tiene una foto.

## [0.8.0]

- Los textos de consentimiento y la política de privacidad dicen que los clips y movimientos de la nube ahora se guardan en Microsoft Azure.

## [0.7.0]

- Ahora Te Tengo te avisa cuando una PC se restablece o se desinstala.
- Las PC que se quitan de la casa desaparecen de «PCs y cámaras».
