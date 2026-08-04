-- ============================================================================
--  bitclap.es  |  Esquema de base de datos para el chatbot de clinicas dentales
--  Sustituye a la hoja de Google Sheets "Citas" y sus pestanas.
--
--  COMO USARLO:
--  1. Entra en tu proyecto de Supabase.
--  2. Menu lateral -> SQL Editor -> New query.
--  3. Pega TODO este archivo y pulsa RUN.
--
--  Se puede ejecutar varias veces sin romper nada (usa IF NOT EXISTS).
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. CLINICAS
--    Hoy solo tendras una fila. Existe desde el principio para que, cuando
--    entre la clinica numero 2, no haya que rehacer la base de datos: solo
--    anadir otra fila aqui.
-- ----------------------------------------------------------------------------
create table if not exists clinicas (
  id                    uuid primary key default gen_random_uuid(),
  nombre                text not null,
  telefono_whatsapp_id  text unique,          -- phone_number_id que da Meta
  calendar_id           text,                 -- id del Google Calendar de la clinica
  email_avisos          text,                 -- a donde van los correos al dentista
  zona_horaria          text not null default 'Europe/Lisbon',
  activo                boolean not null default true,
  creado_en             timestamptz not null default now()
);

-- Tu primera clinica. El id esta fijado a proposito: las tablas de abajo lo
-- usan como valor por defecto de clinica_id, asi no tienes que copiar y pegar
-- ningun identificador a mano.
insert into clinicas (id, nombre, telefono_whatsapp_id, email_avisos)
values (
  '11111111-1111-1111-1111-111111111111',
  'Clinica Dental Salud Lisboa',
  '1084326274761313',
  'prueb4sn8n.pruebas@gmail.com'
)
on conflict (id) do nothing;


-- ----------------------------------------------------------------------------
-- 2. CITAS   (antes: pestana "Citas")
-- ----------------------------------------------------------------------------
create table if not exists citas (
  id                      uuid primary key default gen_random_uuid(),
  clinica_id              uuid not null default '11111111-1111-1111-1111-111111111111'
                            references clinicas(id),

  event_id                text unique,        -- id del evento en Google Calendar
  nombre                  text,
  telefono                text,
  tratamiento             text,

  fecha                   date,               -- 2026-08-05
  hora                    text,               -- '16:00' (texto, como lo maneja el bot)
  fecha_inicio            timestamptz,        -- ISO completo con zona horaria
  fecha_fin               timestamptz,
  duracion_minutos        integer,

  estado                  text not null default 'confirmada',   -- confirmada | cancelada | modificada

  recordatorio_24h        boolean not null default false,
  valoracion_solicitada   boolean not null default false,
  valoracion_estado       text default 'no_solicitada',         -- no_solicitada | pendiente | recibida
  valoracion              integer check (valoracion between 1 and 5),
  comentario_valoracion   text,
  valoracion_enviada_en   text,               -- texto 'dd/MM/yyyy H:mm' que escribe n8n
  valoracion_recibida_en  text,

  creado_en               timestamptz not null default now()
);

create index if not exists citas_fecha_estado_idx  on citas (clinica_id, fecha, estado);
create index if not exists citas_valoracion_idx    on citas (clinica_id, valoracion_estado);
create index if not exists citas_telefono_idx      on citas (clinica_id, telefono);

-- RED DE SEGURIDAD CONTRA DOBLE RESERVA.
-- Google Calendar sigue siendo quien decide si un hueco esta libre, pero si dos
-- pacientes piden exactamente el mismo hueco en el mismo segundo, esto impide
-- que se guarden las dos citas. La segunda fallara con error (mejor un error
-- visible que dos pacientes citados a la misma hora).
create unique index if not exists citas_hueco_unico
  on citas (clinica_id, fecha, hora)
  where estado = 'confirmada';


-- ----------------------------------------------------------------------------
-- 3. LISTA DE ESPERA   (antes: pestana "ListaEspera")
-- ----------------------------------------------------------------------------
create table if not exists lista_espera (
  id                uuid primary key default gen_random_uuid(),
  clinica_id        uuid not null default '11111111-1111-1111-1111-111111111111'
                      references clinicas(id),

  waitlist_id       text unique,
  nombre            text,
  telefono          text,
  tratamiento       text,

  fecha             date,
  hora              text,
  fecha_inicio      text,        -- aqui llega como 'YYYY-MM-DD HH:mm' (sin zona horaria)
  fecha_fin         text,
  duracion_minutos  integer,

  estado            text not null default 'pendiente',   -- pendiente | notificado
  notificado_en     text,
  respondido_en     text,

  creado_en         timestamptz not null default now()   -- decide a quien se avisa primero
);

create index if not exists lista_espera_fecha_estado_idx on lista_espera (clinica_id, fecha, estado);


-- ----------------------------------------------------------------------------
-- 4. LEADS   (antes: pestana "Leads")
-- ----------------------------------------------------------------------------
create table if not exists leads (
  id                      uuid primary key default gen_random_uuid(),
  clinica_id              uuid not null default '11111111-1111-1111-1111-111111111111'
                            references clinicas(id),

  lead_id                 text unique,
  nombre                  text,
  telefono                text,
  tratamiento_interes     text,
  origen                  text,
  estado                  text,
  seguimiento_estado      text,                -- pendiente | cerrado
  numero_seguimientos     integer default 0,
  max_seguimientos        integer default 3,

  -- Fechas en texto 'dd/MM/yyyy H:mm': las genera el codigo del workflow.
  fecha_creacion          text,
  ultima_actualizacion    text,
  ultimo_contacto_en      text,
  ultimo_seguimiento_en   text,
  proximo_seguimiento_en  text,
  cerrado_en              text,

  motivo_cierre           text,
  mensaje_original        text,
  resumen                 text,
  notas                   text,
  responsable             text,

  creado_en               timestamptz not null default now()
);

create index if not exists leads_seguimiento_idx on leads (clinica_id, seguimiento_estado);
create index if not exists leads_telefono_idx    on leads (clinica_id, telefono);


-- ----------------------------------------------------------------------------
-- 5. DERIVACIONES A HUMANO   (antes: pestana "Derivaciones")
--    Aqui aterriza lo mas delicado: pacientes que cuentan dolor, sangrado,
--    medicacion, embarazo... Son datos de salud. Ver nota de RGPD en la guia.
-- ----------------------------------------------------------------------------
create table if not exists derivaciones (
  id                uuid primary key default gen_random_uuid(),
  clinica_id        uuid not null default '11111111-1111-1111-1111-111111111111'
                      references clinicas(id),

  derivacion_id     text unique,
  fecha_hora        text,        -- texto 'dd/MM/yyyy H:mm' generado por el workflow
  nombre            text,
  telefono          text,
  motivo            text,
  resumen           text,
  mensaje_original  text,

  estado            text not null default 'pendiente',   -- pendiente | atendida
  canal_origen      text default 'WhatsApp',
  atendido_por      text,
  cerrado_en        text,
  notas             text,

  creado_en         timestamptz not null default now()
);

create index if not exists derivaciones_estado_idx on derivaciones (clinica_id, estado);


-- ============================================================================
--  SEGURIDAD (RLS)
--
--  n8n se conecta con la clave "service_role", que salta RLS por diseno: por
--  eso los workflows funcionan sin anadir ninguna politica.
--
--  NO actives RLS todavia. Hara falta el dia que:
--    (a) entre una segunda clinica, o
--    (b) montes un panel donde la clinica entre con su usuario.
--  Cuando llegue ese dia, se activa asi (dejado aqui como referencia,
--  comentado a proposito para que no se ejecute por error):
--
--    alter table citas        enable row level security;
--    alter table lista_espera enable row level security;
--    alter table leads        enable row level security;
--    alter table derivaciones enable row level security;
--
--    create policy "cada clinica ve lo suyo" on citas
--      for select using (clinica_id = (auth.jwt() ->> 'clinica_id')::uuid);
-- ============================================================================
