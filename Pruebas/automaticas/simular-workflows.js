// ============================================================================
//  PRUEBA DE REGRESION DE LOS WORKFLOWS (creada el 15-sep-2026)
//
//  Ejecuta el codigo REAL de los nodos Code de los workflows de
//  "Automatizaciones Supabase" con datos de prueba y comprueba que se portan
//  como deben: identidad por telefono (K13), bajas, derivacion con 112, aviso de
//  primer contacto, reservas del mismo dia, plantilla del 02, email diario y
//  boton de cierre del 07.
//
//  NO prueba los nodos de n8n (Supabase, Calendar, WhatsApp, IA): eso solo se
//  prueba en n8n con la bateria de Pruebas/Bateria de mensajes.md.
//
//  COMO EJECUTARLO (no hace falta instalar nada: usa el Node de VS Code)
//  Desde Git Bash, en la carpeta del repositorio:
//    ELECTRON_RUN_AS_NODE=1 "/c/Users/Luis Ander/AppData/Local/Programs/Microsoft VS Code/Code.exe" "Pruebas/automaticas/simular-workflows.js" .
//  Debe terminar con "SIMULACION OK". Pasalo cada vez que alguien toque el
//  codigo de un nodo, antes de importar el workflow en n8n.
// ============================================================================
// Simulador: ejecuta el codigo REAL de los nodos Code de los workflows ya
// modificados, con datos de prueba, y comprueba el comportamiento.
const fs = require('fs');
const path = require('path');

const ROOT = process.argv[2];
const DIR = path.join(ROOT, 'Automatizaciones Supabase');
const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;
const cargar = f => JSON.parse(fs.readFileSync(path.join(DIR, f), 'utf8'));

const wf01 = cargar('Clinica Dental - 01 WhatsApp citas (Supabase).json');
const wf02 = cargar('Clinica Dental - 02 Recordatorios 24h (Supabase).json');
const wf03 = cargar('Clinica Dental - 03 Solicitud valoraciones post cita (Supabase).json');
const wf06 = cargar('Clinica Dental - 06 Email diario Hoy.json');
const wf07 = cargar('Clinica Dental - 07 Marcar derivacion atendida.json');

const codigoDe = (wf, nombre) => {
  const n = wf.nodes.find(x => x.name === nombre);
  if (!n) throw new Error('No existe ' + nombre);
  return n.parameters.jsCode;
};

// datos: { 'Nombre nodo': [json, json...] }, input: [json...]
const ejecutar = async (wf, nombre, datos, input = [{}]) => {
  const $ = n => {
    if (!(n in datos)) throw new Error(`[${nombre}] usa $('${n}') y el simulador no lo tiene`);
    const filas = datos[n];
    return { first: () => ({ json: filas[0] }), all: () => filas.map(json => ({ json })), item: { json: filas[0] } };
  };
  const $input = { all: () => input.map(json => ({ json })), first: () => ({ json: input[0] }), item: { json: input[0] } };
  const $execution = { resumeUrl: 'https://bitclap.app.n8n.cloud/webhook-waiting/12345' };
  const fn = new AsyncFunction('$input', '$', '$execution', '$now', codigoDe(wf, nombre));
  return (await fn($input, $, $execution, null)) || [];
};

let fallos = 0;
let pruebas = 0;
const comprobar = (condicion, descripcion, detalle) => {
  pruebas++;
  if (!condicion) {
    fallos++;
    console.log('❌', descripcion, detalle !== undefined ? '\n   -> ' + JSON.stringify(detalle).slice(0, 600) : '');
  }
};

(async () => {
  // ------------------------------------------------------------------ contexto
  const filaClinica = {
    id: '11111111-1111-1111-1111-111111111111',
    nombre: 'Clinica Dental Salud',
    nombre_asistente: 'Sara',
    direccion: 'Calle Mayor 123',
    telefono_publico: '912 345 678',
    zona_horaria: 'Europe/Madrid',
    duracion_por_defecto: 60,
    calendar_id: 'cal@test',
    email_avisos: 'clinica@test',
    telefono_whatsapp_id: '1084326274761313',
    url_privacidad: 'https://clinica.test/privacidad',
    pausa_derivacion_minutos: 180,
    horarios: { 0: null, 1: { apertura: '09:00', cierre: '20:00' }, 2: { apertura: '09:00', cierre: '20:00' }, 3: { apertura: '09:00', cierre: '20:00' }, 4: { apertura: '09:00', cierre: '20:00' }, 5: { apertura: '09:00', cierre: '20:00' }, 6: { apertura: '09:00', cierre: '14:00' } },
    tratamientos: [
      { nombre: 'Revision', precio_texto: '30€', duracion_minutos: 30, sinonimos: ['revision'], orden: 1, activo: true },
      { nombre: 'Limpieza', precio_texto: '50€', duracion_minutos: 45, sinonimos: ['limpieza'], orden: 2, activo: true }
    ]
  };
  const [ctxItem] = await ejecutar(wf01, 'Construir contexto', { 'Cargar config clinica': [filaClinica] });
  const ctx = ctxItem.json;
  comprobar(ctx.config.url_privacidad === filaClinica.url_privacidad, 'Construir contexto pasa url_privacidad');
  comprobar(!/Suenas humana/.test(ctx.system_prompt), 'El prompt ya no dice "Suenas humana"');
  comprobar(/NO una persona/.test(ctx.system_prompt) && ctx.system_prompt.includes('912 345 678'), 'El prompt obliga a identificarse como IA', ctx.system_prompt.slice(300, 900));
  comprobar(!/nombre completo para buscar tu cita/.test(ctx.system_prompt), 'El prompt ya no pide nombre para consultar citas');

  const TEL = '34600111222';
  const OTRO = '34699888777';
  const trigger = body => ({ metadata: { phone_number_id: '1084326274761313' }, messages: [{ from: TEL, text: { body } }] });
  const router = (body, output) => ejecutar(wf01, 'Normalizar y enrutar', {
    'Construir contexto': [ctx], 'WhatsApp Trigger': [trigger(body)]
  }, [{ output }]);
  const lunes = ctx.contexto_temporal.lunesProximo;

  // ------------------------------------------------------------------ router
  {
    const [r] = await router('Me llamo Salvador López y quiero una limpieza el lunes a las 10:00',
      JSON.stringify({ accion: 'reservar', nombre: 'Salvador López', tratamiento: 'Limpieza', fecha: lunes, hora: '10:00' }));
    comprobar(r.json.accion === 'reservar' && !r.json.requiere_derivacion_humano, 'Salvador reserva sin derivacion', r.json);
  }
  {
    const [r] = await router('Me llamo Dolores García, quiero una revisión el lunes a las 11:00',
      JSON.stringify({ accion: 'reservar', nombre: 'Dolores García', tratamiento: 'Revision', fecha: lunes, hora: '11:00' }));
    comprobar(r.json.accion === 'reservar' && !r.json.requiere_derivacion_humano, 'Dolores reserva sin derivacion', r.json);
  }
  {
    const [r] = await router('me duele mucho una muela y me sangra la encía',
      JSON.stringify({ accion: 'derivar_humano', motivo: 'consulta clinica privada', resumen: 'dolor y sangrado' }));
    comprobar(r.json.accion === 'derivar_humano', 'H1 deriva', r.json);
    comprobar(/consejo médico/.test(r.json.respuesta) && /112/.test(r.json.respuesta), 'H1 respuesta con "consejo médico" y 112', r.json.respuesta);
    comprobar(typeof r.json.token_cierre === 'string' && r.json.token_cierre.length >= 32, 'H1 genera token_cierre', r.json.token_cierre);
  }
  {
    const [r] = await router('me tomo un café y voy para allá, me dais cita?', 'Claro, ¿para qué tratamiento?');
    comprobar(r.json.accion === 'responder', 'H6 "me tomo un café" no deriva', r.json);
  }
  {
    const [r] = await router('stop', 'Entendido.');
    comprobar(r.json.accion === 'cerrar_lead' && r.json.cambiar_opt_out === true && r.json.opt_out_valor === true, 'stop -> baja', r.json);
    comprobar(/ALTA/.test(r.json.respuesta), 'stop explica como volver (ALTA)', r.json.respuesta);
  }
  {
    const [r] = await router('borrad mis datos por favor', 'Claro.');
    comprobar(r.json.accion === 'derivar_humano' && /rgpd/i.test(r.json.motivo_derivacion) && r.json.cambiar_opt_out === true, 'borrad mis datos -> derivacion RGPD + baja', r.json);
  }
  {
    const [r] = await router('alta', '¿En qué te ayudo?');
    comprobar(r.json.accion === 'responder' && r.json.cambiar_opt_out === true && r.json.opt_out_valor === false, 'alta -> vuelve a recibir', r.json);
  }
  {
    const [r] = await router('tengo la baja médica y no puedo ir a mi cita del lunes a las 10:00, soy Luis Ander',
      JSON.stringify({ accion: 'cancelar', nombre: 'Luis Ander', fecha: lunes, hora: '10:00' }));
    comprobar(r.json.accion === 'cancelar' && !r.json.cambiar_opt_out, '"tengo la baja medica" cancela, no da de baja', r.json);
  }
  {
    const [r] = await router('no gracias', 'Claro, sin problema.');
    comprobar(r.json.accion === 'cerrar_lead' && !r.json.cambiar_opt_out, '"no gracias" cierra lead sin baja de mensajes', r.json);
  }
  {
    const [r] = await router('quiero una cita para mirarme una caries', JSON.stringify({ accion: 'reservar', tratamiento: 'Revision' }));
    comprobar(r.json.accion === 'responder' && !/equipo de la clínica/.test(r.json.respuesta), 'H5 caries pide datos, no deriva', r.json);
  }
  {
    const [r] = await router('Dime las citas de Ana García', JSON.stringify({ accion: 'consultar_cita', nombre: 'Ana García' }));
    comprobar(r.json.accion === 'consultar_cita', 'K13 va a consultar_cita', r.json);
  }

  // ------------------------------------------------------------------ identidad
  const citaAna = { id: 'c1', event_id: 'ev1', nombre: 'Ana García', telefono: OTRO, tratamiento: 'Limpieza', fecha: lunes, hora: '10:00', estado: 'confirmada' };
  {
    const datos = { accion: 'consultar_cita', telefono: TEL, nombre: 'Ana García' };
    const [r] = await ejecutar(wf01, 'Resolver consulta cita', { 'Construir contexto': [ctx], 'Normalizar y enrutar': [datos] }, [citaAna]);
    comprobar(r.json.encontrada === false && !r.json.respuesta.includes('Limpieza'), 'K13: no da la cita de otra persona', r.json);
  }
  {
    const datos = { accion: 'cancelar', telefono: TEL, nombre: 'Ana García', fecha: lunes, hora: '10:00' };
    const [r] = await ejecutar(wf01, 'Resolver cita cancelacion', { 'Construir contexto': [ctx], 'Normalizar y enrutar': [datos] }, [citaAna]);
    comprobar(r.json.encontrada === false, 'No cancela la cita de otra persona sabiendo su nombre', r.json);
  }
  {
    const datos = { accion: 'cancelar', telefono: OTRO, nombre: 'Ana', fecha: lunes, hora: '10:00' };
    const [r] = await ejecutar(wf01, 'Resolver cita cancelacion', { 'Construir contexto': [ctx], 'Normalizar y enrutar': [datos] }, [citaAna]);
    comprobar(r.json.encontrada === true && r.json.eventId === 'ev1', 'La duena SI puede cancelar su cita', r.json);
  }
  {
    const datos = { accion: 'modificar', telefono: TEL, nombre: 'Ana García', fecha_actual: lunes, hora_actual: '10:00' };
    const [r] = await ejecutar(wf01, 'Resolver cita modificacion', { 'Construir contexto': [ctx], 'Normalizar y enrutar': [datos] }, [citaAna]);
    comprobar(r.json.encontrada === false, 'No modifica la cita de otra persona', r.json);
  }

  // ------------------------------------------------------------------ duplicados
  {
    const reserva = { accion: 'reservar', nombre: 'Luis Ander', tratamiento: 'Limpieza', fecha: lunes, hora: '12:00', telefono: TEL };
    const mismaPersonaMismoDia = { event_id: 'ev2', nombre: 'Luis Ander', telefono: TEL, tratamiento: 'Revision', fecha: lunes, hora: '10:00', estado: 'confirmada' };
    const [r] = await ejecutar(wf01, 'Preparar reserva y duplicados', { 'Construir contexto': [ctx], 'Evaluar disponibilidad reserva': [reserva] }, [mismaPersonaMismoDia]);
    comprobar(r.json.tiene_duplicados === true && /Ya tienes una cita/.test(r.json.respuesta), 'Mismo dia: pregunta en vez de reservar', r.json);

    const otroDia = { ...mismaPersonaMismoDia, fecha: '2099-01-02' };
    const [r2] = await ejecutar(wf01, 'Preparar reserva y duplicados', { 'Construir contexto': [ctx], 'Evaluar disponibilidad reserva': [reserva] }, [otroDia]);
    comprobar(r2.json.tiene_duplicados === false && r2.json.otras_citas.length === 1, 'Otro dia: reserva y recuerda la otra cita', r2.json);

    const hijo = { ...mismaPersonaMismoDia, nombre: 'Pablo Ander' };
    const [r3] = await ejecutar(wf01, 'Preparar reserva y duplicados', { 'Construir contexto': [ctx], 'Evaluar disponibilidad reserva': [reserva] }, [hijo]);
    comprobar(r3.json.tiene_duplicados === false, 'Mismo dia pero otra persona del mismo telefono: reserva', r3.json);

    const crear = { ...reserva, otras_citas: r2.json.otras_citas, requiere_derivacion_humano: true, derivacion_id: 'DH-1', token_cierre: 'a'.repeat(40), motivo_derivacion: 'consulta clinica privada' };
    const [n] = await ejecutar(wf01, 'Preparar notificacion reserva', { 'Construir contexto': [ctx], 'Preparar crear reserva': [crear], 'Crear evento reserva': [{ id: 'evNuevo' }] });
    comprobar(/también hay esta cita/.test(n.json.respuesta), 'Confirmacion recuerda la otra cita', n.json.respuesta);
    comprobar(/112/.test(n.json.respuesta) && /consejo médico/.test(n.json.respuesta), 'Confirmacion con derivacion lleva 112', n.json.respuesta);
    comprobar(n.json.email_html.includes('https://bitclap.app.n8n.cloud/webhook/derivacion-atendida?id=DH-1&amp;t='), 'Email de reserva con boton de cierre', n.json.email_html.slice(-700));
  }

  // ------------------------------------------------------------------ derivacion
  {
    const d = { accion: 'derivar_humano', telefono: TEL, nombre: 'Luis', motivo_derivacion: 'consulta clinica privada', resumen_derivacion: 'dolor', mensaje_original: 'me duele', derivacion_id: 'DH-2', token_cierre: 'b'.repeat(40), derivado_en: '15/09/2026 10:00', respuesta: 'x' };
    const [r] = await ejecutar(wf01, 'Preparar notificacion derivacion humano', { 'Construir contexto': [ctx] }, [d]);
    comprobar(r.json.email_html.includes('/webhook/derivacion-atendida?id=DH-2'), 'Email de derivacion con boton de cierre', r.json.email_html.slice(-600));
    const [r2] = await ejecutar(wf01, 'Preparar notificacion derivacion humano', { 'Construir contexto': [ctx] }, [{ ...d, motivo_derivacion: 'solicitud RGPD sobre sus datos' }]);
    comprobar(/Solicitud RGPD/.test(r2.json.email_subject) && /un mes/.test(r2.json.email_html), 'Email RGPD distinto', r2.json.email_subject);
  }

  // ------------------------------------------------------------------ primer contacto
  {
    const [r] = await ejecutar(wf01, 'Comprobar primer contacto', { 'Construir contexto': [ctx], 'WhatsApp Trigger': [trigger('hola')], 'Buscar paciente': [{}] });
    comprobar(r.json.primer_contacto === true, 'Telefono nuevo -> primer contacto', r.json.primer_contacto);
    comprobar(/inteligencia artificial/.test(r.json.aviso_primer_contacto) && r.json.aviso_primer_contacto.includes(filaClinica.url_privacidad) && /BAJA/.test(r.json.aviso_primer_contacto), 'Aviso con IA, enlace de privacidad y BAJA', r.json.aviso_primer_contacto);
    comprobar(!!r.json.system_prompt, 'Primer contacto no pierde el system_prompt');
    const [r2] = await ejecutar(wf01, 'Comprobar primer contacto', { 'Construir contexto': [ctx], 'WhatsApp Trigger': [trigger('hola')], 'Buscar paciente': [{ id: 'p1' }] });
    comprobar(r2.json.primer_contacto === false, 'Telefono conocido -> sin aviso');
  }

  // ------------------------------------------------------------------ IA caida
  {
    const [r] = await ejecutar(wf01, 'Respuesta emergencia IA', { 'Construir contexto': [ctx], 'WhatsApp Trigger': [trigger('hola')] }, [{ error: { message: 'The model llama-3.3-70b-versatile has been decommissioned' } }]);
    comprobar(r.json.telefono === TEL && r.json.respuesta.includes('912 345 678') && /decommissioned/.test(r.json.error_ia), 'IA caida: mensaje de emergencia con telefono', r.json);
  }

  // ------------------------------------------------------------------ envios fallidos
  {
    const failed = { metadata: { phone_number_id: 'P1' }, statuses: [{ id: 'wamid.1', status: 'failed', recipient_id: TEL, errors: [{ code: 131047, title: 'Re-engagement message', error_data: { details: 'more than 24 hours' } }] }] };
    const r = await ejecutar(wf01, 'Filtrar envio fallido', { 'WhatsApp Trigger': [failed] });
    comprobar(r.length === 1 && r[0].json.codigo_error === '131047', 'Callback failed -> se registra', r);
    const r2 = await ejecutar(wf01, 'Filtrar envio fallido', { 'WhatsApp Trigger': [{ statuses: [{ status: 'delivered' }] }] });
    const r3 = await ejecutar(wf01, 'Filtrar envio fallido', { 'WhatsApp Trigger': [trigger('hola')] });
    const r4 = await ejecutar(wf01, 'Filtrar envio fallido', { 'WhatsApp Trigger': [null] });
    comprobar(r2.length === 0 && r3.length === 0 && r4.length === 0, 'delivered / mensaje normal / basura -> nada, sin fallar');
  }

  // ------------------------------------------------------------------ workflow 02
  {
    const manana = new Intl.DateTimeFormat('en-CA', { timeZone: 'Europe/Madrid', year: 'numeric', month: '2-digit', day: '2-digit' }).format(new Date(Date.now() + 86400000));
    const base = { clinica_id: filaClinica.id, fecha: manana, hora: '16:00', estado: 'confirmada', recordatorio_24h: false, tratamiento: 'Limpieza' };
    const citas = [
      { ...base, id: 'a', event_id: 'e1', nombre: 'Luis Ander', telefono: TEL },
      { ...base, id: 'b', event_id: 'e2', nombre: 'Marta Baja', telefono: OTRO }
    ];
    const r = await ejecutar(wf02, 'Preparar recordatorios', {
      'Cargar clinicas': [filaClinica],
      'Cargar bajas': [{ id: 'p', clinica_id: filaClinica.id, telefono: OTRO, opt_out: true }]
    }, citas);
    comprobar(r.length === 1 && r[0].json.nombre === 'Luis Ander', '02: excluye al que pidio la baja', r.map(x => x.json.nombre));
    comprobar(r[0] && r[0].json.plantilla === 'recordatorio_cita_24h|es' && r[0].json.param_nombre === 'Luis' && r[0].json.param_hora === '16:00', '02: parametros de plantilla', r[0] && r[0].json);
    const envio = wf02.nodes.find(n => n.name === 'Enviar recordatorio');
    comprobar(envio.parameters.operation === 'sendTemplate' && envio.onError === 'continueErrorOutput', '02: envio con plantilla y salida de error');
    comprobar(wf02.nodes.find(n => n.name === 'Buscar recordatorios manana').executeOnce === true, '02: consulta una sola vez aunque haya varias clinicas');
    const vacio = await ejecutar(wf02, 'Preparar recordatorios', { 'Cargar clinicas': [filaClinica], 'Cargar bajas': [{}] }, citas);
    comprobar(vacio.length === 2, '02: sin bajas envia a todos (item vacio de alwaysOutputData)', vacio.length);
  }

  // ------------------------------------------------------------------ workflow 03
  {
    const base = { clinica_id: filaClinica.id, fecha: '2026-01-10', hora: '10:00', duracion_minutos: 30, estado: 'confirmada', valoracion_solicitada: false };
    const r = await ejecutar(wf03, 'Preparar solicitudes valoracion', {
      'Cargar clinicas': [filaClinica],
      'Cargar bajas': [{ id: 'p', clinica_id: filaClinica.id, telefono: OTRO, opt_out: true }]
    }, [{ ...base, event_id: 'e1', telefono: TEL, nombre: 'A' }, { ...base, event_id: 'e2', telefono: OTRO, nombre: 'B' }]);
    comprobar(r.length === 1 && r[0].json.telefono === TEL, '03: excluye bajas', r.map(x => x.json.telefono));
  }

  // ------------------------------------------------------------------ workflow 06
  {
    const hoy = new Intl.DateTimeFormat('en-CA', { timeZone: 'Europe/Madrid', year: 'numeric', month: '2-digit', day: '2-digit' }).format(new Date());
    const r = await ejecutar(wf06, 'Construir email diario', {
      'Cargar clinicas': [filaClinica],
      'Cargar citas': [{ id: 'c', clinica_id: filaClinica.id, fecha: hoy, hora: '9:30', estado: 'confirmada', nombre: 'Luis <b>', tratamiento: 'Limpieza', telefono: TEL }],
      'Cargar derivaciones pendientes': [{ id: 'd', clinica_id: filaClinica.id, derivacion_id: 'DH-9', token_cierre: 'c'.repeat(40), nombre: 'Ana', telefono: OTRO, motivo: 'consulta clinica privada', resumen: 'SECRETO CLINICO', creado_en: new Date(Date.now() - 5 * 3600000).toISOString() }],
      'Cargar lista de espera': [{}],
      'Cargar leads': [{}]
    });
    const html = r[0] && r[0].json.email_html;
    comprobar(r.length === 1 && /1 cita y 1 paciente por llamar/.test(r[0].json.email_subject), '06: asunto', r[0] && r[0].json.email_subject);
    comprobar(html.includes('derivacion-atendida?id=DH-9') && html.includes('09:30') && html.includes('Luis &lt;b&gt;'), '06: boton, hora normalizada y HTML escapado');
    comprobar(!html.includes('SECRETO CLINICO'), '06: no incluye el resumen clinico');
  }

  // ------------------------------------------------------------------ workflow 07
  {
    const fila = { id: 'x', derivacion_id: 'DH-9', token_cierre: 'c'.repeat(40), estado: 'pendiente', nombre: 'Ana', fecha_hora: '15/09/2026 10:00' };
    const decidir = q => ejecutar(wf07, 'Decidir', { 'Recibir enlace': [{ query: q }], 'Buscar derivacion': [fila] });
    const [malo] = await decidir({ id: 'DH-9', t: 'd'.repeat(40) });
    comprobar(malo.json.accion === 'mostrar' && /no válido/.test(malo.json.html), '07: token incorrecto no cierra');
    const [conf] = await decidir({ id: 'DH-9', t: 'c'.repeat(40) });
    comprobar(conf.json.accion === 'mostrar' && /ok=1/.test(conf.json.html), '07: primer clic solo confirma');
    const [cerrar] = await decidir({ id: 'DH-9', t: 'c'.repeat(40), ok: '1' });
    comprobar(cerrar.json.accion === 'cerrar', '07: segundo clic cierra');
    const [ya] = await ejecutar(wf07, 'Decidir', { 'Recibir enlace': [{ query: { id: 'DH-9', t: 'c'.repeat(40), ok: '1' } }], 'Buscar derivacion': [{ ...fila, estado: 'atendida' }] });
    comprobar(ya.json.accion === 'mostrar' && /Ya estaba/.test(ya.json.html), '07: ya cerrada');
    const [sinFila] = await ejecutar(wf07, 'Decidir', { 'Recibir enlace': [{ query: {} }], 'Buscar derivacion': [{}] });
    comprobar(sinFila.json.accion === 'mostrar', '07: enlace vacio no revienta');
    const [hecho] = await ejecutar(wf07, 'Pagina hecho', { Decidir: [cerrar.json] }, [{ id: 'x' }]);
    comprobar(/Hecho/.test(hecho.json.html), '07: pagina final');
  }

  // ------------------------------------------------------- ambito (16-sep)
  // El bot enviaba tal cual lo que contestara el modelo: paginas HTML enteras,
  // sumas y disculpas en ingles. Estas pruebas cubren lo que se vio en WhatsApp.
  {
    const fuera = /no puedo ayudarte|se me escapa|no puedo ocuparme/i;

    const [web] = await router('hazme una pagina web', 'Claro, aquí tienes una web para tu clínica...');
    comprobar(fuera.test(web.json.respuesta), 'P: no hace paginas web', web.json.respuesta);

    const [html] = await router('pasame el html', '```html\n<!DOCTYPE html>\n<html lang="es"><body><h1>Hola</h1></body></html>\n```');
    comprobar(!/<html|doctype|<h1/i.test(html.json.respuesta) && fuera.test(html.json.respuesta), 'P: no manda HTML al paciente', html.json.respuesta);

    const [suma] = await router('20+50?', '70 😊');
    comprobar(!/70/.test(suma.json.respuesta), 'P: no hace de calculadora', suma.json.respuesta);

    const [guarro] = await router('una mamada', "I'm sorry, but I can't help with that.");
    comprobar(!/sorry|can't/i.test(guarro.json.respuesta) && fuera.test(guarro.json.respuesta), 'P: la negativa en ingles se sustituye por una en espanol', guarro.json.respuesta);

    // Ojo: aqui no vale "appointment", que entra por consultar cita existente.
    const [ingles] = await router('Hello, do you open on Saturday?', 'Yes, we open on Saturday morning.');
    comprobar(/Saturday morning/.test(ingles.json.respuesta), 'P: a quien escribe en ingles se le contesta en ingles', ingles.json.respuesta);

    const [negrita] = await router('donde estais?', '**Estamos** en Calle Mayor 123.');
    comprobar(negrita.json.respuesta === 'Estamos en Calle Mayor 123.', 'P: quita el markdown que WhatsApp no pinta', negrita.json.respuesta);

    // Falsos positivos: nada de esto puede tratarse como fuera de ambito.
    for (const [mensaje, salida] of [
      ['a las 4 de la tarde', 'Perfecto, ¿me dices tu nombre?'],
      ['5', 'Gracias por la valoración.'],
      ['el 17/09/2026', '¿A qué hora te viene bien?'],
      ['cuanto cuesta una limpieza?', 'La limpieza son 50 €.'],
      ['tengo que cambiar mi cita', '¿Para qué día la quieres mover?']
    ]) {
      const [r] = await router(mensaje, salida);
      comprobar(r.json.respuesta === undefined || !fuera.test(r.json.respuesta), 'P: no confunde "' + mensaje + '" con fuera de ambito', r.json.respuesta);
    }
  }

  // ------------------------------------------------ bateria A-C (25-sep)
  {
    const p = ctx.system_prompt;
    // F2: la tabla de los proximos 7 dias, con nombre del dia y fecha ISO.
    const filas = (p.match(/^- (lunes|martes|miércoles|jueves|viernes|sábado|domingo),? \d{1,2} de \w+ = \d{4}-\d{2}-\d{2}$/gm) || []);
    comprobar(filas.length === 7, 'F2: el prompt trae los proximos 7 dias', filas);
    // F4: el nombre se pide al final y hay que confirmar lo entendido.
    const reservar = p.slice(p.indexOf('RESERVAR CITA'), p.indexOf('CANCELAR CITA'));
    comprobar(/1\. Tratamiento/.test(reservar) && /4\. Nombre/.test(reservar) && /confirma en pocas palabras/.test(reservar), 'F4: orden tratamiento-fecha-hora-nombre', reservar.slice(0, 400));
    // F1, F5, F6 y F3 en el prompt.
    comprobar(/NUNCA escribas formatos técnicos/.test(p), 'F1: el prompt prohibe formatos tecnicos');
    comprobar(/NUNCA ofrezcas horas concretas/.test(p), 'F5: el prompt prohibe inventarse horas');
    comprobar(/Trata SIEMPRE al cliente de tú/.test(p), 'F6: tuteo');
    comprobar(/NO es un lead: es una reserva/.test(p), 'F3: pedir cita no es lead');

    // Las expresiones de n8n se evaluan tal cual estan en el JSON.
    const expr = (nodo, campo) => {
      const n = wf01.nodes.find(x => x.name === nodo);
      const e = campo.split('.').reduce((o, k) => o[k], n.parameters);
      return e.replace(/^=\{\{\s*/, '').replace(/\s*\}\}$/, '');
    };
    // F1: filtro de texto de Enviar WhatsApp.
    const cuerpo = new Function('$json', 'return (' + expr('Enviar WhatsApp', 'textBody') + ');');
    const limpio = cuerpo({ respuesta: '¡Encantada, Carlos! ¿Podrías confirmarme la fecha exacta (YYYY‑MM‑DD) para el jueves?' });
    comprobar(!/YYYY/.test(limpio) && /jueves\?$/.test(limpio), 'F1: quita "(YYYY-MM-DD)"', limpio);
    comprobar(cuerpo({ respuesta: '¿Qué hora prefieres el 2026‑09‑29? (Formato HH:mm)' }) === '¿Qué hora prefieres el 29/09/2026?', 'F1: fecha ISO a dd/mm/aaaa y quita "(Formato HH:mm)"', cuerpo({ respuesta: '¿Qué hora prefieres el 2026‑09‑29? (Formato HH:mm)' }));
    comprobar(cuerpo({ respuesta: 'Perfecto, a las 15:00.' }) === 'Perfecto, a las 15:00.', 'F1: no toca un texto normal');
    comprobar(/no he podido terminar/.test(cuerpo({})), 'F1: sin respuesta sigue saliendo el texto de reserva');

    // F3: condicion de If registrar lead.
    const condLead = wf01.nodes.find(x => x.name === 'If registrar lead').parameters.conditions.conditions[0].leftValue
      .replace(/^=\{\{\s*/, '').replace(/\s*\}\}$/, '');
    const esLead = (accion, texto) => new Function('$json', '$', 'return (' + condLead + ');')(
      { accion }, () => ({ first: () => ({ json: { messages: [{ text: { body: texto } }] } }) }));
    comprobar(esLead('registrar_lead', '¿Cuánto cuesta un blanqueamiento?') === true, 'F3: una pregunta de precio sigue siendo lead');
    for (const texto of ['kiero pedir zita pa una limpieza', 'Buenas. ¿Sería posible concertar una consulta de ortodoncia?', 'necesito ir al dentista', 'quiero reservar ortodoncia']) {
      comprobar(esLead('registrar_lead', texto) === false, 'F3: "' + texto + '" no se guarda como lead');
    }
    comprobar(esLead('reservar', 'cita') === false, 'F3: otras acciones no entran');

    // F7: la franja pedida filtra los huecos.
    const horarios = texto => ejecutar(wf01, 'Preparar horarios disponibles', {
      'Construir contexto': [ctx],
      'Normalizar y enrutar': [{ fecha: '2099-01-06', tratamiento: 'Revision', duracion_minutos: 30, hora_apertura: '09:00', hora_cierre: '20:00' }],
      'WhatsApp Trigger': [trigger(texto)]
    }, []);
    const [tarde] = await horarios('Hola, buenas tardes. ¿Hay hueco el martes por la tarde?');
    comprobar(!/Mañana:/.test(tarde.json.respuesta) && /Tarde:/.test(tarde.json.respuesta) && /por la tarde/.test(tarde.json.respuesta), 'F7: "por la tarde" solo da la tarde', tarde.json.respuesta.slice(0, 120));
    const [todo] = await horarios('buenas tardes, ¿qué hay el martes?');
    comprobar(/Mañana:/.test(todo.json.respuesta) && /Tarde:/.test(todo.json.respuesta), 'F7: "buenas tardes" no cuenta como franja');
    const [man] = await horarios('mañana por la mañana');
    comprobar(/Mañana:/.test(man.json.respuesta) && !/Tarde:/.test(man.json.respuesta), 'F7: "por la mañana" solo da la mañana');
  }

  console.log(fallos === 0 ? `SIMULACION OK (${pruebas} comprobaciones)` : `${fallos} de ${pruebas} comprobaciones FALLAN`);
  process.exitCode = fallos ? 1 : 0;
})().catch(e => { console.error('ERROR EN EL SIMULADOR:', e); process.exitCode = 2; });
