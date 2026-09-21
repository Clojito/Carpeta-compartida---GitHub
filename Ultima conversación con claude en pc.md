# Última conversación con Claude en el PC

> **22 de septiembre de 2026.** Sesión hecha en el PC de sobremesa; sigues
> mañana en el portátil.
>
> Punto de partida: auditoría de la carpeta `Automatizaciones Supabase/`. Salieron
> cinco hallazgos multi-clínica y se arreglaron cuatro (el quinto resultó no ser
> un problema). **Nada de esto está todavía en Supabase ni en n8n**: está en los
> ficheros del repositorio, y los pasos para aplicarlo son los de más abajo.

---

## Lo que he cambiado

| # | Hallazgo | Qué he hecho | Dónde |
|---|---|---|---|
| 1 | RLS solo en 2 tablas de 9 | Activada en las 7 que faltaban, **+ la vista** | `07 - multi-clinica-estricto.sql` |
| 2 | Cortacircuitos global | Ahora cuenta **por punto de fallo** + tope global | Workflow 04, nodo `Decidir si avisar` |
| 3 | `clinica_id` con valor por defecto | Quitado en las 4 tablas | `07 - multi-clinica-estricto.sql` |
| 4 | `envios_fallidos` sin `clinica_id` | Columna + disparador que la rellena solo | `07 - multi-clinica-estricto.sql` |
| 5 | Filtros flojos | `clinica_id` añadido en el 02 y el 03 | Workflows 02 y 03 |

**Un fichero nuevo, tres workflows tocados, tres documentos actualizados.** El
workflow 01, que es el que estás a punto de probar, **no lo he tocado**.

---

## Tres decisiones que tomé por el camino

**El `clinica_id` de `envios_fallidos` lo rellena Postgres, no n8n.** Esa rama del
workflow 01 es la de los callbacks de WhatsApp, la misma que provocó la avalancha
del 08/08. Tiene una regla escrita en el código: no consulta nada y no puede
fallar nunca. Así que puse un disparador en la base de datos, donde no puede
romper nada.

**Tuve que cerrar también la vista `clinicas_config`.** Una vista de Postgres
consulta con los permisos de quien la creó, no de quien la usa. Sin eso, habrías
cerrado `clinicas` y `tratamientos` y se habría seguido leyendo todo a través de
la vista. Va con captura de errores por si tu Postgres fuera antiguo.

**Del hallazgo 5, la parte del workflow 07 me retracto.** Fui a arreglarlo y no
hay nada que arreglar: el webhook solo recibe `id` y `token`, no hay ninguna
clínica con la que comparar. Meter `clinica_id` en el enlace no protege de nada,
porque quien tiene el enlace ya lo tiene entero. El token comparado en tiempo
constante ya es la defensa correcta. **Lo marqué como problema y no lo era.**

---

## Paso a paso, en orden

### Paso 1 — Comprobar la credencial de Supabase (2 min) 🔴

**Este es el único paso que puede romper algo. Hazlo antes que nada.**

1. n8n → **Credentials** → `Supabase account`
2. Mira el campo **Service Role Secret**
3. Tiene que llevar la clave que en Supabase aparece en **Settings → API →
   `service_role`** (la marcada como *secret*), **no** la `anon public`

**Por qué importa:** el SQL activa RLS sin políticas, o sea "nadie puede leer
estas tablas". La `service_role` se salta RLS por diseño y n8n sigue igual. La
`anon` no, y el bot se quedaría sin base de datos.

Si no lo tienes claro, ejecuta solo los apartados 1 y 2 del SQL y deja el 3 para
cuando lo confirmes.

### Paso 2 — Ejecutar el SQL (5 min)

Supabase → **SQL Editor** → **New query** → pega entero
`Automatizaciones Supabase/07 - multi-clinica-estricto.sql` → **RUN**.

**Lee su apartado 0 antes de pulsar.** Y ten localizado el apartado 4: es el
comando exacto para deshacer la RLS si algo va mal.

Te devuelve tres comprobaciones al final:

| Consulta | Qué tiene que salir |
|---|---|
| 5.1 defaults | **Ninguna fila.** Si sale alguna, ese `alter` no se aplicó |
| 5.2 RLS | Las 9 tablas con `rowsecurity = true` |
| 5.3 config | 1 fila con tu clínica y sus 5 tratamientos |

**Si la 5.3 sale vacía, para.** Es la señal de que la credencial es la `anon`.
Ejecuta el apartado 4, corrige la credencial y vuelve.

### Paso 3 — Reimportar los tres workflows (10 min)

Solo el **02**, el **03** y el **04**. Import from File, **encima** de los que ya
tienes.

Después, comprueba en cada uno que ningún nodo tiene el aviso rojo de credencial.

### Paso 4 — Probar que sigue funcionando (10 min)

En este orden:

1. **Escríbele al bot** y reserva una cita. Es la prueba de fuego de la RLS: si el
   bot contesta y la cita aparece en Supabase, todo bien.
2. **Cancélala.** Comprueba las escrituras.
3. **Ejecuta el workflow 04 a mano.** Debe llegarte el WhatsApp de prueba del canal.

Si el paso 1 falla, es la RLS. Apartado 4 del SQL y a revisar la credencial.

---

## Lo que cambia en tu día a día

Solo una cosa, y es a propósito: **al dar de alta una clínica nueva, ahora tienes
que poner su `clinica_id` a mano en los `insert`.** Ya no hay valor por defecto
que lo rellene.

Antes, olvidarlo metía los datos en tu clínica de pruebas sin decir nada. Ahora da
un error inmediato. Es más incómodo y mucho más seguro: mejor que se rompa a que
mienta.

Ya está anotado en el README de las automatizaciones.

---

## Pendiente de decidir

- [ ] **¿Commiteamos ya o revisas antes el SQL?** Quedó sin decidir al cerrar la
      sesión. Si has hecho `commit` y `push` antes de apagar, esto ya está
      resuelto y en el portátil lo tienes todo.

---

## Por dónde seguir mañana

El trabajo de esta sesión es **paralelo** al carril principal, no lo sustituye.
El orden sigue siendo el de `PLAN-DE-ARREGLOS.md`, apartado **"Lo que te toca a
ti"**:

| | Qué | Dónde está |
|---|---|---|
| Paso 1 | Supabase: SQL 06 **y ahora también el 07** | `PLAN-DE-ARREGLOS.md` |
| Paso 2 | Groq: crear la key y la credencial en n8n | `PLAN-DE-ARREGLOS.md` |
| Paso 3 | Importar los 7 workflows en n8n | `PLAN-DE-ARREGLOS.md` |

Y el recordatorio de siempre, que no depende del código: **el dentista lleva
meses sin saber de ti.** El mensaje está escrito y listo en
`Negocio/Mensaje para el dentista.md`. Son 15 minutos y es lo único de todo esto
que de verdad te acerca a cobrar.
