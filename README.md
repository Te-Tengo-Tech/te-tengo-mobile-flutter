# te-tengo-mobile-flutter

App móvil **Te Tengo** del familiar/cuidador: alertas de caída y de movimiento inestable, clip del evento, vista en vivo, cámara, consentimiento, familia e historial.

| Stack | Versión |
|---|---|
| Flutter | 3.44.8 (Dart 3.12) |
| Estado y navegación | Riverpod 3 · go_router 18 |
| HTTP | Dio 5 |

## Puesta en marcha
```bash
flutter pub get
flutter run --dart-define=TT_API_URL=http://10.0.2.2:8080   # backend local desde el emulador Android
```

## Calidad
```bash
flutter analyze
flutter test
dart format lib test
```

## Documentación
| Documento | Contenido |
|---|---|
| [AGENTS.md](AGENTS.md) | Reglas del repositorio, para personas y agentes de IA |
| [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) | Estructura por funcionalidad y plan |
| [docs/referencias/](docs/referencias/) | DESIGN.md, PRODUCT.md y el product backlog (copias) |

## Trabajar con Claude Code en la nube
`CLAUDE.md` importa `AGENTS.md`, y el hook `SessionStart` instala Flutter 3.44.8, porque la imagen no lo trae.

---

Proyecto de tesis, Ingeniería de Software, UPC. Autores: Jhosepmyr Gutierrez Soto y Elmer Riva Rodriguez.

Tipografía Atkinson Hyperlegible: SIL Open Font License (`assets/fonts/OFL.txt`).
