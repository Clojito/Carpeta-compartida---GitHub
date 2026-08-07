-- ============================================================================
--  bitclap.es  |  Paso 2: convertir la base de datos en multi-clinica
--
--  Este archivo se ejecuta DESPUES de "01 - esquema.sql".
--  Anade a la tabla clinicas todo lo que hoy esta escrito a mano dentro del
--  workflow (nombre, precios, horarios, telefono, zona horaria...) y crea la
--  tabla de tratamientos.
--
--  A partir de aqui, dar de alta una clinica nueva = insertar filas aqui.
--  No se toca n8n.
--
--  COMO USARLO: Supabase -> SQL Editor -> New query -> pegar todo -> RUN.
--  Se puede ejecutar varias veces sin romper nada.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. Nuevos campos de configuracion de cada clinica
-- ----------------------------------------------------------------------------
alter table clinicas add column if not exists nombre_asistente     text not null default 'Sara';
alter table clinicas add column if not exists direccion            text;
alter table clinicas add column if not exists telefono_publico     text;
alter table clinicas add column if not exists duracion_por_defecto integer not null default 60;
alter table clinicas add column if not exists idiomas              text not null default 'español, portugués, inglés o francés';
alter table clinicas add column if not exists instrucciones_extra  text;

-- Horario de apertura, un bloque por dia de la semana.
-- La clave es el numero de dia igual que en JavaScript: 0 = domingo, 6 = sabado.
-- null = ese dia la clinica esta cerrada.
alter table clinicas add column if not exists horarios jsonb not null default '{
  "0": null,
  "1": {"apertura": "09:00", "cierre": "20:00"},
  "2": {"apertura": "09:00", "cierre": "20:00"},
  "3": {"apertura": "09:00", "cierre": "20:00"},
  "4": {"apertura": "09:00", "cierre": "20:00"},
  "5": {"apertura": "09:00", "cierre": "20:00"},
  "6": {"apertura": "09:00", "cierre": "14:00"}
}'::jsonb;


-- ----------------------------------------------------------------------------
-- 2. Tratamientos que ofrece cada clinica
--    Sustituye a la lista de precios del prompt Y a la tabla de duraciones
--    que estaba repetida dentro del codigo. Una sola fuente de verdad.
-- ----------------------------------------------------------------------------
create table if not exists tratamientos (
  id                uuid primary key default gen_random_uuid(),
  clinica_id        uuid not null references clinicas(id) on delete cascade,

  nombre            text not null,          -- 'Revision'  (como se escribe en la cita)
  precio_texto      text,                   -- '30€'  o  'desde 1.500€'
  duracion_minutos  integer not null default 60,
  nota              text,                   -- 'primera visita', etc.

  -- Como puede escribirlo el paciente, en cualquier idioma y sin tildes.
  -- El bot usa esta lista para reconocer el tratamiento en el mensaje.
  sinonimos         text[] not null default '{}',

  activo            boolean not null default true,
  orden             integer not null default 0,

  creado_en         timestamptz not null default now(),

  unique (clinica_id, nombre)
);

create index if not exists tratamientos_clinica_idx on tratamientos (clinica_id, activo, orden);


-- ----------------------------------------------------------------------------
-- 3. Datos de tu primera clinica
--
--  >>> ZONA HORARIA <<<
--  Aqui esta el fallo de la hora que se guardaba con 1 hora de diferencia.
--  El codigo usaba 'Europe/Lisbon' (Portugal), que en verano va una hora por
--  detras de Espana. Al reservar las 18:00 se guardaba el instante que en
--  Espana son las 19:00, y asi lo mostraba Google Calendar.
--
--  Lo dejo en 'Europe/Madrid' porque tu clinica y tu calendario son espanoles.
--  Si algun dia das de alta una clinica portuguesa de verdad, esa fila lleva
--  'Europe/Lisbon' y las dos conviven sin tocar nada mas.
-- ----------------------------------------------------------------------------
update clinicas set
  nombre            = 'Clinica Dental Salud Lisboa',
  nombre_asistente  = 'Sara',
  direccion         = 'Calle Mayor 123, Lisboa',
  telefono_publico  = '912 345 678',
  zona_horaria      = 'Europe/Madrid',
  -- OJO: pon aqui el Google Calendar real que hayas compartido con tu
  -- credencial de n8n. Si esta vacio, los nodos de Google Calendar del
  -- workflow 01 fallan con "Please enter a valid mode" porque reciben un
  -- calendario vacio.
  calendar_id       = 'prueb4sn8n.pruebas@gmail.com',
  duracion_por_defecto = 60,
  horarios = '{
    "0": null,
    "1": {"apertura": "09:00", "cierre": "20:00"},
    "2": {"apertura": "09:00", "cierre": "20:00"},
    "3": {"apertura": "09:00", "cierre": "20:00"},
    "4": {"apertura": "09:00", "cierre": "20:00"},
    "5": {"apertura": "09:00", "cierre": "20:00"},
    "6": {"apertura": "09:00", "cierre": "14:00"}
  }'::jsonb
where id = '11111111-1111-1111-1111-111111111111';


-- ----------------------------------------------------------------------------
-- 4. Tratamientos de esa clinica
--    Los precios y duraciones son exactamente los que estaban en el prompt
--    y en el codigo del workflow 01.
-- ----------------------------------------------------------------------------
insert into tratamientos (clinica_id, nombre, precio_texto, duracion_minutos, nota, sinonimos, orden) values
  ('11111111-1111-1111-1111-111111111111', 'Revision',       '30€',          30, null,
   array['revision','revision dental','revisao','checkup','check-up'], 1),

  ('11111111-1111-1111-1111-111111111111', 'Limpieza',       '50€',          45, null,
   array['limpieza','limpeza','nettoyage','cleaning'], 2),

  ('11111111-1111-1111-1111-111111111111', 'Blanqueamiento', '150€',         90, null,
   array['blanqueamiento','branqueamento','blanchiment','whitening'], 3),

  ('11111111-1111-1111-1111-111111111111', 'Empaste',        '80€',          60, null,
   array['empaste','obturacion','plombage','filling'], 4),

  ('11111111-1111-1111-1111-111111111111', 'Ortodoncia',     'desde 1.500€', 60, 'primera visita',
   array['ortodoncia','ortodontia','orthodontie','orthodontics'], 5)
on conflict (clinica_id, nombre) do update set
  precio_texto     = excluded.precio_texto,
  duracion_minutos = excluded.duracion_minutos,
  nota             = excluded.nota,
  sinonimos        = excluded.sinonimos,
  orden            = excluded.orden;


-- ----------------------------------------------------------------------------
-- 5. Comprobacion rapida (deberia devolver 1 clinica y 5 tratamientos)
-- ----------------------------------------------------------------------------
select c.nombre, c.zona_horaria, c.telefono_publico, count(t.id) as tratamientos
from clinicas c
left join tratamientos t on t.clinica_id = c.id
group by c.id, c.nombre, c.zona_horaria, c.telefono_publico;


-- ============================================================================
--  DAR DE ALTA LA CLINICA NUMERO 2 (para cuando llegue el momento)
--
--  1. insert into clinicas (nombre, telefono_whatsapp_id, calendar_id,
--       email_avisos, direccion, telefono_publico, zona_horaria, horarios)
--     values ('Clinica X', '<phone_number_id de Meta>', '<id del calendario>',
--       'correo@clinica.com', 'Su direccion', '900 000 000', 'Europe/Madrid',
--       '{"0":null,"1":{"apertura":"10:00","cierre":"21:00"}, ...}'::jsonb)
--     returning id;
--
--  2. Insertar sus tratamientos con ese id.
--
--  3. En las tablas citas / lista_espera / leads / derivaciones, quitar el
--     DEFAULT de clinica_id para que sea obligatorio pasarlo desde n8n:
--       alter table citas alter column clinica_id drop default;
--     (el workflow ya lo envia siempre, el default solo existe por comodidad
--      mientras hay una unica clinica)
--
--  4. Activar RLS como indica el final de "01 - esquema.sql".
-- ============================================================================
