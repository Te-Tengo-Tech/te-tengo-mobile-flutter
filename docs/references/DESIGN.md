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
- Síntesis móvil: cada pantalla muestra primero lo que decide la acción, en una o dos frases cortas; el detalle secundario queda plegado y nada se borra. Dos patrones nativos (`<details>`), sin tarjetas anidadas, con zona táctil de 48 px y chevrón que gira: `more()` es un «ver más» dentro de una tarjeta (p. ej. «Datos de la instalación»), y `fold()` es una fila plegable dentro de una lista (ícono, título y resumen de una línea; al abrir, el texto completo reemplaza al resumen). El prototipo conserva qué está abierto al volver a pintar la pantalla.
- Acceso (bienvenida, crear cuenta, iniciar sesión, recuperar contraseña): título, formulario y una sola ayuda de una línea por campo; sin párrafo de introducción. Los avisos aparecen solo con un error y dicen qué hacer en el título.
- Inicio, solo lo que responde «¿cómo está Rosa?»: saludo, tarjeta de estado (nombre, edad, estado y una frase), sección «Cámara» y «Esta semana». Sin fecha, dirección ni último evento (están en el historial).
- Clip: botón de pantalla completa sobre la imagen (esquina superior derecha) y, en la barra, reproducir, avance, tiempo y velocidad (0,5×, 1×, 1,5× y 2×, en ciclo). En pantalla completa el teléfono pasa a horizontal: el clip se ve con franjas negras, el título arriba y los controles abajo; se sale con la X, con «Salir de pantalla completa» o con Escape.
- Sección «Cámara» en el inicio: fila de la única cámara (estado y última señal) y fila «Ver en vivo · Cada acceso queda registrado». «Esta semana» es una sola tarjeta con tres cifras grandes en Mono (caídas, inestables, falsas) y el último evento.
- Cabecera de cámara (`camHead`): ícono de estado, nombre de la habitación, última señal y detección; «Datos de la instalación» (conectada a la PC de la casa, fecha y «Equipo de Te Tengo») queda plegado.
- «Tu cámara ya está lista» (paso 3 de la configuración): confirma la cámara instalada; sin consentimiento muestra «La cámara está instalada, pero no envía video» con «Completar el consentimiento».
- Nombre de la habitación: campo de texto con sugerencias en chips (Sala, Sala comedor, Comedor, Dormitorio, Cocina) y vista previa «Así se verá en las próximas alertas». Vacío: error «Escribe el nombre de la habitación.». Solo el titular lo cambia.
- Vista en vivo: disponible, no disponible por desconexión (ámbar) o por pausa («hasta las HH:MM», con «Reanudar la cámara ahora»); desde el inicio se cierra con «Cerrar la vista en vivo», desde una alerta vuelve a la alerta.
- Registro de accesos: filas por día (avatar, nombre, «Empezó a las HH:MM · duró N min N s», etiqueta «Desde una alerta»), del más reciente al más antiguo; vacío con ilustración de ojo y «Aún no hay accesos registrados». Al cerrar la vista en vivo, aviso «Acceso registrado». Se abre desde el detalle de la cámara y desde Ajustes > Privacidad.
- Documentos legales (`docPage`): «Términos de uso», «Política de privacidad» y «Consentimiento informado» completo, con secciones cortas (título de 18 px y párrafos de 16 px). Solo contienen hechos que la app ya muestra. Se abren desde «Crear cuenta», desde «Leer el documento completo» y la constancia, y desde Ajustes › Privacidad. El texto del consentimiento es uno solo (`CONSENT_SEC`) para el resumen y el documento.
- Consentimiento: resumen en filas plegables (vista en vivo, qué hacemos, qué no hacemos, qué guardamos, sus derechos). «Vista en vivo en cualquier momento» va primero, abierta y con ícono morado lleno; la casilla de aceptación lo menciona.
- Orden de aviso: filas numeradas (`.order-n`) 1 principal y 2 secundario con enlace «Cambiar», y opciones de espera de 3, 5 (predeterminado) o 10 minutos.
- Solo lectura para el familiar invitado: aviso neutro con candado («Solo Carmen (titular) puede…»), etiqueta `.ro-tag` «Solo ver» en Ajustes, campos deshabilitados con borde punteado y acciones de administración ocultas.
- Comparación semanal (`.trend`): flecha y texto corto con las dos cifras por tipo («Subió de 1 a 2», «Igual (2)», «Bajó de 2 a 1»). Los aumentos de caídas o inestables van en ámbar; las bajas, en verde; lo demás, neutro.
- Constancia de consentimiento: tarjeta con banda verde, quién lo otorgó, quién lo registró, fecha y hora, y la mención a la Ley N.° 29733.
- Alerta a pantalla completa, en una sola pantalla sin desplazarse: etiqueta de severidad, titular, chip de permanencia (`.alert-conf`: «Comprobando si sigue en el suelo», «Sigue en el suelo · confirmada» o «Se levantó a las HH:MM»), tres ranuras (habitación, hora, hace) y dos acciones: «Llamar a Rosa» y «Ver en vivo». Debajo, la tarjeta «¿Rosa no contesta?» con «Llamar al SAMU · 106» (solo caídas), los avisos de escalamiento que piden actuar y dos plegables: «Clip del evento» (abierto en movimiento inestable) y «Más detalles» (dirección, teléfono, Bomberos 116, explicación de la confirmación, a quién avisamos si nadie atiende y el registro). «Marcar alerta» queda fijo abajo; no se repite como paso.
- Hoja inferior para marcar la alerta (Atendida o Falsa alarma); la nota escrita se conserva al cambiar de opción.
- Fila del historial: hora, marca, «Caída» o «Inestable», «por Carmen» (o «Sin marcar») y el sello; la habitación solo aparece si hay más de una cámara.
- Siempre hay un contacto principal: la hoja de un familiar no ofrece «Hacer contacto secundario» ni «Retirar acceso» a quien es principal.
- Avisos no bloqueantes (toasts) y banners de estado: sin permisos, sin internet, cámara desconectada.

## Galería y trabajo futuro

La galería (`pantallas.html`) agrupa las 103 pantallas de la prueba piloto por flujo, de la 00 (arranque) a la 102. La vinculación de varias cámaras vive aparte, en **`pantallas-trabajo-futuro.html`** («Trabajo futuro · Vinculación de varias cámaras», no incluida en la prueba piloto), con 10 pantallas numeradas desde 01: formulario «Agregar una habitación», caja de código `.code-box` `TTG-XXXX` con cuenta regresiva, fila de espera `.wait`, pasos para Te Tengo Captura, «Pendiente de conectar» y lista de varias cámaras. Esa galería se distingue con borde discontinuo y una nota explicativa, y ambas se enlazan entre sí desde la cabecera. Su código vive en `.impeccable/src/futuro.js`, que solo se compila en esa galería: ni `pantallas.html` ni el prototipo navegable (`prototipo.html`) lo incluyen. Sus exportaciones están en `pantallas/trabajo-futuro/` y `figma/trabajo-futuro/`.

- Configuración en 5 pasos; el 5.º, «Avisos», explica por qué antes de que el celular pida permiso: «Notificaciones» y «Sonar en silencio» (alertas críticas), cada una con «Permitir» o «Activadas», y luego el diálogo del sistema. El número de paso va encima de la barra de progreso, no en la barra superior.
- Modo oscuro (`.screen.dark`): la app sigue el tema del celular. Fondos #14111B y tarjetas #221D2D, tinta clara, morado de enlaces #CDBBF5; los avisos y los botones de tinta se invierten. Las alertas conservan su color de severidad: el rojo y la mostaza inundan igual, y la hoja de abajo pasa a oscuro.
- Letra grande (`.screen.big`): con la letra del celular agrandada, la pantalla se reacomoda sin cortes. Los textos largos se parten, las pestañas se encogen y las ranuras de la alerta admiten saltos de línea.

## Accessibility

- Contraste de texto AA como mínimo, y AAA en los datos de alerta.
- Objetivos táctiles de al menos 44 px; los enlaces de texto y los interruptores amplían su zona táctil con un pseudoelemento, sin mover el diseño. El foco visible usa `--focus`, también en las opciones de radio ocultas.
- Al volver a pintar una pantalla, el foco regresa al control que se tocó; las hojas y diálogos atrapan el Tab y se cierran con Escape. Los avisos breves no capturan toques (no tapan el botón de volver).
- Interruptores con nombre accesible; los que siempre están activos (caídas, estado de la cámara) van con `aria-disabled`.
- El estado nunca depende solo del color: siempre va acompañado de un icono y un texto.
