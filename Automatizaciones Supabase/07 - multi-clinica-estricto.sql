-- ============================================================================
--  bitclap.es  |  Paso 7: cerrar los huecos multi-clinica
--
--  Ejecutar DESPUES de "06 - pacientes-y-cumplimiento.sql".
--  Supabase -> SQL Editor -> New query -> pegar todo -> RUN.
--  Se puede ejecutar varias veces sin romper nada.
--
--  QUE ARREGLA (de la auditoria del 21-sep-2026)
--    1. Quita el valor por defecto de clinica_id. Hoy, una insercion que se
--       olvide de ponerlo acaba EN SILENCIO en la clinica de pruebas.
--    2. Anade clinica_id a envios_fallidos y lo rellena solo.
--    3. Activa RLS en las seis tablas que seguian abiertas.
--
--  ⚠️ LEE EL APARTADO 0 ANTES DE EJECUTAR. Hay una comprobacion que tienes
--     que hacer en n8n primero, y si te la saltas puedes dejar el bot sin
--     acceso a la base de datos.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 0. ANTES DE EJECUTAR: comprueba que n8n usa la clave service_role
--
--    El apartado 3 activa RLS sin politicas. Eso significa: "nadie puede leer
--    estas tablas". La clave service_role se salta RLS por diseno, asi que n8n
--    sigue funcionando. La clave anon NO se la salta, y el bot se quedaria
--    sin base de datos.
--
--    COMPRUEBALO ASI (30 segundos):
--      n8n -> Credentials -> "Supabase account" -> el campo se llama
--      "Service Role Secret". Tiene que tener pegada la clave que en Supabase
--      aparece como  Settings -> API -> service_role  (la marcada como secret),
--      NO la  anon public.
--
--    Si no estas seguro, ejecuta primero los apartados 1 y 2, deja el 3 para
--    despues y comprueba que el bot sigue reservando citas.
--
--    Y si algo se rompe, el apartado 4 tiene el comando exacto para deshacerlo.
-- ----------------------------------------------------------------------------


-- ----------------------------------------------------------------------------
-- 1. Quitar el valor por defecto de clinica_id
--
--    Cuando solo habia una clinica, este default evitaba tener que copiar el
--    UUID a mano. Ya cumplio su funcion y ahora es una trampa: si un nodo
--    nuevo olvida escribir clinica_id, la fila se guarda en la clinica 1 sin
--    dar ningun error, y los datos de un paciente acaban en otra clinica.
--
--    Despues de esto, olvidarse de clinica_id da un error inmediato y ruidoso.
--    Que es exactamente lo que queremos: mejor romperse que mentir.
--
--    Los seis "insert" del workflow 01 ya escriben clinica_id, asi que esto
--    no rompe nada de lo que hay hoy. (Comprobado nodo por nodo el 21-sep.)
-- ----------------------------------------------------------------------------
alter table citas        alter column clinica_id drop default;
alter table lista_espera alter column clinica_id drop default;
alter table leads        alter column clinica_id drop default;
alter table derivaciones alter column clinica_id drop default;


-- ----------------------------------------------------------------------------
-- 2. envios_fallidos: saber de que clinica es cada mensaje que no llego
--
--    La tabla guarda phone_number_id, que identifica la clinica de forma
--    indirecta. Faltaba la clave. Dos consecuencias que arregla esto:
--      - Poder responder "cuantos mensajes le fallaron a esta clinica".
--      - Que el borrado por derecho de supresion no se deje esta tabla fuera.
--
--    Se rellena con un disparador en la propia base de datos, NO desde n8n.
--    Motivo: la rama que escribe aqui es la de los callbacks de estado de
--    WhatsApp, la misma que provoco la avalancha del 08/08/2026. Esa rama
--    tiene una regla: no puede consultar nada ni fallar nunca. Asi que el
--    trabajo lo hace Postgres, donde no puede romper nada.
-- ----------------------------------------------------------------------------
alter table envios_fallidos
  add column if not exists clinica_id uuid references clinicas(id);

create or replace function envios_fallidos_rellenar_clinica()
returns trigger
language plpgsql
as $fn$
begin
  if new.clinica_id is null and new.phone_number_id is not null then
    select c.id
      into new.clinica_id
      from clinicas c
     where c.telefono_whatsapp_id = new.phone_number_id
     limit 1;
  end if;
  return new;
end;
$fn$;

drop trigger if exists envios_fallidos_clinica_trg on envios_fallidos;

create trigger envios_fallidos_clinica_trg
  before insert on envios_fallidos
  for each row
  execute function envios_fallidos_rellenar_clinica();

-- Rellenar las filas que ya existan
update envios_fallidos e
   set clinica_id = c.id
  from clinicas c
 where e.clinica_id is null
   and c.telefono_whatsapp_id = e.phone_number_id;

create index if not exists envios_fallidos_clinica_idx
  on envios_fallidos (clinica_id, creado_en desc);


-- ----------------------------------------------------------------------------
-- 3. RLS en las tablas que seguian abiertas
--
--    Hasta ahora solo la tenian pacientes y envios_fallidos (paso 06). Las
--    demas salian en Supabase con la etiqueta roja UNRESTRICTED: cualquiera
--    con la clave publica podia leer nombres, telefonos y motivos de consulta
--    de todos los pacientes.
--
--    Se activa SIN politicas, igual que en el paso 06: nadie lee con la clave
--    anon, y n8n sigue igual porque usa service_role.
--
--    Ademas esto hace verdad el Anexo I del contrato de encargado, donde pone
--    que aplicas el principio de minimo privilegio.
-- ----------------------------------------------------------------------------
alter table citas         enable row level security;
alter table lista_espera  enable row level security;
alter table leads         enable row level security;
alter table derivaciones  enable row level security;
alter table clinicas      enable row level security;
alter table tratamientos  enable row level security;
alter table avisos_error  enable row level security;

-- La vista clinicas_config lee de clinicas y tratamientos. Por defecto, una
-- vista de Postgres consulta con los permisos de quien la creo, no de quien la
-- usa: sin esto, se podria leer la configuracion de todas las clinicas a
-- traves de la vista aunque las tablas de debajo esten cerradas.
--
-- Va dentro de un bloque con captura de errores porque security_invoker
-- necesita PostgreSQL 15 o superior. Si tu proyecto fuera mas antiguo, el
-- script no se corta: deja un aviso y sigue.
do $do$
begin
  execute 'alter view clinicas_config set (security_invoker = on)';
  raise notice 'OK: clinicas_config ahora respeta la RLS de las tablas de debajo.';
exception when others then
  raise notice 'AVISO: no se pudo activar security_invoker en clinicas_config (%). Revisa la version de Postgres.', sqlerrm;
end;
$do$;


-- ----------------------------------------------------------------------------
-- 4. Si algo se rompe: deshacer solo la RLS
--
--    Sintoma de que la credencial de n8n usa la clave anon en vez de
--    service_role: el bot deja de encontrar citas, o los nodos de Supabase
--    devuelven listas vacias sin dar error.
--
--    Pega esto y vuelves al estado de antes. Luego corrige la credencial en
--    n8n y vuelve a ejecutar el apartado 3.
--
--    alter table citas         disable row level security;
--    alter table lista_espera  disable row level security;
--    alter table leads         disable row level security;
--    alter table derivaciones  disable row level security;
--    alter table clinicas      disable row level security;
--    alter table tratamientos  disable row level security;
--    alter table avisos_error  disable row level security;
--    alter view  clinicas_config set (security_invoker = off);
-- ----------------------------------------------------------------------------


-- ----------------------------------------------------------------------------
-- 5. Comprobaciones
-- ----------------------------------------------------------------------------

-- 5.1 Ninguna tabla debe quedar con default en clinica_id.
--     Lo correcto es que esta consulta NO devuelva ninguna fila.
select table_name, column_name, column_default
  from information_schema.columns
 where table_schema = 'public'
   and column_name  = 'clinica_id'
   and column_default is not null;

-- 5.2 Todas las tablas con datos de pacientes deben tener rowsecurity = true.
select tablename, rowsecurity
  from pg_tables
 where schemaname = 'public'
   and tablename in ('citas','lista_espera','leads','derivaciones','clinicas',
                     'tratamientos','pacientes','envios_fallidos','avisos_error')
 order by rowsecurity, tablename;

-- 5.3 El bot sigue viendo su configuracion (debe salir 1 fila con tratamientos).
select nombre,
       telefono_whatsapp_id,
       jsonb_array_length(tratamientos) as num_tratamientos
  from clinicas_config;


-- ----------------------------------------------------------------------------
-- 6. Borrado por derecho de supresion, ACTUALIZADO
--
--    El paso 06 dejaba fuera envios_fallidos. Esta es la lista completa.
--    Sustituye los valores y ejecutalo entero, en este orden.
-- ----------------------------------------------------------------------------
--   delete from citas           where clinica_id = '...' and telefono = '34600111222';
--   delete from lista_espera    where clinica_id = '...' and telefono = '34600111222';
--   delete from leads           where clinica_id = '...' and telefono = '34600111222';
--   delete from derivaciones    where clinica_id = '...' and telefono = '34600111222';
--   delete from envios_fallidos where clinica_id = '...' and destinatario = '34600111222';
--   delete from pacientes       where clinica_id = '...' and telefono = '34600111222';
--
--   OJO: en envios_fallidos la columna del telefono se llama "destinatario",
--   no "telefono". Es la unica que no sigue el patron.
