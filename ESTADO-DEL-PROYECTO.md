# bitclap.es — Estado del proyecto

> **Para qué es este documento.** Para retomar el proyecto desde cero en otro
> ordenador sin tener que releer conversaciones antiguas. Aquí está lo que hay,
> lo que funciona, lo que falta y por qué se tomó cada decisión.
>
> **Mantenlo vivo:** cuando algo deje de ser cierto, edítalo o bórralo. Un
> documento desactualizado es peor que no tenerlo.

**Última actualización:** 9 de agosto de 2026

---

## 1. Qué es esto

Un chatbot de WhatsApp para clínicas dentales. El paciente escribe al WhatsApp
de la clínica y el bot le gestiona la cita solo: la reserva, la modifica, la
cancela, le recuerda el día antes, le pide valoración después y avisa a la
clínica si es algo que necesita una persona.

Marca prevista: **bitclap.es** · Mercado: España · Fundador: solo.

**Estado real: producto terminado y probado, sin vender todavía.**

---

## 2. Situación actual, sin adornos

| Cosa | Estado |
|---|---|
| Producto funcionando | ✅ Sí, 5 workflows probados de punta a punta |
| Base de datos | ✅ Supabase, multi-clínica desde el primer día |
| Cliente potencial | 🟡 Una clínica dental interesada, sin contrato |
| Modelo 036 (censal, gratis) | ❌ No — **bloquea la verificación de Meta** |
| Alta en RETA (cuota) | ❌ No, y **a propósito**: no hasta la primera factura |
| Meta Business Verification | ❌ No — **bloquea escribir a pacientes reales** |
| Documentos legales | 🟡 Listos en `Legal/`. Decisión tomada: **sin abogado**, ver `Negocio/Decisiones - autonomo y abogado.md` |
| Precios | 🟡 Propuesta en `Negocio/Precios y planes.md`, sin validar en mercado |
| Web | ❌ No existe |

**Los dos bloqueos de verdad** (todo lo demás es secundario):

1. **No estás dado de alta como autónomo.** Sin eso no puedes emitir una
   factura legal. Es el primer paso de la cadena, porque además Meta pide
   documentación de empresa para verificarte.
2. **La app de Meta está en modo Desarrollo.** Mientras siga así, el bot
   **solo puede escribir a números dados de alta a mano** en la consola de
   Meta. No puede atender a un paciente real. La verificación de negocio
   tarda días o semanas, así que conviene empezarla pronto.

---

## 3. Cómo está montado

```
Paciente por WhatsApp
        ↓
  n8n Cloud (workflow 01)
        ↓
  ¿de qué clínica es este número? → Supabase (vista clinicas_config)
        ↓
  se construye el prompt al vuelo con los datos de esa clínica
        ↓
  Agente de IA → decide qué quiere el paciente (JSON)
        ↓
  Google Calendar (huecos) + Supabase (citas) + WhatsApp (respuesta)
```

### La decisión de diseño importante: multi-clínica

Un solo workflow atiende a todas las clínicas. Cuando entra un mensaje, el bot
mira **a qué número de WhatsApp llegó** (`phone_number_id`), busca esa clínica
en Supabase y se trae su configuración: nombre, horarios, precios, duraciones,
teléfono, dirección, calendario, zona horaria.

Dar de alta una clínica nueva = insertar dos filas en Supabase. **No se toca n8n.**

**Qué vive dónde, y por qué:**

- **El prompt base vive en el workflow** (nodo `Construir contexto`). Son las
  reglas del producto: cómo devolver JSON, cuándo derivar a un humano, cómo
  interpretar fechas. Si vive en un solo sitio, al mejorarlo mejora para todas
  las clínicas a la vez.
- **Los datos de cada clínica viven en Supabase.** Si metieras el prompt entero
  en la base de datos, cada clínica tendría su copia y arreglar un fallo
  significaría editarlo N veces.
- Para matices de un cliente concreto ("no hacemos urgencias", "trátales de
  usted") está la columna `instrucciones_extra`, que se añade al final del
  prompt de esa clínica.

---

## 4. Los ficheros

### `Automatizaciones Supabase/` — lo que se usa

| Fichero | Qué es |
|---|---|
| `01 - esquema.sql` … `04 - avisos-error.sql` | Se ejecutan **en orden** en Supabase |
| `Clinica Dental - 01 WhatsApp citas (Supabase).json` | El bot (94 nodos) |
| `Clinica Dental - 02 Recordatorios 24h (Supabase).json` | Recordatorio el día antes |
| `Clinica Dental - 03 Solicitud valoraciones post cita (Supabase).json` | Pide valoración |
| `Clinica Dental - 04 Avisos de error.json` | Te avisa por WhatsApp si algo falla |
| `Clinica Dental - 05 Resumen semanal.json` | Email semanal a la clínica |
| `README.md` | **Guía de instalación paso a paso. Empieza por ahí.** |

### `Demo - automatización whatsapp/` — histórico

La versión vieja con Google Sheets. **No se usa.** Se conserva solo por si
hace falta consultar cómo se hacía algo antes. Se puede borrar sin miedo.

### `Legal/` y `Negocio/`

Documentos para poder vender. Ver el `README.md` de cada carpeta.

---

## 5. Montarlo en un ordenador nuevo

No hay nada que instalar: todo vive en la nube. Lo único local es este repo.

1. Clona/copia esta carpeta.
2. Entra en **n8n Cloud** (los workflows ya están ahí, no hay que reimportarlos
   salvo que quieras restaurar una versión del repo).
3. Entra en **Supabase** (proyecto `Bitclap-multiclinic`, región UE).
4. Si necesitas rehacer algo desde cero, sigue `Automatizaciones Supabase/README.md`.

### Cuentas y dónde están las claves

| Servicio | Para qué | Dónde está la clave |
|---|---|---|
| n8n Cloud | Ejecuta los workflows | Login con tu cuenta |
| Supabase | Base de datos | `service_role` en Project Settings → API |
| Meta for Developers | WhatsApp Business API | Token en la app de Meta |
| Google Calendar | Agenda de la clínica | Credencial OAuth dentro de n8n |
| Gmail | Emails al dentista | Credencial OAuth dentro de n8n |
| Groq | Modelo de IA | API key en la credencial de n8n |

> 🔒 **Ninguna clave está en este repo, y no debe estarlo.** Si alguna vez
> subes una por error, regénerala inmediatamente: el historial de git la
> conserva aunque borres el fichero.

---

## 6. Decisiones ya tomadas (no volver a discutirlas)

- **Supabase en vez de Google Sheets o Airtable.** Sheets se rompe con la
  concurrencia y no tiene integridad de datos. Airtable se encarece rápido por
  usuario. Supabase es PostgreSQL de verdad, con región UE (importante por los
  datos de salud) y capa gratuita suficiente para empezar.
- **Multi-clínica desde el principio**, aunque solo haya un cliente. Migrar
  clientes vivos a una arquitectura nueva más adelante es mucho más caro que
  hacerlo bien ahora.
- **Región UE en Supabase.** Datos de salud de pacientes europeos. No
  cambiable después.
- **Zona horaria configurable por clínica** (`Europe/Madrid`), no escrita en
  el código.
- **Sin panel gráfico.** El resumen semanal por email cubre la necesidad con
  una fracción del trabajo.

---

## 7. Fallos ya corregidos (para no repetirlos)

Se documentan porque son trampas fáciles de volver a pisar:

- **Zona horaria.** El código tenía `Europe/Lisbon` escrito a mano y las citas
  se guardaban una hora tarde. Ahora sale de la configuración de la clínica.
- **Bucle infinito de avisos de error.** WhatsApp manda un *callback de estado*
  por cada mensaje que sale. Esos callbacks entran en el workflow como si
  fueran mensajes. Un nodo de esa rama fallaba → saltaba el aviso de error →
  el aviso generaba más callbacks → más fallos. Decenas de WhatsApps seguidos.
  - **Regla que hay que respetar:** el nodo `Preparar respuesta no texto` debe
    ignorar los callbacks en silencio (`return []`) **antes de hacer nada más**,
    y no puede usar `$('Construir contexto')` porque está en la otra rama del IF.
  - Además hay un **cortafuegos** en el workflow 04: máximo 5 avisos cada 15
    minutos.
- **`$input` no es lo que parece.** En un nodo de código, `$input` es la salida
  del nodo **inmediatamente anterior**. Si insertas un nodo por delante, lo
  rompes sin darte cuenta. Usa `$('Nombre del nodo')` cuando importe.
- **Búsqueda de citas por nombre exacto.** Un paciente que escribía "soy Luis"
  no encontraba su cita de "Luis Ander". Ahora la cita se localiza por
  fecha + hora (que son únicas) y la identidad se comprueba con el teléfono de
  WhatsApp, que no se puede falsear escribiendo.
- **Última cita del día.** Una limpieza de 45 min no cabe a las 20:00 si se
  cierra a las 20:00. El bot lo rechaza bien, pero ahora además lo explica y
  dice a qué hora es la última cita posible.
- **El bot no se callaba al derivar.** Tras mandar una consulta al equipo,
  seguía respondiendo a la IA mientras el paciente esperaba la llamada. Ahora
  se pausa 3 h (configurable) y no llega a llamar al modelo. Ver Parte 6 del
  README de las automatizaciones.
- **`Europe/Lisbon` en los workflows 02 y 03.** Al corregir la zona horaria
  solo se arregló el workflow 01. Los otros dos se quedaron con Lisboa escrito
  a mano. Corregido, y además ya no hay ninguna zona horaria escrita a mano:
  cada cita se evalúa con la `zona_horaria` de su propia clínica.
- **Los cinco workflows ya son multi-clínica (29/08/2026).** El 02 y el 03
  enviaban desde un `phoneNumberId` fijo. Ahora cargan la tabla `clinicas`,
  cruzan por `clinica_id` y envían desde el número de cada una. El único número
  escrito a mano que queda es `PHONE_ID_AVISOS` en el workflow 04, y es a
  propósito: es el canal por el que bitclap te avisa a ti, no un cliente.

---

## 8. Lo que falta

### Antes de vender (bloqueante)

1. **Darte de alta de autónomo.** Sin esto no hay factura legal.
2. **Verificación de negocio en Meta** y sacar la app de modo Desarrollo.
   Hasta entonces el bot no puede escribir a pacientes reales.
3. **Token permanente de Meta.** El token de prueba caduca cada 24 h y rompe
   el bot a diario. Meta Business Suite → Usuarios del sistema → token con
   permiso `whatsapp_business_messaging` sin caducidad.
4. **Revisión legal** de los documentos de `Legal/` por un abogado de
   protección de datos. Se tratan datos de salud (categoría especial del RGPD).

### Riesgo técnico que hay que decidir antes de tener pacientes reales

**El modelo de IA (Groq) es una empresa estadounidense** y por él pasan
mensajes con datos de salud ("me duele una muela y me sangra"). Para datos de
categoría especial conviene revisarlo. Opciones: un proveedor con alojamiento
en la UE, o documentar bien la transferencia en el contrato. Decidirlo antes
de firmar con una clínica, no después.

### Decisión pendiente: sincronizar con la agenda real de la clínica

**No todas las citas entran por WhatsApp.** Muchas llegan por teléfono o en
persona, y las apunta la recepcionista.

**Lo que ya funciona:** el bot consulta Google Calendar antes de reservar. Si
la recepcionista apunta las citas de teléfono **en ese mismo calendario**, el
bot las ve y no puede pisarlas. El fallo grave (dos pacientes a la misma hora)
está cubierto.

**Lo que falta:** Supabase no se entera de esas citas. Consecuencias:
- No se manda recordatorio a los pacientes que reservaron por teléfono, que
  probablemente son la mayoría.
- No se les pide valoración.
- Si uno escribe luego por WhatsApp "quiero cancelar mi cita", el bot no la
  encuentra.
- Y al revés: si la recepcionista borra en Calendar una cita creada por el bot,
  Supabase no se entera y el recordatorio se manda igual.

**Solución:** un workflow 06 que sincronice Google Calendar → Supabase.
**Requisito imprescindible:** que el teléfono del paciente esté en el evento
del calendario, con un formato acordado (`Ana García - 600111222 - Limpieza`).
Sin teléfono no hay recordatorio posible; no es una limitación técnica.

**Antes de construirlo hay que preguntar a la clínica:**
1. ¿Qué usáis hoy para la agenda? ¿Papel, Google Calendar, software dental
   (Gesden, Clinic Cloud, Odontonet...)?
2. ¿Quién apunta las citas de teléfono y dónde?
3. ¿Cuántas citas al día entran por teléfono frente a otras vías?

La respuesta cambia bastante el trabajo, así que no conviene construirlo a
ciegas. Si usan software dental propio, hay que mirar si tiene API — muchos
en España no la tienen o es de pago.

### Mejoras del producto (no bloqueantes)

- 🔴 **Plantillas de WhatsApp para los workflows 02 y 03. Esto sí bloquea.**
  Meta solo deja enviar texto libre dentro de la ventana de 24 h desde el
  último mensaje del paciente. Un recordatorio se manda el día antes de la
  cita, y una valoración justo después: **las dos veces la ventana está
  cerrada**. Con pacientes reales fallarán con el error `131047`.
  En las pruebas no se ve porque tú le escribes al bot constantemente.
  Solución: dar de alta dos plantillas y cambiar el nodo de envío. Textos
  exactos en `Negocio/Meta - todo lo que bloquea.md`, apartado 3.
- **Seguimiento comercial de leads.** Las columnas están en la base de datos
  pero no hay workflow que las use. Es lo que más dinero directo genera a la
  clínica: recuperar interesados que no reservaron.
- **RLS desactivada** en Supabase. Innecesario con una clínica; obligatorio a
  partir de la segunda si algún día hay acceso desde fuera de n8n.
- **Batería de pruebas con lenguaje real:** "a las 3 de la tarde", "pasado
  mañana por la mañana", faltas de ortografía, audios, mensajes ambiguos.
- **Aviso de derivación urgente por WhatsApp** al móvil del dentista, no solo
  por email.
- **WhatsApp es mal canal para las alertas de error.** Meta solo permite
  mensajes libres 24 h después de que tú escribas. Telegram o email son mejores.

---

## 9. Cómo probar que todo sigue bien

La batería completa está en `Automatizaciones Supabase/README.md`, paso 7.
Resumen: reservar → hueco ocupado → modificar → cancelar → lead → derivación →
recordatorio → error → resumen semanal.

**Detalle que cuesta descubrir:** los *Error Workflow* de n8n **solo saltan en
ejecuciones de producción** (workflow activo, disparado por su propio trigger).
Si rompes un nodo y le das a "Execute workflow" a mano, no salta ningún aviso.
Es comportamiento normal de n8n, no un fallo.
