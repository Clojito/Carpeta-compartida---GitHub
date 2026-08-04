# Automatizaciones con Supabase — bitclap.es

Versión de las 3 automatizaciones de Clínica Lisboa con **Supabase** en lugar de Google Sheets.
La lógica del bot **no ha cambiado**: solo cambia dónde se guardan los datos.

## Qué hay en esta carpeta

| Archivo | Qué es |
|---|---|
| `01 - esquema.sql` | Las tablas de la base de datos. Se ejecuta una vez. |
| `Clinica Dental - 01 WhatsApp citas (Supabase).json` | El bot principal (92 nodos, 21 de ellos Supabase). |
| `Clinica Dental - 02 Recordatorios 24h (Supabase).json` | Recordatorio el día antes. |
| `Clinica Dental - 03 Solicitud valoraciones post cita (Supabase).json` | Pide valoración al terminar la cita. |

---

## Paso 1 — Crear el proyecto en Supabase

1. Entra en [supabase.com](https://supabase.com) y crea una cuenta (el plan gratis sobra para empezar).
2. **New project**. Te pedirá tres cosas:
   - **Name**: `bitclap-produccion`
   - **Database password**: genera una larga y **guárdala en tu gestor de contraseñas**. Solo se muestra una vez.
   - **Region**: elige **Central EU (Frankfurt)** o **West EU (Ireland)**.

> ⚠️ **La región importa y no se puede cambiar después.** Estás tratando datos de salud de pacientes europeos (dolor, sangrado, medicación, embarazo…). Tenerlos alojados en la UE te quita de encima el problema de las transferencias internacionales de datos del RGPD. No elijas una región de EE. UU.

3. Espera ~2 minutos a que el proyecto termine de crearse.

## Paso 2 — Crear las tablas

1. En el menú lateral: **SQL Editor** → **New query**.
2. Abre `01 - esquema.sql`, copia **todo** el contenido y pégalo.
3. Pulsa **Run** (o Ctrl+Enter).
4. Ve a **Table Editor**. Deberías ver 5 tablas: `clinicas`, `citas`, `lista_espera`, `leads`, `derivaciones`.
5. Abre `clinicas`: tiene que haber 1 fila con "Clinica Dental Salud Lisboa".

Si algo falla, el error sale en rojo abajo. El script se puede volver a ejecutar sin romper nada.

## Paso 3 — Coger las claves de conexión

1. Menú lateral: **Project Settings** (el engranaje) → **API**.
2. Apunta estos dos valores:
   - **Project URL** → algo como `https://abcdefgh.supabase.co`
   - **service_role** (en "Project API keys") → pulsa *Reveal* y cópiala.

> 🔒 **La clave `service_role` es la llave maestra**: salta todas las reglas de seguridad y puede leer y borrar cualquier cosa. Va **únicamente** dentro de n8n. Nunca la pongas en una web, una app, un panel para la clínica, ni la mandes por WhatsApp o email. Si alguna vez se filtra, se regenera desde esta misma pantalla.
>
> La otra clave (`anon`) es la que sí se puede usar en un panel para la clínica el día que lo montes.

## Paso 4 — Conectar Supabase con n8n

1. En n8n: **Credentials** → **Add credential** → busca **Supabase API**.
2. Rellena:
   - **Host**: el *Project URL* del paso anterior
   - **Service Role Secret**: la clave `service_role`
3. Ponle de nombre `Supabase account` y guarda.

## Paso 5 — Importar los 3 workflows

Para cada uno de los 3 archivos `.json`:

1. En n8n: **Workflows** → **Import from File**.
2. Selecciona el archivo.
3. Los nodos morados de Supabase saldrán con un aviso de credencial. **Abre uno**, en el desplegable de credenciales elige `Supabase account` que acabas de crear, y n8n lo aplicará al resto de nodos iguales.
4. Repasa también las credenciales de **WhatsApp**, **Google Calendar** y **Gmail** (esas no han cambiado respecto a tus workflows actuales).

## Paso 6 — Google Calendar

Los nodos de calendario apuntan al calendario de pruebas. Cuando trabajes con la clínica real:

1. La clínica entra en su Google Calendar → **Configuración y uso compartido**.
2. **Compartir con determinadas personas** → añade tu cuenta de Google (la que tienes conectada a n8n) con permiso **"Hacer cambios en los eventos"**.
3. En n8n, en cada nodo de Google Calendar, selecciona ese calendario en el desplegable.

No necesitas la contraseña de nadie. Es el mismo gesto que compartir una carpeta de Drive.

## Paso 7 — Probar, en este orden

Prueba con **tu propio número** antes de enseñárselo a nadie:

1. **Reservar** — "Hola, quiero una cita para una limpieza mañana a las 16:00 a nombre de Luis Ander".
   → Comprueba: fila nueva en `citas`, evento en Google Calendar, WhatsApp de confirmación, email al dentista.
2. **Hueco ocupado** — pide la misma hora otra vez con otro nombre.
   → Comprueba: fila nueva en `lista_espera`.
3. **Modificar** — "Quiero cambiar mi cita de mañana a las 16:00 a las 18:00".
   → Comprueba: la fila vieja pasa a `modificada`, hay una fila nueva `confirmada`, y el de la lista de espera recibe aviso.
4. **Cancelar** → la fila pasa a `cancelada` y el evento desaparece del calendario.
5. **Lead** — "¿Cuánto cuesta la ortodoncia?" → fila nueva en `leads`.
6. **Derivación** — "Me duele una muela y me sangra" → fila nueva en `derivaciones` + email al dentista.
7. **Recordatorio** — deja una cita para mañana y ejecuta el workflow 02 a mano ("Test workflow").
8. **Valoración** — crea una cita en el pasado reciente y ejecuta el workflow 03 a mano.

Activa los workflows (interruptor arriba a la derecha) solo cuando los 8 pasos vayan bien.

---

## Qué cambió respecto a la versión con Google Sheets

**Nombres de columnas** (Postgres se lleva mal con espacios y mayúsculas):

| Antes (Sheets) | Ahora (Supabase) |
|---|---|
| `Numero de telefono` | `telefono` |
| `Event ID` | `event_id` |

Todo lo demás mantiene el mismo nombre.

**Tipos de datos reales.** `fecha` es una fecha de verdad, `valoracion` es un número del 1 al 5 (la base de datos rechaza un 7), y `recordatorio_24h` / `valoracion_solicitada` pasan de ser el texto `"si"`/`"no"` a ser casillas `true`/`false`. El código acepta los dos formatos por si alguna vez migras filas a mano.

**Un fallo corregido.** El workflow 03 tenía su propia tabla de duraciones que **no coincidía** con la del workflow 01 (Limpieza 60 vs 45 min, Empaste 45 vs 60 min). Como esa duración se usa para calcular cuándo termina la cita, la petición de valoración salía hasta 15 minutos antes o después de lo debido. Ahora el workflow 03 lee la columna `duracion_minutos` que ya guarda el workflow 01, así que **solo hay una fuente de verdad** y el fallo no puede repetirse.

**Protección contra doble reserva.** Google Calendar sigue decidiendo si un hueco está libre, pero ahora la base de datos además impide físicamente guardar dos citas confirmadas a la misma hora el mismo día. Si dos personas piden el mismo hueco a la vez, la segunda da error visible en n8n en lugar de crear dos citas solapadas.

**Orden justo de la lista de espera.** El aviso de hueco libre va a quien lleva más tiempo esperando. Antes eso dependía de un texto con formato `dd/MM/yyyy`; ahora la marca de tiempo la pone la propia base de datos.

---

## Lo que queda pendiente (no bloquea salir con el primer cliente)

- **`clinica_id` está en todas las tablas pero aún no se rellena desde n8n.** Se queda con el valor por defecto de tu primera clínica. Es intencionado: la columna existe desde el día 1 para que la clínica número 2 sea *añadir una fila*, no rediseñar la base de datos.
- **RLS (seguridad por fila) está desactivada.** No hace falta con una sola clínica. El SQL trae las instrucciones comentadas para el día que la actives.
- **El nodo "Buscar citas paciente reserva" se trae todas las citas confirmadas en cada reserva.** Funciona igual que antes, pero con miles de citas conviene filtrar también por teléfono en la consulta.
- **Los precios, horarios y tratamientos siguen escritos a mano** en el prompt del agente y en el nodo "Normalizar y enrutar". Ese es el trabajo de la refactorización multi-clínica, no de este cambio de base de datos.
