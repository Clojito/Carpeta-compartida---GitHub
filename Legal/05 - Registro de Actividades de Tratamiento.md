# Registro de Actividades de Tratamiento (RAT)

> **Obligatorio por el artículo 30 del RGPD.** Es un documento **interno**: no
> se publica, pero es lo primero que pide la AEPD si te inspeccionan. No tenerlo
> es una infracción por sí misma, independientemente de si tratas bien los datos.
>
> Como tratas datos de salud, **te aplica aunque tengas menos de 250 empleados**
> (la excepción del art. 30.5 no vale para categorías especiales).
>
> Rellénalo, guárdalo y **actualízalo cada vez que cambie algo**.

---

**Responsable del registro:** [TU NOMBRE Y APELLIDOS], NIF [TU NIF]
**Marca comercial:** bitclap
**Contacto:** [privacidad@bitclap.es]
**Última actualización:** [FECHA]
**Delegado de Protección de Datos:** No designado — [ver nota al final]

---

## Actividad 1 — Atención automatizada de pacientes (como Encargado)

| Campo | Contenido |
|---|---|
| **Papel** | **Encargado del tratamiento**. El Responsable es cada clínica cliente. |
| **Responsables por cuenta de los que trato** | [LISTA DE CLÍNICAS CLIENTES + CIF] |
| **Finalidad** | Gestión automatizada de citas, recordatorios, valoraciones, registro de interesados y derivación de consultas al personal de la clínica. Aviso al paciente, en su primer contacto, de que habla con un sistema de IA, y registro de sus bajas de mensajes automáticos. |
| **Categorías de interesados** | Pacientes y potenciales pacientes de las clínicas cliente. |
| **Categorías de datos** | Identificativos (nombre, teléfono). De la cita (fecha, hora, tratamiento, estado, valoración). Contenido de los mensajes. **Datos de salud (art. 9)** facilitados voluntariamente por el paciente. |
| **Base jurídica** | La que determine cada Responsable. Yo trato por contrato del art. 28 RGPD. |
| **Destinatarios** | La clínica responsable. Subencargados del Anexo II del contrato. |
| **Transferencias internacionales** | Sí, a tres subencargados: WhatsApp (Meta) y Google (Calendar y Gmail), adheridos al EU-US Data Privacy Framework, e inteligencia artificial (Groq, EE. UU.), con cláusulas contractuales tipo y retención cero. Base de datos (Supabase) y automatización (n8n Cloud): tratamiento en la UE, sin transferencia. Detalle en el Anexo II del Contrato de Encargado. |
| **Plazo de supresión** | Al finalizar el contrato con la clínica: devolución o supresión en 30 días. Mientras dure el contrato, los datos se conservan según los plazos que fije la clínica como responsable (propuesta de la EIPD, Legal/07: citas según la documentación asistencial; derivaciones y conversaciones, 12 meses), y nunca más allá del fin del contrato. Registro de envíos fallidos y de errores: 90 días. |
| **Medidas de seguridad** | Ver Anexo I del Contrato de Encargado del Tratamiento. |

## Actividad 2 — Clientes y facturación (como Responsable)

| Campo | Contenido |
|---|---|
| **Papel** | **Responsable del tratamiento** |
| **Finalidad** | Gestión de la relación contractual, facturación y cumplimiento de obligaciones fiscales. |
| **Categorías de interesados** | Clientes (clínicas) y sus personas de contacto. |
| **Categorías de datos** | Identificativos, de contacto profesional y bancarios/de facturación. |
| **Base jurídica** | Ejecución del contrato (art. 6.1.b) y obligación legal (art. 6.1.c). |
| **Destinatarios** | Administración Tributaria. Entidad bancaria. [GESTORÍA]. |
| **Transferencias internacionales** | No previstas. |
| **Plazo de supresión** | 6 años desde la última anotación contable (Código de Comercio) y los plazos fiscales aplicables. |
| **Medidas de seguridad** | Control de acceso, cifrado, copias de seguridad. |

## Actividad 3 — Contactos comerciales (como Responsable)

| Campo | Contenido |
|---|---|
| **Papel** | **Responsable del tratamiento** |
| **Finalidad** | Atender solicitudes de información y demostraciones; enviar comunicaciones comerciales. |
| **Categorías de interesados** | Potenciales clientes que contactan por la web u otros canales. |
| **Categorías de datos** | Nombre, email, teléfono, clínica, contenido del mensaje. |
| **Base jurídica** | Consentimiento (art. 6.1.a) y medidas precontractuales (art. 6.1.b). |
| **Destinatarios** | [PROVEEDOR DE EMAIL / CRM]. |
| **Transferencias internacionales** | [VERIFICAR SEGÚN PROVEEDOR] |
| **Plazo de supresión** | 1 año desde el último contacto, o hasta que se retire el consentimiento. |
| **Medidas de seguridad** | Control de acceso, cifrado en tránsito. |

---

## Nota sobre el Delegado de Protección de Datos (DPD)

El artículo 37 del RGPD obliga a designar un DPD cuando se tratan datos de
categorías especiales **a gran escala**. Con una clínica cliente no estás ahí,
pero **es una pregunta que hay que revisar según crezcas**: no hay un número
exacto que marque la frontera, y depende del volumen de pacientes, del alcance
territorial y de la permanencia del tratamiento.

**Ponlo en tu lista de revisión al llegar a 8–10 clínicas**, y pregunta al
abogado en la primera revisión para tener criterio antes de necesitarlo.

## Nota sobre la Evaluación de Impacto (EIPD)

El artículo 35 puede exigir una evaluación de impacto cuando hay tratamiento a
gran escala de datos de salud o decisiones automatizadas. La obligación recae
sobre el **Responsable** (la clínica), pero tú debes **asistirla** (cláusula
3.h del contrato).

Ya hay un borrador preparado para dárselo hecho a la clínica:
`Legal/07 - Borrador EIPD para la clinica.md`. Es un argumento de venta muy
bueno frente a clínicas con asesoría jurídica, porque les ahorras trabajo.
