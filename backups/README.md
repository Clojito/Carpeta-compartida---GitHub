# backups — solo historia

> **Nada de esta carpeta se importa en n8n.** Ni una sola vez. Lo que se usa
> está en `Automatizaciones Supabase/`.

Esto existe para poder volver atrás si un cambio sale mal, y para saber cómo
estaba el proyecto en una fecha concreta. Una carpeta por momento, de más
reciente a más antiguo.

| Carpeta | Qué es | Por qué se guardó |
|---|---|---|
| `2026-09-16 - export de n8n (credenciales reales)/` | El workflow 01 tal cual salió de n8n Cloud | Es la referencia de qué identificadores de credencial tiene tu cuenta de verdad. Dentro hay un fichero marcado **NO IMPORTAR**: es la versión anterior al cambio de modelo de IA y al filtro de ámbito |
| `2026-09-16 - antes del filtro de ambito/` | Justo antes de arreglar que el bot escribiera webs y se disculpara en inglés | Por si el filtro de ámbito resultara demasiado estricto |
| `2026-09-15 - antes de los arreglos/` | **El proyecto entero** antes de aplicar la auditoría | Es el punto de retorno grande. También existe como etiqueta de git: `antes-arreglos-2026-09-15` |
| `2026-08-10 - antes de la auditoria/` | Los cinco workflows de agosto | Estaban sueltos en la raíz de `backups/`; se agruparon el 21-sep |
| `2026-06 - version Google Sheets (obsoleta)/` | La primera versión, antes de Supabase | Solo valor histórico. Ya no funciona: las tablas que usaba no existen |

---

## Cómo volver atrás

La forma buena es **git**, no copiar ficheros a mano:

```
git log --oneline            # busca el commit
git checkout <commit> -- "Automatizaciones Supabase/<fichero>.json"
```

Estas carpetas son la red de seguridad por si git no está a mano o te has
llevado el proyecto en un USB.

---

## Cuándo borrarlas

`2026-06 - version Google Sheets (obsoleta)/` se puede borrar cuando quieras:
está en el historial de git desde el primer commit y no aporta nada.

El resto, déjalas hasta que el piloto lleve un mes funcionando.
