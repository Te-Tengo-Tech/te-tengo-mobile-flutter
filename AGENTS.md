# AGENTS.md

## Propósito
App móvil **Te Tengo** del familiar/cuidador. Es el contenedor «Aplicación del familiar/cuidador» del modelo C4. Permite:
- recibir alertas de caída y de movimiento inestable;
- ver el clip y la vista en vivo;
- gestionar la cámara, el consentimiento, la familia y el historial.

Habla con el backend `te-tengo-general-api` por HTTPS/REST, con la cabecera `Api-Version: 1`.

Lee antes de cambiar algo:
- [docs/referencias/DESIGN.md](docs/referencias/DESIGN.md): tokens, tipografía, componentes, accesibilidad y textos exactos. **La interfaz debe seguirlo.**
- [docs/referencias/PRODUCT.md](docs/referencias/PRODUCT.md): usuarios, flujos y reglas (titular frente a familiar invitado, solo lectura).
- [docs/referencias/PRODUCT_BACKLOG.md](docs/referencias/PRODUCT_BACKLOG.md): historias y criterios. Cada criterio Dado/Cuando/Entonces se convierte en una prueba.
- [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md): estructura por funcionalidad y patrones.

## Dónde guiarte
- **Qué hacer y en qué orden:** [docs/PLAN_DE_TRABAJO.md](docs/PLAN_DE_TRABAJO.md), que relaciona historias, pantallas y sprints.
- **Cómo debe verse:** las **103 pantallas del prototipo** en `docs/referencias/pantallas/NN-nombre.png`. Ábrelas: son la referencia visual. Los textos exactos y la estructura están en `docs/referencias/prototipo/prototipo.html` (busca el título de la pantalla).
- **Cómo debe comportarse:** los criterios de aceptación en `docs/referencias/PRODUCT_BACKLOG.md`.

## Stack
- **Flutter 3.44.8 y Dart 3.12.** Plataformas: Android e iOS.
- **Riverpod 3** (estado e inyección), **go_router** (navegación), **Dio** (HTTP) y **flutter_secure_storage** (token).
- **Pendientes,** con sus historias:
  - `firebase_messaging` para las notificaciones push (requiere un proyecto Firebase);
  - `drift` para la base de datos local (SQLite);
  - `flutter_webrtc` o WebSocket para la vista en vivo;
  - `video_player` para los clips.

## Estructura
```
lib/
├── app/          app.dart, router.dart y tema/ (colores.dart: tokens de DESIGN.md; tema.dart)
├── core/         configuracion.dart (TT_API_URL), red/ (cliente Dio, ProblemaApi) y sesion/ (token seguro)
└── features/     una carpeta por funcionalidad, con data/ (repositorio), domain/ (modelo) y presentation/ (pantallas y widgets)
    └── camaras/  FUNCIONALIDAD DE REFERENCIA: copiar su estructura
```

## Reglas
- **Diseño:** los colores salen de `Colores` y nunca se escriben a mano. El rojo (`caida`) y el ámbar (`inestable`, `aviso`) se reservan para eventos reales, y **el estado nunca se muestra solo con color**: siempre con icono y texto (`EstadoCamara` es el ejemplo).
- **Accesibilidad:** el cuerpo del texto mide al menos 16, los objetivos táctiles al menos 44 px, el contraste es AA (AAA en los datos de alerta) y se respeta `prefers-reduced-motion` (`MediaQuery.disableAnimations`).
- **Tipografía:** Atkinson Hyperlegible Next en toda la interfaz; Atkinson Hyperlegible Mono (`fuenteMono`) para horas y datos.
- **Textos de la interfaz** en español peruano, copiados de DESIGN.md y PRODUCT.md cuando existan. Nunca se muestran IDs de historias ni etiquetas de prototipo.
- **Multi-tenancy:** el token de la sesión trae el claim `hogar_id` y el backend filtra todo por ese hogar. **La app nunca envía el hogar por su cuenta.** Si un usuario pertenece a varios hogares, cambiar de hogar significa pedir un token para ese hogar.
- **Errores del backend:** llegan como `ProblemaApi`, con un `codigo` estable (RFC 9457). Se muestra `detalle` y se decide por `codigo`, no por el texto.
- **Pruebas:** cada pantalla nueva necesita pruebas de widgets con un repositorio falso (`overrideWithValue`), una por criterio de aceptación. Nada de llamadas reales en las pruebas.

## Comandos
| Comando | Qué hace |
|---|---|
| `flutter pub get` | Dependencias |
| `flutter analyze` | Lint (debe quedar sin avisos) |
| `flutter test` | Pruebas unitarias y de widgets |
| `dart format lib test` | Formatear |
| `flutter run --dart-define=TT_API_URL=http://10.0.2.2:8080` | Ejecutar contra el backend local (emulador Android) |

## Acuerdos para agentes
- **Antes de una pantalla nueva,** abre la funcionalidad `camaras` y copia su estructura, sus providers y la forma de sus pruebas.
- **Cita la historia y el criterio** en el comentario de la pantalla (por ejemplo, `US-06 / CA-06.3`).
- **Commits en Conventional Commits y en español,** sin línea de coautor.
