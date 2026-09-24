# Plan de arreglos — de donde estás a un piloto con pacientes reales

> **Actualizado el 24 de septiembre de 2026.** El 15-sep se aplicó en los
> ficheros todo lo que se podía hacer sin entrar en tus cuentas. El 22-sep lo
> importaste en una instancia nueva de n8n y ejecutaste los SQL. El 24-sep lo
> **comprobé directamente** en tu n8n y tu Supabase: los Pasos 1 a 3 están
> hechos (ver la leyenda en el Paso 1).
>
> ⚠️ **Importado no es probado.** A 24-sep el bot no tiene **ninguna
> ejecución**: nadie le ha escrito desde que se importó. Lo siguiente es el
> Paso 4.
>
> **Copia de cómo estaba todo antes:** carpeta
> `backups/2026-09-15 - antes de los arreglos/` y etiqueta git
> `antes-arreglos-2026-09-15`.
>
> **Cómo convive con tus otros documentos:**
> - `Negocio/Plan de esta semana.md` → **el carril comercial** (dentista, 036,
>   Meta, demo). Tiene arriba las correcciones de orden.
> - **Este documento** → **el carril técnico**: qué queda y en qué orden.
> - `Pruebas/Bateria de mensajes.md` → cómo comprobar que funciona.
> - `Operacion/` → guías para la clínica y el runbook para ti.
>
> **Alcance elegido: A (mínimo legal y seguro).** Reservar, modificar,
> cancelar, derivar, recordar y email diario. **Sin** valoraciones, **sin**
> resumen semanal por ahora.

---

## En 30 segundos

- **Hecho en el repositorio:** todo el código de las fases 0, 2, 3 y 6, el
  cambio de modelo de IA, lo técnico y documental de la fase 4 y el runbook.
  Además, cinco arreglos que no estaban en el plan (abajo).
- **Hecho en tus cuentas (comprobado el 24-sep):** SQL 06 y 07, los 7
  workflows importados, credenciales enlazadas, Error Workflow en todos,
  avisos por email y 01, 04, 06 y 07 activos.
- **Probado:** el código de los nodos, con un simulador (63 comprobaciones) y
  78 casos del detector clínico. **Sin probar:** el bot de verdad por WhatsApp
  (cero ejecuciones a 24-sep).
- **Te queda: unas 18-35 h**, casi todo probar y ajustar el prompt, más los
  trámites con tus cuentas. A tu ritmo real (8-9 h/semana), **3-5 semanas**,
  sin contar esperas externas.
- **Por dónde empezar:** el **Paso 4**. Escribe al bot.

---

## 👉 Lo que te toca a ti, en este orden

> **Estado real comprobado el 24-sep** (con acceso directo a tu n8n y a tu
> Supabase). Leyenda:
> - `[x] ✅` hecho y **comprobado en tu cuenta**.
> - `[x] ✅ (repo)` hecho en los ficheros; en tu cuenta no aplica o no se puede ver.
> - `[ ]` pendiente.
> - `[ ] ❓` puede que esté hecho, pero no lo puedo comprobar desde aquí.

### Paso 1 — Supabase (20 min) — ✅ casi terminado

- [x] ✅ SQL Editor → ejecuta `Automatizaciones Supabase/06 - pacientes-y-cumplimiento.sql`.
      *(Comprobado el 24-sep: existen `pacientes` y `envios_fallidos`, y `derivaciones.token_cierre`.)*
- [ ] ❓ **Comprueba la credencial de Supabase en n8n antes del siguiente punto.**
      n8n → Credentials → `Supabase account` → el campo **Service Role Secret**
      tiene que llevar la clave que en Supabase sale como
      *Settings → API → service_role*, **no** la `anon public`.
      *(La credencial existe, pero n8n no deja ver su contenido. Con la `anon`
      el bot no vería nada por culpa de la RLS: lo sabrás en la primera prueba.)*
- [x] ✅ SQL Editor → ejecuta `Automatizaciones Supabase/07 - multi-clinica-estricto.sql`.
      *(Comprobado el 24-sep: RLS activa en las 9 tablas, `clinica_id` obligatorio
      y sin valor por defecto, y `envios_fallidos.clinica_id` creado.)*
      Cierra los tres huecos multi-clínica de la auditoría del 21-sep: activa RLS
      en las seis tablas que seguían abiertas, quita el valor por defecto de
      `clinica_id` y añade `clinica_id` a `envios_fallidos`.
      Lee su **apartado 0** antes de pulsar RUN, y ten a mano el apartado 4, que
      es el comando para deshacerlo si algo se rompe.
- [ ] Si la clínica ya tiene política de privacidad web:
      `update clinicas set url_privacidad = 'https://...' where id = '...';`
      (Para probar, déjala vacía o pon cualquier dirección.)
      *(24-sep: sigue vacía. Para las pruebas no importa; antes de un paciente real, sí.)*

### Paso 2 — Groq (15-30 min) — 🟡 falta probar

> Decidido el 15-sep: se sigue con **Groq gratis** en lugar de Mistral. Modelo
> `openai/gpt-oss-120b` y, de reserva, `openai/gpt-oss-20b`.

- [x] ✅ [console.groq.com](https://console.groq.com) → API Keys → crea una key
      (gratis, sin tarjeta).
- [ ] ❓ Settings → **Data Controls** → activa **Zero Data Retention**.
      *(No tengo acceso a Groq. Compruébalo tú: es obligatorio antes de datos reales.)*
- [x] ✅ n8n → Credentials → New → **Groq** → nombre exacto `Groq account`.
      *(Comprobado el 24-sep: existe y está puesta en los dos nodos de Groq del 01.)*
- [x] ✅ Importa `Automatizaciones Supabase/Clinica Dental - 01 WhatsApp citas
      (Supabase).json` **encima** de tu workflow 01. Lleva tus identificadores
      de credencial reales; solo hay que elegir `Groq account` en los dos nodos
      de Groq.

      > **Ojo, cambió la ruta el 21-sep.** Este fichero estaba en
      > `Automatizacion n8n - Conectado/`, al lado de una copia vieja que era
      > muy fácil importar por error. Esa carpeta ya no existe: los siete
      > workflows viven **solo** en `Automatizaciones Supabase/` y todos usan
      > los mismos identificadores de credencial. Lo archivado está en
      > `backups/2026-09-16 - export de n8n (credenciales reales)/`.
      **Actualizado el 16-sep** con el filtro de ámbito (el bot escribía páginas
      web y se disculpaba en inglés). Si ya lo habías importado, vuelve a
      importarlo: el cambio está en `Normalizar y enrutar` y en el prompt.
      *(Comprobado el 24-sep: el 01 de n8n es **idéntico** al del repo en el código
      de los 107 nodos y en las conexiones, filtro de ámbito incluido.)*
- [ ] Después de importar, pasa el **bloque P** de la batería (P1 a P5 son las
      que se rompían).
- [ ] Antes del primer paciente real: acepta el DPA de Groq y guárdalo en PDF.

### Paso 3 — n8n: importar (1-3 h) — ✅ terminado

- [x] ✅ **Descarga primero** los workflows que tienes ahora en n8n (⋯ →
      Download) y guárdalos en `backups/` con la fecha.
      *(Montaste una instancia nueva de n8n el 22-sep, así que no había nada que guardar.)*
- [x] ✅ **Importa encima** de los que ya tienes, no como nuevos: abre el workflow
      → ⋯ → Import from File. Así conservas el Error Workflow y el webhook de
      WhatsApp. Hazlo con el 01, el 02, el 03 y el 04.
      *(Comprobado el 24-sep: los 7 workflows están en `bitclap0.app.n8n.cloud`.)*
- [x] ✅ Importa como nuevos el **06** y el **07**.
- [x] ✅ En cada workflow, revisa que no haya nodos con aviso rojo de credencial:
      `Groq account`, `WhatsApp account` (una sola para todos),
      `Supabase account`, Google Calendar y `Gmail account`.
      *(Comprobado el 24-sep: una credencial por servicio, todas enlazadas.)*
- [x] ✅ Settings → Error Workflow = 04 en el 01, 02, 03, 05, 06 y 07.
      *(Comprobado el 24-sep en los seis.)*
- [x] ✅ En el 04, nodo `Decidir si avisar`: escribe tu correo en `EMAIL_AVISOS`.
      *(24-sep: puesto y publicado en n8n = `prueb4sn8n.pruebas@gmail.com`, por
      decisión tuya. En el fichero del repo se queda **vacío a propósito** para no
      subir un correo a GitHub: si reimportas el 04, vuelve a ponerlo.)*
- [x] ✅ **Activa el 07** y el **01**. El 02 y el 06, cuando pases el Paso 4. El
      03 y el 05 se quedan **desactivados**.
      *(24-sep: activos el 01, el 04, el 06 y el 07. El 06 se activó antes del
      Paso 4 por decisión tuya: solo manda correos a la dirección de prueba.
      El 02, el 03 y el 05 siguen apagados.)*

> **Si al importar algo se queja** (por ejemplo, el desplegable del modelo de
> Groq o el de la plantilla en blanco), vuelve a elegirlo a mano en el nodo.
> Los parámetros están comprobados contra el código fuente de n8n, pero no he
> podido importarlos en tu cuenta.

### Paso 4 — Lo básico funciona (1-2 h, más lo que haya que retocar)

- [ ] `README` de las automatizaciones, Paso 7, puntos 1 a 6 y 10 a 13.
- [ ] Batería, bloques **N** y **O1**: aviso de primer contacto, bajas e IA caída.
- [ ] Si algo falla, apunta el código de la prueba y la respuesta literal.

### Paso 5 — Meta, Google y Supabase (1-2 h + esperas)

- [ ] **Plantilla** `recordatorio_cita_24h`: categoría Utilidad, idioma
      *Spanish*, **sin botones**. Texto en `Negocio/Meta - todo lo que bloquea.md`,
      apartado 3. La aprobación corre sola mientras haces otra cosa.
- [ ] **Token permanente** de Meta, pegado en la credencial `WhatsApp account`.
- [ ] **Google Cloud** → pantalla de consentimiento OAuth → publicar la app
      (*In production*). Si sigue en *Testing*, Calendar y Gmail caducan cada 7
      días.
- [ ] **Supabase Pro** (25 $/mes) antes del primer paciente real: copias diarias
      y sin pausa. Sin esto, el Anexo I del contrato miente.
- [x] ✅ Borra la credencial vieja `WhatsApp account 15` cuando todo funcione.
      *(Comprobado el 24-sep: en la instancia nueva ya no existe.)*

### Paso 6 — Batería completa y ajuste del prompt (9-16 h)

- [ ] Bloques **C y H** primero (fechas y derivaciones): el prompt de 13.583
      caracteres estaba afinado para Llama 3.3 y gpt-oss no se comporta igual.
      **No lo reescribas**: corrige solo lo que falle.
- [ ] Bloques **B, K y M**. K13 desde otro número.
- [ ] **O2**: recordatorio a un número que lleve más de 24 h sin escribir (con la
      plantilla ya aprobada).
- [ ] **O3 a O7**.

### Paso 7 — Antes del primer paciente real

- [ ] **Número real + método de pago** en Meta (esto es lo que saca del modo
      prueba, no la verificación).
- [ ] Rellenar los `[CORCHETES]` de `Legal/01` y `Legal/02`. Guardar los DPA en PDF.
- [ ] Decidir Google: Workspace (unos 7 €/mes) o el calendario y el correo de la
      clínica. Con Gmail gratuito la fila de Google del Anexo II no se sostiene.
- [ ] Dar a la clínica `Legal/06` (apartado 3), `Legal/07` (EIPD) y las dos guías
      de `Operacion/`, con los corchetes rellenos.
- [ ] **Firmar** acuerdo de piloto + `Legal/01`. Aunque el piloto sea gratis:
      tratar datos de un paciente real activa el artículo 28 desde el primer
      mensaje.
- [ ] En la demo: **preguntar cómo llevan hoy la agenda.** Decide si hace falta
      la sincronización.

---

## Detalle por fases (lo que había en el plan, con su estado)

### FASE 0 — Bot vivo y salida de error
- [x] ✅ **Salida de error del `AI Agent` conectada.** `Respuesta emergencia IA`
  manda al paciente *"ahora mismo no puedo atenderte por aquí. Llama a la
  clínica al..."* y `Aviso fallo IA` hace fallar la ejecución a propósito para
  que salte el workflow 04. `retryOnFail`: 2 intentos, 3 s.
- [ ] (Opcional) Escribir al bot viejo para confirmar que está muerto.

### FASE 1 — Modelo de IA
- [x] ✅ **Proveedor: Groq gratis** (decidido por ti el 15-sep, en lugar de
  Mistral): `openai/gpt-oss-120b`, con `openai/gpt-oss-20b` como modelo de
  reserva (cada uno tiene su propio cupo). Límite gratuito: 8.000 tokens por
  minuto y 200.000 al día por modelo. Para caber: máximo de respuesta en 2.000
  tokens (con el valor por defecto, Groq rechaza todo) y memoria en 8
  mensajes. Temperatura 0,5.
- [x] ✅ **Dos cambios mínimos de prompt:** se identifica como IA y consulta
  las citas por teléfono, sin pedir nombre.
- [ ] **Reajustar el prompt con la batería** → Paso 6.
- [x] ✅ **Credencial de Groq** en n8n (comprobado el 24-sep).
- [ ] ❓ **Zero Data Retention** en Groq → Paso 2.

### FASE 2 — Arreglos baratos de alto impacto
- [x] ✅ **Fallback por nombre eliminado** en `Resolver cita cancelacion`,
  `Resolver cita modificacion` y `Resolver consulta cita`. Si no coincide el
  teléfono: *"No encuentro ninguna cita confirmada a este número..."*. Además,
  `Buscar cita informativa` ya solo trae citas de ese teléfono: antes cargaba
  las de toda la clínica y quedaban guardadas en el historial de n8n.
- [x] ✅ **Detector clínico reescrito** con palabras completas. Comprobado
  ejecutando el código viejo y el nuevo: de 12 frases normales, antes derivaban
  11; ahora 0. De 8 frases con síntomas, antes se escapaba 1; ahora ninguna.
  "caries" sola ya no deriva. Nombres trampa en la batería, bloque M.
- [x] ✅ **Una reserva ya no cancela otras citas.** Mismo día y mismo nombre:
  no reserva y pregunta. Otro día: reserva y le recuerda la otra cita.
- [x] ✅ **Teléfono en el evento de Calendar**, al reservar y al modificar.

### FASE 3 — Plantillas de WhatsApp
- [ ] **Dar de alta `recordatorio_cita_24h`** → Paso 5.
- [x] ✅ **Workflow 02 cambiado a `Send Template`.** Nombre e idioma en dos
  constantes al principio de `Preparar recordatorios`.
- [ ] **Respuestas de botón:** aplazado a propósito. La plantilla va sin botones.
- [x] ✅ **Fallos de entrega registrados** en la tabla `envios_fallidos`
  (callbacks `failed`). Solo se registran: avisar desde ahí podría reabrir el
  bucle del 08/08.
- [x] ✅ **Envío del 02 que no aborta el lote.** Mejor que el
  `continueRegularOutput` que proponía el plan: con aquel, un envío fallido se
  habría marcado como enviado. Ahora los rechazados **no** se marcan y al final
  la ejecución falla para que te avise el 04. Lo mismo en el 03.

### FASE 4 — Legal y datos
- [x] ✅ **Tabla `pacientes`** (en `06 - pacientes-y-cumplimiento.sql`, con RLS
  activada) → ejecutarla en el Paso 1.
- [x] ✅ **Aviso de primer contacto** (art. 50 RIA + RGPD), mensaje aparte con
  la fecha en `pacientes.informado_rgpd_en`.
- [x] ✅ **"Suenas humana" fuera.** Ahora admite siempre que es una IA (K7).
- [x] ✅ **Opt-out:** `BAJA`, `stop`, `no me escribas más`... → `opt_out`; `ALTA`
  lo deshace; el 02 y el 03 excluyen las bajas. *"Tengo la baja médica"* ya
  **no** cuenta. *"Borrad mis datos"* se deriva a la clínica como solicitud RGPD.
- [x] ✅ **Mensaje de derivación** con "no puedo darte consejo médico" y el 112,
  también en la confirmación de reservas que traen un síntoma.
- [x] ✅ **Anexo II relleno** con datos verificados, más cláusula 5 bis sobre IA
  en `Legal/01`. Pendiente tuyo: DPAs en PDF y la decisión de Google → Paso 7.
- [x] ✅ **Anexo I corregido**, con aviso de que las copias solo son verdad con
  Supabase Pro.
- [x] ✅ **Borrador de EIPD**: `Legal/07 - Borrador EIPD para la clinica.md`.

### FASE 5 — Infraestructura que se cae sola
- [x] ✅ **Credenciales unificadas**: una de WhatsApp y una de Gmail para los
  siete workflows. Ya también en tu n8n (comprobado el 24-sep).
- [ ] **Token permanente de Meta** → Paso 5.
- [ ] **OAuth de Google en producción** → Paso 5.
- [ ] **Supabase Pro** → Paso 5.

### FASE 6 — Que la clínica trabaje sin llamarte
- [x] ✅ **Botón "Marcar como atendida"**: workflow 07, en dos clics para que el
  antivirus del correo no la cierre solo.
- [x] ✅ **Email diario "Hoy"** a las 8:00, de lunes a sábado: workflow 06. No
  incluye el detalle clínico.
- [x] ✅ **Guía para recepción**: `Operacion/Guia para recepcion.md`.
- [x] ✅ **Guía para el dentista**: `Operacion/Guia para el dentista.md`.
- [ ] **Preguntar en la demo cómo llevan la agenda** → Paso 7.

### FASE 7 — Antes del primer paciente real
- [x] ✅ **Runbook**: `Operacion/Runbook - que hacer si algo falla.md`.
- [ ] Batería completa, K13, recordatorio a más de 24 h, credencial de IA rota,
  número real + pago, firma → Pasos 4 a 7.

### Arreglos que no estaban en el plan
- [x] ✅ **Recordatorios duplicados con 2 clínicas:** la consulta de citas del
  02 y del 03 se ejecutaba una vez por clínica. Arreglado con `executeOnce`.
- [x] ✅ **Avisos de error también por email** (workflow 04, `EMAIL_AVISOS`).
- [x] ✅ **README, paso 8:** decía que un fallo con "Execute workflow" manda
  aviso. No es así en n8n; corregido.
- [x] ✅ **Siete notas del workflow 01** que ya no eran verdad (Groq, "pestaña
  de Google Sheet", "cancela las citas antiguas", un "workflow 04 de
  seguimiento de leads" que no existe).
- [x] ✅ **Numeración de `Legal/`**: los documentos se citaban como 06 y 07 cuando
  eran 05 y 06.

### 🆕 Problemas nuevos encontrados el 24-sep

- [ ] **Los avisos de error y el email diario van al mismo buzón**
  (`prueb4sn8n.pruebas@gmail.com`). Para las pruebas vale. Con una clínica real,
  **los avisos tienen que ir a un correo tuyo**, no al de la clínica: son fallos
  técnicos. Se cambia en el 04, `EMAIL_AVISOS`.
- [ ] **El fichero del 04 en el repo no lleva el correo** y el de n8n sí. Es a
  propósito (no se sube un email a GitHub), pero si reimportas el 04 desde el
  repo, los avisos por email dejan de salir hasta que lo vuelvas a poner.
- [ ] **`url_privacidad` vacía** en la clínica de prueba. El aviso de primer
  contacto sale sin enlace a la política. Antes de un paciente real → Paso 7.
- [ ] ❓ **La credencial `Supabase account` no se puede comprobar desde fuera.**
  Si lleva la clave `anon` en vez de `service_role`, el bot fallará en su primer
  mensaje por la RLS. La primera prueba del Paso 4 lo dirá.
- [x] ✅ **Error mío durante la revisión, ya corregido:** al editar el 06 envié
  un texto de relleno en lugar del código del nodo `Construir email diario`. Lo
  restauré en el momento y el historial de n8n confirma que quedó **idéntico** a
  antes. El 06 estaba apagado, así que no afectó a nada.

---

## Lo que NO vas a hacer todavía

- **Multi-dentista / varias agendas** (35-55 h), solo cuando una clínica lo pida
  y lo pague.
- **Sincronización Calendar → Supabase**, hasta saber qué usan para la agenda.
- **Valoraciones y resumen semanal**: el 03 y el 05 se quedan apagados.
- **Botones en las plantillas**, hasta después del piloto.
- **La web, el seguimiento de leads, RETA.**
  *(La RLS en las tablas antiguas ya no está aquí: se hizo el 22-sep con el SQL 07.)*
- **Reescribir el router**: funciona. Tócalo solo donde falle la batería.

---

## Horas restantes

| Paso | Qué | Horas |
|---|---|---|
| 1 | Supabase: SQL 06 y 07 | ✅ hecho |
| 2 | Groq: key, credencial e importar (falta ZDR y bloque P) | ✅ casi, 0,5 |
| 3 | Importar y configurar en n8n | ✅ hecho |
| 4 | Pruebas básicas + retoques | 2-6 |
| 5 | Meta, Google, Supabase Pro | 1-2 |
| 6 | Batería con gpt-oss + ajuste del prompt | 9-16 |
| 7 | Legal, firma y demo | 5-10 |
| | **Total restante (24-sep)** | **~18-35 h** |

A **8-9 h/semana** (tu ritmo observado): **3-5 semanas**.
A **15 h/semana**: **2-3 semanas**.

El rango es ancho por dos incógnitas que no se pueden conocer sin probar: cuánto
se desvía gpt-oss del prompt afinado para Llama (Paso 6) y qué pide retocar la
importación (Paso 4). Las esperas externas (aprobación de la plantilla, el
dentista) van aparte, pero corren en paralelo si las lanzas pronto.

---

## Lo que no he podido comprobar (para que no te pille por sorpresa)

1. ✅ ~~**Nada se ha importado en n8n.**~~ Resuelto: importado el 22-sep sin
   retoques y comprobado el 24-sep. Pero **ningún workflow se ha ejecutado
   todavía**: los nodos de Supabase, Calendar, WhatsApp y Groq no se han probado
   de verdad.
2. **El simulador solo prueba los nodos Code**, que es donde estaban los fallos.
   Los nodos de Supabase, Calendar y WhatsApp solo se prueban en n8n.
3. **El prompt con gpt-oss no está probado.** Es la parte con más riesgo y más
   horas.
4. **El enlace del botón** usa la dirección de tu n8n que da la propia ejecución
   (`$execution.resumeUrl`). En n8n Cloud debería ser correcta. Si sale mal,
   hay una constante `URL_N8N_MANUAL` en los tres nodos que la usan.
5. **El límite gratuito de Groq**: 8.000 tokens por minuto por modelo. Con el
   prompt cacheado y el modelo de reserva da para probar y para la demo, **no
   para una clínica con pacientes**. Si en las pruebas ves a menudo el mensaje
   de emergencia (error 429 o 413 en la ejecución), es esto. La salida es el
   pago por uso de Groq: menos de 1 $ al mes por clínica.
