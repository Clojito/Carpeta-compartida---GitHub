# Plan de arreglos — de donde estás a un piloto con pacientes reales

> **Revisado el 9 de septiembre de 2026** contra el código real, después de
> tu commit `main2`. Lo que ya está hecho aparece tachado y marcado ✅.
>
> **Cómo usar este documento.** Está ordenado por **dependencias**, no por
> gravedad: si lo sigues en orden, nunca harás un trabajo que luego tengas
> que repetir. Marca las casillas según avances — está en el repo, así que lo
> tienes igual desde cualquier ordenador.
>
> **Cómo convive con tus otros documentos:**
> - `Negocio/Plan de esta semana.md` → **el carril comercial** (dentista,
>   036, Meta, demo). Sigue siendo válido, con dos correcciones de orden que
>   están abajo.
> - **Este documento** → **el carril técnico**. Qué arreglar y en qué orden.
> - `Pruebas/Bateria de mensajes.md` → cómo comprobar que lo arreglado
>   funciona.
>
> **Alcance elegido: A (mínimo legal y seguro).** Reservar, modificar,
> cancelar, derivar y recordar. **Sin** valoraciones, **sin** lista de
> espera, **sin** resumen semanal por ahora.
>
> **Total restante: ~60-105 h** (bajó desde 78-133 h gracias a lo que ya
> hiciste). Diagnóstico completo:
> [AUDITORIA-2026-09-08.md](./AUDITORIA-2026-09-08.md)

---

## ✅ Ya hecho (verificado en el código, 9-sep)

No lo vuelvas a tocar:

- ✅ **Workflows 02 y 03 multi-clínica de verdad.** Cargan `clinicas`,
  cruzan por `clinica_id`, `phoneNumberId` dinámico, zona horaria por
  clínica. *(era la Fase 7, 6-10 h — cerrada)*
- ✅ **Workflow 04**: número de avisos desde configuración.
- ✅ **Cláusula de límite de responsabilidad** en el contrato de encargado,
  alineada con el de servicios. *(era parte de la Fase 5)*
- ✅ **Batería de pruebas escrita**, 12 bloques + 5 trampas documentadas.
  *(era la mitad de la Fase 3, ~4-7 h — cerrada)*
- ✅ **Decidido**: 036 sí / RETA solo antes de la primera factura; sin
  abogado por ahora. Documentado en `Negocio/Decisiones - autonomo y
  abogado.md`.

---

## 🔴 Dos correcciones de orden respecto a tu plan de la semana

**1. El cambio de proveedor de IA sube al día 1.** Tu plan lo pone en
"Semana 2, después de la demo". Pero el modelo `llama-3.3-70b-versatile`
está apagado desde el 16 de agosto: **sin cambiarlo no hay demo**. Es la
primera tarea de ordenador, no la última.

**2. La verificación de Meta no es el cuello de botella.** Una cuenta sin
verificar puede escribir a **250 destinatarios únicos cada 24 h** — tu
clínica piloto son ~5 al día. Lo que te ata es el **número de prueba** (5
destinatarios): sal de ahí con un número real + método de pago, sin esperar a
nadie. Arranca igual la verificación (la necesitas para la clínica 2 y para
el nombre visible), pero deja de planificar alrededor de esa espera.

---

## FASE 0 — Hoy (1-3 h)

- [ ] **Confirma que el bot está muerto.** Escríbele. Si no contesta, es el
  modelo apagado. *15 min.*

- [ ] **Conecta la salida de error del `AI Agent`.** Sigue teniendo solo la
  salida `[0]` conectada. Es la razón de que lleves tres semanas con el bot
  caído sin un solo aviso.
  - Nodo Code que devuelva:
    `{accion:'responder', respuesta:'Ahora mismo no puedo atenderte por aquí. Llama a la clínica al [teléfono] y te ayudamos.'}`
  - Conectar `AI Agent` (salida 1) → ese nodo → `Enviar WhatsApp`.
  - Activar `retryOnFail` (2 intentos, 3 s).
  *1-3 h.*

> **Por qué sigue siendo lo primero:** no es arreglar un fallo, es la red que
> hace visibles todos los demás. Sin ella vuelves a trabajar a ciegas.

---

## FASE 1 — Cambiar el modelo de IA (12-20 h)

**Sube de la Fase 3 a la Fase 1.** Todo lo que pruebes con el modelo viejo
hay que repetirlo, así que va antes que cualquier otro arreglo.

- [ ] **Decide proveedor.** Recomendación: **Mistral** (Francia, UE) — tiene
  nodo nativo en n8n (`Mistral Cloud Chat Model`) y resuelve de paso el punto
  legal más débil que tú mismo identificaste en `Decisiones - autonomo y
  abogado.md`. Alternativas: OpenAI con endpoint europeo (`eu.api.openai.com`,
  +10%) o Azure OpenAI en región UE. *1 h.*

- [ ] **Sustituye el nodo** `Groq Chat Model` por el del proveedor elegido.
  Aprovecha para **fijar la temperatura** (hoy usa el valor por defecto, y
  para emitir JSON exacto conviene bajarla). *2-3 h.*

- [ ] **Reajusta el prompt.** 13.583 caracteres afinados a las manías de
  Llama 3.3. No lo reescribas: pasa la batería y corrige solo lo que falle.
  *6-10 h.*

- [ ] **Pasa los bloques C y H** de `Pruebas/Bateria de mensajes.md`. Son los
  que tú mismo marcaste como los de más riesgo. *3-6 h.*

> **Bonus:** al cambiar de proveedor tachas también el punto *"sacar la IA de
> Estados Unidos"* de tu lista legal. Dos problemas, un trabajo.

---

## FASE 2 — Los arreglos baratos que más daño evitan (5-11 h)

Se pueden hacer mientras esperas al dentista o a Meta.

- [ ] **Quita el fallback por nombre.** Sigue intacto. Hoy cualquiera puede
  cancelar, mover o consultar la cita de otra persona sabiendo solo su
  nombre. Tres nodos del workflow 01:
  - `Resolver cita cancelacion`: `conTelefono[0] || conNombre[0]` → `conTelefono[0]`
  - `Resolver cita modificacion`: mismo patrón con `.length - 1`
  - `Resolver consulta cita`: quitar el bloque que busca por nombre cuando no
    hay candidatas por teléfono
  - Sin coincidencia por teléfono → *"No encuentro ninguna cita a este
    número. Llama a la clínica al [teléfono]."*
  *1-4 h.* **Es tu prueba K13, y hoy la fallaría.**

- [ ] **Arregla el detector de información clínica.** Tú lo detectaste como
  trampa T3 ("caries", "golpe", "tomo "). Va más lejos de lo que apuntaste:
  como compara subcadenas, **"Dolores", "Salvador", "febrero" y "después"**
  también disparan la derivación y callan el bot 3 horas.
  - Reescribir la lista como expresiones regulares con `\b`.
  - Quitar los términos de 3-4 letras: `dor`, `doi`, `pus`, `tomo `, `pain`,
    `golpe`, `blood`.
  - Excepción si va tras "me llamo / soy / a nombre de".
  - Decidir qué hacer con `caries`: para una clínica dental, *"quiero cita
    para mirarme una caries"* es una petición normal, no una urgencia.
  - **Añade a la batería 6 nombres trampa** (Dolores, Salvador...).
  *2-4 h.*

- [ ] **Que una reserva nueva deje de cancelar en silencio otras citas.** Hoy
  cancela **todas** las citas futuras confirmadas del paciente sin avisar.
  Cambia el criterio a "misma fecha" y que pregunte:
  *"Ya tienes una cita de X el día Y a las Z. ¿Quieres cambiarla o añadir
  otra?"* *2-3 h.*

- [ ] **Añade el teléfono al evento de Calendar.** `Crear evento reserva`
  solo pone `nombre - tratamiento`. Añade `description` con el teléfono.
  Lo necesitarás para la sincronización futura y la recepcionista podrá
  llamar desde el evento. *0,5-1 h.*

---

## FASE 3 — Plantillas de WhatsApp (10-18 h + espera de aprobación)

Los textos ya los tienes escritos en `Negocio/Meta - todo lo que bloquea.md`,
apartado 3. Solo falta darlos de alta y cambiar los nodos.

- [ ] **Da de alta `recordatorio_cita_24h`** (categoría Utilidad). Hazlo ya
  aunque no vayas a tocar los nodos hasta la semana que viene: la aprobación
  corre sola mientras haces otra cosa. *30 min.*

- [ ] **Cambia el nodo de envío del workflow 02** a `Send Template`. *3-5 h.*

- [ ] **Enseña al workflow 01 a entender respuestas de botón.** Si pones
  botones ("Confirmar" / "Necesito cambiarla"), hoy el paciente recibiría
  *"solo puedo gestionar mensajes de texto"*: `If texto valido` solo acepta
  `messages[0].text.body`. Hay que tratar los tipos `button` e `interactive`.
  *4-8 h.* **Si quieres ahorrar tiempo ahora, lanza la plantilla sin botones
  y deja esto para después del piloto.**

- [ ] **Registra los fallos de entrega.** Hoy el workflow 01 descarta todos
  los callbacks de estado, incluidos los `failed`: un recordatorio que no
  llega es invisible. *2-4 h.*

- [ ] **Pon `onError: continueRegularOutput`** en el nodo de envío del 02:
  hoy un envío fallido aborta el lote y esas citas se quedan sin recordatorio
  para siempre. *1 h.*

> La plantilla de valoración (`solicitud_valoracion`) también la tienes
> escrita — dala de alta si quieres, pero el workflow 03 queda fuera del
> alcance A. Coste real de las plantillas: ~0,0166 €/mensaje en España.

---

## FASE 4 — Legal y datos (12-20 h)

Ha bajado porque la cláusula de responsabilidad ya está hecha.

- [ ] **Crea la tabla `pacientes`.** Sin ella no hay dónde registrar
  consentimiento, opt-out ni atender una supresión:
  ```sql
  create table pacientes (
    id uuid primary key default gen_random_uuid(),
    clinica_id uuid not null references clinicas(id),
    telefono_e164 text not null,
    nombre text,
    primer_contacto_en timestamptz default now(),
    informado_rgpd_en timestamptz,
    opt_out boolean not null default false,
    opt_out_en timestamptz,
    unique (clinica_id, telefono_e164)
  );
  ```
  *3-5 h.*

- [ ] **Implementa el aviso de primer contacto.** Es obligación legal **ya en
  vigor** (artículo 50 del Reglamento de IA, desde el 2 de agosto de 2026).
  Ojo: tu tabla de `Decisiones - autonomo y abogado.md` no la incluye, y
  **no es una obligación de la clínica sino tuya**, como proveedor del
  sistema. Antes del `AI Agent`: si `informado_rgpd_en` está vacío, antepón
  el texto de `Legal/06` y marca la fecha. *4-8 h.*

- [ ] **Cambia "suenas humana" en el prompt.** Sigue ahí. Sustitúyelo por:
  *"Eres un asistente virtual automático; si te preguntan si eres una persona
  o un robot, di siempre que eres un asistente virtual de IA de la clínica."*
  Es también tu prueba K7. *15 min.*

- [ ] **Implementa el opt-out.** Hoy "stop" solo cierra un lead; al día
  siguiente le llega el recordatorio igual. *2-3 h.*

- [ ] **Arregla el mensaje de derivación al paciente.** Tu `Legal/06` exige
  que incluya *"no puedo darte consejo médico"* y el **112**; el texto real
  del workflow no los lleva. *30 min.*

- [ ] **Rellena el Anexo II del contrato.** Datos ya verificados:
  | Subencargado | Ubicación | Transferencia |
  |---|---|---|
  | Supabase | AWS eu-central-1, Frankfurt | No |
  | n8n Cloud | Azure Frankfurt (UE) | No |
  | Meta / WhatsApp | WhatsApp Ireland → EE. UU. | Sí, EU-US Data Privacy Framework |
  | Google | EE. UU. | Sí, DPF — **el DPA solo cubre Workspace, no Gmail gratuito** |
  | Mistral (si lo eliges) | Francia (UE) | No |
  *2-3 h.* **Es lo primero que mirará el asesor de la clínica** — tú mismo lo
  escribiste.

- [ ] **Corrige el Anexo I**: hoy promete copias de seguridad diarias que el
  plan gratuito de Supabase no hace. *15 min.*

- [ ] **Prepara un borrador de EIPD para dársela hecha a la clínica.** Con
  datos de salud + IA + pacientes se cumplen 2-3 criterios de la lista de la
  AEPD, así que la clínica está obligada a hacerla. Formalmente es cosa suya
  — pero si no se la das hecha, no se hará, y su asesor lo va a señalar. La
  AEPD tiene herramienta gratuita. *4-6 h.* **Es lo que más cerca está de
  sustituir al abogado que has decidido no contratar.**

---

## FASE 5 — Infraestructura que se cae sola (2-5 h)

Barato, y evita caídas silenciosas durante el piloto.

- [ ] **Token permanente de Meta + unificar credenciales.** Pasos en tu
  `Meta - todo lo que bloquea.md`, apartado 4. Tienes **dos credenciales de
  WhatsApp distintas** que caducan por separado: déjalo en una. *0,5-1 h.*

- [ ] **Pasa el OAuth de Google a "In production".** Si sigue en modo
  *Testing*, los refresh tokens de Calendar y Gmail **caducan cada 7 días**
  — caída semanal silenciosa de reservas. Para uso propio no exige
  verificación. *1-2 h.*

- [ ] **Sube Supabase a Pro** (25 $/mes). El plan gratuito no hace copias de
  seguridad y pausa el proyecto tras 7 días sin actividad. *15 min.*

---

## FASE 6 — Que la clínica pueda trabajar sin llamarte (10-18 h)

Esto no está en ninguno de tus documentos y es lo que un dentista escéptico
preguntará: *"¿y mi recepcionista qué hace con esto cada mañana?"*

- [ ] **Botón para cerrar una derivación desde el email.** Hoy solo se cierra
  ejecutando SQL en Supabase — o sea, solo tú. Mientras tanto el bot sigue
  callado 3 h y el resumen semanal la muestra en rojo aunque ya hayan llamado
  al paciente. Enlace "Marcar como atendida" → webhook de n8n con token
  firmado. *3-6 h.*

- [ ] **Email diario "Hoy" a las 8:00**: citas del día, derivaciones
  pendientes con teléfono, lista de espera, leads de las últimas 24 h. La
  clínica no ve nada de eso hoy. *3-6 h.*

- [ ] **Guía de una página para la recepcionista**: qué hace el bot, cómo
  bloquear un día (un evento de todo el día "Cerrado" en Calendar ya
  funciona), qué hacer con una derivación, a quién escribir si algo falla.
  *2-3 h.*

- [ ] **Guía de una página para el dentista**: qué emails recibirá y qué
  significa cada uno. *1 h.*

- [ ] **En la demo, pregunta cómo llevan la agenda hoy.** Ya lo tienes
  apuntado en tu plan del día 5. Decide si hace falta la sincronización.
  *1 h de conversación.*

---

## FASE 7 — Antes del primer paciente real

- [ ] Batería completa pasada con el modelo nuevo y los arreglos aplicados.
- [ ] **Prueba K13** (`Dime las citas de Ana García`) desde otro número: debe
  fallar.
- [ ] **Recordatorio a un número que no haya escrito en más de 24 h** — es el
  caso que hoy falla y que no estabas probando.
- [ ] Tira la credencial de IA a propósito: debe llegarte el aviso **y** el
  paciente recibir el mensaje de emergencia.
- [ ] Número real + método de pago en Meta (esto es lo que te saca del modo
  prueba, no la verificación).
- [ ] **Firma con la clínica** el acuerdo de piloto + `Legal/01` con el Anexo
  II relleno. Aunque el piloto sea gratis: tratar datos de un paciente real
  activa el artículo 28 desde el primer mensaje.
- [ ] **Runbook de una página**: cómo regenerar cada credencial, qué hacer si
  el bot no responde.

---

## Lo que NO vas a hacer todavía

Coincide casi entero con tu propia lista de "Qué NO hacer esta semana", y
sigo estando de acuerdo:

- **Multi-dentista / varias agendas** (35-55 h) — solo cuando una clínica lo
  pida y lo pague.
- **Workflow 06 de sincronización Calendar → Supabase** — hasta que sepas qué
  usan para la agenda.
- **Valoraciones, lista de espera y resumen semanal** — necesitan sus propias
  plantillas. Cuando el piloto esté vivo.
- **RLS, la web, el seguimiento de leads, RETA** — como tú dices.
- **Reescribir el router de 976 líneas** — funciona. Tócalo solo donde este
  plan te lo pide.

---

## Resumen de horas restantes

| Fase | Qué | Horas |
|---|---|---|
| 0 | Bot vivo + salida de error | 1-3 |
| 1 | Cambiar el modelo de IA + pruebas C y H | 12-20 |
| 2 | Arreglos baratos de alto impacto | 5-11 |
| 3 | Plantillas de WhatsApp | 10-18 |
| 4 | Legal y datos | 12-20 |
| 5 | Infraestructura que se cae sola | 2-5 |
| 6 | Operación de la clínica | 10-18 |
| 7 | Pruebas finales y firma | 6-10 |
| | **Total** | **58-105 h** |

A **8-9 h/semana** (tu ritmo real observado): **7-12 semanas**.
A **15 h/semana** sostenidas: **4-7 semanas**.

Las esperas externas no se suman si lanzas los trámites en paralelo. Y con la
corrección sobre la verificación de Meta, **la espera más larga probablemente
ya no está en tu camino crítico**: el que manda ahora es el dentista.
