# Automatizaciones con Supabase — bitclap.es

Chatbot de WhatsApp para clínicas dentales, con **Supabase** como base de datos y
preparado para **varias clínicas con un solo workflow**.

## Qué hay en esta carpeta

| Archivo | Qué es |
|---|---|
| `01 - esquema.sql` | Tablas base. Se ejecuta primero. |
| `02 - multi-clinica.sql` | Configuración por clínica + tratamientos. Se ejecuta segundo. |
| `03 - optimizaciones.sql` | Vista e índice de rendimiento. Se ejecuta tercero. |
| `Clinica Dental - 01 WhatsApp citas (Supabase).json` | El bot principal (94 nodos). |
| `Clinica Dental - 02 Recordatorios 24h (Supabase).json` | Recordatorio el día antes. |
| `Clinica Dental - 03 Solicitud valoraciones post cita (Supabase).json` | Pide valoración al terminar. |
| `Clinica Dental - 04 Avisos de error.json` | Te avisa por WhatsApp si algo falla. |
| `Clinica Dental - 05 Resumen semanal.json` | Email semanal a cada clínica. |

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

Los tres se pueden ejecutar varias veces sin romper nada. El último te devuelve una fila de comprobación: debe decir `num_tratamientos = 5`.

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

## Paso 5 — Importar los 5 workflows

Para cada `.json`: **Workflows** → **Import from File**. Luego abre un nodo morado de Supabase y elige la credencial `Supabase account`; n8n la aplica al resto.

Repasa también las credenciales de WhatsApp, Google Calendar y Gmail.

## Paso 6 — Activar los avisos de error

El workflow 04 **no funciona hasta que le dices a los demás que lo usen**:

En cada workflow (01, 02, 03 y 05): menú **⋯** → **Settings** → **Error Workflow** → elige `Clinica Dental - 04 Avisos de error` → Guardar.

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
8. **Error** — desconecta a propósito la credencial de Supabase en el workflow 02 y ejecútalo: debe llegarte un WhatsApp.
9. **Resumen semanal** — ejecuta a mano el workflow 05.

Activa los workflows solo cuando los 9 pasos vayan bien.

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

## Verificación: cero datos de clínica en el workflow

Comprobado en el archivo final — 0 apariciones de:
`912 345 678` · `Salud Lisboa` · `Calle Mayor 123` · `Europe/Lisbon` · el ID del calendario de pruebas · el `phoneNumberId` fijo.

## Dar de alta la clínica número 2

1. Conseguir su `phone_number_id` de WhatsApp Business (Meta).
2. Que comparta su Google Calendar con tu cuenta (permiso "Hacer cambios en los eventos").
3. `insert into clinicas (...)` con sus datos → te devuelve un `id`.
4. `insert into tratamientos (...)` con ese `id`.
5. Ya está. Sin tocar n8n.

Al final de `02 - multi-clinica.sql` tienes el SQL preparado, más los dos pasos extra recomendados a partir de la segunda clínica: quitar el `default` de `clinica_id` y activar RLS.

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

# Parte 5 — Avisos de error (workflow 04)

Salta cuando **cualquier** workflow falla y manda un WhatsApp al **+34 640575291** con: qué workflow, qué nodo, el error y el enlace a la ejecución.

> ⚠️ **Limitación de Meta que debes conocer.** La API de WhatsApp Business solo permite mensajes libres durante las 24 h siguientes a que *ese* número te escriba. Si hace más de 24 h que no escribes al número del bot desde tu móvil, **el aviso no te llegará**. No es un fallo del workflow; es una norma de Meta.
>
> El nodo está configurado para no romper nada si eso pasa, pero un aviso que no llega no sirve. **Mi recomendación: cambia ese nodo por Telegram** (gratis, 5 minutos, sin ventana de 24 h) o por email. Te lo dejo montado en WhatsApp porque es lo que pediste, pero para alertas reales no es el canal adecuado.

---

# Parte 6 — Resumen semanal (workflow 05)

Cada lunes a las 8:00 manda un email a cada clínica activa:

- Citas atendidas y canceladas la semana pasada
- Citas de los próximos 7 días
- Nuevos interesados (leads) de la semana
- Valoraciones recibidas y nota media
- **Consultas clínicas pendientes de atender** — arriba y en rojo, porque es lo que no puede esperar

Es multi-clínica desde el primer día: hace 4 consultas en total (no 4 por clínica), agrupa por `clinica_id` y manda un email a la dirección `email_avisos` de cada una. Con 1 clínica o con 30, siempre 4 consultas.

---

# Lo que queda pendiente

- **RLS sigue desactivada.** No hace falta con una sola clínica. Instrucciones al final de `01 - esquema.sql`.
- **`instrucciones_extra` está vacío.** Úsalo para matices de cada cliente sin tocar el prompt base.
- **Seguimiento comercial de leads.** Las columnas `proximo_seguimiento_en`, `numero_seguimientos` y `max_seguimientos` se rellenan pero nadie las lee. Falta el workflow que recupere leads fríos: es el que más ingresos directos genera a la clínica.
- **Los workflows 02 y 03 no son multi-clínica todavía.** Funcionan (leen todas las citas de todas las clínicas), pero envían desde un `phoneNumberId` fijo. Con la segunda clínica hay que agruparlos por `clinica_id` como hace el workflow 05.
- **Aviso de derivación urgente por WhatsApp** al móvil del dentista, además del email.
