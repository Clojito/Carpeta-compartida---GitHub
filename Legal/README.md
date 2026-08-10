# Legal — qué necesitas para poder vender

> ⚠️ **Léeme antes que nada.**
>
> No soy abogado. Lo que hay en esta carpeta son **borradores de trabajo**
> hechos a la medida de tu servicio: te ahorran la mayor parte del tiempo y el
> dinero, pero **no sustituyen a una revisión profesional**.
>
> En tu caso concreto esa revisión no es opcional, y el motivo es este: tu bot
> procesa **datos de salud** ("me duele una muela y me sangra"). El RGPD los
> llama *categoría especial* (artículo 9) y les aplica un régimen más estricto,
> con sanciones más altas. No es lo mismo que montar una tienda online.
>
> Presupuesto realista de un abogado especializado en protección de datos
> sanitarios para revisar todo esto: **300–700 €**. Es de lo mejor que puedes
> hacer con ese dinero. Vas a firmar con clínicas que manejan historiales
> médicos: el día que una te pida el contrato de encargado, tiene que estar bien.

---

## Lo primero de todo: no puedes facturar todavía

**No estás dado de alta como autónomo.** Sin eso no puedes emitir una factura
legal, y ningún documento de esta carpeta lo arregla.

Lo que hay que hacer:

1. **Alta censal en Hacienda** (modelo 036 o 037). Es gratis y online.
   Epígrafe IAE orientativo: **763** (servicios informáticos) o **844**
   (servicios de publicidad y marketing). Confírmalo con una gestoría.
2. **Alta en RETA** (autónomos, Seguridad Social). Aquí empieza la cuota.
3. Hay **tarifa plana** para nuevos autónomos durante el primer año, ampliable
   si los ingresos son bajos. **Verifica la cuota y las condiciones vigentes**,
   porque cambian con frecuencia y no me fío de darte una cifra de memoria.

**Cuándo darte de alta:** no antes de tener un compromiso real del dentista.
La cuota corre desde el día del alta, tengas clientes o no. El orden sensato es:
hablar con el dentista → acuerdo de piloto por escrito (aunque sea un email) →
alta de autónomo → Meta Business Verification → primera factura.

> Una gestoría online cuesta unos 30–50 €/mes y te lleva altas, IVA e IRPF.
> Con un solo cliente puedes apañarte tú, pero merece la pena en cuanto haya
> dos o tres.

---

## Tu papel en el RGPD (esto hay que entenderlo)

Es la idea que más veces te van a preguntar, así que conviene tenerla clara:

- **La clínica es el Responsable del Tratamiento.** Los pacientes son suyos,
  decide para qué se usan sus datos y responde ante ellos.
- **Tú eres el Encargado del Tratamiento.** Tratas esos datos *por cuenta de*
  la clínica, solo para darle el servicio, y no puedes usarlos para otra cosa.

Consecuencia práctica: **el artículo 28 del RGPD obliga a que exista un contrato
por escrito entre vosotros dos.** No es opcional ni es un formalismo. Es el
documento `01` de esta carpeta y es el más importante de todos.

Y una consecuencia más: los servicios que tú usas (Meta, Supabase, Google, el
proveedor de IA) son **subencargados**. La clínica tiene que autorizarlos, y
por eso están listados en el contrato.

---

## Los documentos, por orden de importancia

| # | Documento | Para qué | ¿Obligatorio? |
|---|---|---|---|
| 01 | Contrato de Encargado del Tratamiento | Lo firmas con cada clínica | **Sí, artículo 28 RGPD** |
| 02 | Contrato de prestación de servicios | Precio, permanencia, responsabilidad | Muy recomendable |
| 03 | Política de privacidad (web) | Para tu propia web | Sí, si tienes web |
| 04 | Aviso legal | Quién eres, LSSI-CE | Sí, si tienes web |
| 05 | Política de cookies | Solo si la web usa cookies | Depende |
| 06 | Registro de Actividades de Tratamiento | Te lo pide la AEPD si te inspecciona | **Sí, artículo 30 RGPD** |
| 07 | Textos RGPD del bot | Lo que el bot debe decirle al paciente | **Sí, artículos 13 y 14** |

**Si solo pudieras hacer tres cosas:** el 01, el 06 y el 07. Sin el 01 no
puedes trabajar legalmente con una clínica. El 06 es lo primero que pide la
AEPD. El 07 es lo que ve el paciente.

---

## Cómo usar estos borradores

1. Busca los `[CORCHETES EN MAYÚSCULAS]` y rellénalos con tus datos.
2. Repasa las notas marcadas con `>` — son decisiones que tienes que tomar tú.
3. Manda el paquete a un abogado de protección de datos.
4. Guarda copia firmada de cada contrato. Escaneada vale.

---

## Dos cosas que te van a morder si no las miras ahora

**1. El proveedor de IA está en Estados Unidos.**

Ahora mismo usas **Groq**, empresa estadounidense. Por ahí pasan los mensajes
de los pacientes, incluyendo síntomas. Eso es una transferencia internacional
de datos de salud, y es el punto más flojo de todo tu montaje legal.

Opciones, de mejor a peor:
- Un modelo alojado en la UE (Mistral es francesa; Azure OpenAI y AWS Bedrock
  permiten fijar región europea).
- Seguir con un proveedor de EE. UU. **verificando** que tiene un mecanismo de
  transferencia válido y documentándolo en el contrato.
- No hacer nada. No te lo recomiendo con datos de salud.

Decídelo **antes** de firmar con la clínica, no después.

**2. Minimiza lo que guardas.**

Cuanto menos dato sensible almacenes, menos expuesto estás. Revisa si de verdad
necesitas guardar el texto literal de los síntomas en la tabla `derivaciones`,
o si te basta con "consulta clínica pendiente" y que el detalle lo vea el
dentista en su email y ahí muera. Menos datos guardados = menos riesgo, menos
obligaciones y una conversación más fácil con cualquier clínica.
