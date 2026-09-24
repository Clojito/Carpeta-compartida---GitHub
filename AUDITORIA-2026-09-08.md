# Auditoría bitclap.es — 8 de septiembre de 2026
### · Revisada contra el código el 9 de septiembre ·

> ## 📋 SEGUIMIENTO A 24 DE SEPTIEMBRE — qué está resuelto de esta auditoría
>
> El texto original de la auditoría se conserva debajo tal cual. Cada hallazgo
> lleva ahora su estado en el título. Comprobado el 24-sep **directamente en tu
> n8n y tu Supabase**, no solo en los ficheros.
>
> **Leyenda:** ✅ resuelto · 🟡 a medias · 🔴 sigue abierto
>
> | # | Hallazgo | Estado | Qué falta |
> |---|---|---|---|
> | 3.1 | El bot no responde | ✅ Resuelto | Nada. Modelo nuevo (Groq gpt-oss) y salida de error conectada. Respondió el 16-sep |
> | 3.2 | Recordatorios sin plantilla | 🟡 A medias | El 02 ya usa plantilla. Falta **darla de alta en Meta**. El 03 sigue con texto libre (fuera del piloto) |
> | 3.3 | Fuga de identidad | ✅ Resuelto | Nada. Solo por teléfono |
> | 3.4 | Detector clínico | ✅ Resuelto | Nada. De 11/12 falsas derivaciones a 0 |
> | 3.5 | Sin entidad paciente ni opt-out | ✅ Resuelto | Nada. Tabla `pacientes` creada en Supabase y BAJA/ALTA en el bot |
> | 3.6 | No dice que es una IA | ✅ Resuelto | Probarlo con la batería (N1, N6). Falta `url_privacidad` para el enlace |
> | 3.7 | Contrato no firmable | 🟡 A medias | Anexo II relleno. Faltan corchetes, DPAs en PDF y firma |
> | 3.8 | Sin backups reales | 🔴 Abierto | Supabase Pro (25 $/mes) antes del primer paciente |
> | 4 | Token de Meta que caduca / dos credenciales | 🟡 A medias | Credenciales unificadas ✅. Falta el **token permanente** |
> | 4 | OAuth de Google en "Testing" | 🔴 Abierto | Publicar la app en Google Cloud |
> | 4 | Una reserva cancela otras citas | ✅ Resuelto | — |
> | 4 | Evento sin teléfono | ✅ Resuelto | — |
> | 4 | La clínica no puede cerrar derivaciones | ✅ Resuelto | Workflow 07, activo |
> | 4 | La clínica no ve lista de espera ni leads | ✅ Resuelto | Workflow 06 (email diario), activo desde el 24-sep |
> | 4 | Derivación sin el 112 | ✅ Resuelto | — |
> | 4 | Migrar el número es irreversible | 🔴 Abierto | Decisión antes de la demo: número nuevo (recomendado) |
> | 4 | Precios venden cosas que no existen | 🔴 Abierto | Corregir `Clínica+` en `Negocio/Precios y planes.md` |
> | 4 | Ejecuciones extra por callbacks | 🔴 Abierto | Vigilar el contador de n8n en el piloto |
> | 6 | Multi-clínica | ✅ Resuelto | RLS en las 9 tablas y `clinica_id` obligatorio (SQL 07, 22-sep) |
>
> **Nuevo desde la auditoría:** el bot se salía del papel (escribía HTML, sumaba
> y se disculpaba en inglés) → ✅ resuelto el 16-sep con un filtro en el código.
> Los problemas nuevos del 24-sep están en
> [PLAN-DE-ARREGLOS.md](./PLAN-DE-ARREGLOS.md), apartado "Problemas nuevos".

> ## ✅ ACTUALIZACIÓN 15 DE SEPTIEMBRE — arreglado en los ficheros
>
> Los 5 bloqueantes que quedaban el 9-sep (modelo de IA, salida de error, fuga
> de identidad, detector clínico y plantillas) y casi todo el plan están
> **aplicados en los ficheros del repositorio**. ✅ *(24-sep: ya también en tu
> n8n, importados el 22-sep. Falta probarlos.)* Qué está hecho y qué te toca a ti, en
> [PLAN-DE-ARREGLOS.md](./PLAN-DE-ARREGLOS.md).
>
> **Una corrección a esta auditoría, comprobada ejecutando el código viejo:**
> en la sección 3.4, "después" **no** disparaba la derivación (no contiene
> "pus"). El resto de ejemplos sí, y el problema era mayor de lo que decía: de
> 12 frases normales de prueba, el detector viejo derivaba **11** (incluidas
> "quiero una cita para mirarme una caries", "I live in Spain" y "tuve un
> accidente de coche y no puedo ir a mi cita"). Con el detector nuevo, 0, y
> detecta los 8 síntomas de prueba (el viejo no detectaba "toothache").

> ## ⚠️ ESTADO A 9 DE SEPTIEMBRE — LEE ESTO PRIMERO
>
> Anoche subiste el trabajo que habías hecho en el PC de casa (commit
> `main2`, 8-sep 23:39, con documentos fechados el 29 de agosto). He
> revisado **el código, no los documentos**, para ver qué está arreglado de
> verdad. Resultado:
>
> **✅ Arreglado y verificado en el código:**
> - **Workflows 02 y 03 son multi-clínica de verdad.** Cargan la tabla
>   `clinicas`, cruzan por `clinica_id`, el `phoneNumberId` sale de la
>   configuración y cada cita se evalúa en la zona horaria de su clínica.
>   Bien hecho, y los comentarios del código explican el porqué.
> - **Workflow 04**: el número de avisos ya sale de configuración.
> - **Contrato de encargado**: la cláusula 7 ya tiene límite real de
>   responsabilidad (12 meses facturados, excluido el lucro cesante),
>   alineada con el contrato de servicios. Era un hueco real y está cerrado.
> - **Batería de pruebas creada** (`Pruebas/Bateria de mensajes.md`): 12
>   bloques y 5 trampas documentadas. Cubre buena parte de lo que pedía la
>   Fase 3 del plan. La trampa T3 que apuntaste ahí es, además, el mismo
>   fallo que yo encontré en el detector clínico.
>
> **🔴 Sigue exactamente igual (verificado línea a línea):**
> - **El modelo de IA sigue siendo `llama-3.3-70b-versatile` en `lmChatGroq`.**
>   Es el modelo que Groq apagó el 16 de agosto. **El bot sigue muerto.**
> - **La salida de error del `AI Agent` sigue desconectada** (solo existe
>   `AI Agent -> [0] -> Normalizar y enrutar`). Por eso no te has enterado.
> - **La fuga de identidad sigue ahí**: `conTelefono[0] || conNombre[0] || null`.
> - **El detector clínico sigue comparando subcadenas** (`valor.includes(termino)`
>   con `'dor'`, `'doi'`, `'pus'`, `'pain'`, `'tomo '` en la lista).
> - **Las plantillas de WhatsApp siguen sin existir** (0 usos de `sendTemplate`
>   en 02 y 03) — pero ya tienes los textos redactados y listos para darlos
>   de alta, que era la parte que costaba decidir.
>
> **📌 Dos correcciones a tus documentos nuevos** — ver la sección 0.
>
> Efecto en el plan: **quedan 5 bloqueantes de los 8**, y el trabajo total
> baja de 78-133 h a **unas 60-105 h**. Detalle en
> [PLAN-DE-ARREGLOS.md](./PLAN-DE-ARREGLOS.md).

---

## 0. Dos cosas de tus documentos nuevos que conviene corregir

### 0.1 — La verificación de Meta **no** bloquea escribir a pacientes reales

Tu `ESTADO-DEL-PROYECTO.md` y `Negocio/Plan de esta semana.md` dicen que
hasta que Meta apruebe la verificación *"el bot solo puede escribir a números
dados de alta a mano"*. **Eso describe el número de prueba, no la
verificación.**

Verificado con varias fuentes independientes: una cuenta **sin verificar**
puede enviar a **250 destinatarios únicos cada 24 horas** y responder sin
límite dentro de la ventana, con un tope de 2 números de teléfono. La
verificación sube ese tope a 2.000/24 h y a 20 números.

Una clínica de 150 citas al mes son **unos 5 pacientes distintos al día**.
Estás 50 veces por debajo del límite sin verificar.

Lo que de verdad te tiene atado hoy es que usas el **número de prueba de
Meta** (máximo 5 destinatarios). Para salir de ahí necesitas: **un número
real + un método de pago en la cuenta**. Ninguna de las dos cosas exige la
verificación.

**Por qué importa:** tu plan de la semana da por hecho que hay que esperar
semanas a Meta antes de tener pacientes reales, y ordena las tareas alrededor
de esa espera. Si esto se confirma en tu cuenta, **el piloto puede arrancar
sin esperar la verificación**. Arráncala igual (la necesitas para la clínica
2 y para el nombre visible), pero deja de tratarla como el cuello de botella.

*Confianza: alta en el límite de 250/24 h; media en si el nombre visible
aprobado exige verificación previa. Compruébalo en tu propia cuenta antes de
prometerle fechas al dentista.*

### 0.2 — "El bot está terminado y probado" ya no es cierto

La regla 2 de `Plan de esta semana.md` dice: *"El bot está terminado, probado
y ya es multi-clínica entero. Nada de funciones nuevas."*

La segunda mitad es buen consejo y la mantengo. La primera no se sostiene:
el modelo de IA está apagado desde el 16 de agosto, y hay tres fallos serios
sin tocar. **No son funciones nuevas — son reparaciones**, y la regla "nada
de funciones nuevas" no debería usarse para aplazarlas.

Ligado a esto, tu plan sitúa el cambio de proveedor de IA en *"Semana 2, no
antes de la demo"*. **Ese orden ya no funciona: sin cambiar el modelo no hay
demo que enseñar.** Es la primera tarea de ordenador, no la última.

---

> **Qué es esto.** Auditoría completa: 9 agentes especializados (técnica,
> IA, datos, legal, Meta/WhatsApp, negocio, multi-dentista, operaciones) +
> un verificador adversarial independiente para cada uno + refutación
> específica de cada hallazgo bloqueante + 3 rondas más para cubrir huecos
> (operación diaria de la clínica, modelo económico real, ruta crítica
> deduplicada). 217 hallazgos revisados, 178 hechos contrastados con fuente.
> Nota de transparencia: los dos últimos agentes (que iban a dar una
> estimación de tiempo final) fallaron por límite de créditos de la sesión;
> la estimación de la sección 2 la hago yo mismo a partir de lo que sí
> completó el agente de "ruta crítica", que ya había hecho casi ese mismo
> trabajo.
>
> Metodología: no pude acceder directamente a developers.facebook.com ni a
> facebook.com/business/help (fallo de red en la sesión), así que los datos
> de Meta vienen de fuentes secundarias (BSPs, guías) que replican su
> documentación — están marcados como confianza media donde corresponde.
> Todo lo demás sale de leer el código, los SQL y los documentos, línea a
> línea, con cita.

---

## 1. Veredicto en una frase

**No tienes "un prototipo terminado esperando cliente": tienes un prototipo
que probablemente lleva tres semanas sin funcionar y no lo sabes.** El
modelo de IA que usa el bot (`llama-3.3-70b-versatile` en Groq) fue retirado
por Groq el **16 de agosto**, dos días después de tu último commit. Desde
entonces, cualquier mensaje que llegue al bot probablemente cae en un
silencio total — ni el paciente recibe respuesta ni tú recibes aviso, porque
la salida de error del nodo de IA está desconectada. Antes de leer nada más
de este documento: **abre n8n y mándale un mensaje al bot ahora mismo.**

Descontando esa sorpresa, el veredicto de fondo no cambia mucho respecto a lo
que ya intuías: arquitectura multi-clínica bien pensada, prompt y router
sobrecargados de parches pero funcionales, y una distancia real entre
"funciona conmigo probando" y "vendible a un extraño" que se concentra en
cuatro sitios muy concretos — la ventana de 24h de WhatsApp, dos obligaciones
legales que ya están en vigor y no cumples, la identidad del paciente, y una
hoja de precios que promete funciones que no existen.

---

## 2. Cuánto te queda — estimación con ritmo real, no ideal

El propio repositorio da el dato que hace falta para no vivir de ilusiones:
**8 commits entre el 30-jul y el 14-ago (2026), y ninguno desde entonces —
25 días a día de hoy.** Eso no son "3 h/día constantes": son ~50 horas
comprimidas en una ráfaga de 16 días (tres commits de madrugada, 02:24–02:50)
seguidas de una parada total. El ritmo *observado* son unas **8-9 h/semana
efectivas**, no las 21 h/semana que darían 3 h/día todos los días.

### Tres alcances de piloto posibles

No hace falta arreglar los 217 hallazgos para tener un piloto legal y
funcional. Hay tres alcances razonables:

| Alcance | Qué incluye | Horas de ordenador | + trámites |
|---|---|---|---|
| **A — Mínimo legal y seguro** | Reservar/modificar/cancelar + derivación segura + recordatorio (con plantilla). **Sin** valoraciones, **sin** lista de espera, **sin** resumen semanal | **70–110 h** | 8–14 h |
| **B — Todo lo que hay hoy, arreglado** | A + valoraciones + lista de espera + resumen semanal, todo funcionando de verdad | 100–155 h | 8–14 h |
| **C — B + agenda real** | B + sincronización Calendar→Supabase + capacidad por sillón | 115–180 h | 8–14 h |

**Mi recomendación: alcance A.** Ninguna de las tres cosas que se recortan
(valoraciones, lista de espera, resumen semanal) es lo que hace que un
dentista firme; las tres funcionan hoy con texto libre fuera de la ventana de
24h de Meta, así que "tenerlas" ahora mismo es una  ilusión, no una ventaja.

### Con el ritmo real, ¿cuándo?

| Ritmo | Primer paciente real | Con alcance A |
|---|---|---|
| 21 h/semana sostenidas (3h/día *todos* los días) | 20 oct – 3 nov 2026 | el más optimista |
| 10 h/semana constantes | 27 oct – 24 nov 2026 | razonable |
| **Ritmo real observado (~8-9 h/semana, a ráfagas)** | **10 nov – mediados de dic 2026** | **el más probable — con riesgo de irse a enero por las fiestas** |

**La primera factura** no la fija la técnica, la fija tu propia propuesta:
"2 meses gratis" significa que, tal como está escrita hoy, no hay ingreso
antes de **enero-marzo de 2027**. Si acortas el piloto a 4-6 semanas, la
factura se adelanta a noviembre-diciembre de 2026.

**Probabilidad de tener un paciente real antes del 31-12-2026** (criterio
propio, no una cifra de laboratorio): **50-60% si consigues una fecha
comprometida con el dentista en las próximas 3 semanas; 25-35% si no la
consigues.** La palanca que más mueve esta probabilidad no es técnica: es
tener un ancla externa (una fecha con alguien más) que sostenga el ritmo
cuando venga la siguiente racha de "otro trabajo me ha comido la semana".

### Lo urgente: el abogado entra en el camino crítico si no le escribes ya

La revisión legal tarda 2-4 semanas de calendario. Si no contactas con
un abogado de protección de datos sanitarios **antes del 15 de septiembre**
(en una semana), esa espera se convierte en el cuello de botella del piloto
completo, por delante incluso de Meta.

---

## 3. Los 8 bloqueantes reales (deduplicados — el workflow encontró 15 IDs, pero son 8 problemas distintos)

### ✅ 3.1 [RESUELTO] — El bot probablemente no responde ahora mismo

Groq retiró `llama-3.3-70b-versatile` (el modelo que usa tu nodo "Groq Chat
Model") para cuentas gratuitas/developer el **16 de agosto de 2026**
([console.groq.com/docs/deprecations](https://console.groq.com/docs/deprecations)),
anunciado un mes antes. Tu último commit es del 14 de agosto. Desde el 16,
las llamadas a la IA fallan — y como la salida de error del nodo `AI Agent`
está configurada pero **desconectada** (nunca lo conectaste a nada), el
paciente no recibe nada y el workflow 04 tampoco avisa. Silencio total, sin
que te enteres.

**Haz esto hoy:** escribe al bot y confírmalo. Después, no lo sustituyas por
otro modelo de Groq — aprovecha el cambio forzoso para migrar a un proveedor
con residencia en la UE (ver 3.2). Mientras decides, conecta la salida de
error del `AI Agent` a una respuesta de emergencia ("ahora mismo no puedo
atenderte, llama al [teléfono]") — son 1-3 h y evita que esto vuelva a
pasar en silencio con cualquier otro fallo de proveedor.

*Esfuerzo: 1-3 h el parche de emergencia; 12-20 h la migración completa de
modelo y reajuste del prompt.*

### 🟡 3.2 [A MEDIAS: falta la plantilla en Meta] — Recordatorios, valoraciones y avisos de lista de espera no van a llegar (esto ya lo sabía yo, pero el workflow lo confirmó con fuente y lo amplió)

Los 5 mensajes que tu negocio inicia (recordatorio 24h, solicitud de
valoración, aviso de hueco liberado ×2, y las propias alertas del workflow
04) se mandan como texto libre (`operation: send`). Fuera de la ventana de
servicio de 24h de Meta (que se abre cuando el paciente te escribe), esto
falla con el error **131047** — confirmado contra la documentación de Meta
replicada por varios proveedores. Un recordatorio del día siguiente a una
cita reservada la semana anterior sale casi siempre fuera de ventana.

Lo nuevo que aporta esta pasada: **el fallo es silencioso, no ruidoso.** El
workflow 01 descarta *todos* los callbacks de estado de WhatsApp, incluidos
los `failed` (es la misma línea que corrigió el bucle infinito del 08/08),
así que nunca sabrás que un recordatorio no llegó — y los workflows 02/03
marcan la fila como "enviada" igualmente.

**Qué hacer:** crear 3 plantillas *utility* en el WhatsApp Manager
(recordatorio, valoración, hueco liberado; con botones "Confirmar" /
"Cambiar" si quieres reducir fricción) y cambiar esos nodos a `Send
Template`. Coste real: ~0,0166 €/mensaje en España — para una clínica de 150
citas/mes, unos 5 €/mes. No es un problema de coste, es de que hoy
simplemente no funciona.

*Esfuerzo: 12-20 h (crear + adaptar 5 nodos + aprender a manejar respuestas
de botón, que hoy caen en "solo gestiono texto") + aprobación de Meta
(normalmente minutos, hasta 24-48h en sectores sensibles como salud).*

### ✅ 3.3 [RESUELTO] — Fuga de identidad: cualquiera puede consultar, cancelar o mover la cita de otra persona

Este es nuevo respecto a mi primera pasada y es serio. En `Resolver cita
cancelacion` (línea 1806), `Resolver cita modificacion` (línea 2058) y
`Resolver consulta cita` (líneas 4247-4252), la comprobación es:

```js
const cita = conTelefono[0] || conNombre[0] || null;
```

Si el teléfono no coincide, **cae a buscar por nombre** — incluso parcial
("Ana" encaja con cualquier "Ana ..."). Tu propio README dice lo contrario
("la identidad se comprueba con el teléfono, que no se puede falsear"), pero
el `||` lo anula. Un desconocido puede escribir "cuándo tiene cita Ana
García" y recibir tratamiento, fecha y hora de otra persona; puede cancelar
la cita de alguien dando solo nombre+fecha+hora.

**Qué hacer:** quitar el fallback por nombre en los tres sitios. Si no hay
coincidencia por teléfono, responder "no encuentro citas con este número;
llama a la clínica" en vez de buscar por nombre.

*Esfuerzo: 1-4 h. Es de las cosas más baratas de arreglar de toda la
auditoría y de las que más daño hacen si no se arregla.*

### ✅ 3.4 [RESUELTO] — El detector de "información clínica" se dispara con nombres y palabras normales

`Normalizar y enrutar` busca subcadenas sin límite de palabra: **"Dolores",
"Salvador", "tomo nota", "me puse", "febrero", "después"** contienen
fragmentos de la lista (`dor`, `pus`, `tomo `...) y activan la derivación a
un humano + 3 horas de silencio del bot. Un paciente llamado Salvador que
escribe "Me llamo Salvador López" recibe un mensaje de derivación clínica
falsa, y el dentista recibe un email de consulta médica que no existe.

**Qué hacer:** reescribir la lista como expresiones regulares con límite de
palabra (`\b`), quitar los términos de 3-4 letras ambiguos, y añadir una
excepción cuando el término aparece justo después de "me llamo/soy/a nombre
de".

*Esfuerzo: 2-4 h.*

### ✅ 3.5 [RESUELTO] — No existe entidad "paciente": sin consentimiento, sin opt-out, sin forma de atender un "no me escribas más"

`stop`/`baja`/`no me escribas` hoy solo cierran un lead comercial — no
existe ningún flag que bloquee el resto de envíos. Un paciente que pide baja
sigue recibiendo el recordatorio de su próxima cita al día siguiente. Y
sigue sin haber ningún registro de que se le informó, la primera vez que
escribió, de que habla con un sistema automático (ver 3.6).

**Qué hacer:** tabla `pacientes` (clínica_id, teléfono, `informado_rgpd_en`,
`opt_out`) enlazada desde citas/lista_espera/leads/derivaciones. En el
primer contacto: anteponer el aviso de IA/RGPD. En 02/03: excluir a quien
tenga `opt_out=true`.

*Esfuerzo: 6-12 h.*

### ✅ 3.6 [RESUELTO, falta probarlo] — El bot no dice que es una IA: el artículo 50 del Reglamento de IA europeo ya está en vigor (2 de agosto de 2026)

Confirmado con fuente oficial de la Comisión Europea: el artículo 50
(transparencia — informar de que se interactúa con IA) aplica desde el **2
de agosto de 2026** y **no** fue aplazado por el paquete Omnibus (que solo
retrasó las obligaciones de alto riesgo). Tu prompt ordena explícitamente
"suenas humana" y no hay ninguna instrucción de identificarse si preguntan.
Sanción máxima teórica: hasta 15M€ o 3% de facturación (proporcional a
pymes, pero existe).

Buena noticia dentro de esto: el propio razonamiento del prompt (deriva
*toda* consulta clínica a una persona, nunca diagnostica) es exactamente el
argumento que te libra de ser clasificado como "alto riesgo" del Anexo III
(que sí cubre triaje/priorización sanitaria). No hay que rehacer nada de
seguridad clínica, solo añadir el aviso.

**Qué hacer:** cambiar "suenas humana" por una instrucción de admitir
siempre ser un asistente de IA si preguntan, y añadir el mensaje de primer
contacto de tu propio `Legal/06` (que ya lo tenías escrito, solo sin
implementar).

*Esfuerzo: 4-8 h.*

### 🟡 3.7 [A MEDIAS: faltan corchetes, DPAs y firma] — El contrato de encargado no es firmable tal cual

El Anexo II (subencargados) sigue con corchetes `[VERIFICAR]`. Esta pasada
sí verificó los datos reales que faltan:

- **Supabase**: AWS eu-central-1 Frankfurt, DPA en supabase.com/legal/dpa.
- **n8n Cloud**: Azure Frankfurt (UE), DPA disponible en n8n.io/legal.
- **Meta/WhatsApp**: WhatsApp Ireland Ltd transfiere a EE. UU. bajo el
  EU-US Data Privacy Framework.
- **Google**: certificado en el DPF, pero el DPA de Cloud solo cubre
  Workspace — **no una cuenta Gmail gratuita**, que es lo que usas hoy.
- **Groq**: DPA vigente con cláusulas contractuales tipo, sin retención de
  inferencia por defecto, *Zero Data Retention* activable.

**Qué hacer:** rellenar el Anexo II con estos datos y enlaces (guarda cada
DPA en PDF con fecha), añadir una cláusula explícita sobre el uso de IA de
terceros, y firmarlo como anexo del acuerdo de piloto — sí, aunque el piloto
sea gratis, porque tratar datos de un paciente real ya activa el artículo 28.

*Esfuerzo: 3-5 h + 400-1.200 € de abogado para revisar 01+02+06 (contrastado
contra el rango 300-700 € de tu propio documento).*

### 🔴 3.8 [ABIERTO: Supabase Pro] — Sin backups reales, con un contrato que promete lo contrario

El plan gratuito de Supabase **no incluye copias de seguridad** (confirmado
en supabase.com/pricing: "Daily backups: Not included") y pausa el proyecto
tras 7 días de inactividad. Tu propio `Legal/01`, Anexo I, promete "copias de
seguridad automáticas diarias" — eso es firmar un documento con una medida
de seguridad falsa.

**Qué hacer:** pasar a Supabase Pro (25 $/mes, backups diarios de 7 días, sin
pausa) antes de la primera clínica real. Actualizar el Anexo I para que diga
la verdad.

*Esfuerzo: 1-4 h. Barato, y necesario para poder firmar el contrato con la
conciencia tranquila.*

---

## 4. Hallazgos "altos" que merece la pena que veas (de 65 totales — los que más cambian tu forma de ver el proyecto)

No los voy a listar todos — para eso está el detalle en el historial de esta
sesión. Estos son los que aportan algo que probablemente no tenías en la
cabeza:

- 🟡 **[A MEDIAS: credenciales unificadas, falta token permanente]** **El token temporal de Meta caduca cada 24h de verdad, y tienes dos
  credenciales de WhatsApp distintas** (una para el workflow 01, otra para
  02/03/04) que caducan por separado. Con el ritmo a ráfagas que tienes,
  el bot pasa la mayoría de las horas del mes sin poder enviar nada. Arreglo:
  20 minutos en Meta Business Suite → Usuarios del sistema → token
  permanente, y unificar las dos credenciales en una.
- 🔴 **[ABIERTO]** **El OAuth de Google (Calendar y Gmail) probablemente está en modo
  "Testing"**, lo que hace que los refresh tokens caduquen **cada 7 días**
  — una caída semanal silenciosa de reservas. Se arregla pasando la app a
  "In production" en la consola de Google Cloud (para uso propio no exige
  verificación).
- ✅ **[RESUELTO]** **Una reserva nueva cancela en silencio TODAS las citas futuras
  confirmadas del mismo paciente**, sin avisar a nadie — el código que
  detecta "duplicados" es más agresivo de lo que crees.
- ✅ **[RESUELTO]** **El evento que crea el bot en Calendar no lleva el teléfono del
  paciente** — el propio requisito que tu ESTADO-DEL-PROYECTO pide para el
  futuro workflow 06, el bot de hoy no lo cumple.
- ✅ **[RESUELTO: workflow 07]** **La clínica no tiene ninguna forma de cerrar una derivación** salvo que
  tú entres a Supabase y ejecutes SQL a mano. Mientras tanto el bot sigue
  callado 3h y el resumen semanal la sigue mostrando en rojo aunque ya se
  haya atendido.
- ✅ **[RESUELTO: workflow 06]** **La clínica no ve la lista de espera ni los leads en ningún sitio** —
  viven solo en Supabase. Dos funciones que cobras en los planes son
  invisibles para quien las tiene que usar.
- ✅ **[RESUELTO]** **El mensaje de derivación al paciente no incluye el aviso "no puedo
  darte consejo médico" ni el 112**, que tu propio documento legal 06 exige.
- 🔴 **[ABIERTO: decidir antes de la demo]** **Migrar el número de WhatsApp de la clínica a la Cloud API es
  irreversible**: si la clínica ya tiene la app de WhatsApp Business en ese
  número, lo pierde para siempre salvo que uses "Coexistence" (que exige ser
  Tech Provider o pasar por un BSP de pago). Decide esto *antes* de la
  demo, no lo descubras en el onboarding del primer cliente.
- 🔴 **[ABIERTO]** **La hoja de precios (`Clínica+`, 399€) vende multi-agenda y seguimiento
  comercial automático que no existen** — ya lo tenía en mi primera pasada,
  y aquí se confirma con coste de construirlas: 25-50h y 10-20h
  respectivamente.
- 🔴 **[ABIERTO: vigilar en el piloto]** **Cada mensaje saliente de WhatsApp genera hasta 3 ejecuciones extra en
  n8n Cloud** (los callbacks de estado). Con 150 citas/mes, una sola clínica
  puede rondar 4.400-5.300 ejecuciones/mes — el plan Starter (2.500) se
  queda corto ya en el primer mes de piloto, no con la segunda clínica.

---

## 5. El modelo económico, con cifras reales (esto no lo tenías)

Tu documento `Precios y planes.md` dice "total fijo ~25-75 €/mes". La
realidad, contrastada con precios de 2026, es unas 4 veces mayor:

| Concepto | €/mes |
|---|---|
| RETA (tarifa plana) | 88 |
| Gestoría | 40 |
| Supabase Pro | 23 |
| n8n Cloud Pro (necesario por los callbacks) | 55 |
| Seguro RC profesional (no obligatorio, recomendable) | 25 |
| Abogado amortizado | 55 |
| Dominio + web + Workspace | 12 |
| **Total fijo real, año 1** | **~300 €/mes** |
| **Total fijo real, año 2** (sin tarifa plana) | **~420 €/mes** |

Coste variable por clínica: ~22 €/mes directo con Meta (IA 5, Meta 15, cobro
2), o ~71 €/mes si el número va por un BSP.

**Consecuencia real:** con esto, la primera clínica a 149 €/mes *pierde*
dinero (~170 €/mes negativo). El punto de equilibrio real es **3 clínicas a
149 € (4 sin tarifa plana), o 2 clínicas a 249 €.** Para que tú te lleves
1.500 €/mes netos hacen falta del orden de 9 clínicas a 249 € (o 16 a 149 €)
antes de impuestos.

El piloto "2 meses gratis + 149 €/mes 12 meses" regala más de lo que cuesta:
en el primer año aporta ~1.490 € frente a un fijo real de ~3.600 €. Solo se
justifica si el testimonio de esa clínica te trae la 2ª y 3ª clínica en
menos de 6 meses — que es exactamente para lo que lo diseñaste, así que el
razonamiento del documento sigue siendo válido, solo hay que ser consciente
de que estás financiando ese testimonio con tu propio bolsillo, no gratis.

**Dos detalles fiscales que nadie había mirado:** la clínica dental está
exenta de IVA y no lo deduce (así que a ella le sale a 180,29 € reales, no
149 €); y facturación electrónica/Verifactu **no son bloqueantes hoy**
(Verifactu entra el 1-jul-2027 para autónomos; factura B2B obligatoria, más
tarde aún) — puedes dejarlo para cuando toque, no es urgente.

---

## 6. Multi-clínica y multi-dentista: veredicto actualizado con horas reales

Mi primera pasada acertaba en el diagnóstico (01 y 05 son multi-clínica de
verdad; 02, 03 y 04 no) pero se quedaba corta en las horas. Con lo que
verificó esta pasada:

- ~~**Antes del piloto (obligatorio, aunque solo haya 1 clínica):** hacer 02/03
  dinámicos por clínica + limpiar el número de pruebas cableado = **6-10 h**.~~
  ✅ **HECHO** (verificado en el código el 9-sep). Los cinco workflows son
  multi-clínica. Lo que queda de este bloque es la migración a plantillas de
  la sección 3.2, que es el verdadero trabajo grande — el multi-clínica en sí
  ya no es el problema.
- **Durante el piloto** (según lo que diga la clínica sobre cómo lleva su
  agenda hoy): capacidad por sillón (2-4h), workflow 06 de sincronización
  Calendar→Supabase (10-16h + 4-6h de casos borde) = **18-30 h**.
- **Tras la 2ª-3ª clínica:** RLS + quitar defaults (1-3h), multi-dentista
  completo (**35-55 h**, con riesgo real de regresión porque el router ya
  duplica los mismos helpers 4 y hasta 8 veces), y si llegas a 5+ clínicas,
  convertirte en Tech Provider de Meta (20-40h + semanas de aprobación).

**Confirmo mi recomendación anterior con más convicción todavía**: multi-
dentista es una segunda versión del producto, no un ajuste — constrúyela
solo cuando una clínica concreta la pague. Lo único que sí hay que tocar
antes del piloto es lo barato (6-10h), porque el número de pruebas cambia
igualmente en cuanto tengas cliente real.

Un dato nuevo que vale la pena que sepas: el **índice único
`citas_hueco_unico`** no es solo una imperfección teórica — significa que
una clínica con **dos sillones no puede usar el bot tal cual está** (impide
dos citas simultáneas en la misma clínica, sin importar el sillón). Si tu
clínica piloto tiene más de un sillón, esto pasa de "media" a bloqueante
para ellos específicamente.

---

## 7. Lo que está bien hecho (se sostiene tras la verificación)

La pasada profunda confirma casi todo lo que ya había visto, y añade matices
que hacen que la valoración positiva sea, si acaso, más sólida:

- El **cero-datos-de-clínica-en-el-workflow** está verificado nodo a nodo:
  los 23 nodos Supabase filtran por `clinica_id`, los 8 de Calendar usan
  `config.calendar_id`, los 3 de WhatsApp usan `metadata.phone_number_id`
  del propio webhook. No hay ni una excepción.
- La **capa de validación determinista** tras el LLM (fechas, horarios,
  duración, última hora posible explicada al paciente) es mejor que lo
  habitual en un proyecto de una sola persona en n8n.
- El **webhook de WhatsApp sí valida la firma criptográfica** (verificado
  contra el código fuente de n8n) — no es un punto de entrada abierto.
- El **incidente del 08/08 está realmente cerrado**, no parcheado: la causa
  raíz se entendió y además se añadió un cortafuegos independiente.
- La **pausa tras derivar a un humano** es, en palabras del propio auditor
  de operaciones, "la decisión de seguridad clínica más importante del
  producto, y está bien resuelta".
- **Posicionamiento de precio del plan Esencial (149€) coherente con el
  mercado** — contrastado contra cliniflux.es (banda 99-199€) y agencias de
  automatización (290-450€ + setup): hay hueco real para un proveedor
  pequeño y cercano.

---

## 8. Qué hacer esta semana (arranca los relojes que no dependen de ti)

1. **Hoy: comprueba si el bot responde.** Si no, conecta la salida de error
   del AI Agent a un mensaje de emergencia (1-3h) mientras decides proveedor.
2. **Decide esta semana dos cosas que bloquean todo lo demás:** proveedor de
   IA (Mistral UE u OpenAI con endpoint UE — ambos tienen nodo/soporte en
   n8n) y modelo de número de WhatsApp para la clínica (por defecto: número
   nuevo bajo tu propio portfolio, no el número histórico de la clínica).
3. **Escribe al abogado de protección de datos sanitarios ya** — antes del
   15 de septiembre, para que sus 2-4 semanas no sean el cuello de botella.
4. **Manda el mensaje de reactivación al dentista** (ya lo tienes escrito),
   pero con un margen de demo de 2-3 semanas, no "esta semana o la que
   viene" — necesitas ese tiempo para tener algo real que enseñar.
5. **Compra el dominio y monta una landing de una página** con política de
   privacidad — es requisito técnico previo para que Meta pase tu app a
   modo Live, no solo un tema de imagen.
6. **Arregla lo barato de la sección 3 esta misma semana** (identidad por
   nombre, detector de síntomas, backups de Supabase): son horas, no días,
   y quitan el riesgo más serio mientras decides lo demás con calma.

---

## 9. Lo que decidí no incluir en detalle (y por qué)

El workflow generó 217 hallazgos con evidencia; no tiene sentido volcarlos
todos aquí. Prioricé lo que cambia una decisión tuya esta semana o el mes
que viene. Quedan fuera del documento (pero están en el registro de esta
sesión si los necesitas más adelante): los ~103 hallazgos "media" —
deuda técnica real pero que puede esperar a la 2ª-3ª clínica — y los 34
"baja", mejoras que no tienen impacto en vender ni en operar con seguridad.
