# Paper artifacts

This branch is the caregiver app behind the paper (Flutter: Android, iOS and its web build). The capture agent and the classifier, and the backend with its integration tests, are in the two companion repositories.

| Paper | Where |
|---|---|
| Alert screen with the call and the 12-s clip (Fig. 4; Section 3.5) | `lib/features/alertas/presentation/pantalla_alerta.dart`, `pantalla_detalle_alerta.dart`, `reproduccion_clip.dart`; tests in `test/features/alertas/` |
| Push notifications and device registration (Section 3.5; Table 2, reliability) | `lib/app/push.dart`, `lib/core/notificaciones/`; tests in `test/app/push_test.dart` |
| Consent before the camera opens; revocation (Table 2, security) | `lib/features/hogar/presentation/pantallas_consentimiento.dart`; tests in `test/features/hogar/consentimiento_test.dart`, `revocacion_test.dart` |
| Live view only while watched, skeleton-only mode, access log (Table 2, security) | `lib/features/vivo/` (`cliente_whep.dart`, `modos_vista.dart`, `registro_accesos.dart`); tests in `test/features/vivo/` |

Run the tests with `flutter test`.
