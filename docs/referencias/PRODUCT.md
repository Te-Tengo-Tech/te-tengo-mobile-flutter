# Product

<!-- impeccable:product-schema 1 -->

> Registro escrito sin ronda de entrevista: este init corrió dentro de un subagente sin herramienta de preguntas. Todo lo marcado *(inferido)* sale del brief del encargo y de los documentos de `Proyecto-Demo/01-project-charter/` y `03-product-backlog/` (ALCANCE, STAKEHOLDERS, SUPOSICIONES, Product Backlog); lo demás es literal del brief. Actualizado con el Product Backlog vigente (27 historias, 85 criterios) y las decisiones del asesor para la prueba piloto: una sola webcam instalada por el equipo del proyecto, sin vinculación; vista en vivo en cualquier momento; registro de accesos.

## Platform

web

La entrega actual es un prototipo de alta fidelidad en HTML que simula una aplicación móvil dentro de un marco de teléfono. La plataforma nativa final (Android, iOS o multiplataforma) está sin decidir. *(inferido: en Perú predomina Android, por eso la pantalla de bloqueo simulada es neutra y no copia a ningún sistema operativo.)*

## Stack

Delegado por el brief: HTML autocontenido con CSS y JS en línea, sin frameworks ni compilación, tipografías solo desde Google Fonts, íconos en SVG en línea. Debe abrirse con doble clic, sin servidor.

## Users

- **Familiar o cuidador** (usuario activo): por ejemplo, la hija que trabaja fuera de casa. Recibe la alerta en su celular mientras está en otra parte, a menudo en medio de otra actividad, y necesita entender en dos segundos qué pasó, dónde y qué hacer.
- **Adulto mayor** (usuario pasivo): vive o pasa gran parte del día sin supervisión en su vivienda. No usa la aplicación.
- **Titular**: quien crea la cuenta (Carmen). Es el único que cambia el perfil del adulto mayor, el consentimiento, el nombre de la habitación de la cámara, la familia (invitar, retirar, cancelar invitaciones) y el orden de aviso con el tiempo de espera.
- **Familiares invitados** (Luis, Milagros): entran con su propio acceso y ven las mismas alertas, clips, vista en vivo (en cualquier momento), registro de accesos, historial y resumen. Pueden marcar alertas como atendidas o falsa alarma y pausar la cámara. Lo demás lo ven en solo lectura, con el aviso «Solo Carmen (titular) puede…».
- Contenido de demostración: Rosa Huamán, 78 años; titular Carmen Huamán (hija, contacto principal); Luis Huamán (hijo, invitado, contacto secundario); Milagros Quispe (sobrina, invitación pendiente); vivienda en San Miguel, Lima.

## Product Purpose

En la prueba piloto, una **webcam USB** instalada en la vivienda por el equipo del proyecto, conectada a una PC con Windows que ejecuta el agente **Te Tengo Captura** (prototipo aparte en `../app-escritorio/`) con un archivo de configuración fijo, envía el video a la nube, donde la estimación de pose y parámetros cinemáticos (sin aprendizaje profundo entrenado) detectan caídas y movimientos inestables. Al detectar un evento, la aplicación avisa al familiar con una notificación push. El éxito es que el familiar se entere en segundos, entienda la gravedad y actúe, y que el adulto mayor no tenga que llevar ningún dispositivo ni activar nada.

## Positioning

No es una cámara de seguridad. La vista en vivo existe para comprobar cómo está el adulto mayor: cualquier familiar vinculado puede abrirla en cualquier momento (desde el inicio, el detalle de la cámara o una alerta), pero solo porque el adulto mayor lo aceptó en su consentimiento, no se graba y cada acceso queda en un **registro de accesos** visible para toda la familia (quién, cuándo empezó y cuánto duró). Los clips y la vista en vivo se muestran como una ilustración de la habitación con el esqueleto de pose, no como fotos de la persona. El producto cuida, no vigila, y lo hace con transparencia.

## Operating Context

- La alerta llega con la app cerrada, en la pantalla de bloqueo, en cualquier momento del día.
- Flujo de primer uso: crear cuenta, registrar al adulto mayor, firmar el consentimiento informado (que incluye la vista en vivo en cualquier momento), ver la cámara ya instalada («Tu cámara ya está lista») y, si se quiere, cambiar el nombre de su habitación, e invitar familiares.
- **Sin vinculación en el piloto.** El equipo del proyecto instala una sola webcam USB y la configura en la PC de la casa. La cámara aparece en la app con el nombre de habitación definido en la instalación (en la demo, «Sala»); el titular puede cambiarlo (no se admite vacío) y el nuevo nombre se usa en las alertas siguientes. No hay códigos, ni elección de webcam, ni estado «Pendiente de conectar».
- Sin consentimiento registrado, la cámara está instalada pero no envía video; la app lo muestra y pide completar el consentimiento. El consentimiento solo se registra si el adulto mayor lo acepta.
- Estados de la cámara: en línea (con la hora de la última señal), desconectada (con qué revisar: el cable de la cámara, que la PC esté encendida y la conexión a internet), reconectada (aviso de monitoreo restablecido), en pausa (hasta una hora, con reactivación automática), detenida sin consentimiento y **detección no confiable** (si durante más de 5 minutos solo llegan fotogramas descartados, se avisa y se indica revisar la luz y el encuadre).
- Vista en vivo: disponible en cualquier momento para todo familiar vinculado; si la cámara está desconectada se informa que no está disponible; si está en pausa, se indica hasta qué hora. Al cerrarla se registra el acceso.
- **Trabajo futuro (no incluido en el piloto):** la vinculación de varias cámaras (registrar cada habitación, código de un solo uso `TTG-XXXX` que vence a los 10 minutos, elección de webcam en la PC, «Pendiente de conectar») se conserva en una galería aparte, `pantallas-trabajo-futuro.html` («Trabajo futuro · Vinculación de varias cámaras»; exportaciones en `pantallas/trabajo-futuro/` y `figma/trabajo-futuro/`), y no forma parte de `pantallas.html` ni del prototipo navegable. Nunca baño, por privacidad.
- Revisión posterior: historial filtrable, grabaciones con retención limitada, resumen semanal.

## Capabilities and Constraints

- Una cuenta gestiona un único adulto mayor.
- Sin consentimiento registrado (con fecha y hora) la cámara no envía video; revocarlo detiene la captura y la vista en vivo y elimina las grabaciones. El formulario indica que los familiares vinculados pueden ver la cámara en vivo en cualquier momento.
- Alertas: caída (severidad alta) y movimiento inestable (severidad media, puede evolucionar a caída: la alerta se actualiza a caída). La notificación llega en menos de 10 s, con habitación y hora. Si la persona sigue en el suelo 30 s, la caída queda confirmada («Sigue en el suelo · confirmada») y la alerta sigue activa. Caída e inestable se distinguen por color, ícono y etiqueta. Clip de 6 s antes y 6 s después del evento. Estados: activa, atendida, falsa alarma. Registro de quién marcó y cuándo.
- Todos los familiares vinculados reciben cada alerta; el contacto principal es el responsable. Si nadie la marca en el tiempo de espera (3, 5 o 10 minutos; 5 por defecto), se avisa al contacto secundario. Con un solo familiar, la app indica que no hay contacto secundario.
- Cuando alguien marca una alerta, los demás ven quién la atendió y a qué hora.
- Aviso de recuperación ("Rosa se levantó").
- Pausa de cámara con reactivación automática; mientras dura no hay detección ni vista en vivo.
- Registro de accesos a la vista en vivo: automático al cerrarla; lista del más reciente al más antiguo; estado vacío «Aún no hay accesos registrados».
- Seguridad de la cuenta: bloqueo de 15 minutos tras 5 intentos fallidos; enlace de recuperación válido 30 minutos.
- Sin funcionamiento offline, sin reconocimiento facial, sin diagnóstico médico, sin versión web del producto final.
- Retención de grabaciones limitada; plazo exacto sin decidir *(inferido: se usa 30 días en el prototipo)*.
- Constancia del consentimiento con fecha y hora, exigida por la Ley N.° 29733.
- Resumen semanal por tipo, comparado con la semana anterior (aumentó, disminuyó o se mantuvo).

## Brand Commitments

- Nombre de la app: **Te Tengo** (siempre dos palabras, con mayúscula inicial en ambas). **Te Tengo** es lo que dices cuando sostienes a alguien que se cae. El nombre es una promesa de sostén, no de vigilancia: la app no está para mirar, sino para llegar a tiempo y sostener. El agente de escritorio se llama **Te Tengo Captura**.
- Logo: «La T que sostiene». El travesaño de la T se curva como dos brazos abiertos que reciben un punto (la persona) y el fuste la sostiene desde abajo. Archivos, colores y reglas de uso en `../marca/`.
- Arranque: al abrir la app, el símbolo se arma sobre morado de marca (el punto cae y los brazos lo reciben) con el lema «Cerca de los tuyos, aunque estés lejos.».
- Tono: calma, confianza y claridad bajo estrés. Nada de estética de vigilancia.
- Todo el texto en español peruano.
- Nunca mostrar códigos de historias de usuario ni etiquetas de prototipo en la interfaz.

## Evidence on Hand

- Product Backlog con 27 historias y 85 criterios Gherkin: `../../03-product-backlog/PRODUCT_BACKLOG.md`.
- No hay capturas reales, logos, testimonios ni métricas de precisión validadas; no se deben inventar cifras de exactitud en la interfaz.

## Product Principles

1. La alerta se entiende en dos segundos: qué, dónde, cuándo y la acción siguiente.
2. Cuidar, no vigilar: la vista en vivo está autorizada en el consentimiento, siempre abstraída, nunca grabada y cada acceso queda registrado para toda la familia.
3. La privacidad se ve: consentimiento, pausa y eliminación son visibles y reversibles donde la ley lo pide.
4. Nunca dejar un evento sin dueño: estados, responsables y escalamiento explícitos.

## Accessibility & Inclusion

Contraste alto (WCAG AA como mínimo), objetivos táctiles de al menos 48 px, texto legible sin zoom y color nunca como único portador de significado (la severidad lleva forma y texto además del color). Los familiares pueden ser adultos de 40 a 60 años con presbicia *(inferido)*.
