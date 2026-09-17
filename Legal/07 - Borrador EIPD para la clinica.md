# Borrador de Evaluación de Impacto (EIPD) — asistente de WhatsApp para citas

> **Nota para ti (bórrala antes de mandarlo a la clínica).**
> La EIPD es obligación de la clínica, no tuya (art. 35 RGPD). Pero si no se la
> das hecha no se hará, y su asesor lo va a echar en falta. Es lo que más cerca
> está de sustituir al abogado que has decidido no contratar.
>
> Sigue la estructura de la guía de la AEPD *"Gestión del riesgo y evaluación de
> impacto en tratamientos de datos personales"*. Está escrito para que el asesor
> de la clínica lo revise, lo complete y lo firme la clínica. La AEPD tiene una
> herramienta gratuita (Evalúa-Riesgo RGPD) donde se pueden volcar estos datos.
>
> Rellena los `[CORCHETES]`. Donde pone **Pendiente**, no lo cambies a "Hecho"
> hasta que lo sea: un documento que promete medidas que no existen es peor que
> no tenerlo.

---

**Responsable del tratamiento:** [NOMBRE FISCAL DE LA CLÍNICA], CIF [CIF]
**Delegado de Protección de Datos o asesor:** [NOMBRE]
**Encargado del tratamiento:** [NOMBRE Y APELLIDOS], NIF [NIF], marca bitclap
**Versión:** borrador 1 · [FECHA]
**Próxima revisión:** a los 6 meses del inicio, o antes si cambia un proveedor
o una función del asistente.

---

## 1. ¿Hace falta esta evaluación?

La AEPD publica una lista de tratamientos que requieren EIPD (art. 35.4 RGPD).
Como regla general basta con que se den **dos** de sus criterios. Aquí se dan
al menos dos:

| Criterio de la lista de la AEPD | ¿Se da? | Por qué |
|---|---|---|
| Datos de categorías especiales (art. 9 RGPD) | **Sí** | Los pacientes pueden contar síntomas, medicación o un embarazo |
| Uso de tecnologías nuevas o innovadoras | **Sí** | Un modelo de inteligencia artificial interpreta los mensajes |
| Interesados vulnerables | Posible | Pacientes que a veces escriben con dolor o angustia |
| Decisiones automatizadas con efectos significativos | No | El sistema no decide nada clínico: deriva toda consulta clínica a una persona |
| Tratamiento a gran escala | [VALORAR] | Depende del volumen de pacientes de la clínica |

**Conclusión:** procede realizar la EIPD. [Confirmar por el DPD o asesor.]

---

## 2. Descripción del tratamiento

### 2.1 Finalidad

Atender por WhatsApp, de forma automatizada y a cualquier hora, las gestiones
administrativas de cita de los pacientes: pedir, cambiar y anular cita,
consultar su cita y los horarios, apuntarse a la lista de espera, recibir un
recordatorio el día antes y dejar constancia del interés por un tratamiento.

Las consultas clínicas **no** se atienden: se derivan al personal de la clínica.

### 2.2 Datos tratados

| Categoría | Datos | Origen |
|---|---|---|
| Identificativos | Nombre y teléfono de WhatsApp | El paciente |
| De la cita | Tratamiento, fecha, hora y estado | El paciente y la agenda |
| Contenido | Texto de los mensajes | El paciente |
| Salud (art. 9) | Lo que el paciente cuente por iniciativa propia (dolor, sangrado, medicación, embarazo...) | El paciente, **sin que se le pida** |
| Cumplimiento | Fecha en que se le informó del sistema de IA; bajas de mensajes automáticos | El sistema |

No se piden DNI, datos bancarios ni historial clínico.

### 2.3 Interesados

Pacientes y potenciales pacientes que escriben al número de WhatsApp del
asistente. Volumen previsto: [Nº] conversaciones al mes.

### 2.4 Ciclo de vida del dato

1. El paciente escribe al WhatsApp del asistente (Meta).
2. El mensaje llega al motor de automatización (n8n Cloud, en la UE).
3. La primera vez, el sistema le informa de que habla con un asistente de
   inteligencia artificial, de quién trata sus datos, de dónde consultar la
   política de privacidad y de cómo dejar de recibir mensajes. Guarda la fecha.
4. El texto se envía al modelo de IA (Groq, en EE. UU., sin conservarlo), que devuelve qué
   quiere hacer el paciente. El modelo no decide nada por sí solo: un código de
   validación comprueba fechas, horarios y disponibilidad antes de tocar la
   agenda.
5. Si el mensaje contiene información clínica, no se contesta a esa consulta.
   Se le dice al paciente que no se le puede dar consejo médico, que le
   llamarán y que ante una urgencia llame a la clínica o al 112, y se envía un
   email a la clínica.
6. Las citas se guardan en la base de datos (Supabase, en la UE) y en el Google
   Calendar de la clínica (nombre, tratamiento y teléfono).
7. El día antes de la cita se envía un recordatorio con una plantilla de
   WhatsApp, salvo a quien haya pedido la baja.
8. Al terminar el contrato con el encargado, los datos se devuelven o se
   suprimen en 30 días.

### 2.5 Intervinientes

| Quién | Papel | Dónde trata los datos |
|---|---|---|
| [CLÍNICA] | Responsable | España |
| [NOMBRE] (bitclap) | Encargado | España |
| Supabase | Subencargado: base de datos | UE (Fráncfort) |
| n8n GmbH | Subencargado: automatización | UE (Fráncfort) |
| Groq | Subencargado: modelo de IA | EE. UU. (cláusulas contractuales tipo, retención cero) |
| WhatsApp Ireland (Meta) | Subencargado: mensajería | UE, con transferencia a EE. UU. (EU-US Data Privacy Framework) |
| Google | Subencargado: agenda y correo | EE. UU. (EU-US Data Privacy Framework) |

---

## 3. Necesidad y proporcionalidad

| Pregunta | Respuesta |
|---|---|
| **¿Cuál es la base jurídica?** | Gestión de la cita: medidas precontractuales y relación asistencial (art. 6.1.b). Datos de salud que aporta el paciente: gestión de servicios de asistencia sanitaria (art. 9.2.h, con el deber de secreto del art. 9.3). Recordatorios: interés legítimo en que el paciente no pierda su cita, con oposición sencilla. **[Validar por el asesor]** |
| **¿Es necesario usar IA?** | Permite entender mensajes escritos en lenguaje natural, con faltas y en varios idiomas, a cualquier hora. Alternativa menos intrusiva valorada: un menú de botones sin IA, que reduce mucho la utilidad para pacientes mayores o poco habituados. [Valorar] |
| **¿Se minimizan los datos?** | No se piden datos de salud. Las consultas clínicas se derivan sin valorarlas. El email diario a la clínica no incluye el detalle clínico. Las citas solo se consultan desde el teléfono que las reservó. **Pendiente:** hoy se guarda el texto literal del mensaje en la derivación; bastaría con un resumen. |
| **¿Se informa al paciente?** | Sí. Aviso automático en su primer mensaje (sistema de IA, responsable, enlace a la política de privacidad, cómo darse de baja), con registro de la fecha. La política de privacidad de la clínica incluye el apartado del canal automatizado. |
| **¿Puede ejercer sus derechos?** | Oposición a los mensajes automáticos escribiendo BAJA. Cualquier otra petición sobre sus datos se deriva automáticamente a la clínica. Siempre puede llamar a la clínica. |
| **¿Hay decisiones automatizadas (art. 22)?** | No. El sistema solo gestiona la agenda. Ninguna decisión clínica se toma de forma automatizada. |
| **¿Cuánto se conservan?** | [Definir con la clínica]. Propuesta: citas, según los plazos de la documentación asistencial; conversaciones y derivaciones, [12 meses]; registros técnicos de errores y envíos fallidos, 90 días. |

---

## 4. Riesgos y medidas

Probabilidad e impacto: Bajo / Medio / Alto. **Residual** = riesgo que queda
con las medidas aplicadas.

| # | Riesgo para el paciente | Prob. | Impacto | Medidas | Residual |
|---|---|---|---|---|---|
| R1 | Un tercero consulta, cambia o anula la cita de otra persona haciéndose pasar por ella | Media | Medio | Las citas solo se localizan desde el número de WhatsApp con el que se reservaron; el nombre no basta. Si no coincide, se pide llamar a la clínica | Bajo |
| R2 | El paciente recibe un consejo médico erróneo o entiende que su caso "puede esperar" | Media | **Alto** | Prohibido dar consejo médico; toda información clínica se deriva; mensaje fijo con "no puedo darte consejo médico" y el 112; mientras la derivación está abierta el asistente no contesta consultas (máx. 3 h) | Bajo |
| R3 | Una consulta clínica no se detecta y se trata como administrativa | Baja | Alto | Doble control: instrucciones al modelo de IA y detector de términos clínicos en español, inglés, portugués y francés; batería de pruebas antes de producción | Bajo-Medio |
| R4 | Nadie en la clínica atiende una derivación | Media | Alto | Email inmediato a la clínica; email diario con los pacientes pendientes en rojo; obligación contractual de la clínica de atender las derivaciones | **Depende de la clínica** |
| R5 | El paciente no sabe que habla con una IA | Baja | Medio | Aviso en el primer mensaje; el asistente responde siempre con la verdad si se le pregunta | Bajo |
| R6 | Acceso no autorizado a la base de datos | Baja | Alto | Alojamiento en la UE; clave de servicio solo en el motor de automatización; tablas nuevas con acceso público bloqueado; [doble factor en todas las plataformas — confirmar]; [copias diarias con Supabase Pro — pendiente] | Bajo |
| R7 | Transferencia de datos a EE. UU. | Alta (ocurre) | Medio | Meta (imprescindible para usar WhatsApp) y Google (agenda y correo), en el Data Privacy Framework. El modelo de IA (Groq) procesa el texto de cada mensaje en EE. UU., con cláusulas contractuales tipo y retención cero: no lo conserva. La base de datos está en la UE. En la agenda solo va nombre, tratamiento y teléfono | **Medio** |
| R8 | El proveedor de IA reutiliza los mensajes | Baja | Medio | Prohibición contractual de entrenar con los datos (DPA de Groq); retención cero activada | Bajo |
| R9 | Recordatorio no entregado, o enviado a quien no lo quiere | Media | Bajo | Plantillas aprobadas por Meta; registro de envíos fallidos; exclusión automática de quien pidió la baja | Bajo |
| R10 | El servicio cae y nadie lo sabe | Media | Medio | Si la IA falla, el paciente recibe el teléfono de la clínica; avisos automáticos de error al encargado | Bajo |
| R11 | El historial técnico de ejecuciones guarda el contenido de los mensajes más de lo necesario | Media | Medio | **Pendiente:** limitar en n8n la conservación del historial de ejecuciones | Medio |
| R12 | Datos de salud guardados en texto literal en la derivación | Alta (ocurre) | Medio | Acceso restringido. **Pendiente:** guardar solo un resumen | Medio |

---

## 5. Plan de acción

| Medida | Quién | Cuándo | Estado |
|---|---|---|---|
| Firmar el contrato de encargado (con el Anexo II de subencargados) | Clínica y encargado | Antes del primer paciente | Pendiente |
| Añadir el apartado del canal automatizado a la política de privacidad y facilitar el enlace | Clínica | Antes del primer paciente | Pendiente |
| Decidir quién atiende las derivaciones y en qué plazo | Clínica | Antes del primer paciente | Pendiente |
| Copias de seguridad diarias (Supabase Pro) | Encargado | Antes del primer paciente | Pendiente |
| DPA de Groq aceptado y retención cero (ZDR) activada | Encargado | Antes del primer paciente | Pendiente |
| Valorar un proveedor de IA en la UE si el DPD no acepta la transferencia de R7 | Clínica y encargado | Antes del primer paciente | Pendiente |
| Agenda y correo en Google Workspace (o de la clínica) en lugar de una cuenta Gmail gratuita | Encargado y clínica | Antes del primer paciente | Pendiente |
| Limitar la conservación del historial de ejecuciones en n8n | Encargado | Primer mes | Pendiente |
| Guardar solo un resumen en las derivaciones | Encargado | Primer trimestre | Pendiente |
| Revisar esta EIPD | Clínica | A los 6 meses | — |

---

## 6. Conclusión

[A completar por el responsable tras la revisión del DPD o asesor.]

**Propuesta:** con las medidas del apartado 4 aplicadas y las del plan de acción
que tienen plazo "antes del primer paciente" completadas, el riesgo residual se
considera **aceptable**, salvo R4, que depende de la organización interna de la
clínica, y R11 y R12, que tienen medidas pendientes con plazo. No se considera
necesaria la consulta previa a la AEPD (art. 36 RGPD). [Validar]

**Firma del responsable:** ______________________   Fecha: __________

**Opinión del DPD o asesor:** ______________________
