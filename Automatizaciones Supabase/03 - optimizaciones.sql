-- ============================================================================
--  bitclap.es  |  Paso 3: optimizaciones
--
--  Ejecutar DESPUES de "02 - multi-clinica.sql".
--  Supabase -> SQL Editor -> New query -> pegar todo -> RUN.
-- ============================================================================


-- ----------------------------------------------------------------------------
--  Vista clinicas_config
--
--  Devuelve la clinica CON sus tratamientos ya incrustados en una sola fila.
--
--  Por que: al hacer el workflow multi-clinica, cada mensaje de WhatsApp
--  necesitaba dos consultas a Supabase (una para la clinica y otra para sus
--  tratamientos). Con esta vista es UNA sola. Se ahorra un viaje de ida y
--  vuelta a la base de datos en cada mensaje que entra.
--
--  Para n8n una vista se consulta igual que una tabla.
-- ----------------------------------------------------------------------------
create or replace view clinicas_config as
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
--  Indice para la busqueda de citas duplicadas
--
--  El workflow, antes de crear una reserva, busca otras citas confirmadas del
--  mismo paciente. Ahora esa consulta filtra tambien por fecha (solo mira
--  citas de hoy en adelante), asi que este indice la deja en microsegundos
--  aunque la tabla tenga anos de historico.
-- ----------------------------------------------------------------------------
create index if not exists citas_futuras_confirmadas_idx
  on citas (clinica_id, fecha)
  where estado = 'confirmada';


-- ----------------------------------------------------------------------------
--  Comprobacion: debe devolver la clinica con sus 5 tratamientos dentro
-- ----------------------------------------------------------------------------
select nombre, zona_horaria, jsonb_array_length(tratamientos) as num_tratamientos
from clinicas_config;
