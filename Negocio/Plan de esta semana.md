# Plan de la semana — 7 días desde que empieces

> Actualizado el 29 de agosto de 2026 con tus dos decisiones (no darte de alta
> en RETA hasta cobrar, y no contratar abogado) y con dos cosas nuevas que
> aparecieron al revisar los workflows.
>
> Los días van numerados, no con fecha. El plan empieza el día que lo empieces.

Objetivo: **tener el sí del dentista por escrito y todos los relojes que no
controlas puestos en marcha.**

---

## Primero, una corrección al objetivo

Dijiste "salir al mercado la semana que viene". Hay que separar dos cosas,
porque una depende de ti y la otra no:

| | ¿Esta semana? |
|---|---|
| Cerrar el acuerdo con el dentista | ✅ Sí, depende de vosotros dos |
| Meterte en la cola de Meta | ✅ Sí, y ahora sabemos que es gratis |
| Tener los papeles legales cerrados | ✅ Sí, y sin abogado |
| **Que el bot atienda pacientes reales** | ❌ **No. Y no es culpa tuya.** |

El último punto está bloqueado por la **verificación de negocio de Meta**, que
tarda de días a semanas y la decide un revisor de Meta, no tú. Hasta que la
apruebe, el bot **solo puede escribir a números dados de alta a mano**.

**Esto no es un problema si lo ordenas bien.** La demo funciona perfectamente
con tu número en la lista de prueba. El dentista puede decir que sí esta
semana. Lo único que no puedes acelerar es la cola de Meta — así que lo que
importa es **meterte en esa cola cuanto antes**.

> **Hay un atajo.** Si la clínica ya hace publicidad en Instagram o Facebook,
> su cuenta de Meta probablemente ya esté verificada, y el piloto puede
> arrancar con la suya en días en vez de semanas. Está explicado en
> `Negocio/Meta - todo lo que bloquea.md`, apartado 2. **Pregúntaselo en la
> demo.**

---

## Las dos vías

**Vía A — cosas con espera (arráncalas YA, aunque no estén perfectas)**
- Mensaje al dentista → su agenda manda
- Modelo 036 → gratis, y es lo que Meta te pide
- Verificación de Meta → de días a semanas
- Plantillas de WhatsApp → de minutos a 24 h, pero sin ellas no hay recordatorios

**Vía B — cosas que dependen solo de ti (se hacen en paralelo)**
- Pasar la batería de pruebas
- Arreglar lo que falle
- Rellenar los corchetes de los documentos legales

**Si un día solo tienes 30 minutos, gástalos en la Vía A.** Siempre.

---

## Día 1 (2 h)

**🔴 Mínimo innegociable: mandar el mensaje al dentista.** 15 minutos.

Está escrito y listo en `Negocio/Mensaje para el dentista.md`. Divídelo en 2-3
mensajes de WhatsApp. Que lo lea por la mañana.

No esperes a tener el bot perfecto. Su respuesta va a tardar días; el bot lo
arreglas mientras tanto.

- [ ] Mandar el mensaje al dentista
- [ ] Comprobar que tu número sigue en la lista de destinatarios de prueba de Meta
- [ ] Comprobar que el token de Meta no ha caducado
- [ ] Empezar batería de pruebas: **bloque C** (fechas y horas, pruebas C1 a C10)

## Día 2 (3 h)

**🔴 Mínimo innegociable: dar de alta las dos plantillas de WhatsApp.** 30 min.

Los textos exactos y la categoría están en
`Negocio/Meta - todo lo que bloquea.md`, apartado 3. **Sin esto, los
recordatorios y las valoraciones no funcionan con pacientes reales.** Se
aprueban solas en horas, pero si no las mandas hoy, no están el jueves.

- [ ] Dar de alta `recordatorio_cita_24h` y `solicitud_valoracion`
- [ ] Terminar **bloque C** (C11 a C20)
- [ ] **Bloque H** completo (derivaciones clínicas)
- [ ] Anotar los ❌ con la respuesta literal del bot
- [ ] Pasarme los fallos → yo los arreglo

> Los bloques C y H son donde ya sé que hay trampas. Si algo se va a romper
> delante del dentista, va a ser ahí.

## Día 3 (2-3 h)

**🔴 Mínimo innegociable: modelo 036. Es gratis y desbloquea Meta.**

Online, en la sede de la Agencia Tributaria. **No es el alta de autónomo**: no
lleva cuota, no es la Seguridad Social. Es solo decir que existes como
actividad, y es el documento que Meta te va a pedir para verificarte.

- [ ] Presentar el **modelo 036** y descargar el certificado de situación censal
- [ ] **Arrancar la verificación de negocio de Meta** con ese certificado
- [ ] Reimportar los workflows con los arreglos
- [ ] Reprobar solo lo que había fallado
- [ ] **Bloque B** (cómo escribe la gente de verdad) — es el 80 % de los mensajes reales

## Día 4 (2-3 h)

- [ ] **Generar el token permanente de Meta** (Usuario del Sistema, permisos
      `whatsapp_business_messaging` y `whatsapp_business_management`, caducidad
      **Nunca**). Pasos en `Negocio/Meta - todo lo que bloquea.md`, apartado 4.
      Se te caduca cada 24 h y es cuestión de tiempo que te reviente en mitad
      de una demo.
- [ ] **Bloque K**, sobre todo K11, K12 y **K13** (que no dé datos de otro paciente)
- [ ] Ensayar la demo entera de principio a fin, cronometrada. 15 minutos.
- [ ] Mirar cuánto cuesta un **número de prepago nuevo** para el piloto (ver abajo)

## Día 5 — día de la demo

(O el día que te diga el dentista; su agenda manda.)

Guion completo en `Negocio/Mensaje para el dentista.md`. Resumen:
1. Empieza por SU problema, no por tu producto
2. Reserva una cita en directo desde el móvil
3. Enseña la derivación urgente (quítale el miedo al "robot que da consejo médico")
4. Enseña el resumen semanal
5. **Y ahí** propones el piloto

- [ ] Hacer la demo
- [ ] **Preguntarle qué usan para la agenda** (papel, Google Calendar, software
      dental). Esta respuesta decide si hay que construir la sincronización.
- [ ] **Preguntarle si hacen publicidad en Instagram o Facebook.** Si su cuenta
      de Meta ya está verificada, el piloto puede arrancar en días.
- [ ] **Proponerle un número nuevo para el bot**, no el suyo de siempre. Es el
      argumento que le quita el miedo: su WhatsApp de siempre no se toca y
      puede apagar el bot cuando quiera. Explicado en `Meta - todo lo que
      bloquea.md`, apartado 1.
- [ ] Si dice que sí: mandarle un email ese mismo día confirmando lo acordado

> No hables de precio salvo que pregunte. Si pregunta: 249 €/mes es la tarifa,
> a él le propones 2 meses gratis y 149 € el primer año por ser el primero.

## Día 6 (2-3 h)

**Si hay sí (aunque sea verbal):**

- [ ] Mandarle el paquete legal (`Legal/01` y `Legal/02` rellenados) para que
      lo revise **su** asesor de protección de datos. Esa es tu revisión gratis.
- [ ] Empezar el piloto: número, calendario compartido, fila en `clinicas`
- [ ] **NO te des de alta en RETA todavía.** Los 2 meses de piloto son gratis,
      o sea que no hay factura. El RETA va justo antes de la primera factura.

**Si no hay respuesta todavía:**

- [ ] Seguir con la batería (bloques D, E, F, G)
- [ ] Mandar el recordatorio corto que tienes escrito, si van 4-5 días

## Día 7 (3-4 h)

- [ ] Rellenar **todos** los `[CORCHETES]` de `Legal/01` y `Legal/02`
- [ ] Completar el **Anexo II** del contrato de encargado: entrar en la web de
      cada proveedor (Supabase, n8n, Meta, Google, tu proveedor de IA) y apuntar
      dónde alojan los datos y qué mecanismo de transferencia usan. Es tedioso,
      es lo único que está a medias de todo el paquete, y es **lo primero que va
      a mirar el asesor de la clínica**.
- [ ] Pedir presupuesto de **seguro de responsabilidad civil profesional**.
      Sustituye al abogado en lo que de verdad importa y cuesta mucho menos.
- [ ] Terminar los bloques de pruebas que queden

---

## Reglas de la semana

**1. La Vía A antes que la Vía B, siempre.** El dentista y Meta tardan. Tú no.

**2. Nada de funciones nuevas.** El bot está terminado, probado y ya es
multi-clínica entero. Todo lo que añadas esta semana es tiempo que no dedicas a
vender. La tentación de seguir puliendo es real y es la forma más cómoda de no
salir nunca al mercado.

**3. Si el dentista no contesta en 4-5 días**, mándale el recordatorio corto que
tienes escrito. No insistas más de eso.

**4. Un fallo en la demo no es el fin.** Es un piloto. Si algo se rompe, lo
apuntas y lo arreglas. Por eso se llama piloto y no lanzamiento.

---

## Qué NO hacer esta semana

Está todo apuntado como pendiente, y **nada de esto bloquea al primer cliente**:

- ❌ La web. No convierte con cero testimonios y no te ayuda a cerrar a alguien
  que ya te conoce.
- ❌ Contratar abogado. Razones en `Negocio/Decisiones - autonomo y abogado.md`.
- ❌ Darte de alta en RETA. No hasta la primera factura.
- ❌ El workflow de seguimiento de leads. Se vende bien, pero no bloquea.
- ❌ Activar RLS. Innecesario con un solo cliente.
- ❌ La sincronización con la agenda de la clínica. Depende de qué te conteste
  el dentista el día 5. Construirla antes es adivinar.
- ⚠️ Cambiar el proveedor de IA **sí** hay que hacerlo, pero **antes de
  pacientes reales**, no antes de la demo. Como eso depende de Meta, tienes
  semanas. Semana 2.

---

## Cómo saber que la semana ha ido bien

No es "el bot funciona". Eso ya lo sabes. Es esto:

- [ ] El dentista ha visto la demo
- [ ] Tienes un sí o un no **claro** (un no también vale: te libera)
- [ ] Si es sí: lo tienes por escrito, aunque sea un email
- [ ] El modelo 036 está presentado
- [ ] La verificación de Meta está **enviada** (no aprobada — enviada)
- [ ] Las dos plantillas de WhatsApp están aprobadas
- [ ] El token permanente está puesto y el bot ya no se te cae solo
- [ ] Los bloques C, H, B y K de la batería están pasados

Si marcas esos ocho, la semana que viene solo tienes que esperar a Meta. Y
esperar no es trabajar: puedes usar ese tiempo para buscar la clínica número 2.
