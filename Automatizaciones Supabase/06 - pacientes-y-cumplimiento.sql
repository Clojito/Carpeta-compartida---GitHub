-- ============================================================================
--  bitclap.es  |  Paso 6: pacientes, aviso de IA/RGPD, bajas y envios fallidos
--
--  Ejecutar DESPUES de "05 - pausa-derivacion.sql".
--  Supabase -> SQL Editor -> New query -> pegar todo -> RUN.
--  Se puede ejecutar varias veces sin romper nada.
--
--  PARA QUE SIRVE
--  Hasta ahora no existia la idea de "paciente": solo citas, leads y
--  derivaciones sueltas. Sin ella no habia donde apuntar tres cosas que son
--  obligacion legal desde el primer paciente real:
--
--    1. Que se le informo, la primera vez que escribio, de que habla con un
--       sistema automatico (art. 50 del Reglamento europeo de IA, en vigor
--       desde el 2-ago-2026) y de como se tratan sus datos (arts. 13-14 RGPD).
--    2. Que ha pedido que no le escribamos mas (opt-out). Antes, "stop" solo
--       cerraba un lead y al dia siguiente le llegaba el recordatorio igual.
--    3. Que un mensaje nuestro no le llego (callback "failed" de WhatsApp).
--       Antes se descartaban en silencio.
--
--  Ademas prepara dos columnas que usan los workflows nuevos:
--    - clinicas.url_privacidad: enlace a la politica de privacidad de la
--      clinica, que sale en el aviso de primer contacto.
--    - derivaciones.token_cierre: el codigo secreto del enlace
--      "Marcar como atendida" de los emails.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. PACIENTES
--    Una fila por telefono y clinica. La crea el workflow 01 la primera vez
--    que ese telefono escribe a esa clinica, justo cuando le manda el aviso.
-- ----------------------------------------------------------------------------
create table if not exists pacientes (
  id                  uuid primary key default gen_random_uuid(),
  clinica_id          uuid not null references clinicas(id),

  -- Mismo formato que citas.telefono: el "from" de WhatsApp, solo digitos y
  -- con prefijo de pais (ej. 34600111222). Asi se cruzan sin conversiones.
  telefono            text not null,
  nombre              text,

  primer_contacto_en  timestamptz not null default now(),

  -- Cuando se le envio el aviso de "soy un asistente automatico" + RGPD.
  -- Si alguna vez te preguntan "como demuestras que se le informo", es esto.
  informado_rgpd_en   timestamptz,

  -- true = no quiere mensajes que inicie el sistema (recordatorios,
  -- valoraciones). Si el escribe, se le sigue contestando.
  opt_out             boolean not null default false,
  -- Fecha del ultimo cambio de opt_out (baja o vuelta de alta).
  opt_out_en          timestamptz,

  creado_en           timestamptz not null default now(),

  unique (clinica_id, telefono)
);

create index if not exists pacientes_bajas_idx
  on pacientes (clinica_id)
  where opt_out = true;


-- ----------------------------------------------------------------------------
-- 2. Enlace a la politica de privacidad de cada clinica
--    Si esta vacio, el aviso de primer contacto dice que la informacion se
--    pide en la clinica. Rellenalo antes del primer paciente real:
--      update clinicas set url_privacidad = 'https://...' where id = '...';
-- ----------------------------------------------------------------------------
alter table clinicas add column if not exists url_privacidad text;


-- ----------------------------------------------------------------------------
-- 3. Token para cerrar derivaciones desde el email
--    El enlace "Marcar como atendida" lleva el derivacion_id y este token.
--    Sin el token correcto no se puede cerrar nada, aunque se adivine el id.
-- ----------------------------------------------------------------------------
alter table derivaciones add column if not exists token_cierre text;


-- ----------------------------------------------------------------------------
-- 4. ENVIOS FALLIDOS
--    Cada vez que WhatsApp avisa de que un mensaje nuestro NO se entrego
--    (status = failed), el workflow 01 lo apunta aqui. El caso tipico es el
--    error 131047: se intento mandar texto libre fuera de la ventana de 24 h.
--
--    Solo se registra, no se avisa por WhatsApp: si el aviso tambien fallara
--    (y fuera de ventana fallaria), generaria otro "failed" y volveria a
--    empezar el bucle del 08/08/2026.
-- ----------------------------------------------------------------------------
create table if not exists envios_fallidos (
  id               uuid primary key default gen_random_uuid(),
  phone_number_id  text,     -- numero de WhatsApp de la clinica que envio
  destinatario     text,     -- telefono del paciente
  wamid            text,     -- id del mensaje en WhatsApp
  codigo_error     text,
  titulo_error     text,
  detalle_error    text,
  creado_en        timestamptz not null default now()
);

create index if not exists envios_fallidos_recientes_idx
  on envios_fallidos (creado_en desc);


-- ----------------------------------------------------------------------------
-- 5. Seguridad de las tablas nuevas
--    RLS activada SIN politicas: nadie puede leerlas con la clave publica
--    (anon), y n8n sigue funcionando porque usa la clave service_role, que
--    salta RLS por diseno. No rompe nada y cierra la puerta a los datos.
-- ----------------------------------------------------------------------------
alter table pacientes       enable row level security;
alter table envios_fallidos enable row level security;


-- ----------------------------------------------------------------------------
-- 6. Rehacer la vista para que incluya url_privacidad
--    (misma razon que en el paso 5: una vista congela sus columnas al crearse)
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
--  Comprobacion: debe salir la clinica con sus tratamientos y url_privacidad
--  (vacia hasta que la rellenes), y las dos tablas nuevas con 0 filas.
-- ----------------------------------------------------------------------------
select nombre,
       url_privacidad,
       jsonb_array_length(tratamientos) as num_tratamientos,
       (select count(*) from pacientes)       as pacientes,
       (select count(*) from envios_fallidos) as envios_fallidos
from clinicas_config;


-- ----------------------------------------------------------------------------
--  Util para el dia a dia
-- ----------------------------------------------------------------------------

-- Quien ha pedido no recibir mensajes
--   select telefono, nombre, opt_out_en from pacientes
--   where opt_out = true order by opt_out_en desc;

-- Mensajes que no llegaron en la ultima semana
--   select creado_en, destinatario, codigo_error, titulo_error, detalle_error
--   from envios_fallidos
--   where creado_en > now() - interval '7 days'
--   order by creado_en desc;

-- Un paciente pide que borremos sus datos (lo decide la clinica, que es la
-- responsable; tu lo ejecutas cuando te lo pida por escrito):
--   delete from citas        where clinica_id = '...' and telefono = '34600111222';
--   delete from lista_espera where clinica_id = '...' and telefono = '34600111222';
--   delete from leads        where clinica_id = '...' and telefono = '34600111222';
--   delete from derivaciones where clinica_id = '...' and telefono = '34600111222';
--   delete from pacientes    where clinica_id = '...' and telefono = '34600111222';
--   (Los eventos de Google Calendar y el historial de n8n se borran aparte.)
