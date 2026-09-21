# bitclap.es — mapa del repositorio

Chatbot de WhatsApp para clínicas dentales. Esta carpeta es todo el proyecto:
automatizaciones, base de datos, legal, comercial y pruebas.

---

## Si acabas de abrir esto, lee en este orden

| | Fichero | Para qué | Tiempo |
|---|---|---|---|
| 1 | [ESTADO-DEL-PROYECTO.md](ESTADO-DEL-PROYECTO.md) | Qué hay, qué funciona y por qué se decidió cada cosa | 5 min |
| 2 | [PLAN-DE-ARREGLOS.md](PLAN-DE-ARREGLOS.md) | **El documento del día a día.** Qué te toca y en qué orden | 10 min |
| 3 | [AUDITORIA-2026-09-08.md](AUDITORIA-2026-09-08.md) | Solo si necesitas el porqué de algo concreto | a demanda |

---

## Las carpetas

| Carpeta | Qué hay dentro |
|---|---|
| **[Automatizaciones Supabase/](Automatizaciones%20Supabase/)** | ⭐ **Lo único que se importa en n8n.** Los 7 workflows, los 6 SQL en orden y el `README.md` con la instalación paso a paso |
| [Legal/](Legal/) | Contratos, política de privacidad, RAT, EIPD y los textos RGPD del bot |
| [Negocio/](Negocio/) | Precios, plan comercial, mensaje al dentista, Meta y las decisiones tomadas |
| [Operacion/](Operacion/) | Guía para recepción, guía para el dentista y el runbook de "algo se ha roto" |
| [Pruebas/](Pruebas/) | Batería de mensajes para romper el bot + el simulador automático |
| [backups/](backups/) | 🗄️ **Solo historia.** Nada de aquí se importa nunca |

---

## Regla de oro

> **Los workflows que se usan viven SOLO en `Automatizaciones Supabase/`.**
> Si te encuentras un `.json` fuera de esa carpeta, es historia y no se importa.

Hasta el 21 de septiembre de 2026 había **tres copias del workflow 01**
repartidas en dos carpetas, y una estaba desactualizada (sin el modelo de IA
nuevo y sin el filtro de ámbito). Importar la equivocada deshacía un mes de
trabajo sin que saltara ningún aviso. Por eso ahora hay una sola.

---

## Los siete workflows

Todos comparten los mismos identificadores de credencial, así que al importar
deberían quedar conectados solos.

| | Workflow | Estado previsto en el piloto |
|---|---|---|
| 01 | WhatsApp citas | 🟢 Activo — es el bot |
| 02 | Recordatorios 24 h | 🟢 Activo cuando la plantilla esté aprobada |
| 03 | Solicitud de valoraciones | ⚪ Apagado (fuera del alcance del piloto) |
| 04 | Avisos de error | 🟢 Activo — es tu alarma |
| 05 | Resumen semanal | ⚪ Apagado (fuera del alcance del piloto) |
| 06 | Email diario "Hoy" | 🟢 Activo — lo que lee la clínica cada mañana |
| 07 | Marcar derivación atendida | 🟢 Activo — el botón del email |

> Si al importar algún nodo sale en rojo pidiendo credencial, es un desplegable:
> elige la que corresponde por nombre (`Supabase account`, `WhatsApp account`,
> `Gmail account`, `Google Calendar account`, `Groq account`) y guarda.

---

## Lo que no está aquí

🔒 **Ninguna clave, token ni contraseña está en este repositorio, y no debe
estarlo.** Si alguna vez subes una por error, regenérala inmediatamente: el
historial de git la conserva aunque borres el fichero.

Los secretos viven en n8n (Credentials), en Supabase y en el Administrador de
Meta. Aquí solo hay identificadores, que no sirven para entrar en ningún sitio.
