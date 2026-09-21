# bitclap.es — Estado del proyecto

> **Para qué es este documento.** Para retomar el proyecto desde cero en otro
> ordenador sin tener que releer conversaciones antiguas. Aquí está lo que hay,
> lo que funciona, lo que falta y por qué se tomó cada decisión.
>
> **Mantenlo vivo:** cuando algo deje de ser cierto, edítalo o bórralo. Un
> documento desactualizado es peor que no tenerlo.

**Última actualización:** 15 de septiembre de 2026

> **Si vienes de otro ordenador, lee en este orden:**
> 1. Este documento (5 minutos).
> 2. `PLAN-DE-ARREGLOS.md`, apartado **"Lo que te toca a ti"**. Es el documento
>    de trabajo del día a día.
> 3. `AUDITORIA-2026-09-08.md`, solo si necesitas el porqué de algo.

---

## 1. Qué es esto

Un chatbot de WhatsApp para clínicas dentales. El paciente escribe al WhatsApp
del asistente y este le gestiona la cita solo: la reserva, la modifica, la
cancela, le recuerda el día antes y avisa a la clínica si es algo que necesita
una persona. La clínica recibe cada mañana un email con lo que tiene que hacer.

Marca prevista: **bitclap.es** · Mercado: España · Fundador: solo.

**Estado real (15-sep-2026):** el producto está construido, y el 15-sep se
aplicaron **en los ficheros** los arreglos de la auditoría. **Todavía no están
importados en n8n ni probados.** El bot que corre hoy en n8n Cloud sigue mudo
desde el 16-ago, porque Groq retiró el modelo de IA que usaba. Cero clientes.

---

## 2. Situación actual, sin adornos

| Cosa | Estado |
|---|---|
| Bot en n8n Cloud | 🟡 Vuelve a responder (probado el 16-sep). Se salía del papel: escribía webs, hacía sumas y se disculpaba en inglés |
| Bot en el repositorio | 🟡 Arreglado el 15-sep y con filtro de ámbito el 16-sep. Falta importarlo y pasar la batería |
| Modelo de IA | 🟡 Groq gratis: `gpt-oss-120b` + `gpt-oss-20b` de reserva, ya en el workflow. Falta la credencial en n8n. **En EE. UU.** y con un límite gratuito que solo da para pruebas y demo |
| Base de datos | ✅ Supabase en la UE, multi-clínica. 🟡 Falta ejecutar el SQL 06 y pasar a Pro |
| Plantilla de recordatorio | 🟡 El workflow 02 ya la usa. Falta darla de alta en Meta |
| Operación de la clínica | ✅ Email diario, botón para cerrar derivaciones y guías (en el repo) |
| Cliente potencial | 🟡 Una clínica interesada, sin contrato, unos 2 meses sin hablar |
| Modelo 036 (censal, gratis) | ❌ No. Lo pide la verificación de Meta |
| Alta en RETA (cuota) | ❌ No, y a propósito: justo antes de la primera factura |
| Meta | 🟡 Número de prueba (máx. 5 destinatarios). **La verificación no bloquea el piloto** (250 destinatarios únicos/24 h sin verificar). Lo que hace falta es número real + método de pago |
| Documentos legales | 🟡 Anexo II relleno, cláusula de IA y borrador de EIPD. Faltan corchetes, DPAs en PDF y firma. Sin abogado (decidido) |
| Precios | 🟡 Propuesta sin validar. El plan Clínica+ vende cosas que no existen |
| Web | ❌ No existe |

**Lo que de verdad separa hoy de un primer paciente, en orden:**

1. **Importar y probar los arreglos** (tu tiempo: unas 20-40 h, casi todo pruebas).
2. **Una fecha con el dentista.** Es lo que más mueve la probabilidad de arrancar este año.
3. **Número real + método de pago en Meta**, y la plantilla aprobada.
4. **Firmar** el acuerdo de piloto y el contrato de encargado antes del primer paciente.
5. Alta en RETA, solo antes de facturar.

---

## 3. Cómo está montado

```
Paciente por WhatsApp
        ↓
  n8n Cloud (workflow 01)
        ↓
  ¿de qué clínica es este número? → Supabase (vista clinicas_config)
        ↓
  ¿primera vez? → aviso "soy un asistente de IA" + privacidad → tabla pacientes
        ↓
  ¿tiene una consulta clínica pendiente? → no se llama a la IA
        ↓
  Groq (gpt-oss-120b; reserva gpt-oss-20b) → qué quiere el paciente (JSON)
        │           si falla → mensaje con el teléfono de la clínica + aviso a ti
        ↓
  validación en código → Google Calendar + Supabase + WhatsApp + email a la clínica
```

| Workflow | Qué hace | En el piloto |
|---|---|---|
| 01 WhatsApp citas | El bot | Sí |
| 02 Recordatorios 24h | Plantilla de Meta el día antes | Sí, con la plantilla aprobada |
| 03 Valoraciones | Pide valoración tras la cita | **No** (sigue con texto libre) |
| 04 Avisos de error | Te avisa por WhatsApp y email | Sí |
| 05 Resumen semanal | Email de los lunes | **No** |
| 06 Email diario | "Hoy en la clínica", a las 8:00 | Sí |
| 07 Marcar derivación atendida | El botón de los emails | Sí |

### Decisión de diseño 1: multi-clínica

Un solo workflow atiende a todas las clínicas. Cuando entra un mensaje, el bot
mira **a qué número de WhatsApp llegó** (`phone_number_id`), busca esa clínica
en Supabase y se trae su configuración: nombre, horarios, precios, duraciones,
teléfono, dirección, calendario, zona horaria y enlace de privacidad.

Dar de alta una clínica nueva = insertar filas en Supabase. **No se toca n8n.**

- **El prompt base vive en el workflow** (nodo `Construir contexto`): son las
  reglas del producto. Si vive en un solo sitio, al mejorarlo mejora para todas
  las clínicas a la vez.
- **Los datos de cada clínica viven en Supabase.** Para matices de un cliente
  concreto está la columna `instrucciones_extra`.

### Decisión de diseño 2: el paciente es su teléfono

Las citas se buscan, se cambian y se cancelan **solo desde el número de WhatsApp
con el que se reservaron**. El nombre nunca basta: hasta el 15-sep, sí bastaba,
y cualquiera podía ver o cancelar la cita de otra persona. Si alguien reservó
desde otro teléfono, se le pide que llame a la clínica.

---

## 4. Los ficheros

| Carpeta / fichero | Qué es |
|---|---|
| `PLAN-DE-ARREGLOS.md` | **Documento de trabajo.** Qué queda, en qué orden y cuánto |
| `AUDITORIA-2026-09-08.md` | Diagnóstico completo con evidencia |
| `Automatizaciones Supabase/` | **Lo que se usa.** SQL 01 a 06 (en orden), workflows 01 a 07 y el `README.md` con la instalación paso a paso |
| `Pruebas/Bateria de mensajes.md` | Batería de pruebas manuales en n8n (bloques A a O) |
| `Pruebas/automaticas/simular-workflows.js` | Prueba automática del código de los nodos (instrucciones dentro) |
| `Operacion/` | Guía para recepción, guía para el dentista y runbook para ti |
| `Legal/` | Documentos 01 a 07. Ver su `README.md` |
| `Negocio/` | Decisiones, Meta, precios, plan comercial, mensaje al dentista |
| `backups/` | **Solo historia.** Una carpeta por fecha. Nada de aquí se importa nunca |

> **Regla de oro del repositorio (21-sep):** los workflows que se usan viven
> **solo** en `Automatizaciones Supabase/`. Si encuentras un `.json` fuera de
> ahí, es historia. Antes había tres copias del workflow 01 repartidas en dos
> carpetas y una estaba desactualizada: era cuestión de tiempo importar la mala.

---

## 5. Montarlo en un ordenador nuevo

No hay nada que instalar: todo vive en la nube. Lo único local es este repo.

1. Clona o copia esta carpeta.
2. Entra en **n8n Cloud**. Los workflows están ahí; solo hay que reimportar si
   quieres restaurar una versión del repo.
3. Entra en **Supabase** (proyecto `Bitclap-multiclinic`, región UE).
4. Para rehacer algo desde cero: `Automatizaciones Supabase/README.md`.
5. Si vas a tocar código de nodos en un PC sin Node instalado, sirve el de VS
   Code (instrucciones en `Pruebas/automaticas/simular-workflows.js`).

### Cuentas y dónde están las claves

| Servicio | Para qué | Dónde está la clave | Credencial en n8n |
|---|---|---|---|
| n8n Cloud | Ejecuta los workflows | Login con tu cuenta | — |
| Supabase | Base de datos | `service_role` en Project Settings → API | `Supabase account` |
| Meta for Developers | WhatsApp Business API | Token de usuario del sistema | `WhatsApp account` (una para todos) y `WhatsApp OAuth account` (disparador) |
| Groq | Modelo de IA | console.groq.com → API Keys | `Groq account` |
| Google Calendar | Agenda de la clínica | OAuth dentro de n8n | Google Calendar account |
| Gmail | Emails a la clínica | OAuth dentro de n8n | `Gmail account` |

> 🔒 **Ninguna clave está en este repo, y no debe estarlo.** Si alguna vez
> subes una por error, regénerala inmediatamente: el historial de git la
> conserva aunque borres el fichero.

---

## 6. Decisiones ya tomadas (no volver a discutirlas)

- **Supabase en vez de Google Sheets o Airtable.** PostgreSQL de verdad, región
  UE (datos de salud) y capa gratuita suficiente para empezar.
- **Multi-clínica desde el principio**, aunque solo haya un cliente.
- **Región UE en Supabase.** No cambiable después.
- **Zona horaria configurable por clínica**, no escrita en el código.
- **Sin panel gráfico.** Los emails cubren la necesidad con una fracción del trabajo.
- **Autónomo: 036 sí, RETA justo antes de la primera factura** (29-ago).
- **Sin abogado por ahora**; la revisión la hace el asesor de la clínica (29-ago).
- **Alcance A del piloto**: reservar, modificar, cancelar, derivar, recordar y
  email diario. Sin valoraciones ni resumen semanal (9-sep).
- **IA: Groq, gratis** (15-sep): `openai/gpt-oss-120b`, con `gpt-oss-20b` de
  reserva. Groq retiró Llama 3.3 el 16-ago. Se valoró Mistral (UE) y decidiste
  seguir con Groq gratis. Precio de esa decisión: la IA sigue en EE. UU. (punto
  débil del paquete legal: DPA y Zero Data Retention obligatorios) y el límite
  gratuito solo da para pruebas y demo. Cambiar de modelo es un solo nodo, y
  después hay que repetir los bloques C y H.
- **El ámbito del bot se controla en el código, no solo en el prompt** (16-sep):
  el nodo `Normalizar y enrutar` decide qué sale hacia WhatsApp. Un prompt es una
  petición al modelo; el filtro es una garantía, y sigue valiendo si mañana
  cambias de modelo.
- **La identidad del paciente es su teléfono**, nunca su nombre (15-sep).
- **Número nuevo para el piloto**, no el WhatsApp de siempre de la clínica
  (recomendado; decídelo antes de la demo).

---

## 7. Fallos ya corregidos (para no repetirlos)

Se documentan porque son trampas fáciles de volver a pisar.

**Hasta agosto:**
- **Zona horaria** `Europe/Lisbon` escrita a mano: las citas se guardaban una
  hora tarde. Ahora sale de la configuración de la clínica.
- **Bucle infinito de avisos de error (08/08).** Los *callbacks de estado* de
  WhatsApp entran en el workflow como si fueran mensajes. **Regla:** los nodos
  de la rama "no texto" (`Preparar respuesta no texto`, `Filtrar envio fallido`)
  no pueden usar `$('Construir contexto')` ni fallar. Además hay un cortafuegos
  en el 04: máximo 5 avisos cada 15 minutos.
- **`$input` no es lo que parece.** Es la salida del nodo **inmediatamente
  anterior**. Si insertas un nodo delante, lo rompes. Usa `$('Nombre del nodo')`.
- **Última cita del día**: el bot explica a qué hora es la última posible.
- **El bot no se callaba al derivar**: ahora se pausa 3 h.
- **Los cinco workflows son multi-clínica** (29-ago).

**El 15-sep-2026** (detalle en `Automatizaciones Supabase/README.md`, Parte 8):
- **Bot mudo sin aviso:** el modelo de IA desapareció y la salida de error del
  `AI Agent` no iba a ninguna parte. Ahora el paciente recibe el teléfono y a ti
  te llega el aviso.
- **Fuga de identidad:** se buscaban citas por nombre si no coincidía el teléfono.
- **Detector clínico por trozos de palabra:** "Salvador" o "tomo nota" derivaban
  y callaban el bot. De 12 frases normales derivaban 11; ahora 0.
- **Una reserva cancelaba en silencio** todas las demás citas del paciente.
- **Recordatorios con texto libre**, que Meta rechaza fuera de 24 h, y marcados
  como enviados aunque fallaran.
- **Recordatorios duplicados** con dos o más clínicas.
- **"stop" no daba de baja**: solo cerraba un lead.
- **Sin aviso de IA** en el primer contacto (obligatorio desde el 2-ago-2026).
- **Mensaje de derivación sin el 112** ni el aviso de consejo médico.
- **Dos credenciales de WhatsApp** que caducaban por separado.

**El 16-sep-2026** (probando el bot por WhatsApp de verdad):
- **El bot hacía de asistente general:** escribió una página HTML entera cuando
  le pidieron "pásame el html" y contestó "70" a "20+50?". La última línea de
  `Normalizar y enrutar` enviaba al paciente el texto del modelo **sin mirarlo**.
- **Se disculpaba en inglés** (*"I'm sorry, but I can't help with that"*) ante un
  mensaje obsceno: es la negativa de fábrica de gpt-oss, y salía tal cual.
- **Repetía clavada la frase de folleto** del prompt, horario incluido, dos veces
  seguidas. Lo que más delata a un bot no es equivocarse: es repetirse.
- **Arreglo:** el filtro vive en el código (bloque `// ambito`), no solo en el
  prompt, así que aguanta aunque cambies de modelo. Bloque P de la batería.

---

## 8. Lo que falta

### Tuyo, con tus cuentas
Todo está, en orden y con horas, en `PLAN-DE-ARREGLOS.md` → "Lo que te toca a ti".

### Decisión pendiente: sincronizar con la agenda real de la clínica

**No todas las citas entran por WhatsApp.** Muchas llegan por teléfono o en
persona.

**Lo que ya funciona:** el bot consulta Google Calendar antes de reservar. Si la
recepcionista apunta las citas de teléfono **en ese mismo calendario**, el bot
no puede pisarlas. Y desde el 15-sep los eventos que crea el bot llevan el
teléfono del paciente en la descripción.

**Lo que falta:** Supabase no se entera de las citas apuntadas a mano. Esas no
reciben recordatorio, y el bot no las encuentra si el paciente escribe para
cancelar.

**Solución:** un workflow que sincronice Google Calendar → Supabase, con el
teléfono en el evento en un formato acordado. **Antes de construirlo, pregunta
a la clínica:** qué usan hoy para la agenda, quién apunta las citas de teléfono
y dónde, y cuántas entran por cada vía. Si usan software dental propio, hay que
mirar si tiene API.

### Mejoras del producto (no bloqueantes)

- **Workflow 03 con plantilla**, igual que el 02, para poder activar valoraciones.
- **Respuestas con botones** en el 01, para poner botones en las plantillas.
- **Seguimiento comercial de leads**: las columnas existen pero nadie las lee.
- ~~RLS en las tablas antiguas~~ → **hecho el 22-sep** con `07 - multi-clinica-estricto.sql`, junto con quitar el `default` de `clinica_id` y añadir `clinica_id` a `envios_fallidos`. Falta **ejecutarlo en Supabase**.
- **Guardar solo el resumen** de las derivaciones, no el texto literal.
- **Aviso de derivación urgente por WhatsApp** al móvil del dentista.
- **Limitar el historial de ejecuciones** de n8n, que guarda el contenido de los mensajes.

---

## 9. Cómo probar que todo sigue bien

1. **Si has tocado código de nodos:** `Pruebas/automaticas/simular-workflows.js`.
2. **En n8n:** `Automatizaciones Supabase/README.md`, Paso 7.
3. **Con lenguaje real y casos trampa:** `Pruebas/Bateria de mensajes.md`.

**Detalle que cuesta descubrir:** los *Error Workflow* de n8n **solo saltan en
ejecuciones de producción** (workflow activo, disparado por su propio trigger).
Si rompes un nodo y le das a "Execute workflow" a mano, no salta ningún aviso.
Es comportamiento normal de n8n, no un fallo.
