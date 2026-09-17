-- ============================================================================
--  bitclap.es  |  Paso 4: registro y cortafuegos de avisos de error
--
--  Ejecutar DESPUES de "03 - optimizaciones.sql".
--  Supabase -> SQL Editor -> New query -> pegar todo -> RUN.
--
--  PARA QUE SIRVE
--  El 08/08/2026 un fallo en el workflow 01 provoco una avalancha de avisos
--  por WhatsApp. El motivo: cada aviso enviado generaba callbacks de estado
--  de WhatsApp, que volvian a entrar en el workflow 01, que volvia a fallar,
--  que mandaba otro aviso... y asi indefinidamente.
--
--  La causa concreta ya esta corregida, pero esta tabla es la red de
--  seguridad: el workflow 04 la consulta antes de enviar y se calla si ya ha
--  avisado demasiado en los ultimos minutos. Asi, ningun fallo futuro
--  (venga de donde venga) puede volver a inundarte el movil.
-- ============================================================================

create table if not exists avisos_error (
  id                uuid primary key default gen_random_uuid(),

  workflow_nombre   text,
  nodo              text,
  error             text,

  -- workflow + nodo + error, recortado. Sirve para no repetir el mismo aviso.
  huella            text,

  -- true  = se envio el WhatsApp
  -- false = se registro pero se silencio (duplicado o tope alcanzado)
  enviado           boolean not null default false,

  creado_en         timestamptz not null default now()
);

create index if not exists avisos_error_recientes_idx
  on avisos_error (enviado, creado_en desc);


-- ----------------------------------------------------------------------------
--  Consultas utiles para ti
-- ----------------------------------------------------------------------------

-- Que ha fallado en las ultimas 24 horas (incluidos los silenciados)
--   select creado_en, workflow_nombre, nodo, error, enviado
--   from avisos_error
--   where creado_en > now() - interval '24 hours'
--   order by creado_en desc;

-- Los fallos mas repetidos de la ultima semana: por aqui se empieza a arreglar
--   select workflow_nombre, nodo, error, count(*) as veces
--   from avisos_error
--   where creado_en > now() - interval '7 days'
--   group by workflow_nombre, nodo, error
--   order by veces desc
--   limit 20;

-- Limpieza (el registro no necesita crecer para siempre)
--   delete from avisos_error where creado_en < now() - interval '90 days';
