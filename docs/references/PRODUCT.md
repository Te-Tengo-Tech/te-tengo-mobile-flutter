# Product

<!-- impeccable:product-schema 1 -->

> Registro escrito sin ronda de entrevista: este init corrió dentro de un subagente sin herramienta de preguntas. Todo lo marcado *(inferido)* sale del brief del encargo y de los documentos de `Proyecto-Demo/01-project-charter/` y `03-product-backlog/` (ALCANCE, STAKEHOLDERS, SUPOSICIONES, Product Backlog); lo demás es literal del brief. Actualizado con el Product Backlog vigente (27 historias, 85 criterios) y las decisiones del asesor para la prueba piloto (vista en vivo en cualquier momento; registro de accesos), y con el diseño de las historias US-28 a US-40 (PCs, cámaras y datos de movimiento; [solicitud de cambio](../../01-project-charter/solicitud-de-cambio-pcs-camaras-y-movimientos.md) **pendiente de aprobación** del equipo y del asesor). El prototipo ya muestra el comportamiento nuevo; ver [«PCs, cámaras y datos de movimiento»](#pcs-cámaras-y-datos-de-movimiento).

## Platform

web

La entrega actual es un prototipo de alta fidelidad en HTML que simula una aplicación móvil dentro de un marco de teléfono. La plataforma nativa final (Android, iOS o multiplataforma) está sin decidir. *(inferido: en Perú predomina Android, por eso la pantalla de bloqueo simulada es neutra y no copia a ningún sistema operativo.)*

## Stack

Delegado por el brief: HTML autocontenido con CSS y JS en línea, sin frameworks ni compilación, tipografías solo desde Google Fonts, íconos en SVG en línea. Debe abrirse con doble clic, sin servidor.

## Users

- **Familiar o cuidador** (usuario activo): por ejemplo, la hija que trabaja fuera de casa. Recibe la alerta en su celular mientras está en otra parte, a menudo en medio de otra actividad, y necesita entender en dos segundos qué pasó, dónde y qué hacer.
- **Adulto mayor** (usuario pasivo): vive o pasa gran parte del día sin supervisión en su vivienda. No usa la aplicación.
- **Titular**: quien crea la cuenta (Carmen). Es el único que cambia el perfil del adulto mayor, el consentimiento, las cámaras de cada PC (cuál usar, en qué habitación está y dejar de usarla), el nombre de la habitación de la cámara, la familia (invitar, retirar, cancelar invitaciones) y el orden de aviso con el tiempo de espera.
- **Familiares invitados** (Luis, Milagros): entran con su propio acceso y ven las mismas alertas, clips, vista en vivo (en cualquier momento), registro de accesos, historial y resumen. Pueden marcar alertas como atendidas o falsa alarma y pausar la cámara. Lo demás lo ven en solo lectura, con el aviso «Solo Carmen (titular) puede…».
- Contenido de demostración: Rosa Huamán, 78 años; titular Carmen Huamán (hija, contacto principal); Luis Huamán (hijo, invitado, contacto secundario); Milagros Quispe (sobrina, invitación pendiente); vivienda en San Miguel, Lima.

## Product Purpose

Una o más **PCs con Windows** de la vivienda ejecutan el agente **Te Tengo Captura** (prototipo aparte en `../app-escritorio/`); el familiar titular vincula cada PC desde la app escaneando el código QR que muestra la PC (o escribiendo su código de 8 letras) y **elige desde el celular** qué **webcam USB** cuida cada habitación (una cámara por habitación), con una vista previa que no se graba. En la PC solo queda lo que necesita a alguien en la casa: mostrar el código, conectar las webcams, el estado y el modo avanzado; su «Elegir cámaras» es un respaldo para el instalador. Cada PC analiza el video en la propia PC: la estimación de pose y parámetros cinemáticos (sin aprendizaje profundo entrenado) detectan caídas y movimientos inestables, y a la nube solo llegan los eventos y el clip de cada evento ([decisión del 07/10/2026](../../04-arquitectura/decision-procesamiento-en-pc.md)). Al detectar un evento, la aplicación avisa al familiar con una notificación push. El éxito es que el familiar se entere en segundos, entienda la gravedad y actúe, y que el adulto mayor no tenga que llevar ningún dispositivo ni activar nada.

## Positioning

No es una cámara de seguridad. La vista en vivo existe para comprobar cómo está el adulto mayor: cualquier familiar vinculado puede abrirla en cualquier momento (desde el inicio, el detalle de la cámara o una alerta), pero solo porque el adulto mayor lo aceptó en su consentimiento, no se graba y cada acceso queda en un **registro de accesos** visible para toda la familia (quién, cuándo empezó y cuánto duró). Los clips y la vista en vivo se muestran como una ilustración de la habitación con el esqueleto de pose, no como fotos de la persona. El producto cuida, no vigila, y lo hace con transparencia.

## Operating Context

- La alerta llega con la app cerrada, en la pantalla de bloqueo, en cualquier momento del día.
- Flujo de primer uso: crear cuenta, registrar al adulto mayor, firmar el consentimiento informado (que incluye la vista en vivo en cualquier momento), **vincular la PC de la casa** (paso 3: escanear el QR o escribir el código, aprobar la PC y, en la pantalla siguiente, **elegir sus cámaras** desde el celular), invitar familiares y activar los avisos.
- **Vinculación de la PC (US-28).** La PC muestra un QR y un código de 8 letras (solo consonantes, RFC 8628) que vence a los 10 minutos y se renueva solo. Solo el titular aprueba; antes ve el nombre de la PC, su sistema, la versión de Te Tengo Captura y lo que podrá hacer, con «No reconozco esta PC». Cinco códigos incorrectos bloquean el ingreso 15 minutos. Varias PCs por vivienda (US-30), cada una con sus cámaras; una cámara por habitación (CA-29.3). El titular puede cambiar el nombre de la habitación de una cámara (no vacío ni repetido) y el nuevo nombre se usa en las alertas siguientes.
- **Elegir las cámaras desde el celular (US-29).** Después de «PC vinculada» viene «Elige las cámaras» (también desde el detalle de la PC y desde «Necesitan atención» en la página «Cámaras» cuando una PC tiene «Falta elegir las cámaras» o una webcam sin usar). Lista las webcams que detecta la PC, con su nombre y si están conectadas; cada una con «Ver vista previa», «¿En qué habitación está?» (Sala, Dormitorio, Cocina, Comedor, Pasillo, Otra… con campo) y «Usar esta cámara», o «Dejar de usar» si ya está en uso. Reglas: una cámara por habitación en toda la casa (chip deshabilitado y punteado, «Punteadas: ya tienen cámara.», y mensaje si se escribe un nombre repetido), nunca baño («Por privacidad, Te Tengo no admite cámaras en el baño.»), nombre no vacío, una cámara desconectada conserva su habitación, sin cámaras detectadas se pide a alguien en la casa conectar una por USB y «Buscar de nuevo», con la PC sin conexión la lista no está disponible y el invitado la ve en solo lectura. El detalle de la cámara suma «Dejar de usar esta cámara» (titular, con confirmación).
- **Vista previa al elegir cámaras.** Unos 15 s de lo que ve esa webcam, tratada como la vista en vivo: la cubre la cláusula de vista en vivo del consentimiento, no se graba y queda en el registro de accesos («Vista previa al elegir cámaras · Webcam USB HD»). En el prototipo es la ilustración de la habitación, sin personas, con cuenta regresiva y «Cerrar». Si no se puede ver (PC sin conexión, cámara desconectada o en pausa, sin consentimiento), dice por qué.
- Sin consentimiento registrado, la cámara está instalada pero no envía video; la app lo muestra y pide completar el consentimiento. El consentimiento solo se registra si el adulto mayor lo acepta.
- Estados de la cámara: en línea (con la hora de la última señal), desconectada (con qué revisar: el cable de la cámara, que la PC esté encendida y la conexión a internet), reconectada (aviso de monitoreo restablecido), en pausa (hasta una hora, con reactivación automática), detenida sin consentimiento y **detección no confiable** (si durante más de 5 minutos solo llegan fotogramas descartados, se avisa y se indica revisar la luz y el encuadre).
- Vista en vivo (y vista previa al elegir cámaras): disponible en cualquier momento para todo familiar vinculado; si la cámara está desconectada se informa que no está disponible; si está en pausa, se indica hasta qué hora. Al cerrarla se registra el acceso.
- **Trabajo futuro:** varias cámaras en una misma habitación con una sola alerta por evento, reconstrucción 3D a partir de varias vistas y varias personas en la imagen, en una galería aparte, `pantallas-trabajo-futuro.html` (exportaciones en `pantallas/trabajo-futuro/` y `figma/trabajo-futuro/`), fuera del prototipo navegable. El flujo anterior con el código `TTG-XXXX` generado en la app y escrito en la PC quedó superado y se retiró. Nunca baño, por privacidad.
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
- Logo: kit de marca vigente, dos figuras abrazadas (la violeta abraza, la coral es abrazada). Archivos, colores y reglas de uso en `../marca/`; tokens y componentes en `DESIGN.md`.
- Arranque: sobre crema, llega la figura violeta, entra la coral al abrazo, el símbolo late una vez y aparecen «Te Tengo» y el lema «Cerca de los tuyos, aunque estés lejos.».
- Tono: calma, confianza y claridad bajo estrés. Nada de estética de vigilancia.
- Todo el texto en español peruano.
- Nunca mostrar códigos de historias de usuario ni etiquetas de prototipo en la interfaz.

## Evidence on Hand

- Product Backlog con 27 historias aprobadas y 17 propuestas (US-28 a US-40 y US-41 a US-44, pendientes de dos solicitudes de cambio): `../../03-product-backlog/PRODUCT_BACKLOG.md`. Brief de diseño: `../BRIEF-pcs-camaras-y-movimientos.md`.
- No hay capturas reales, logos, testimonios ni métricas de precisión validadas; no se deben inventar cifras de exactitud en la interfaz.

## Product Principles

1. La alerta se entiende en dos segundos: qué, dónde, cuándo y la acción siguiente.
2. Cuidar, no vigilar: la vista en vivo está autorizada en el consentimiento, siempre abstraída, nunca grabada y cada acceso queda registrado para toda la familia.
3. La privacidad se ve: consentimiento, pausa y eliminación son visibles y reversibles donde la ley lo pide.
4. Nunca dejar un evento sin dueño: estados, responsables y escalamiento explícitos.

## Accessibility & Inclusion

Contraste alto (WCAG AA como mínimo), objetivos táctiles de al menos 48 px, texto legible sin zoom y color nunca como único portador de significado (la severidad lleva forma y texto además del color). Los familiares pueden ser adultos de 40 a 60 años con presbicia *(inferido)*.

## PCs, cámaras y datos de movimiento

Diseño de las historias US-28 a US-40 para la app móvil, según el [brief](../BRIEF-pcs-camaras-y-movimientos.md). La solicitud de cambio está **pendiente de aprobación**; el prototipo navegable y la galería ya muestran el comportamiento nuevo.

### Decisiones aplicadas

- **Cuándo se registra una repetición (decidido el 11/10/2026).** Una repetición queda en el registro de accesos (US-24, US-39) solo cuando alguien la reproduce o recorre la línea de tiempo. Abrir la cámara y ver la imagen fija del último evento no se registra: es lo mismo que ya mostró la alerta. Criterio CA-39.3 actualizado en el Product Backlog.

- **«Habitación», no «ambiente».** Decidido el 10/10/2026: toda la interfaz dice «habitación». Ya está en más de cien pantallas y en cada alerta («Posible caída en la Sala»), es la palabra de la casa y «ambiente» se lee como *environment*. El backlog puede conservar «ambiente» como término técnico.
- **Video en la PC.** El video se procesa en la PC de la casa ([registro de decisiones](../../04-arquitectura/registro-de-decisiones.md), entradas 1 y 8). Se corrigió el copy que decía que la cámara envía video a Te Tengo (consentimiento «Qué hacemos», política de privacidad, constancia, Privacidad, galería): solo salen de la casa los avisos, el clip de cada alerta y la vista en vivo mientras alguien la mira. Nunca hay video en la nube.
- **Marca.** Rige el kit de marca del código (dos figuras abrazadas, crema, violeta y coral); el brief se corrigió en ese punto.
- **Paso de la configuración.** El paso que reemplaza a «Tu cámara ya está lista» es el **3 de 5** (1 Persona cuidada, 2 Consentimiento, 3 PC de la casa, 4 Familia, 5 Avisos; crear la cuenta no es un paso numerado). Dentro del paso 3 van «Vincula la PC de la casa», «PC vinculada» y «Elige las cámaras». El brief usa la misma numeración.
- **Cámaras desde el celular.** Cambio de producto aprobado el 10/10/2026: las webcams se asignan a las habitaciones **desde el celular del titular**, no desde la PC. La PC conserva lo que necesita a alguien en la casa (código QR, conectar webcams, estado, modo avanzado) y su «Elegir cámaras» queda como respaldo del instalador (decidido el 10/10/2026, CA-29.8). Si la asignación cambia a la vez en el celular y en la PC, queda el último cambio guardado y Actividad muestra ambos con su origen (CA-29.10). La vista previa en el celular se trata como la vista en vivo (consentimiento, sin grabar, registro de accesos).
- **Datos por defecto.** La cuenta de Carmen tiene dos PCs (Sala-Rosa con Sala, Dormitorio y Pasillo; Cocina-Rosa con Cocina), el permiso de movimientos vigente y la nube en 30 días, para que todo se pueda recorrer. Una cuenta nueva empieza sin PC, sin permiso de movimientos y con la nube desactivada (CA-37.1).
- **Fechas.** El día de demostración es el **23/09/2026** (miércoles), en el prototipo y en el brief, que se alineó con él: movimientos desde el 24/08/2026 (30 días), acortar a 7 días borra lo anterior al 16/09/2026, el permiso de movimientos es del 24/08/2026 a las 10:15 (el mismo día desde el que hay movimientos), Sala-Rosa se vinculó el 03/08/2026 (la instalación del piloto) y Cocina-Rosa el 22/09/2026. En el brief, la cámara en pausa del ejemplo es la del **Pasillo** (hasta las 11:42), igual que en la lista de PCs del prototipo.
- **Cámaras por habitación, gestión por excepción.** La familia piensa en habitaciones, no en PCs, y con 5 o más cámaras la lista por PC se volvía muy larga. El inicio ya no lista las cámaras: la tarjeta «Cámaras» dice cuántas funcionan («4 de 4 funcionan») con un punto por habitación y abre la página «Cámaras»; los problemas los dice la tarjeta de Rosa («1 cámara no responde · Cocina» con «Ver qué revisar») y, si hay otro que ella no menciona, una sola fila compacta debajo. La página «Cámaras» (Ajustes › «Cámaras y PCs») muestra arriba el resumen («5 cámaras · 4 funcionan bien»), primero «Necesitan atención» con la acción de cada problema, luego «Funcionando» en una rejilla compacta de habitaciones, chips de filtro por PC solo si hay más de una, y al final «PCs de la casa», una fila por PC que abre su detalle (versión, sus cámaras, «Elegir las cámaras», «Quitar esta PC»). «Ver en vivo» con una cámara abre directo; con varias, la hoja «¿Qué habitación quieres ver?», con las no disponibles deshabilitadas y su motivo.
- **Habitaciones de muestra para probar la escala.** Las pantallas 287 a 302 usan 8 habitaciones en dos PCs (Sala-Rosa: Sala, Comedor, Dormitorio y Pasillo; Cocina-Rosa: Cocina, Patio, Estudio y Dormitorio 2). Son **datos de muestra** para probar cómo escala la interfaz, no la casa de Rosa: los datos por defecto siguen siendo 4 cámaras en 2 PCs.
- **Repetición de ejemplo.** La caída de las 10:41:52 en la Sala es del brief; el movimiento inestable de las 10:41:40, «Se levantó» a las 10:43:05 y la marca «Atendida» son de ejemplo para mostrar las tres marcas (en la galería, una alerta de hoy con esos datos). Desde una alerta del historial, el reproductor usa los datos de esa alerta (por ejemplo, la caída del 15/09 a las 07:55:12 que se levantó a las 07:58).
- **Detalle de la cámara con el reproductor primero.** Pedido del 11/10/2026: «dentro de la cámara hay mucha información; organízala bien», con «Ver qué pasó» como un video que abre en lo último que pasó y se puede retroceder, y los filtros abajo. Una sola pantalla: el reproductor fijo arriba, de borde a borde, abre en el evento más reciente con movimientos guardados (o, sin eventos, en los últimos minutos); se retrocede arrastrando la línea, con −10 s, con la lista de eventos o eligiendo el día; «● En vivo» sobre el reproductor abre la vista en vivo. Debajo, el estado, los filtros (día, 10 min · 1 hora, «Solo eventos») y los eventos del día; todo lo demás, en un solo plegable «Ajustes de la cámara». Reemplaza a «Ver qué pasó · elegir el momento» y a la pantalla «Repetición»; «Ver qué pasó» en una alerta y «Abrir de nuevo» en el registro de accesos abren este reproductor en ese momento. El acceso se registra (CA-39.3) desde que se reproduce o se recorre; al abrir solo se ve el cuadro del último evento, que la alerta ya mostró.
- **Un solo adulto mayor por cuenta.** Se quitaron «¿Cuidas a otra persona?» y «Agregar otra persona» de «Persona cuidada» y su pantalla de la galería (la 101 pasó a «Persona cuidada · cambios guardados»). Los Términos conservan «Cada cuenta cuida a una sola persona».

### Criterios vigentes que cambian si se aprueba

El prototipo muestra el comportamiento nuevo de estos criterios (hoy no se modifican en el backlog):

| Criterio | Hoy | En el prototipo |
|---|---|---|
| CA-06.1 | El equipo del proyecto instala y configura la cámara | El titular vincula la PC (QR o código) y elige las cámaras desde el celular |
| US-06 | Nombre de la habitación de la única cámara | Se conserva el cambio de nombre desde el detalle de cada cámara, con la regla de una cámara por habitación (CA-29.3) |
| CA-08.4 | El invitado ve en solo lectura perfil, consentimiento, cámaras, familia y orden | Se agregan «Cámaras y PCs», «Elige las cámaras», «Guardar movimientos» y «Movimientos en la nube» en solo lectura; puede ver repeticiones, Actividad y enviar «¿Hubo una caída y no avisó?» |
| CA-09.1 | Revocar programa la eliminación de las grabaciones | Sin cambio en la revocación del monitoreo; el permiso de movimientos se retira aparte (CA-35.4) y borra los de la nube |
| CA-11.4 | Sin guardar video salvo el clip | La app móvil no guarda video; el video continuo (US-38) solo existe en la PC |
| CA-24.1 | Se registra cada acceso a la vista en vivo | También se registra cada vista previa al elegir cámaras («Vista previa al elegir cámaras · …») |
| CA-30.2 | «PCs y cámaras» muestra cada PC con su estado y versión y, debajo, sus cámaras | La página se llama «Cámaras» (en Ajustes, «Cámaras y PCs») y se ordena por habitación: primero lo que necesita atención y luego la rejilla de las que funcionan, con filtro por PC. Cada PC queda en «PCs de la casa» con su estado; su versión y sus cámaras están en el detalle de la PC, a un toque. El invitado la ve sin opciones para cambiarla |
| CA-29.1 a CA-29.6 (propuestos) | Cámaras y vista previa en la aplicación de escritorio | Se eligen desde el celular, con la vista previa tratada como vista en vivo; en la PC, «Elegir cámaras» queda como respaldo del instalador (el texto de los criterios se actualiza en el backlog) |

### Productos de diseño nuevos

- Componentes en `core.js`/`app.css`, documentados en `DESIGN.md`: «Elige las cámaras» (`S.elegirCams`, `webCard`, `websOf`, `pickRow`), vista previa (`O.vistaPrevia`, `previewWhy`), «Dejar de usar» (`O.dejarCam`), página «Cámaras» por habitación (`camsPage`, `camSummary`, `attRows`, `roomCard`, `pcRow`), tarjeta «Cámaras» del inicio (`camTileLine`, `roomDots`), hoja «¿Qué habitación quieres ver?» (`O.elegirCam`, `liveWhy`), cabecera de PC (`pcHead`), estado «Sin conexión» por PC (`cam-pcoff`), código de 8 casillas (`codeInput`) y QR dibujado (`qrArt`), selector de plazo (`retentionPicker`), detalle de la cámara con el reproductor primero (`S.camara`, `camLatest`, `camPlayer`, `camStage`, `camFilters`, `camEvList`, `camSettings`, `O.elegirDia`), repetición (`makeReplay`, `rpCanvas`, `rpTimeline`) e interruptor «Puntos del cuerpo» en `clipBlock`, filas de actividad (`actRow`) y detalle de un familiar (`S.familiar`).
- En móvil no hace falta barra de uso de almacenamiento: el almacenamiento se configura en la PC (US-38).

## Trazabilidad de las pantallas nuevas

Números de `pantallas.html`. Las pantallas 22, 25 y 29 se rediseñaron en su sitio para la vinculación (la 25 y la 142 ya llevan a «Elige las cámaras»); la 76 y la 77 pasaron de la hoja de opciones al detalle de un familiar. El inicio (30, 161 a 166) y la página «Cámaras» (144 a 152, antes «PCs y cámaras») se rediseñaron en su sitio, por habitación, sin cambiar la numeración. El detalle de la cámara (35 a 38, 42, 46, 83, 168, 169, 198 a 212, 240, 247 y 275) pasó en su sitio al reproductor primero, y sus estados nuevos van al final, de la 303 a la 312, para no mover la numeración. Con Ver todas, la vista en vivo (43, 60 y otras) suma «Video» y «Esqueleto», la página «Cámaras» suma «Ver todas», «Ordenar» y la estrella, y la hoja de habitaciones suma «Ver todas a la vez», en su sitio; lo nuevo va de la 313 a la 352.

| Pantallas | Historia | Criterios |
|---|---|---|
| 22 Vincula la PC de la casa · 120 a 124 (antes de empezar, sin internet, permiso de cámara, bloqueada) | US-28 | CA-28.1, CA-28.2 |
| 125 a 127 Escanear, código leído, QR que no es de Te Tengo | US-28 | CA-28.1 |
| 128 a 133 Escribir el código, solo consonantes, incorrecto, vencido, demasiados intentos, sin internet | US-28 | CA-28.2, CA-28.3, CA-28.6 |
| 134 a 139 Buscando la PC, aprobar, vinculando, error de red, código vencido al aprobar | US-28 | CA-28.3, CA-28.4 |
| 140 Familiar invitado no puede aprobar | US-28 | CA-28.5 |
| 141 No reconozco esta PC | US-28 | CA-28.4 |
| 25, 142, 143 PC vinculada (sin consentimiento, falta elegir las cámaras, cámaras elegidas) · 29 Todo listo | US-28, US-29 | CA-28.1, CA-29.2 |
| 144 a 152 Cámaras por habitación (pausa y PC sin conexión, PC sin conexión, cargando, sin PCs, una PC, PC sin cámaras, sin consentimiento, invitado) | US-29, US-30 | CA-29.2, CA-29.5, CA-29.10, CA-30.1, CA-30.2, CA-30.3 |
| 153 a 156 Detalle de la PC (quitar, sin conexión, invitado) | US-30, US-31 | CA-30.2, CA-31.5 |
| 157 a 159 Quitar la PC, PC quitada, quitada sin conexión | US-31 | CA-31.1, CA-31.2, CA-31.4 |
| 160 Aviso: PC desvinculada desde la PC | US-31 | CA-31.3 |
| 161 a 166 Inicio con la tarjeta «Cámaras» (4 cámaras en 2 PCs, PC sin conexión, otra cámara necesita atención, sin PCs), elegir la habitación para la vista en vivo | US-30, US-23 | CA-30.2, CA-30.3, CA-23.1, CA-23.3, CA-23.4 |
| 167 Ajustes con Cámaras y PCs y Actividad | US-30, US-33 | CA-30.2, CA-33.2 |
| 35 a 38, 42, 46 Detalle de la cámara: al abrir, lo último que pasó; desconectada, nombre actualizado, pausar, detección no confiable, acceso registrado | US-39, US-23, US-24, US-07, US-06 | CA-39.1, CA-23.1, CA-23.3, CA-24.1 |
| 83 Cámara · familiar invitado (ajustes en solo lectura) | US-08, US-39 | CA-08.4 |
| 168, 169 Cámara: ajustes de la cámara, PC sin conexión (lo último disponible y tramo sin datos con el motivo) | US-29, US-39, US-40 | CA-29.5, CA-39.5, CA-40.4 |
| 23, 24, 170 Nombre de la habitación (cambio, vacío, ya tiene cámara) | US-06, US-29 | CA-06.2, CA-06.3, CA-29.3 |
| 171 a 184 Guardar movimientos (resumen, permiso, representante, error, sin consentimiento, invitado, constancia, documento, dejar de guardar, borrando, listo, Privacidad) | US-35 | CA-35.1 a CA-35.4 |
| 185 a 192 Movimientos en la nube (sin elegir, 30 días, acortar, guardado, sin permiso, invitado, sin internet, pendientes de subir) | US-37 | CA-37.1, CA-37.3, CA-37.4 |
| 193 a 197 Clip con y sin puntos del cuerpo, no disponibles, pantalla completa | US-36 | CA-36.1, CA-36.2 |
| 198 a 203 Ver qué pasó desde una alerta, elegir el día, días fuera del plazo, fuera del plazo, sin permiso, nube desactivada | US-39 | CA-39.1, CA-39.4 |
| 204 a 211 Cámara: cargando, retrocediste, posible caída, en el suelo a 2×, evento elegido en la lista, 1 hora con tramo sin datos, sin internet, permiso retirado | US-39 | CA-39.1, CA-39.5, CA-35.4 |
| 212 a 214 Repetición registrada, registro de accesos con repeticiones | US-39, US-24 | CA-39.3, CA-24.2 |
| 215 a 220 Actividad (filtro por PC, detalle, cargando, vacía, invitado) | US-33 | CA-33.1, CA-33.2, CA-33.4 |
| 221 a 230 ¿Hubo una caída y no avisó? (enlace, formulario, errores, sin movimientos, enviado, sin internet, desde un inestable, invitado) | US-40 | CA-40.4 |
| 76, 77, 231 a 236 Detalle de un familiar (Luis, opciones, uno mismo, invitación pendiente, vista del invitado, llamar) | US-08, US-10, US-19, US-24 | CA-08.3, CA-08.4, CA-10.1, CA-19.3, CA-24.2 |
| 237 a 249 Pantallas nuevas en modo oscuro y letra grande | Transversal | — |
| 250, 251, 254, 255 Elige las cámaras (configuración paso 3, habitación elegida, cámara elegida, todas elegidas) | US-29 | CA-29.1, CA-29.2 |
| 252, 253, 259 Vista previa (cuenta regresiva, registrada al cerrar, webcam nueva) | US-29, US-24 | CA-29.1, CA-24.1, CA-05.4 |
| 256, 257, 269 Sin consentimiento y vista previa no disponible (sin consentimiento, cámara en pausa) | US-29, US-05 | CA-05.2, CA-29.1 |
| 258, 260 Otra webcam en la PC: habitaciones que ya tienen cámara, nombre repetido | US-29 | CA-29.3, CA-29.4 |
| 261, 262 Otra habitación: baño, nombre vacío | US-29 | CA-29.2 |
| 263 a 266 Cámaras e Inicio con una webcam sin usar y con la cámara del Comedor | US-29, US-30 | CA-29.2, CA-29.10, CA-30.2 |
| 267, 268 Cámara desconectada que conserva su habitación, webcam sin usar desconectada | US-29 | CA-29.5 |
| 270, 271 Buscando cámaras, no encontramos cámaras | US-29 | CA-29.6 |
| 272 PC sin conexión: lista no disponible | US-29, US-30 | CA-30.3 |
| 273 Familiar invitado: solo lectura | US-29, US-08 | CA-08.4 |
| 274 a 276 Dejar de usar una cámara (desde la lista y desde el detalle), cámara que se dejó de usar | US-29 | CA-29.2 |
| 277 Inicio: falta elegir las cámaras | US-29 | CA-29.2 |
| 278 Registro de accesos con una vista previa | US-24 | CA-24.1, CA-24.2 |
| 279 Actividad: cámara elegida desde el celular | US-33, US-29 | CA-33.1, CA-29.10 |
| 280 a 283 Elige las cámaras y vista previa en modo oscuro y letra grande | Transversal | — |
| 284, 285 Muchas cámaras: inicio y página «Cámaras» con una sola cámara | US-29, US-30 | CA-30.2 |
| 286 Cámaras: ver solo una PC (filtro) | US-30 | CA-30.2 |
| 287 a 289 Inicio y Cámaras con 8 habitaciones en 2 PCs (rejilla y PCs de la casa) | US-30 | CA-30.2 |
| 290, 291 Inicio y Cámaras con 8 habitaciones: cámara desconectada y otra en pausa | US-29, US-30, US-07 | CA-29.5, CA-30.2, CA-07.2 |
| 292 Cámaras con 8 habitaciones: una PC sin conexión | US-30 | CA-30.3 |
| 293, 294 Ver en vivo: elegir la habitación (PC sin conexión y pausa; 8 habitaciones) | US-23, US-24 | CA-23.1, CA-23.3, CA-23.4, CA-24.1 |
| 295 Cámaras con 8 habitaciones: familiar invitado | US-30, US-08 | CA-30.2, CA-08.4 |
| 296 a 298 Inicio, Cámaras y elegir la habitación en modo oscuro | Transversal | — |
| 299 a 302 Inicio, Cámaras y elegir la habitación con la letra al 200 % | Transversal | — |
| 240, 247 Cámara en modo oscuro y con letra grande | Transversal | — |
| 303 a 305 Cámara: último evento de otro día, solo eventos, sin eventos (los últimos minutos) | US-39 | CA-39.1 |
| 306 Cámara en pausa: lo último disponible y el tramo «Cámara en pausa» | US-07, US-39, US-23 | CA-07.2, CA-39.5, CA-23.4 |
| 307 Cámara · familiar invitado sin permiso de movimientos | US-39, US-08 | CA-39.4, CA-08.4 |
| 308 a 312 Cámara y elegir el día en modo oscuro y con la letra al 200 % | Transversal | — |
| 313, 314 Entradas a Ver todas (página «Cámaras» y hoja de habitaciones) | US-41 | CA-41.1 |
| 315 a 325, 331, 333 Ver todas en horizontal: 4, 3 y 6 cámaras (2 páginas), modos Video y Esqueleto, desconectada, en pausa, PC sin conexión, pantalla completa horizontal, mover, ordenar, favoritas primero, invitado | US-41 | CA-41.1 a CA-41.5, CA-08.4 |
| 326, 327 Acceso registrado al cerrar Ver todas; registro de accesos con «Carmen (tú) vio Sala, Cocina y Pasillo» | US-41, US-24 | CA-41.6, CA-24.2 |
| 328 a 330, 332 Ordenar y favoritas (Cámaras, hoja de habitaciones); una sola cámara, sin Ver todas | US-41 | CA-41.1, CA-41.4 |
| 334 Vista en vivo · solo esqueleto | US-23 | CA-23.1 |
| 335 a 338, 340, 341 Ver todas, Cámaras y Ordenar en modo oscuro y con la letra al 200 % | Transversal | — |
| 339 Ver todas en vertical (opcional, botón «Vertical») | US-41 | CA-41.1 |
| 342 a 346 Widget en la pantalla de inicio (tranquilo, posible caída, cámara sin respuesta, oscuro) y «Agregar el widget» | US-44 | CA-44.1, CA-44.2 |
| 347 a 352 Aumentar el contraste (Preferencias, inicio, Cámaras, alerta; claro y oscuro) | Transversal | — |

## Varias cámaras a la vez, favoritas, widget y contraste

Pedido del 11/10/2026, a partir de la app de cámaras que mostró el usuario, adaptado a las reglas de privacidad de Te Tengo. **Ver todas es la US-41** (amplía US-23, vista en vivo, y US-24, registro de accesos), con favoritas y orden en el CA-41.4; **el widget es la US-44**, y «Aumentar el contraste» es un requisito transversal de accesibilidad, sin historia. Están pendientes de la [solicitud de cambio de vista de varias cámaras, audio y actualizaciones](../../01-project-charter/solicitud-de-cambio-varias-camaras-audio-y-actualizaciones.md), junto con la US-42 (hablar con el adulto mayor por la PC) y la US-43 (actualizaciones), que aún no tienen pantallas.

### Flujos

- **Ver todas.** Página «Cámaras» › «Ver todas», o «Ver en vivo» › «Ver todas a la vez» (primera fila de la hoja). Se abre en horizontal: mosaico de 2 × 2 a pantalla completa con las cámaras en el orden de este celular y una barra delgada abajo (cerrar, «Video», «Esqueleto», «‹ 01/02 ›», privacidad, «Ordenar», «Vertical»). Con más de 4, páginas de 4 («1/2», «1/3»…): se desliza o se tocan ‹ ›. «Video» y «Esqueleto» cambian todas las celdas. Tocar una celda la abre a pantalla completa; volver regresa al mosaico. Mantener presionada y arrastrar la mueve; soltar sin mover (o el menú contextual del teclado) ofrece «Mover antes» y «Mover después». Al cerrar, aviso «Acceso registrado».
- **Favoritas y orden.** Estrella en cada tarjeta de habitación y en «Ordenar» (manija para arrastrar y subir/bajar). Solo en este celular; el familiar invitado también ordena el suyo.
- **Widget.** Pantalla de inicio del celular (panel de demostración › «Ir a la pantalla de inicio del celular»). Tocarlo abre la alerta activa, la página «Cámaras» si una no responde o el inicio; «Ver en vivo» abre la app con la hoja de habitaciones (con «Ver todas a la vez»). Ajustes › Este celular › «Agregar el widget» explica cómo ponerlo.
- **Aumentar el contraste.** Ajustes › Preferencias › «Aumentar el contraste», o el ajuste del celular (panel › «Aumentar el contraste»).

### Decisiones

- **A lo sumo 4 en vivo a la vez.** Cuida el ancho de banda de la PC de la casa y del celular, y en un teléfono no se distingue más.
- **Solo transmite la página visible.** Al cambiar de página, las cámaras de la anterior dejan de transmitir; a pantalla completa solo transmite esa cámara.
- **Por defecto, Video encendido y Esqueleto apagado** («que se pueda ver video en el mosaico normal»). Los modos son los de la API (`VIDEO`, `VIDEO_CON_POSTURA`, `SOLO_POSTURA`): el mosaico pide el mismo modo para cada cámara visible y la vista en vivo usa el mismo. Solo esqueleto no saca ningún píxel de la casa. La elección se recuerda en este celular. En el prototipo, el video es la ilustración de la habitación con una silueta.
- **Un solo acceso en el registro por cada vez que se abre Ver todas**, con las habitaciones que se vieron y la duración («Carmen vio Sala, Cocina y Pasillo · 2 min»). Cambiar de página suma las habitaciones nuevas; abrir una a pantalla completa es parte del mismo acceso. Las cámaras que no estaban disponibles no se cuentan. Se ve con el filtro «Vista en vivo».
- **Las no disponibles ocupan su lugar** con el motivo, igual que en la hoja de habitaciones; tocar una abre la vista en vivo con su aviso (por ejemplo, «Reanudar la cámara ahora»).
- **Una sola cámara: sin «Ver todas».** «Ver en vivo» abre directo, como antes.
- **Orden:** las favoritas primero, luego las demás; rige en «Cámaras», en los puntos del inicio (dentro de cada grupo, los problemas primero), en la hoja de habitaciones (las disponibles primero) y en Ver todas.
- **El widget muestra el estado, nunca imágenes de la casa**, y no abre la vista en vivo por sí solo: todo acceso pasa por la app y queda registrado.
- **Ver todas en horizontal por defecto; vertical, opcional** (pedido del 11/10/2026: «el mosaico se ve mejor en horizontal como el ejemplo»). En horizontal, cuatro cámaras se ven más grandes y la barra no les quita alto; tocar una la abre a pantalla completa, también en horizontal, con «Volver a todas». «Vertical» deja el mosaico de antes para quien lo prefiera y se recuerda en este celular. Las ranuras vacías no llevan «+»: las cámaras se agregan en Cámaras › PC. «Ordenar» en la barra permite arrastrar o usar «Mover antes» y «Mover después» sin mantener presionado. La pantalla 339 de la galería («letra al 200 %, más abajo») se reemplazó por «Ver todas · en vertical (opcional)» para no cambiar la numeración: en horizontal no hay desplazamiento.

### Copy en borrador

«Ver todas» · «Ordenar» · «Ver todas a la vez» / «Hasta 4 por página» / «No disponible ahora» · «Todas en vivo» · «Video» · «Esqueleto» · «EN VIVO» · «No se graba · queda en el registro» · «1/2» · celdas «Desconectada · Desde las 10:31», «En pausa · Hasta las 11:42», «Sin conexión · La PC no responde», «Detenida · Sin consentimiento» · «Volver a todas» · barra «Cerrar», «Ordenar», «Vertical», «Ver en horizontal», «Listo», «Arrastra o mueve Pasillo», «Elige una cámara para moverla», «01/02» · menú «Mover antes», «Mover después», «Marcar como favorita», «Quitar de favoritas», «Ver en pantalla completa» · aviso «Sala se movió» / «Mismo orden en Cámaras y Ver en vivo.» · «Las favoritas van primero» / «Cambia la estrella para pasarla al otro grupo.» · «Acceso registrado» / «Viste Sala, Cocina y Pasillo · 2 min.» · registro «Carmen (tú) vio Sala, Cocina y Pasillo» / «Varias cámaras · 10:42 · 2 min» · «Ordenar» / «Favoritas primero. Solo en este celular.» / «Favoritas» / «Las demás» / «Listo» · widget «Todo tranquilo» / «4 cámaras», «Posible caída» / «Sala · 10:41», «1 cámara no responde» / «Cocina», «Ver en vivo» · «Agregar el widget» / «Rosa y «Ver en vivo» en tu pantalla de inicio» / «Mantén presionado un espacio libre de la pantalla de inicio.» / «Toca «Widgets» y busca Te Tengo.» / «Elige el tamaño y suéltalo.» / «Muestra el estado, nunca imágenes de la casa.» · Preferencias «Contraste» / «Aumentar el contraste» / «Texto y bordes más marcados».

## Texto reducido

Pedido del 11/10/2026: menos texto en todas las pantallas, más móvil. Se recortó un tercio o más sin inventar datos ni tocar lo que la alerta necesita (quién, dónde, cuándo, «Llamar a Rosa», el SAMU · 106 y el escalamiento). Los documentos legales conservan todos sus hechos con menos palabras. Cortes principales:

- **Títulos repetidos:** fuera el «Consentimiento informado» bajo la barra «Consentimiento», «¿Cómo se llama esta habitación?» bajo «Nombre de la habitación» y las introducciones de Términos, Política, Actividad, Invitar y Movimientos en la nube.
- **Párrafos a una línea:** bienvenida («Detecta caídas y te avisa al instante.»), consentimiento («Lo acepta Rosa o su representante. Sin él, no detectamos caídas.»), avisos, vincular la PC (sin párrafo; pasos de una línea), elegir las cámaras («3 cámaras en la PC Sala-Rosa. Una por habitación.»), vista previa, aprobar la PC (permisos en tres palabras), revocar y dejar de guardar movimientos.
- **Ayudas y subtítulos:** sin la ayuda del nombre en «Crear cuenta» y «Tu perfil», sin la de la dirección y sin subtítulos en «¿Con quién vive?»; subtítulos de Ajustes, Notificaciones, Privacidad y Preferencias más cortos («Activadas», «Vigente · 3 ago 2026», «Se guardan 30 días»).
- **Vacíos y avisos:** sin la segunda frase en historial vacío, filtros sin resultados, semana sin eventos, registro de accesos vacío y sin PCs; avisos de error con el título y, a lo sumo, una frase («Bloqueado por 15 minutos» / «Vuelve a intentarlo a las 10:57.»).
- **Registro de accesos:** «Carmen (tú) · 10:42 · 1 min 12 s» en lugar de «Empezó a las … · duró …»; la introducción, «Quién miró, cuándo y cuánto. Toda la familia lo ve.».
- **Familia y familiar:** papeles en pocas palabras («Si nadie atiende en 5 min», «Sin escalamiento»), «Qué podrá hacer» en tres líneas cortas y el ejemplo del tiempo de espera en una.
- **Galería:** la cabecera de `pantallas.html` y `pantallas-trabajo-futuro.html` y la descripción de cada flujo, en una línea.

## Copy en borrador (revisar)

Todo el copy de las pantallas nuevas es borrador. El que viene del [brief](../BRIEF-pcs-camaras-y-movimientos.md) (§5) se usó tal cual, con «habitación» en lugar de «ambiente». Estos son los **textos nuevos** que no están en el brief ni en las pantallas anteriores (unos 110; los nombres y horas son los datos de ejemplo):

- **Agregar PC:** «Sin una PC vinculada no detectamos caídas.» · «Código de 8 letras» · diálogo del sistema «"Te Tengo" quiere usar la cámara» / «Para escanear el código QR de la PC.» · «Apunta al código QR que muestra la PC.» (debajo del aviso de QR ajeno) · «Esta PC ya está vinculada» / «La encuentras en Cámaras y PCs.» · «Sus cámaras ya están elegidas.» · «Escribe la hora así: 07:30.»
- **Configuración y consentimiento:** «Vincular la PC de la casa» (paso 3) · «Continuar con la PC de la casa» · «Las cámaras ya detectan caídas.» / «Detectarán caídas al vincular la PC.» · «Sin él, no detectamos caídas.» · «Falta el consentimiento» / «Sin él no detectamos caídas.» · consentimiento «Qué hacemos»: «La PC de la casa analiza la postura del cuerpo para detectar caídas y movimientos inestables. El video se procesa ahí: solo salen el clip de cada alerta y la vista en vivo mientras alguien la mira.» · política: «La PC de la casa analiza el video para detectar la postura. No reconocemos rostros ni guardamos video en la nube.» · Privacidad: «Video · Se analiza en la PC; nunca va a la nube»
- **Cámaras y PCs e Inicio:** «Sin suspender» · «Junto al reloj de Windows» · «Cámaras de esta PC» · «Deja de detectar caídas con esta PC.» · «Por ahora, cada habitación usa una sola cámara.» · «Sin conexión · la PC no responde» · «La PC Cocina-Rosa no responde» / «Desde las 09:58. Las cámaras de las otras PCs siguen detectando.» · aviso «La PC Cocina-Rosa no responde» / «No detectamos caídas en la Cocina. Revisa que esté encendida y con internet.» · «La PC Cocina-Rosa volvió a conectarse» / «Sus cámaras vuelven a detectar.» · «Las cámaras de la PC Sala-Rosa ya cuidan a Rosa» · «Sin cámaras» / «Falta elegir las cámaras de la PC de la casa.» / «Aún no hay una PC vinculada. Sin ella no detectamos caídas.» · «2 cámaras no responden» · «Las demás siguen cuidando.» · Ajustes: «Aún no hay una PC vinculada», «Cocina-Rosa sin conexión» · Nombre de la habitación: «Las que ya tienen cámara no se pueden elegir.», «Ya hay una cámara en la Sala. Por ahora, cada habitación usa una sola cámara.»
- **Cámaras por habitación:** tarjeta «Cámaras» · «4 de 4 funcionan» / «3 de 4 funcionan» / «1 de 4 funciona» · «Funciona · Sala» · «Detenidas» · página «Cámaras» y fila de Ajustes «Cámaras y PCs» («4 cámaras · 2 PCs») · resumen «5 cámaras · 4 funcionan bien», «4 cámaras · todas funcionan bien», «1 cámara · funciona bien», «1 cámara · no funciona ahora», «ninguna funciona ahora», «4 cámaras · detenidas», «Aún no hay cámaras elegidas» · chips «Todas · Sala-Rosa · Cocina-Rosa» · secciones «Necesitan atención», «Funcionando», «Detenidas», «PCs de la casa» · filas «Cocina sin conexión» / «La PC Cocina-Rosa no responde desde las 09:58» → «Qué revisar», «Patio: cámara desconectada» / «Desde las 10:31», «Pasillo en pausa» / «Hasta las 11:42 · se reactiva sola» → «Reanudar ahora», «Detección no confiable · Sala» / «Revisa la luz y el encuadre», «1 cámara sin usar» / «En la PC Sala-Rosa · elige en qué habitación está» → «Elegir las cámaras», «PC Cocina-Rosa» / «Falta elegir las cámaras» · fila de PC «3 cámaras · En línea», «1 cámara · Sin conexión» · inicio: «2 cámaras necesitan atención» · hoja «¿Qué habitación quieres ver?» con «Disponible ahora», «En pausa hasta las 11:42», «Sin conexión · la PC Cocina-Rosa no responde», «Desconectada desde las 10:31», «Detenida · sin consentimiento» · vista en vivo: «La cámara está sin conexión: la vista en vivo no está disponible.» (registro de la demo) · «La encuentras en Cámaras y PCs.» · «Agrégala desde Ajustes › Cámaras y PCs».
- **Elegir las cámaras desde el celular:** «Ahora elige sus cámaras desde aquí.» · «Elegir las cámaras» · «Hacerlo después» / «Sin cámaras elegidas no detectamos caídas.» · «Elige las cámaras» · «3 cámaras en la PC Sala-Rosa. Una por habitación.» · «Una cámara por habitación.» · estados de cada webcam «Sin usar», «En uso · Sala», «En uso · Sala · en pausa», «Desconectada», «Desconectada · Pasillo» · «Ver vista previa» / «No se graba · queda registrado» · «¿En qué habitación está?» · chip «Otra…» y «Punteadas: ya tienen cámara.» · «Nombre de la habitación» / «Ej.: Estudio» · «Usar esta cámara» · «Dejar de usar» · «Revisa el cable USB. Pasillo conserva esta cámara.» · «Pide que la conecten por USB.» · «¿Falta una? Que la conecten por USB.» · «Buscando cámaras en la PC Sala-Rosa…» · «No encontramos cámaras en la PC Sala-Rosa» / «Que conecten una webcam por USB.» · «Falta el consentimiento de Rosa» / «Sin él no hay vista previa ni detección.» · «Solo Carmen (titular) puede elegir las cámaras.» · error escrito «Ya hay una cámara en la Cocina (PC Cocina-Rosa). Por ahora, cada habitación usa una sola cámara.» · toast «La cámara Webcam USB HD cuida ahora la Sala» / «Las próximas alertas dirán «en la Sala».» o «Detectará caídas cuando registres el consentimiento.» · «1 cámara sin usar» / «Elige en qué habitación está» · «Usa otra cámara o deja de usar una» · vista previa: «Vista previa · Webcam USB HD», «VISTA PREVIA · 0:12», «No se graba · queda en el registro de accesos», «Se cierra sola a los 15 s.», «La cámara está desconectada» / «Que revisen el cable USB.», «Falta el consentimiento de Rosa» / «Sin él no hay video.», «La cámara está en pausa» / «Hasta las 11:42.», «Acceso registrado» / «Viste la vista previa de Webcam USB HD durante 15 s.» · registro de accesos: «Vista previa al elegir cámaras · Logitech C270», «Quién miró, cuándo y cuánto. Toda la familia lo ve.» · dejar de usar: «Dejar de usar esta cámara» · «¿Dejar de usar la cámara USB2.0 PC Camera?» / «No detectaremos caídas en el Pasillo. Puedes volver a elegirla.» · «Dejamos de usar la cámara USB2.0 PC Camera» / «Ya no detectamos caídas en el Pasillo.» · actividad: «Carmen eligió la cámara HD Pro Webcam para la Cocina», «… dejó de usar la cámara … del Pasillo».
- **Guardar movimientos:** resúmenes plegados «Ver qué pasó y mejorar la detección», «Solo puntos del cuerpo, sin imagen», «En la PC y, si lo eliges, en la nube», «Tú eliges el plazo», «Solo la familia, con registro» · «Nombre del representante» / «Escribe el nombre del representante.» · «Constancia exigida por la Ley N.° 29733 para datos sensibles.» · «Leer el documento aceptado» · «Es opcional: las alertas funcionan igual.» · «Solo Carmen (titular) puede retirar este permiso.» / «… registrar este permiso.» · documento: «Cómo retirarlo» · progreso: «Ya no guardamos movimientos», «Movimientos borrados de la nube», «En la PC de la casa», «Preguntará si también se borran ahí.», «Las alertas siguen igual.», «Volver a Privacidad» · «Permiso registrado» / «Ahora puedes elegir si se guardan en la nube.» · «Los borramos de la nube.» · Privacidad: sección «Movimientos», «Desactivado · falta el permiso».
- **Movimientos en la nube:** «Movimientos en la nube: 90 días» / «Se borran solos al cumplirse el plazo.» / «Borramos los movimientos de la nube.» · «¿Dejar de guardar en la nube?» / «Borraremos todos los movimientos de la nube.» · «Solo Carmen (titular) puede cambiar el plazo.»
- **Detalle de la cámara (reproductor):** «● En vivo» · ícono «?» (Solo puntos del cuerpo, nunca video…) · estados «En línea», «En pausa hasta las 11:42», «Desconectada desde las 10:31», «Sin conexión desde las 09:58», «Detección no confiable» · «Qué revisar» («El cable USB de la cámara», «La PC encendida» / «Con Te Tengo Captura abierto», «El internet de la casa»; «La luz» / «De noche, una lámpara pequeña», «El encuadre» / «Que se vea a Rosa de cuerpo entero») · chips «Hoy», «Ayer», «Elegir día…», «10 min», «1 hora», «Solo eventos» · «Eventos · Hoy» · «Sin eventos hoy» · «Últimos eventos» · tramos «Cámara en pausa», «Cámara desconectada», «La PC no responde» · «Para ver lo que pasó, activa Guardar movimientos» / «… activa Movimientos en la nube» / «Activar» / «Solo Carmen puede activarlo» · «No hay movimientos del 11/08. Hay desde el 24/08/2026.» / «Ver lo último» · «Cargando…» · «Sin internet» · «Rosa retiró el permiso. Se borraron sus movimientos.» · «No hay más eventos este día» · «Ajustes de la cámara» / «Pausa, nombre, registro» · «Pausar» / «Sin detección ni vista en vivo» · «Reanudar ahora» · «Nombre: Sala» / «Así aparece en las alertas» · «PC Sala-Rosa» / «Webcam USB HD · desde el 03/08/2026» · hoja «Elegir día» / «Hay movimientos desde el 24/08/2026.» / «Con eventos» · aviso «Acceso registrado» / «Repetición de la Sala · 2 min 10 s» · alerta: «Ver qué pasó» / «En la cámara, sin video».
- **Actividad:** «Nadie puede borrar ni cambiar este registro.» · vacío: «Aquí verás cada cambio en PCs, cámaras y datos.» · detalle: «Alguien en la PC», «Celular de Carmen», «Cerrar» · filas nuevas con el patrón del brief: «Desde la PC Cocina-Rosa: la cámara HD Pro Webcam pasó a Cocina», «Carmen vinculó la PC Cocina-Rosa», «… reanudó la cámara de la Sala», «… quitó la PC …», «… dejó de guardar los movimientos de Rosa», «Desde la PC Sala-Rosa: se desvinculó esta PC», «… cambió el nombre de la habitación de la Sala a Sala comedor».
- **¿Hubo una caída y no avisó?:** «Contarnos qué pasó» (barra superior) · «Habitación» · «Hora aproximada» · «Elige la habitación o «No sé».» · «Lo guardamos para enviarlo».
- **Detalle de un familiar:** «Familiar» / «Tu perfil en la familia» · secciones «Contacto», «En las alertas», «Actividad», «Opciones» · «Teléfono», «Correo», «Llamar» · «Invitación enviada a milagros.quispe@outlook.com» / «Vence en 7 días.» · «3 alertas marcadas» / «Última: Inestable en la Sala · jue 17 sep · 18:26» · «Aún no marcó alertas» · «2 accesos a la cámara» · «Aún no abrió la vista en vivo» · «Podrá ser contacto cuando acepte la invitación» · «Solo Carmen (titular) puede cambiar el papel de un familiar o retirar su acceso.» · «Llamando a Luis…».

## Ayudas en ícono ?

Las líneas fijas de privacidad y de ayuda pasan a un ícono «?» de 24 px (44 px de toque). Un toque abre una tarjeta pequeña con el texto. En el prototipo también la abren el cursor y el foco del teclado. Se cierra con Escape, con un toque fuera o al desplazar. Pasaron a ícono (12 lugares):

- Ver todas en horizontal, en la barra («No se graba · queda en el registro»).
- Ver todas en vertical, en la barra superior (antes, el pie).
- Pantalla completa desde Ver todas, sobre la imagen.
- Vista en vivo, en la barra superior (antes, el pie «No se graba · tu acceso queda registrado.»).
- Detalle de la cámara, junto al estado («Nunca video · con registro»).
- Hoja «¿Qué habitación quieres ver?», junto al título («Cada acceso queda registrado.»).
- Inicio, fila «Ver en vivo» (antes, el subtítulo «Cada acceso queda registrado»; «No disponible ahora» sigue a la vista).
- Clip de la alerta, junto a la duración («6 s antes y 6 s después.»).
- Elegir las cámaras: junto a «Ver vista previa» («No se graba · queda registrado») y junto a «¿En qué habitación está?» (sin cámaras en el baño).
- Hoja de vista previa, junto al título («No se graba…» y «Se cierra sola a los 15 s.»).
- Actividad, en la barra superior («Nadie puede borrar ni cambiar este registro.»).
- Trabajo futuro, vista 3D, en la barra superior.

Siguen a la vista: el texto de seguridad de las alertas (quién, dónde, cuándo, llamar, SAMU), los errores y mensajes de validación, el consentimiento, las páginas legales y sus casillas, y los estados que son la información («En pausa hasta las 11:42», «No disponible ahora», «No disponibles: …» de los puntos del cuerpo). Las ayudas del widget y la introducción del registro de accesos se quedan porque explican la pantalla, no un control.
