# Plan de trabajo de la app

Orden según los sprints del product backlog (`docs/referencias/PRODUCT_BACKLOG.md`). Cada fila es una tarea para una sesión: implementar la historia, con sus criterios como pruebas, imitando las pantallas indicadas.

**Cómo guiarse en cada tarea:**
1. **La historia y sus criterios** están en `PRODUCT_BACKLOG.md`.
2. **Las pantallas** están en `docs/referencias/pantallas/NN-*.png`: ábrelas y replica la composición, el orden y los estados.
3. **Los textos exactos y la estructura** están en `docs/referencias/prototipo/prototipo.html`: busca el título de la pantalla.
4. **Los tokens, componentes y la accesibilidad** están en `docs/referencias/DESIGN.md`.
5. **Las reglas del producto** (titular frente a familiar invitado) están en `docs/referencias/PRODUCT.md`.
6. **La API:** si el endpoint aún no existe en `te-tengo-general-api`, usa un repositorio falso e indica en el commit qué endpoint falta.

> La relación entre pantallas e historias se armó a partir de los nombres de archivo; confírmala con la imagen.

## Sprint 3
| # | Historia | Pantallas | Notas |
|---|---|---|---|
| 1 | Arranque y bienvenida | 00, 01 | Animación del logo; con `disableAnimations`, cuadro final quieto |
| 2 | US-01 Registro de cuenta | 02–05 | CA-01.1 a CA-01.3 |
| 3 | US-02 Inicio de sesión | 06–08, 13 | Bloqueo tras 5 intentos durante 15 min (CA-02.3); guarda el token en `SesionSegura` |
| 4 | US-03 Recuperar contraseña | 09–12 | Mensaje genérico (CA-03.2); enlace de 30 min (CA-03.3) |
| 5 | US-04 Datos de la persona cuidada | 14, 15, 95 | Un adulto mayor por cuenta (CA-04.2) |
| 6 | US-05 Consentimiento | 16–18, 22, 102 | Constancia con fecha y hora (Ley N.° 29733) |
| 7 | US-06 Cámara y nombre de la habitación | 19–21, 32 | **Ya existe la base (`features/camaras`)**: completar con estas pantallas |
| 8 | US-08 Invitar familiares (alta) | 23, 24 | |
| 9 | Inicio y avisos generales | 25–27 | Tarjeta de estado del adulto mayor |
| 10 | US-07 Estado de conexión | 28–31 | Estado con icono y texto, nunca solo color |
| 11 | US-16 Alerta de caída | 44–48 | Pantalla completa en rojo, llamar, «Qué hacer ahora»; push con `firebase_messaging` |
| 12 | US-13 Confirmación por permanencia | 46 | Chip «Sigue en el suelo · confirmada» |
| 13 | US-17 Movimiento inestable | 49–52 | Ámbar; nunca comparte color ni icono con la caída |
| 14 | US-18 Clip del evento | 47, 53 | `video_player`; clip no disponible |

## Sprint 4
| # | Historia | Pantallas | Notas |
|---|---|---|---|
| 15 | US-09 Revocar el consentimiento | 97–101 | Eliminación de grabaciones |
| 16 | US-19 Marcar la alerta | 55, 56, 60, 61 | Atendida o falsa alarma; avisa a los demás familiares |
| 17 | US-25 Historial | 83–88 | Filtros, vacío y cargando |
| 18 | US-10 Orden de aviso y espera | 62–65, 72 | 3, 5 (predeterminado) o 10 min |
| 19 | US-20 Escalamiento | 58, 59 | |
| 20 | US-22 Pausar la cámara | 33–35 | Reactivación automática |
| 21 | US-15 Detección no confiable (aviso) | 36, 37 | «Revisa la luz y el encuadre» |
| 22 | US-23 Vista en vivo | 38–40, 54, 74 | Fondo oscuro, «EN VIVO · mm:ss», «el acceso queda registrado» |
| 23 | US-24 Registro de accesos | 41–43 | |
| 24 | US-08 Invitar familiares (gestión) | 66–71 | |
| 25 | Familiar invitado, solo lectura | 73, 75–82 | Candado y «Solo ver» (PRODUCT.md) |
| 26 | US-21 Aviso de recuperación | 57 | «Se levantó a las HH:MM» |
| 27 | US-26 Grabaciones | 89–91 | Descarga y retención |
| 28 | US-27 Resumen semanal | 92, 93 | Comparación con la semana anterior |
| 29 | Ajustes y notificaciones | 94, 96 | |
