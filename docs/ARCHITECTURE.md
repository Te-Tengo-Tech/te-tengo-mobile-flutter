# App architecture

## Feature-first, three layers
Each folder in `lib/features/` is a backlog feature, with three layers inside:
- **`domain/`:** immutable models that parse the backend JSON (`Camara.desdeJson`).
- **`data/`:** a repository interface, its Dio implementation following `docs/API_CONTRACT.md`, and the Riverpod providers (`camarasRepositorioProvider`, `camarasProvider`).
- **`presentation/`:** screens (`ConsumerWidget` / `ConsumerStatefulWidget`) and reusable widgets.

Screens only know the repository interface, so tests replace it with a fake through `overrideWithValue`.

```
lib/
├── app/          app.dart, router.dart, tema/ (colores.dart = DESIGN.md tokens, tema.dart)
├── core/         configuracion.dart (TT_API_URL), red/ (Dio client, ProblemaApi), sesion/ (secure token)
└── features/     one folder per feature: data/, domain/, presentation/
    └── camaras/  REFERENCE FEATURE
```

## Planned features
They are built in backlog-sprint order; see [WORK_PLAN.md](WORK_PLAN.md).

| Feature | Stories | Status |
|---|---|---|
| `camaras` | US-06, US-07 | **Reference:** list with status, rename with validation |
| `sesion` | US-01 to US-03 | To do |
| `hogar` | US-04, US-05, US-09 | To do |
| `familia` | US-08, US-10 | To do |
| `alertas` | US-13, US-16 to US-21 | To do |
| `monitoreo` | US-15, US-22 to US-24 | To do |
| `historial` | US-25 to US-27 | To do |

## Communication
- **REST:** `te-tengo-general-api` through `clienteApiProvider`, which sets the base URL, `Api-Version: 1` and `Authorization: Bearer`.
- **Push:** Amazon SNS delivers through FCM (Android) and APNs (iOS); `firebase_messaging` obtains the device token, which is registered with `POST /api/dispositivos`.
- **Live view:** on demand, using the transport in the API contract.
