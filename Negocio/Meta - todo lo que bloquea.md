# Meta / WhatsApp — todo lo que bloquea, en un sitio

Preguntaste si hay más problemas con Meta aparte de la verificación. Sí, hay
seis más. Ninguno es grave por separado; el problema es descubrirlos de uno en
uno el día que te revientan.

Esta es la lista completa. Los ordeno por **cuándo te van a doler**.

---

## Resumen: qué te bloquea y cuánto tarda

| # | Cosa | ¿Bloquea pacientes reales? | Cuánto tarda | ¿Depende de ti? |
|---|---|---|---|---|
| 1 | El número ya está en WhatsApp Business | 🔴 Sí | 1 día | Sí |
| 2 | Verificación del negocio | 🔴 Sí | Días–semanas | No |
| 3 | Plantillas aprobadas (workflows 02 y 03) | 🔴 Sí | Minutos–24 h | Sí |
| 4 | Token permanente | 🟠 No, pero te tira el bot cada día | 20 min | Sí |
| 5 | Nombre para mostrar aprobado | 🟠 Sí, para salir del modo prueba | 1–3 días | Sí |
| 6 | Ventana de 24 horas | 🟡 Cambia cómo escribes los mensajes | — | Sí |
| 7 | Límites y calidad del número | 🟡 Cuando crezcas | — | Parcial |

---

## 1. El número de la clínica probablemente ya tiene WhatsApp

**Este es el que menos gente ve venir y el que más incómodo es explicar en una
demo.**

Un número solo puede estar en un sitio: o en la app de WhatsApp Business (la
que el dentista usa hoy en el móvil), o en la API en la nube (la que usa tu
bot). **No en los dos.**

Si mueves el número de la clínica a la API:

- La recepcionista **deja de tener WhatsApp en el móvil** para ese número.
- Todo el historial de conversaciones anterior se queda atrás.
- Todo pasa a ir por tu sistema. Si tu bot está caído, la clínica se queda sin
  WhatsApp.

Tres salidas, de mejor a peor para el piloto:

| Opción | Qué pasa | Cuándo usarla |
|---|---|---|
| **Número nuevo** para el bot | La clínica sigue con su WhatsApp de siempre. Cero riesgo. | **Piloto. Es la que te recomiendo.** |
| Migrar su número principal | Más limpio de cara al paciente, pero la clínica pierde su app | Cuando el piloto haya ido bien |
| Un número tuyo | Rápido, pero el paciente ve un número desconocido | Solo para la demo |

**Para el piloto: número nuevo.** Una tarjeta prepago vale unos pocos euros y
elimina de golpe el mayor miedo del dentista, que es "y si esto me deja sin
WhatsApp". Además te deja apagar el bot sin romperle nada.

Llévalo preparado a la demo. Es un argumento de venta, no un problema.

---

## 2. Verificación del negocio — la cola larga

Es la que ya conoces. Meta revisa que tu negocio existe: nombre legal,
dirección, documento oficial.

**Lo que no sabías: para esto NO necesitas estar de alta en la Seguridad
Social.** Lo que Meta pide es un documento oficial con tu nombre y tu
dirección de actividad. En España, el **certificado de situación censal** (el
que sale del modelo 036/037) sirve, y **el 036 es gratis**.

Es decir: puedes meterte en la cola de Meta sin pagar cuota de autónomo.
Más abajo lo explico bien, porque enlaza con lo que me dijiste.

### El atajo que puede ahorrarte semanas

Hay dos formas de montar esto:

**Ruta A — tu propio negocio verificado (la escalable).**
Todos tus clientes cuelgan de tu cuenta de Meta. Un solo token, un solo sitio
donde tocar. Es lo que ya soporta el sistema: cada clínica guarda su
`telefono_whatsapp_id` y los workflows envían desde el suyo. **Pero requiere
que Meta te verifique a ti, y eso son semanas.**

**Ruta B — la cuenta de Meta de la clínica (el puente).**
Si la clínica ya hace publicidad en Instagram o Facebook, **es muy probable
que su Business Manager ya esté verificado**. En ese caso el bot puede
arrancar con su cuenta en días, no en semanas.

El precio: cada clínica con su propia cuenta necesita su propia credencial en
n8n, y eso no escala más allá de dos o tres clientes.

**Haz las dos.** Arranca tu verificación esta semana (el reloj largo) y
pregúntale al dentista si ya hace publicidad en Instagram. Si dice que sí, el
piloto puede empezar mucho antes. Migrar después a la ruta A no rompe nada:
solo cambia el `telefono_whatsapp_id` en la tabla `clinicas`.

**Pregunta para la demo, apúntala:**
> "¿Hacéis publicidad en Instagram o Facebook? Si ya tenéis la cuenta de
> empresa verificada, esto lo tenemos funcionando en días."

---

## 3. Plantillas — esto rompe los workflows 02 y 03 en producción 🔴

**Este es el problema serio que no habíamos visto, y lo he encontrado
revisando los workflows hoy.**

Meta divide los mensajes en dos mundos:

| | Qué es | Qué puedes enviar |
|---|---|---|
| **Ventana abierta** | El paciente te ha escrito hace menos de 24 h | Lo que quieras, texto libre |
| **Ventana cerrada** | Han pasado más de 24 h | **Solo plantillas aprobadas** |

Ahora mira lo que hacen tus workflows:

- **02 Recordatorios**: escribe a un paciente **el día antes de su cita**. Ese
  paciente reservó hace una semana. **Ventana cerrada.**
- **03 Valoraciones**: escribe **una hora después de la cita**. Si el paciente
  vino sin escribir por WhatsApp, o reservó hace días: **ventana cerrada.**

Los dos envían texto libre. **Los dos van a fallar** con el error
`131047 — Message failed to send because more than 24 hours have passed since
the customer last replied`.

### Por qué en tus pruebas funcionaba

Porque tú le escribes al bot todo el rato. Tu ventana siempre está abierta.
Un paciente real no hace eso. Este fallo **solo aparece con pacientes de
verdad**, que es el peor momento posible para descubrirlo.

### Cómo se arregla

Das de alta dos plantillas en el Administrador de WhatsApp y esperas la
aprobación (suele ser cuestión de minutos u horas). Luego yo cambio el nodo de
envío en 10 minutos.

**Plantilla 1 — recordatorio**

- Nombre: `recordatorio_cita_24h`
- Categoría: **Utilidad** *(no marketing: va ligada a una cita concreta)*
- Idioma: Español

```
Hola {{1}}, te recordamos tu cita de {{2}} mañana a las {{3}} en {{4}}.
Si no puedes asistir, responde a este mensaje y te la cambiamos.
```

| Variable | Qué es | Ejemplo |
|---|---|---|
| `{{1}}` | Nombre del paciente | Luis |
| `{{2}}` | Tratamiento | Limpieza |
| `{{3}}` | Hora | 16:00 |
| `{{4}}` | Nombre de la clínica | Clínica Dental Salud |

**Plantilla 2 — valoración**

- Nombre: `solicitud_valoracion`
- Categoría: **Utilidad**, y si Meta te la reclasifica como Marketing, acéptalo
- Idioma: Español

```
Hola {{1}}, esperamos que tu visita a {{2}} haya ido bien.
¿Podrías valorar tu experiencia del 1 al 5? Puedes añadir un comentario
si quieres. Ejemplo: 5 Todo genial
```

> **Cuidado con la categoría.** Utilidad es barata y se aprueba fácil.
> Marketing cuesta más, exige consentimiento explícito y el paciente puede
> bloquearla. Si Meta te clasifica la de valoración como Marketing, no
> discutas: cámbiale la redacción para que hable de "tu visita del [fecha]" y
> vuelve a enviarla como Utilidad.

**Dos reglas que evitan que te rechacen la plantilla:**
1. No empieces ni termines con una variable.
2. Nada de emojis raros, mayúsculas gritadas ni promesas comerciales.

Cuando estén aprobadas, dímelo y cambio los nodos.

---

## 4. Token permanente — 20 minutos y se acaba el problema

El token que estás usando caduca cada 24 horas. Por eso el bot se te muere
solo. Lo has vivido ya varias veces.

El arreglo es un **token de Usuario del Sistema**, que no caduca:

1. Business Manager → **Configuración del negocio** → **Usuarios** →
   **Usuarios del sistema**
2. Crear uno, rol **Administrador**
3. **Añadir activos** → tu app de WhatsApp → control total
4. **Generar token** → permisos `whatsapp_business_messaging` y
   `whatsapp_business_management` → caducidad **Nunca**
5. Pegarlo en las credenciales de n8n

Hazlo **antes de la demo**. Que se te caiga el bot delante del dentista por
esto sería una tontería evitable.

---

## 5. Nombre para mostrar

El nombre que ve el paciente ("Clínica Dental Salud") también lo aprueba Meta.
Tiene que parecerse al nombre real del negocio. "Bot citas" o "Asistente" te
lo rechazan.

Tarda uno a tres días. Se pide en el mismo sitio que el número.

---

## 6. La ventana de 24 horas — cómo cambia el diseño

Además de las plantillas, la ventana tiene una consecuencia que conviene
entender:

**Los mensajes que entran son gratis. Los que sales tú a enviar, no.**

Desde que Meta cambió el modelo, las conversaciones que inicia el usuario no
se cobran, pero cada plantilla que envías tú sí. En España son céntimos por
mensaje, pero cuenta esto:

- Una clínica con 300 citas al mes = 300 recordatorios + 300 valoraciones
- 600 plantillas al mes

A céntimos por mensaje son unos pocos euros. **No te arruina, pero tiene que
estar en tu cuenta de resultados**, porque lo pagas tú, no la clínica.

> **Compruébalo tú mismo antes de fijar precios.** Las tarifas de Meta cambian
> cada pocos meses. Busca "WhatsApp Business Platform pricing" y mira la fila
> de España, categoría Utility. Ajusta el margen de los planes con el número
> real, no con el mío.

---

## 7. Límites y calidad del número

Cuando pases la verificación empiezas con un tope de conversaciones iniciadas
por día. Sube solo si el número se porta bien.

Lo que baja la calidad: que la gente te bloquee o te reporte. Lo que la sube:
que la gente conteste.

Con una clínica no lo vas a notar. Pero es la razón por la que **no debes
mandar nada que huela a publicidad** desde el número de una clínica: un
bloqueo masivo te tira la calidad y te limita a todos los clientes a la vez si
van bajo tu misma cuenta.

---

## Qué hacer, en orden

**Esta semana**

- [ ] Generar el **token permanente** (20 min, quita un dolor diario)
- [ ] Dar de alta las **dos plantillas** y esperar la aprobación
- [ ] Modelo **036** (gratis) para tener el certificado censal
- [ ] Arrancar la **verificación de negocio** de Meta con ese certificado
- [ ] Comprar/apartar un **número nuevo** para el piloto
- [ ] En la demo: preguntar si la clínica ya hace publicidad en Instagram

**Cuando las plantillas estén aprobadas**

- [ ] Avisarme → cambio los nodos de envío de los workflows 02 y 03

**Antes de pacientes reales**

- [ ] Nombre para mostrar aprobado
- [ ] Verificación aprobada (o ruta B con la cuenta de la clínica)
- [ ] Sacar el proveedor de IA fuera de Estados Unidos
