# Textos RGPD para el bot

> Los artículos 13 y 14 del RGPD obligan a **informar al paciente** de que sus
> datos se están tratando. Como el paciente habla con un bot, esa información
> tiene que llegarle por WhatsApp.
>
> **La obligación es de la clínica** (es la Responsable), pero eres tú quien
> tiene que dárselo hecho. Esto es tanto cumplimiento como argumento de venta:
> le estás resolviendo un problema que probablemente ni sabía que tenía.

---

## 1. Primer mensaje del bot a un paciente nuevo

Este texto debe salir la **primera vez** que alguien escribe. En WhatsApp no
puede ser un tocho: si es largo, nadie lo lee y encima estropea la experiencia.

```
¡Hola! Soy [NOMBRE DEL ASISTENTE], el asistente virtual de [NOMBRE DE LA CLÍNICA] 🦷

Te ayudo a pedir, cambiar o anular tu cita, a cualquier hora.

ℹ️ Soy un sistema automático. [NOMBRE DE LA CLÍNICA] trata tus datos para
gestionar tus citas. Puedes consultar los detalles y ejercer tus derechos
aquí: [ENLACE A LA POLÍTICA DE PRIVACIDAD DE LA CLÍNICA]

Si prefieres hablar con una persona, escribe "persona" o llama al [TELÉFONO].

¿En qué te ayudo?
```

**Por qué está montado así:**

- **Se identifica como sistema automático desde la primera línea.** No hay que
  engañar a nadie sobre si habla con una persona.
- **Enlaza a la política de la clínica**, no a la tuya: la Responsable es ella.
- **Ofrece salida a un humano.** Es exigible cuando hay tratamiento
  automatizado, y además evita frustración.
- **Es corto.** Un mensaje de 400 palabras en WhatsApp no lo lee nadie, y un
  aviso que nadie lee no cumple su función.

> **Implementación:** hoy el bot no distingue si es la primera vez que alguien
> escribe. Se puede resolver mirando si el teléfono ya existe en la base de
> datos. Está apuntado en el estado del proyecto como pendiente.

## 2. Aviso al pedir datos de salud

Cuando el paciente describe un síntoma y el bot va a derivar:

```
Gracias por contarme lo que te pasa. Le paso el mensaje al equipo de la
clínica para que te llamen lo antes posible.

⚠️ No puedo darte consejo médico ni valorar tu caso: para eso hace falta
un profesional.

Si es urgente y te encuentras mal, llama al [TELÉFONO] o al 112.
```

**Esta es la frase más importante de todo el bot.** Deja claro que no hay
diagnóstico automatizado. Sin ella, un paciente puede entender que el bot le ha
"valorado" y esperar en casa cuando debería ir a urgencias.

## 3. Texto para la política de privacidad de la clínica

Pásale esto a tu cliente para que lo añada a su política. **Le ahorras trabajo
y te posiciona como alguien que sabe lo que hace.**

```
CANAL DE ATENCIÓN AUTOMATIZADA POR WHATSAPP

Ponemos a tu disposición un asistente virtual en WhatsApp para gestionar citas.

¿Quién trata tus datos? [NOMBRE DE LA CLÍNICA], CIF [CIF], como responsable.

¿Con qué finalidad? Gestionar tu cita (alta, cambio y anulación), enviarte
recordatorios, pedirte tu opinión tras la visita y atender tus consultas.

¿Qué datos tratamos? Tu nombre, tu teléfono, los datos de tu cita y el
contenido de los mensajes que nos envíes. Si nos describes un síntoma, esa
información se considera dato de salud y solo se usa para que nuestro equipo
pueda atenderte.

¿Cuál es la base legal? Tu consentimiento al escribirnos y la ejecución de la
relación asistencial. Para los recordatorios, nuestro interés legítimo en que
no pierdas tu cita.

¿Quién más accede? Un proveedor tecnológico que nos presta el servicio de
automatización, con contrato de encargado de tratamiento firmado, y los
servicios de mensajería y agenda necesarios para que funcione.

¿Cuánto tiempo? Mientras seas paciente y durante los plazos legales que nos
obligan a conservar la información asistencial.

¿Y el asistente decide algo por su cuenta? El asistente solo gestiona la
agenda. Ninguna decisión clínica se toma de forma automatizada: toda consulta
sanitaria la revisa una persona de nuestro equipo.

Tus derechos: puedes acceder, rectificar, suprimir, oponerte, limitar el
tratamiento y solicitar la portabilidad de tus datos escribiendo a [EMAIL].
También puedes reclamar ante la Agencia Española de Protección de Datos
(www.aepd.es).
```

## 4. Cosas que el bot no debe hacer nunca

Repásalo cada vez que toques el prompt:

- ❌ Dar diagnósticos, aunque el paciente insista.
- ❌ Recomendar medicamentos o dosis, ni siquiera un ibuprofeno.
- ❌ Decir si algo "es grave" o "puede esperar".
- ❌ Hacerse pasar por una persona si le preguntan directamente.
- ❌ Pedir datos que no necesita: DNI, número de tarjeta, historial completo.
- ❌ Guardar más información sensible de la imprescindible.

> **Sobre el último punto:** revisa si necesitas guardar el texto literal de los
> síntomas en la tabla `derivaciones`. Si te basta con "consulta clínica
> pendiente" y que el detalle viaje solo en el email al dentista, reduces mucho
> tu exposición: menos datos guardados, menos riesgo, menos obligaciones y una
> conversación más cómoda con cualquier clínica que tenga asesor legal.
