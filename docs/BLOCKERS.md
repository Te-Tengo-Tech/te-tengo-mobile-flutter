# Blockers

Tasks that cannot be finished without an outside decision or credential. Agents add an entry here, keep working on the next task, and never invent the missing value.

| Task | What is missing | Who decides | Date |
|---|---|---|---|
| Real push notifications | Firebase project (`google-services.json`, `GoogleService-Info.plist`) and an Apple Developer account for APNs | Team | — |
| Live view transport | Team confirmation of the WebSocket JPEG relay proposed in the API contract | Team | — |
| T05, T26 Email links | The contract does not define the links the backend emails. The app opens `tetengo://app/nueva-contrasena?token=…&correo=…` (password reset; `correo` optional) and `tetengo://app/invitacion/{token}` (invitation). HTTPS app links need a domain and its `assetlinks.json` / `apple-app-site-association` | Team | 2026-10-07 |
| T06, T13 Older adult age and phone | The prototype asks for «Edad» and shows «Llamar a Rosa · 987 654 321», but `adultoMayor` in the contract has only `nombre`, `direccion` and `convivencia`. The app omits the age field, reads `edad` and `telefono` if the backend ever sends them, and «Llamar» opens the dialer without a number until the contract adds them | Team | 2026-10-07 |
| T07, T17 Consent document | The prototype links «Leer el documento completo» and «Ver la constancia completa» (a PDF with date, time and signature), but the contract offers no document or certificate file. The app shows the summary and the certificate card and hides both links | Team | 2026-10-07 |
| T07, T08 Camera installation date | The camera header shows «Instalada el», but `Camara` has no installation date. The app reads an optional `instaladaEn` and hides the row otherwise | Team | 2026-10-07 |
