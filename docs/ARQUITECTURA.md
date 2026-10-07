# Arquitectura de la app

## Por funcionalidad, con tres capas
Cada carpeta de `lib/features/` es una funcionalidad del backlog. Adentro tiene:
- **`domain/`:** modelos inmutables, que leen el JSON del backend (`Camara.desdeJson`).
- **`data/`:** una interfaz de repositorio y su implementación con Dio, más los *providers* de Riverpod (`camarasRepositorioProvider`, `camarasProvider`).
- **`presentation/`:** pantallas (`ConsumerWidget` o `ConsumerStatefulWidget`) y widgets reutilizables.

Las pantallas solo conocen la interfaz del repositorio. Por eso las pruebas la reemplazan con `overrideWithValue` por un repositorio falso.

## Funcionalidades previstas

Se implementan en el orden de los sprints del backlog.

| Funcionalidad | Historias | Estado |
|---|---|---|
| `camaras` | US-06 y US-07 | **Referencia:** listar con estado y renombrar con validación |
| `sesion` | US-01 a US-03 (registro, inicio de sesión con bloqueo y recuperación) | Pendiente |
| `hogar` | US-04, US-05 y US-09 (perfil del adulto mayor y consentimiento) | Pendiente |
| `familia` | US-08 y US-10 (invitar familiares, orden y tiempo de aviso) | Pendiente |
| `alertas` | US-16 a US-21 (alerta a pantalla completa, clip, atendida o falsa alarma, recuperación) | Pendiente |
| `monitoreo` | US-22 a US-24 (pausa, vista en vivo y registro de accesos) | Pendiente |
| `historial` | US-25 a US-27 | Pendiente |

## Comunicación
- **REST:** con `te-tengo-general-api`, mediante `clienteApiProvider`, que agrega la URL base, `Api-Version: 1` y `Authorization: Bearer`.
- **Push:** Amazon SNS entrega por FCM (Android) y APNs (iOS); `firebase_messaging` obtiene el token del dispositivo.
- **Vista en vivo:** a demanda, con el protocolo que se decida en el backend.
