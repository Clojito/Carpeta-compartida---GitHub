# Runbook — qué hacer cuando algo falla

Para ti. Ordenado por síntoma. Escrito el 15-sep-2026 para la versión con
Groq (gpt-oss) y los workflows 01 a 07.

---

## 0. Dónde mirar primero

1. **n8n → Executions** del workflow afectado. La ejecución en rojo dice qué
   nodo falló y con qué error.
2. **Supabase → tabla `avisos_error`**: todo lo que ha fallado, incluidos los
   avisos silenciados por el cortafuegos.
3. **Supabase → tabla `envios_fallidos`**: mensajes que WhatsApp no entregó.
4. Tu WhatsApp o tu email: avisos del workflow 04.

## 1. "El bot no contesta"

| Lo que ves | Causa probable | Arreglo |
|---|---|---|
| No aparecen ejecuciones nuevas del 01 | El 01 está desactivado, o Meta ha perdido la suscripción del webhook | Activa el 01. En Meta for Developers → WhatsApp → Configuración → Webhook: comprueba la URL y que el campo `messages` esté suscrito |
| Ejecución en rojo en `Enviar WhatsApp` con error 190 u `OAuthException` | Token de Meta caducado | Apartado 2.1 |
| El paciente recibe "ahora mismo no puedo atenderte por aquí" | La IA falla | Apartado 2.2 |
| Error `invalid_grant` en un nodo de Google Calendar o Gmail | Token de Google caducado | Apartado 2.3 |
| Error en nodos de Supabase o "project paused" | Supabase pausado | Apartado 2.4 |
| Error "No hay ninguna clinica dada de alta para este numero" | `clinicas.telefono_whatsapp_id` no coincide con el número que recibe | Corrige la fila en `clinicas` |

## 2. Regenerar cada credencial

### 2.1 WhatsApp (Meta)

1. Business Manager → Configuración del negocio → Usuarios del sistema → tu
   usuario → **Generar token** → tu app → permisos
   `whatsapp_business_messaging` y `whatsapp_business_management` → caducidad
   **Nunca**.
2. n8n → Credentials → **WhatsApp account** → pega el token. Es una sola
   credencial para los siete workflows.

El disparador del 01 usa otra credencial, **WhatsApp OAuth account** (App ID y
App Secret). Solo hay que tocarla si regeneras el secreto de la app.

### 2.2 Groq (IA)

- Error **401**: la API key no vale. console.groq.com → API Keys → crea una
  nueva → n8n → Credentials → **Groq account**.
- Error **429** (*rate limit*) o **413** (*Request too large ... tokens per
  minute*): es el límite gratuito, 8.000 tokens por minuto por modelo. Si pasa a
  menudo, no subas "Maximum Number of Tokens" por encima de 2000 y pasa al pago
  por uso (console.groq.com → Settings → Billing, menos de 1 $/mes por clínica).
- Error de **modelo retirado** (*model_decommissioned*): mira
  console.groq.com/docs/deprecations, elige el sustituto en el nodo
  `Groq Chat Model` y pasa los bloques C y H de la batería. **Es exactamente lo
  que pasó con Llama 3.3 el 16-ago.** Mientras tanto contesta el modelo de
  reserva (`gpt-oss-20b`), salvo que lo hayan retirado a la vez.

### 2.3 Google Calendar y Gmail

- Si caduca cada 7 días: Google Cloud Console → APIs y servicios → Pantalla de
  consentimiento OAuth → **Publicar la app** (pasar a "In production").
- Luego, en n8n, abre la credencial y pulsa **Reconnect**.

### 2.4 Supabase

- Proyecto pausado: Dashboard → **Restore**. Con el plan Pro no se pausa.
- Clave `service_role` filtrada: Project Settings → API → **Regenerate** → pégala
  en n8n, credencial **Supabase account**. Y ve al apartado 3, "brecha".

## 3. Situaciones concretas

**Un paciente dice que no le llegó el recordatorio.**
Mira `envios_fallidos` y las ejecuciones del 02 (si hay rechazos, termina en
rojo en `Avisar fallos recordatorio`). Códigos habituales:
- `131047`: se envió texto libre fuera de la ventana de 24 h. La plantilla no se
  usó o no estaba aprobada.
- `132001`: la plantilla no existe con ese nombre o ese idioma. Revisa
  `IDIOMA_PLANTILLA` en `Preparar recordatorios`.
- `131026`: ese número no tiene WhatsApp.

**El bot se ha quedado callado con un paciente.**
Tiene una derivación pendiente. La clínica debe pulsar "Marcar como atendida"
en el email. Si es una derivación anterior al 15-sep (sin botón), usa el SQL de
la Parte 6 del README de las automatizaciones.

**El bot contesta cosas que no son de la clínica** (código, sumas, una receta),
**o responde en inglés.**
El filtro está en el nodo `Normalizar y enrutar` del workflow 01, en el bloque
`// ambito`. Si se cuela algo nuevo:
1. Copia el mensaje del paciente tal cual.
2. Si el bot no debería haber entrado al trapo, añade el patrón a
   `PATRONES_FUERA_DE_AMBITO`.
3. Si el problema es la respuesta (código, inglés), mira `respuestaSegura`.
4. Pasa `Pruebas/automaticas/simular-workflows.js` y el bloque P de la batería.

Ojo: el filtro es la red de seguridad, no la solución. Si pasa a menudo, el
modelo se está saltando el prompt: es motivo para cambiar de modelo, no para
seguir añadiendo parches.

**Llega una avalancha de avisos.**
El cortafuegos del 04 corta en 5 avisos cada 15 minutos. Busca en
`avisos_error` el fallo más repetido y desactiva el workflow que falla hasta
arreglarlo.

**La clínica pide borrar los datos de un paciente.**
Espera a tenerlo por escrito. Ejecuta el SQL que hay al final de
`06 - pacientes-y-cumplimiento.sql`, borra sus eventos de Google Calendar y
revisa el historial de ejecuciones de n8n.

**Brecha de seguridad** (una clave filtrada, un acceso que no reconoces):
1. Regenera la clave afectada.
2. Apunta la fecha, qué ha pasado y qué datos pueden estar afectados.
3. **Avisa a la clínica en menos de 24 horas** (contrato de encargado, cláusula
   3.g). La clínica decide si notifica a la AEPD, y tiene 72 horas para hacerlo.

**Hay que apagar el bot ya.**
Desactiva el workflow 01 en n8n. Ojo: los pacientes que escriban no recibirán
ninguna respuesta. Avisa a la clínica para que estén pendientes del teléfono.

## 4. Antes de tocar un workflow que está en producción

1. Descárgalo desde n8n (⋯ → Download) y guárdalo en `backups/` con la fecha.
2. Si tocas el código de un nodo, pasa `Pruebas/automaticas/simular-workflows.js`.
3. Prueba con tu número antes que con nadie.
4. Comprueba que sigue teniendo el Error Workflow puesto (Settings).
