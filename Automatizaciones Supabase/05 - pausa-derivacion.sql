-- ============================================================================
--  bitclap.es  |  Paso 5: pausa del bot tras derivar a una persona
--
--  Ejecutar DESPUES de "04 - avisos-error.sql".
--  Supabase -> SQL Editor -> New query -> pegar todo -> RUN.
--
--  PARA QUE SIRVE
--  Cuando el bot deriva una consulta al equipo de la clinica, hasta ahora
--  seguia contestando al paciente mientras esperaba la llamada. Ese es
--  justo el peor momento para que responda una maquina: el paciente esta
--  describiendo un problema de salud y espera ayuda.
--
--  Con esto, el bot se calla durante un tiempo despues de cada derivacion.
--  No desaparece: si el paciente insiste, le recuerda que le van a llamar y
--  le da el telefono de urgencias. Y si lo que quiere es gestionar una cita,
--  el bot sigue atendiendole con normalidad.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. Cuanto tiempo se calla el bot, configurable por clinica
--    180 minutos (3 horas) es un valor razonable para empezar: suficiente
--    para que la clinica llame, sin dejar al paciente sin bot todo el dia.
-- ----------------------------------------------------------------------------
alter table clinicas
  add column if not exists pausa_derivacion_minutos int not null default 180;


-- ----------------------------------------------------------------------------
-- 2. Indice para localizar rapido las derivaciones pendientes de un paciente
-- ----------------------------------------------------------------------------
create index if not exists derivaciones_pendientes_idx
  on derivaciones (clinica_id, creado_en desc)
  where estado = 'pendiente';


-- ----------------------------------------------------------------------------
-- 3. Rehacer la vista para que incluya la columna nueva
--
--    OJO: hay que borrarla y volver a crearla. Una vista de Postgres congela
--    su lista de columnas al crearse, asi que "create or replace" no basta
--    cuando la tabla de debajo gana una columna nueva.
-- ----------------------------------------------------------------------------
drop view if exists clinicas_config;

create view clinicas_config as
select
  c.*,
  coalesce(
    (
      select jsonb_agg(
               jsonb_build_object(
                 'nombre',           t.nombre,
                 'precio_texto',     t.precio_texto,
                 'duracion_minutos', t.duracion_minutos,
                 'nota',             t.nota,
                 'sinonimos',        t.sinonimos,
                 'orden',            t.orden,
                 'activo',           t.activo
               )
               order by t.orden, t.nombre
             )
      from tratamientos t
      where t.clinica_id = c.id
        and t.activo = true
    ),
    '[]'::jsonb
  ) as tratamientos
from clinicas c;


-- ----------------------------------------------------------------------------
--  Comprobacion: debe salir la clinica con 5 tratamientos y la pausa en 180
-- ----------------------------------------------------------------------------
select nombre,
       pausa_derivacion_minutos,
       jsonb_array_length(tratamientos) as num_tratamientos
from clinicas_config;


-- ----------------------------------------------------------------------------
--  Util para el dia a dia
-- ----------------------------------------------------------------------------

-- Consultas que siguen sin atender (el bot esta callado con estos pacientes)
--   select creado_en, nombre, telefono, motivo, resumen
--   from derivaciones
--   where estado = 'pendiente'
--   order by creado_en desc;

-- Reactivar el bot para un paciente concreto antes de que pase el tiempo:
-- basta con marcar su derivacion como atendida.
--   update derivaciones
--   set estado = 'atendida', cerrado_en = now()::text
--   where telefono = '34600111222' and estado = 'pendiente';
