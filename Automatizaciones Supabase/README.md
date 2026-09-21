# Automatizaciones con Supabase — bitclap.es

Chatbot de WhatsApp para clínicas dentales, con **Supabase** como base de datos y
preparado para **varias clínicas con un solo workflow**.

## Qué hay en esta carpeta

| Archivo | Qué es |
|---|---|
| `01 - esquema.sql` | Tablas base. Se ejecuta primero. |
| `02 - multi-clinica.sql` | Configuración por clínica + tratamientos. Se ejecuta segundo. |
| `03 - optimizaciones.sql` | Vista e índice de rendimiento. Se ejecuta tercero. |
| `04 - avisos-error.sql` | Registro de errores y cortafuegos. Se ejecuta cuarto. |
| `05 - pausa-derivacion.sql` | El bot se calla tras derivar a una persona. Se ejecuta quinto. |
| `06 - pacientes-y-cumplimiento.sql` | Pacientes, aviso de IA/RGPD, bajas y envíos fallidos. Se ejecuta sexto. |
| `07 - multi-clinica-estricto.sql` | Cierra los huecos multi-clínica: RLS, defaults y `envios_fallidos`. Se ejecuta séptimo. |
| `Clinica Dental - 01 WhatsApp citas (Supabase).json` | El bot principal (107 nodos). |
| `Clinica Dental - 02 Recordatorios 24h (Supabase).json` | Recordatorio el día antes. |
| `Clinica Dental - 03 Solicitud valoraciones post cita (Supabase).json` | Pide valoración al terminar. |
| `Clinica Dental - 04 Avisos de error.json` | Te avisa por WhatsApp si algo falla. |
| `Clinica Dental - 05 Resumen semanal.json` | Email semanal a cada clínica (fuera del piloto). |
| `Clinica Dental - 06 Email diario Hoy.json` | Email diario a la clínica: pacientes a los que llamar, citas, lista de espera y leads. |
| `Clinica Dental - 07 Marcar derivacion atendida.json` | El botón "Marcar como atendida" de los emails. |

---

# Parte 1 — Puesta en marcha

## Paso 1 — Crear el proyecto en Supabase

1. Entra en [supabase.com](https://supabase.com) → **New project**.
2. **Database password**: genera una larga y guárdala. Solo se muestra una vez.
3. **Region**: **Central EU (Frankfurt)** o **West EU (Ireland)**.

> ⚠️ **La región no se puede cambiar después.** Tratas datos de salud de pacientes europeos (dolor, sangrado, medicación, embarazo). Alojarlos en la UE te evita el problema de las transferencias internacionales del RGPD. No elijas EE. UU.

## Paso 2 — Crear las tablas

En **SQL Editor** → **New query**, pega y ejecuta **en este orden**:

1. `01 - esquema.sql` → crea `clinicas`, `citas`, `lista_espera`, `leads`, `derivaciones`
2. `02 - multi-clinica.sql` → añade la configuración de cada clínica y la tabla `tratamientos`
3. `03 - optimizaciones.sql` → crea la vista `clinicas_config` y un índice
4. `04 - avisos-error.sql` → crea la tabla `avisos_error` (el workflow 04 no funciona sin ella)
5. `05 - pausa-derivacion.sql` → añade la pausa del bot tras derivar a una persona
6. `06 - pacientes-y-cumplimiento.sql` → crea `pacientes` y `envios_fallidos`, y añade `clinicas.url_privacidad` y `derivaciones.token_cierre`
7. `07 - multi-clinica-estricto.sql` → activa RLS en el resto de tablas, quita el valor por defecto de `clinica_id` y añade `clinica_id` a `envios_fallidos`

> ⚠️ **El 07 tiene una comprobación previa. Léete su apartado 0 antes de ejecutarlo.**
> Activa RLS, y si la credencial de Supabase en n8n usa la clave `anon` en vez de
> `service_role`, el bot se queda sin base de datos. El propio fichero lleva el
> comando exacto para deshacerlo.

Todos se pueden ejecutar varias veces sin romper nada. El último te devuelve tres comprobaciones: ninguna tabla con valor por defecto en `clinica_id`, todas con `rowsecurity = true`, y la clínica con sus tratamientos.

Después, pon el enlace a la política de privacidad de la clínica (sale en el aviso de primer contacto):

```sql
update clinicas set url_privacidad = 'https://...' where id = '11111111-1111-1111-1111-111111111111';
```

## Paso 3 — Claves de conexión

**Project Settings** → **API**. Apunta:
- **Project URL** → `https://xxxx.supabase.co`
- **service_role** → pulsa *Reveal* y cópiala

> 🔒 La `service_role` es la llave maestra: salta todas las reglas de seguridad. Va **solo** dentro de n8n. Nunca en una web, una app o un panel. Si se filtra, se regenera desde esa misma pantalla.

## Paso 4 — Conectar con n8n

**Credentials** → **Add credential** → **Supabase API**:
- **Host**: el Project URL
- **Service Role Secret**: la clave `service_role`
- Nómbrala `Supabase account`.

Crea también estas dos, con estos nombres exactos (los workflows las buscan así):

- **Groq** → nombre `Groq account`. API key gratuita de
  [console.groq.com](https://console.groq.com) → API Keys. Activa también
  **Zero Data Retention** (Settings → Data Controls): Groq procesa los mensajes
  en EE. UU. y así no los conserva.
- **WhatsApp API** → nombre `WhatsApp account`, con el token permanente de Meta.
  Es **una sola** credencial para los siete workflows.

## Paso 5 — Importar los 7 workflows

Para cada `.json`: **Workflows** → **Import from File**. Luego abre un nodo morado de Supabase y elige la credencial `Supabase account`; n8n la aplica al resto.

> **Si ya tienes los workflows en n8n**, no los importes como nuevos: abre cada
> uno → **⋯** → **Import from File** y elige su `.json`. Así se reemplaza el
> contenido pero se conservan su Error Workflow y la dirección del webhook de
> WhatsApp. Antes, descárgalos (**⋯** → **Download**) y guárdalos en `backups/`
> con la fecha. El 06 y el 07 sí son nuevos.

Repasa también las credenciales de WhatsApp, Google Calendar y Gmail.

## Paso 6 — Activar los avisos de error

El workflow 04 **no funciona hasta que le dices a los demás que lo usen**:

En cada workflow (01, 02, 03, 05, 06 y 07): menú **⋯** → **Settings** → **Error Workflow** → elige `Clinica Dental - 04 Avisos de error` → Guardar.

En el workflow 04, nodo `Decidir si avisar`, escribe tu correo en `EMAIL_AVISOS`: así los avisos te llegan también por email aunque lleves más de 24 h sin escribir al bot.

Y **activa el workflow 07**: es un webhook, y sin activar el botón "Marcar como atendida" de los emails no funciona.

## Paso 7 — Probar, en este orden

Prueba con **tu propio número** antes de enseñárselo a nadie:

1. **Reservar** — "Quiero una cita para una limpieza mañana a las 16:00 a nombre de Luis Ander"
   → fila en `citas`, evento en Calendar **a las 16:00 reales**, WhatsApp de confirmación, email al dentista.
2. **Hueco ocupado** — misma hora, otro nombre → fila en `lista_espera`.
3. **Modificar** → la vieja pasa a `modificada`, aparece una nueva `confirmada`, avisa al de lista de espera.
4. **Cancelar** → pasa a `cancelada`, el evento desaparece del calendario.
5. **Lead** — "¿Cuánto cuesta la ortodoncia?" → fila en `leads`.
6. **Derivación** — "Me duele una muela y me sangra" → fila en `derivaciones` + email.
7. **Recordatorio / valoración** — ejecuta a mano los workflows 02 y 03.
8. **Error** — en n8n los avisos de error **solo saltan con el workflow activo** y disparado por su propio trigger, no con "Execute workflow". Sigue los pasos de la nota del workflow 04 (cron cada 2 minutos).
9. **Resumen semanal** — ejecuta a mano el workflow 05 (fuera del piloto).
10. **Primer contacto** — escribe desde un número que nunca haya escrito al bot: llega primero el aviso de IA y privacidad, y aparece una fila en `pacientes`.
11. **IA caída** — pon una API key falsa en `Groq account` y escribe: debes recibir *"ahora mismo no puedo atenderte por aquí. Llama a la clínica..."*.
12. **Botón de derivación** — tras el paso 6, abre el email y pulsa "Marcar como atendida": pide confirmar y, al confirmar, la fila pasa a `atendida`.
13. **Email diario** — ejecuta a mano el workflow 06.

La batería completa, con los casos trampa, está en `Pruebas/Bateria de mensajes.md`. Activa los workflows solo cuando todo esto vaya bien.

---

# Parte 2 — El fallo de la hora, explicado

Reservabas las 18:00 y en Google Calendar salían las 19:00.

El código tenía escrita la zona horaria `Europe/Lisbon`. En verano Portugal va **una hora por detrás** de España. Al pedir las 18:00, se guardaba el instante que en Portugal son las 18:00 — que en España son las 19:00. Google Calendar, que muestra hora española, enseñaba las 19:00. No fallaba el calendario: fallaba la zona horaria de partida.

**Solución:** la zona horaria ya no está escrita en el código. Sale de la columna `zona_horaria` de la tabla `clinicas`, y la he dejado en `Europe/Madrid`.

Si algún día das de alta una clínica portuguesa de verdad, esa fila lleva `Europe/Lisbon` y las dos conviven sin tocar el workflow.

> Compruébalo en el paso 7.1: la cita debe aparecer en Calendar **a la hora que pediste**.

---

# Parte 3 — Multi-clínica: cómo funciona ahora

## Qué ha cambiado

Antes, dar de alta una clínica nueva era duplicar el workflow entero y editar a mano el prompt, los precios, los horarios y el teléfono. Ahora **no se toca n8n**: se insertan filas en Supabase.

Cuando entra un mensaje, el bot hace esto:

1. Mira a **qué número de WhatsApp** ha llegado el mensaje (`phone_number_id`, que Meta envía en cada webhook).
2. Busca ese número en la columna `telefono_whatsapp_id` de la tabla `clinicas`.
3. Se trae la configuración de esa clínica **con sus tratamientos incluidos**.
4. **Construye el prompt del asistente al vuelo** con esos datos.
5. A partir de ahí, todo el workflow usa esa configuración: calendario, horarios, duraciones, teléfono, email del dentista, zona horaria.

## Dónde vive cada cosa (y por qué)

Esta es la decisión de diseño importante:

- **El prompt base vive en el workflow** (nodo `Construir contexto`). Son las reglas del producto: cómo devolver JSON, cuándo derivar a un humano, cómo tratar fechas. Es *tu* ingeniería. Si vive en un solo sitio, cuando la mejoras, mejora para **todas** las clínicas a la vez.
- **Los datos de cada clínica viven en Supabase**: nombre, nombre del asistente, precios, duraciones, horarios, dirección, teléfono, idiomas, zona horaria, calendario, email.

Si metieras el prompt entero en la base de datos, cada clínica tendría su propia copia y arreglar un fallo significaría editarlo N veces. Por eso se separa así.

Para matices concretos de un cliente ("no ofrecemos urgencias", "trátales de usted") existe la columna `instrucciones_extra`, que se añade al final del prompt de esa clínica.

## Verificación: cero datos de clínica en los workflows

Comprobado en los cinco archivos — 0 apariciones de:
`912 345 678` · `Salud Lisboa` · `Calle Mayor 123` · `Europe/Lisbon` · el ID del calendario de pruebas · el `phoneNumberId` fijo.

La única excepción es a propósito: el workflow 04 tiene la constante `PHONE_ID_AVISOS`,
el número desde el que **bitclap** te avisa a ti de los fallos. No es el de ninguna
clínica, y sigue siendo uno solo tengas 1 cliente o 30.

### Los cinco workflows son multi-clínica

| | Cómo sabe a qué clínica pertenece cada cosa |
|---|---|
| 01 WhatsApp citas | Por el `phone_number_id` que trae el propio webhook de Meta |
| 02 Recordatorios | Carga `clinicas` y cruza por `clinica_id`; usa la zona horaria de cada una |
| 03 Valoraciones | Igual que el 02; el fin de la cita se calcula en la zona de su clínica |
| 04 Avisos de error | No aplica: los avisos son para ti, no para el cliente |
| 05 Resumen semanal | Agrupa por `clinica_id` y manda un correo a cada `email_avisos` |
| 06 Email diario | Igual que el 05, cada mañana |
| 07 Marcar derivación atendida | Por el `derivacion_id` y el token del enlace |

**Por qué los workflows 02 y 03 buscan citas de varios días y luego filtran en código:**
si la consulta filtrase por «la fecha de mañana en Madrid», una clínica en otro huso
horario recibiría el recordatorio el día equivocado. La consulta trae un margen y quien
decide qué cita toca es el código, que sí conoce la zona de cada clínica.

## Dar de alta la clínica número 2

1. Conseguir su `phone_number_id` de WhatsApp Business (Meta).
2. Que comparta su Google Calendar con tu cuenta (permiso "Hacer cambios en los eventos").
3. `insert into clinicas (...)` con sus datos → te devuelve un `id`.
4. `insert into tratamientos (...)` con ese `id`.
5. Ya está. Sin tocar n8n.

Al final de `02 - multi-clinica.sql` tienes el SQL preparado.

> Los dos pasos que antes figuraban aquí como "recomendados a partir de la segunda clínica" —quitar el `default` de `clinica_id` y activar RLS— **ya están hechos** en `07 - multi-clinica-estricto.sql`. Si lo has ejecutado, al dar de alta una clínica nueva **tienes que poner su `clinica_id` a mano** en los `insert`: ya no hay valor por defecto que lo rellene, y eso es a propósito.

---

# Parte 4 — Optimización: qué es lento de verdad

Me pediste optimizar el workflow 01 porque tiene muchos nodos. Analicé la composición real:

| Tipo | Cantidad | ¿Cuesta tiempo? |
|---|---|---|
| Notas (sticky) | 11 | No, son documentación. No se ejecutan. |
| IF | 19 | No, son microsegundos. |
| Code | 26 | No, JavaScript local. |
| Llamadas de red | 33 | **Sí. Aquí está todo el tiempo.** |

**El número de nodos no es el problema.** En una reserva completa se ejecutan unos 20 nodos, pero el reparto del tiempo es más o menos así:

- **Llamada a la IA: 1–3 segundos** ← el 70-80% del total
- Google Calendar: ~0,3–0,4 s por llamada
- Supabase: ~0,1 s por consulta
- Envío de WhatsApp: ~0,3 s
- Los 26 nodos de código, los 19 IF y las 11 notas juntos: menos de 50 ms

Fusionar nodos de código habría tocado lógica que hoy funciona, a cambio de ahorrar milisegundos. No compensa, y menos con tu prioridad de cero fallos con el primer cliente.

## Lo que sí he optimizado

**1. Una consulta menos en cada mensaje.** El refactor multi-clínica necesitaba dos consultas (clínica + tratamientos). He creado la vista `clinicas_config`, que devuelve la clínica con sus tratamientos ya incrustados. Una consulta en vez de dos, y un nodo menos.

**2. Búsqueda de duplicados acotada — y un fallo corregido de paso.** Antes, al reservar, el bot se traía **todas** las citas confirmadas de la historia para ver si el paciente ya tenía una. Dos problemas: la consulta crecía sin parar, y si el paciente tenía una cita **pasada** aún marcada como confirmada, el bot la cancelaba y **borraba el evento histórico del calendario**. Ahora solo mira citas de hoy en adelante. Más rápido y deja de destruir el historial.

## Si de verdad quieres que vaya más rápido

La única palanca que mueve la aguja es la IA:
- **Prompt caching** — tu prompt de sistema son ~14.000 caracteres iguales en cada mensaje. OpenAI y Anthropic lo cachean y cobran ~90% menos por esa parte; también reduce latencia.
- **Un modelo más rápido** para los mensajes fáciles.
- **Saltarse la IA** en mensajes obvios ("hola", un número del 1 al 5 para valorar). El nodo `Normalizar y enrutar` ya sabe resolver varios de esos casos: adelantar esa comprobación antes del agente ahorraría la llamada entera. Es la optimización con más recorrido, y la dejo apuntada porque toca el flujo principal y merece hacerse con calma y con pruebas.

---

# Incidente del 08/08/2026 — la avalancha de avisos

Merece la pena entenderlo porque explica dos arreglos del código.

**Qué pasó.** Caducó el token de Meta, el bot no pudo enviar un mensaje y empezaron a llegar decenas de avisos de error seguidos, solos, sin que nadie tocara nada.

**Por qué.** El token no fue la causa, solo la chispa. Había un bucle:

1. WhatsApp manda un *callback de estado* (enviado / entregado / leído) por **cada** mensaje que sale. Esos callbacks entran en el workflow 01 igual que un mensaje normal.
2. `If texto valido` los manda por la rama FALSE, a `Preparar respuesta no texto`.
3. Ese nodo había quedado con `$('Construir contexto')` en su primera línea. Pero `Construir contexto` está en la **otra** rama del IF, así que nunca se había ejecutado → el nodo reventaba con *"Node 'Construir contexto' hasn't been executed"*.
4. Al fallar el workflow 01 → saltaba el workflow 04 → mandaba un aviso por WhatsApp.
5. **Ese aviso generaba sus propios callbacks de estado** → volvían al paso 1.

Cada aviso producía más avisos. Por eso se disparó solo y por eso paró solo (cuando Meta cortó por límites).

**De quién fue el fallo: mío.** Al hacer el refactor multi-clínica añadí la línea de configuración a todos los nodos que mencionaban el teléfono de la clínica, sin comprobar que uno de ellos vivía en la rama que no pasa por la configuración. El código original tenía ahí un `return []` que ignoraba los callbacks en silencio — y era justo lo que cortaba el bucle. Mi línea se ejecutaba antes de ese `return` y lo dejó inútil.

**Qué se ha arreglado**

1. `Preparar respuesta no texto` ya no depende de la configuración, y su primer acto vuelve a ser ignorar los callbacks en silencio. Lleva un comentario explicando por qué no se puede tocar.
2. `Enviar WhatsApp` tenía el mismo problema: sacaba el número emisor de la configuración, así que también reventaba en esa rama. Ahora lo saca de `metadata.phone_number_id` del propio webhook, que viene siempre, en las dos ramas. Aplicado a los 3 nodos de WhatsApp.
3. El workflow 04 tiene ahora un **cortafuegos**: máximo 5 avisos cada 15 minutos y nunca el mismo error repetido. Aunque vuelva a aparecer un bucle por otro motivo, no puede inundarte.

**Cómo comprobar que está resuelto:** manda un audio o una foto al bot. Debe contestarte que solo gestiona texto, **una sola vez**, y no debe llegarte ningún aviso de error.

---

# Parte 5 — Avisos de error (workflow 04)

Salta cuando **cualquier** workflow falla y manda un WhatsApp al **+34 640575291** con: qué workflow, qué nodo, el error y el enlace a la ejecución.

> ⚠️ **Limitación de Meta que debes conocer.** La API de WhatsApp Business solo permite mensajes libres durante las 24 h siguientes a que *ese* número te escriba. Si hace más de 24 h que no escribes al número del bot desde tu móvil, **el aviso no te llegará**. No es un fallo del workflow; es una norma de Meta.
>
> El nodo está configurado para no romper nada si eso pasa, pero un aviso que no llega no sirve. **Por eso, desde el 15-sep, el aviso sale también por email**: escribe tu correo en `EMAIL_AVISOS`, dentro del nodo `Decidir si avisar`. Mientras esté vacío, solo se usa WhatsApp.

---

# Parte 6 — El bot se calla al derivar a una persona

Antes, cuando el bot derivaba una consulta al equipo ("me duele una muela y me
sangra" → email al dentista), **seguía contestando** al paciente mientras este
esperaba la llamada. Era justo el peor momento para que respondiera una máquina:
el paciente está describiendo un problema de salud y espera ayuda de verdad.

**Cómo funciona ahora.** Antes de llamar a la IA, el bot mira si ese teléfono
tiene una derivación pendiente reciente. Si la tiene:

- **No llama a la IA.** No hay forma de que se le escape una respuesta clínica.
- Le recuerda al paciente que le van a llamar y le da el teléfono de urgencias
  y el 112.
- Si la derivación acaba de crearse (menos de 2 minutos), se calla del todo:
  el paciente ya ha recibido el mensaje de "te llamamos" y no hace falta
  repetírselo.

**El paciente no se queda atrapado.** Si escribe algo relacionado con su cita
("cita", "cancelar", "cambiar", "hora"...), el bot le atiende con normalidad.
Solo se silencian las consultas.

**Cuánto dura.** Lo marca la columna `pausa_derivacion_minutos` de cada clínica.
Por defecto **180 minutos (3 horas)**. Pasado ese tiempo el bot vuelve solo.

**Para reactivarlo antes**, la clínica pulsa **"Marcar como atendida"** en el email de la derivación o en el email diario (workflow 07). Pide confirmación en un segundo clic, para que el antivirus del correo no la cierre solo al analizar el enlace.

Las derivaciones anteriores al 15-sep-2026 no tienen botón. Esas se cierran en Supabase:

```sql
update derivaciones
set estado = 'atendida', cerrado_en = now()::text
where telefono = '34600111222' and estado = 'pendiente';
```

> **Cómo probarlo:** escribe "me duele mucho una muela y me sangra" → recibes
> el mensaje de derivación. Escribe después "¿me tomo un ibuprofeno?" → el bot
> **no** debe responder con la IA, sino con el aviso de espera. Escribe "quiero
> cambiar mi cita" → debe atenderte con normalidad.

---

# Parte 7 — Resumen semanal (workflow 05)

Cada lunes a las 8:00 manda un email a cada clínica activa:

- Citas atendidas y canceladas la semana pasada
- Citas de los próximos 7 días
- Nuevos interesados (leads) de la semana
- Valoraciones recibidas y nota media
- **Consultas clínicas pendientes de atender** — arriba y en rojo, porque es lo que no puede esperar

Es multi-clínica desde el primer día: hace 4 consultas en total (no 4 por clínica), agrupa por `clinica_id` y manda un email a la dirección `email_avisos` de cada una. Con 1 clínica o con 30, siempre 4 consultas.

---

# Parte 8 — Cambios del 15-sep-2026

Lo que cambió en estos ficheros al aplicar el plan de arreglos. El porqué de
cada punto está en `AUDITORIA-2026-09-08.md`; el orden de trabajo, en
`PLAN-DE-ARREGLOS.md`.

| Qué | Dónde | Por qué |
|---|---|---|
| IA: Llama 3.3 → **Groq `gpt-oss-120b`** (gratis), con `gpt-oss-20b` de reserva | 01, `Groq Chat Model` y `Groq Chat Model reserva` | Groq retiró Llama 3.3 el 16-ago y el bot estaba mudo |
| Salida de error del `AI Agent` conectada, con 1 reintento | 01, `Respuesta emergencia IA` → `Aviso fallo IA` | Si la IA falla, el paciente recibe el teléfono de la clínica y a ti te llega el aviso |
| Citas solo por teléfono, nunca por nombre | 01, los tres nodos `Resolver ...` y `Buscar cita informativa` | Cualquiera podía ver, mover o cancelar la cita de otra persona sabiendo su nombre |
| Detector clínico con palabras completas | 01, `Normalizar y enrutar` | "Salvador", "Dolores", "febrero" o "tomo nota" derivaban y callaban el bot 3 h |
| Reservar ya no cancela otras citas | 01, `Preparar reserva y duplicados` | Cancelaba en silencio todas las citas futuras del paciente |
| Teléfono en el evento de Calendar | 01, `Crear evento reserva` y `Crear evento modificado` | Recepción no podía llamar desde el evento |
| Aviso de primer contacto (IA + privacidad) | 01, de `Buscar paciente` a `Registrar paciente` | Art. 50 del Reglamento de IA, en vigor desde el 2-ago-2026 |
| Fuera "Suenas humana"; admite ser una IA | 01, `Construir contexto` | Misma razón |
| BAJA / ALTA / "borrad mis datos" | 01, router y `Actualizar opt-out paciente`; 02 y 03, `Cargar bajas` | "stop" solo cerraba un lead y el recordatorio llegaba igual |
| Derivación con "no puedo darte consejo médico" y 112 | 01, router y confirmación de reserva | Lo exige `Legal/06` |
| Mensajes no entregados, registrados | 01, `Filtrar envio fallido`; tabla `envios_fallidos` | Un recordatorio que no llegaba era invisible |
| Recordatorio con **plantilla** de Meta | 02, `Enviar recordatorio` | Fuera de la ventana de 24 h el texto libre falla (131047) |
| Envíos rechazados: no se marcan y avisan | 02 y 03, `Resumir fallos` → `Avisar fallos` | Antes se marcaban como enviados aunque fallaran |
| Una sola consulta aunque haya varias clínicas | 02 y 03, `executeOnce` | Con 2 clínicas cada paciente habría recibido 2 recordatorios |
| Avisos de error también por email | 04, `EMAIL_AVISOS` | WhatsApp no avisa si llevas 24 h sin escribir al bot |
| Una sola credencial de WhatsApp y de Gmail | 01 a 07 | Había dos que caducaban por separado |
| Email diario "Hoy" | 06 (nuevo) | La clínica no veía derivaciones, lista de espera ni leads |
| Botón "Marcar como atendida" | 07 (nuevo) y `derivaciones.token_cierre` | Una derivación solo se podía cerrar con SQL |

**Prueba automática:** `Pruebas/automaticas/simular-workflows.js` ejecuta el
código real de los nodos Code con datos de prueba (52 comprobaciones). Pásala
cada vez que toques el código de un nodo, antes de importar.

**Límite gratuito de Groq — léelo antes de tocar el nodo del modelo.** El plan
gratuito permite **8.000 tokens por minuto y 200.000 al día por modelo**, y
cuenta el prompt **más** el máximo de respuesta que se reserva. El prompt del
bot son unos 4.000 tokens. Por eso:

- "Maximum Number of Tokens" está en **2000**. Con el valor por defecto del
  nodo (4096), Groq rechaza **todas** las peticiones (error 413).
- La memoria guarda 8 mensajes, no 12.
- El prompt de sistema es igual en todos los mensajes del día, así que Groq lo
  cachea (2 h) y los tokens cacheados no cuentan para el límite.
- Hay un modelo de reserva (`gpt-oss-20b`) con su propio cupo: si el principal
  da error de límite o lo retiran, contesta el otro.

Con esto da para probar y para la demo. **Para una clínica con pacientes no
basta**: pasa al pago por uso de Groq (console.groq.com → Settings → Billing),
que sale por menos de 1 $ al mes por clínica.

# Lo que queda pendiente

- **Plantilla `recordatorio_cita_24h`**: el workflow 02 ya la usa, pero hay que darla de alta y que Meta la apruebe. Sin eso el 02 falla (y ahora te avisa).
- **Workflow 03 (valoraciones)** sigue enviando texto libre: no lo actives hasta hacerle lo mismo que al 02.
- **Respuestas con botones** (`button` / `interactive`): el 01 las trata como "no texto". Por eso la plantilla va sin botones.
- **RLS**: ya está en todas las tablas, en cuanto ejecutes `07 - multi-clinica-estricto.sql`. Activarla sin políticas no rompe n8n **siempre que la credencial use la clave `service_role`**; con la `anon` dejaría al bot sin base de datos. El apartado 0 del propio fichero explica cómo comprobarlo y el 4 cómo deshacerlo.
- **Los avisos de lista de espera** del 01 no miran las bajas. Se mandan a quien acaba de pedir ese hueco, normalmente dentro de la ventana de 24 h.
- **Minimización:** `derivaciones.mensaje_original` guarda el texto literal del síntoma. Valorar guardar solo el resumen (`Legal/06`, apartado 4).
- **`instrucciones_extra` está vacío.** Úsalo para matices de cada cliente sin tocar el prompt base.
- **Seguimiento comercial de leads.** Las columnas `proximo_seguimiento_en`, `numero_seguimientos` y `max_seguimientos` se rellenan pero nadie las lee.
- **Aviso de derivación urgente por WhatsApp** al móvil del dentista, además del email.
