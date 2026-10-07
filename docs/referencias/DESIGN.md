# Design

<!-- impeccable:design-schema 1 -->

> Documentado a partir del código de `prototipo.html` y `pantallas.html` (tokens en `:root`). Modo: **Operate**. Producto: **Te Tengo**, app móvil del familiar/cuidador.

## Visual direction

Calma bajo estrés. Una base neutra y serena, en la que el color semántico solo aparece cuando algo pide atención. La alerta de caída ocupa toda la pantalla en rojo, con tres datos de lectura inmediata (habitación, hora y tiempo transcurrido) y una acción principal: llamar. Nada remite a una cámara de seguridad; los clips y la vista en vivo se muestran como ilustración de la habitación con el esqueleto de pose. La vista en vivo usa un fondo oscuro propio, con la etiqueta «EN VIVO · mm:ss» y el recordatorio de que el acceso queda registrado.

## Color

| Token | Valor | Uso |
|---|---|---|
| `--ground` / `--ground-2` | `#EEF0F4` / `#E4E6EC` | Fondo de la app |
| `--card` | `#FFFFFF` | Tarjetas y hojas |
| `--ink` / `--ink-2` / `--ink-3` | `#221A38` / `#4F4766` / `#655D7A` | Texto primario, secundario y terciario |
| `--line` / `--line-2` | `#D9D7E1` / `#C7C3D3` | Divisores y bordes |
| `--morado` (+ `-press`, `-soft`, `-ink`) | `#4A2A85` | Marca y acción principal fuera de las alertas |
| `--caida` (+ `-deep`, `-soft`, `-ink`) | `#BF2A1B` | Alerta de caída (severidad alta) |
| `--inestable` (+ `-deep`, `-soft`, `-ink`) | `#F1B42F` | Movimiento inestable (severidad media) |
| `--calma` (+ `-soft`, `-ink`) | `#1C7A4C` | Estado normal, cámaras en línea, recuperación |
| `--aviso` / `--aviso-soft` | `#8F5400` / `#FBEFD9` | Avisos no urgentes (permisos, conexión) |
| `--pausa` / `--pausa-soft` | `#4E5B74` / `#E6E9F0` | Cámara en pausa |

Estados de cámara (icono + texto + trazo, nunca solo color): **En línea** (verde, cámara, con la hora de la última señal), **Desconectada** (ámbar, wifi tachado, contorno punteado), **Detección no confiable** (ámbar, ojo tachado, contorno punteado, con «revisa la luz y el encuadre»), **En pausa** (gris azulado rayado, pausa, con la hora de reactivación) y **Detenida** (gris, candado, sin consentimiento). **Pendiente de conectar** (morado suave, enchufe) solo existe en la galería de trabajo futuro (`pantallas-trabajo-futuro.html`).

Regla: el rojo y el ámbar se reservan para eventos reales. Una caída y un movimiento inestable nunca comparten color, icono ni etiqueta.

## Brand

- **Nombre:** Te Tengo, lo que dices cuando sostienes a alguien que se cae. Es una promesa de sostén, no de vigilancia.
- **Logo «La T que sostiene»** (`../marca/`): el travesaño de la T se curva como dos brazos abiertos, el punto es la persona y el fuste la sostiene. En la interfaz: `LOGO` (ícono de la app, cuadrado morado con radio 28/120) en notificaciones, banners y pantalla de bloqueo; `logotipo()` (símbolo + «Te Tengo») en bienvenida, inicio de sesión, invitación y «Todo listo»; `wordmark()` en el arranque. El nombre va trazado en curvas desde Atkinson Hyperlegible Next 800.
- **Colores de marca:** `--morado` `#4A2A85`, `--coral` `#E8765A` (punto y «Tengo» sobre claro) y `--durazno` `#FFB59C` (sobre morado). El coral y el durazno son solo de marca: nunca marcan un estado ni una alerta.
- **Arranque (pantalla 00):** fondo morado a pantalla completa. Los brazos se abren desde el centro, el punto cae y los brazos lo reciben con un leve vaivén, se dibuja el fuste, aparecen «Te Tengo» y el lema «Cerca de los tuyos, aunque estés lejos.» y la pantalla se desvanece hacia la bienvenida o el inicio de sesión (unos 2,2 s; se omite tocando). Solo anima `transform`, `opacity` y `stroke-dashoffset`, así que no mueve el layout. Con `prefers-reduced-motion` se muestra el cuadro final quieto y se desvanece. Se ve al abrir el prototipo, al reiniciar la demo y al cerrar sesión, nunca antes de una alerta.

## Typography

- **Atkinson Hyperlegible Next** para toda la interfaz. Está diseñada para lectores con baja visión y alta legibilidad bajo estrés, y distingue bien caracteres ambiguos (1/l/I, 0/O).
- **Atkinson Hyperlegible Mono** para horas y datos tabulares (`10:42`).
- Jerarquía: los titulares de alerta son grandes y en negrita, los datos clave van en bloques de tres columnas y el cuerpo es de al menos 16 px.

## Shape and depth

- Radios: tarjetas `22px`, controles `16px`.
- Sombras: `--shadow-1` en tarjetas en reposo, `--shadow-2` en hojas y modales.
- Movimiento: `cubic-bezier(.16,1,.3,1)` en transiciones, que se desactivan con `prefers-reduced-motion`.

## Components

- Barra inferior de 4 pestañas: Inicio, Historial, Familia y Ajustes. Es la misma para el titular y para un familiar invitado.
- Tarjeta de estado del adulto mayor, con una franja superior del color del estado (tranquilo, alerta, desconectada, detección no confiable, pausa, detenida).
- Sección «Cámara» en el inicio: fila de la única cámara (estado y última señal) y fila «Ver en vivo · Cuando quieras. Cada acceso queda registrado».
- Cabecera de cámara (`camHead`): ícono de estado, nombre de la habitación y datos: última señal, conectada a la PC de la casa, fecha de instalación, «Instalada por: Equipo del proyecto» y detección.
- «Tu cámara ya está lista» (paso 3 de la configuración): confirma la cámara instalada; sin consentimiento muestra «La cámara está instalada, pero no envía video» con «Completar el consentimiento».
- Nombre de la habitación: campo de texto con sugerencias en chips (Sala, Sala comedor, Comedor, Dormitorio, Cocina) y vista previa «Así se verá en las próximas alertas». Vacío: error «Escribe el nombre de la habitación.». Solo el titular lo cambia.
- Vista en vivo: disponible, no disponible por desconexión (ámbar) o por pausa («hasta las HH:MM», con «Reanudar la cámara ahora»); desde el inicio se cierra con «Cerrar la vista en vivo», desde una alerta vuelve a la alerta.
- Registro de accesos: filas por día (avatar, nombre, «Empezó a las HH:MM · duró N min N s», etiqueta «Desde una alerta»), del más reciente al más antiguo; vacío con ilustración de ojo y «Aún no hay accesos registrados». Al cerrar la vista en vivo, aviso «Acceso registrado». Se abre desde el detalle de la cámara y desde Ajustes > Privacidad.
- Consentimiento: bloque destacado en morado suave «Vista en vivo en cualquier momento» dentro del resumen; la casilla de aceptación lo menciona.
- Orden de aviso: filas numeradas (`.order-n`) 1 principal y 2 secundario con enlace «Cambiar», y opciones de espera de 3, 5 (predeterminado) o 10 minutos.
- Solo lectura para el familiar invitado: aviso neutro con candado («Solo Carmen (titular) puede…»), etiqueta `.ro-tag` «Solo ver» en Ajustes, campos deshabilitados con borde punteado y acciones de administración ocultas.
- Comparación semanal (`.trend`): flecha y texto por tipo («Aumentó: 1 más que la semana anterior», «Igual…», «Disminuyó…»). Los aumentos de caídas o inestables van en ámbar; las bajas, en verde; lo demás, neutro.
- Constancia de consentimiento: tarjeta con banda verde, quién lo otorgó, quién lo registró, fecha y hora, y la mención a la Ley N.° 29733.
- Alerta a pantalla completa: etiqueta de severidad, titular, chip de permanencia (`.alert-conf`: «Comprobando si sigue en el suelo», «Sigue en el suelo · confirmada» en blanco sobre rojo o «Se levantó a las HH:MM»), tres datos, llamada, vista en vivo y "Qué hacer ahora" en pasos numerados. El registro indica cuántos segundos después de la caída se envió el aviso (menos de 10 s) y cuándo se confirmó.
- Hoja inferior para marcar la alerta (Atendida o Falsa alarma).
- Avisos no bloqueantes (toasts) y banners de estado: sin permisos, sin internet, cámara desconectada.

## Galería y trabajo futuro

La galería (`pantallas.html`) agrupa las 103 pantallas de la prueba piloto por flujo, de la 00 (arranque) a la 102. La vinculación de varias cámaras vive aparte, en **`pantallas-trabajo-futuro.html`** («Trabajo futuro · Vinculación de varias cámaras», no incluida en la prueba piloto), con 10 pantallas numeradas desde 01: formulario «Agregar una habitación», caja de código `.code-box` `TTG-XXXX` con cuenta regresiva, fila de espera `.wait`, pasos para Te Tengo Captura, «Pendiente de conectar» y lista de varias cámaras. Esa galería se distingue con borde discontinuo y una nota explicativa, y ambas se enlazan entre sí desde la cabecera. Su código vive en `.impeccable/src/futuro.js`, que solo se compila en esa galería: ni `pantallas.html` ni el prototipo navegable (`prototipo.html`) lo incluyen. Sus exportaciones están en `pantallas/trabajo-futuro/` y `figma/trabajo-futuro/`.

## Accessibility

- Contraste de texto AA como mínimo, y AAA en los datos de alerta.
- Objetivos táctiles de al menos 44 px; el foco visible usa `--focus`.
- El estado nunca depende solo del color: siempre va acompañado de un icono y un texto.
