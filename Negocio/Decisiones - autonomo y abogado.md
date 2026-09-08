# Dos decisiones: autónomo y abogado

Tomaste dos decisiones y las dos me parecen bien. Aquí las dejo escritas con
los matices, porque las dos tienen una trampa pequeña que conviene ver.

> No soy abogado ni asesor fiscal. Esto es un análisis de coste y riesgo, no
> asesoramiento legal. Donde hay riesgo real, lo digo.

---

## 1. Autónomo: no darte de alta hasta tener el pago confirmado

**Tu decisión es correcta.** Pagar cuota mientras no ingresas es tirar dinero,
y no hay ninguna prisa artificial para hacerlo.

Pero hay algo que el plan mezclaba y que hay que separar, porque **cambia lo
que puedes hacer esta semana**:

| Trámite | Qué es | Coste | ¿Lo necesitas ya? |
|---|---|---|---|
| **Modelo 036/037** (alta censal) | Decirle a Hacienda que existes como actividad | **Gratis** | 🟢 Sí — Meta te lo pide |
| **Alta en RETA** | Seguridad Social de autónomos | **Cuota mensual** | 🔴 No — solo antes de facturar |

**Son dos administraciones distintas y dos trámites distintos.**

Lo importante: **Meta no te pide estar en la Seguridad Social.** Te pide un
documento oficial con tu nombre y tu dirección de actividad. El **certificado
de situación censal**, que sale del 036, sirve. Y el 036 es gratis.

### Lo que esto significa

Puedes meterte en la cola de verificación de Meta **esta semana, sin pagar un
euro de cuota**. Y como esa cola es lo único que no puedes acelerar, es
justamente lo que te interesa arrancar antes.

### Y encaja con tu propio plan de precios

Tu oferta al primer dentista son **2 meses gratis**. Dos meses gratis = **cero
facturas**. O sea que ni siquiera te hace falta el RETA durante el piloto: te
das de alta cuando vayas a emitir la primera factura de 149 €.

**El orden queda así:**

1. **Ahora** → modelo 036. Gratis. Desbloquea Meta.
2. **Cuando el dentista diga que sí** → firmas el piloto. Sigue sin costarte nada.
3. **Antes de la primera factura** → alta en RETA. Ahí empieza la cuota.

### Los matices honestos

- **No puedes emitir una factura sin estar de alta en los dos sitios.** Ni una.
  Esto no es negociable ni interpretable.
- Estar en el 036 sin estar en RETA es una situación **común y defendible
  mientras no ingresas**, pero no es riesgo cero: la Seguridad Social puede
  entender que hay actividad habitual. Con dos meses de piloto gratuito y sin
  ingresos, el argumento está de tu lado.
- **Pregúntalo gratis.** Cualquier gestoría te resuelve esta duda por teléfono
  en cinco minutos porque quiere tenerte de cliente. No pagues por preguntarlo.
- Cuando te des de alta, mira la **tarifa plana** para nuevos autónomos: la
  cuota del primer año es una fracción de la normal, y se puede prorrogar si
  facturas por debajo del salario mínimo. Confirma la cifra vigente, que cambia.
- La cuota **se prorratea por días** desde 2023. Darte de alta el día 25 te
  cuesta seis días, no un mes. Otra razón para no adelantarlo, pero también
  para no tenerle miedo.

---

## 2. Abogado para el RGPD: prefiero no gastarme ese dinero

**No es obligatorio.** No existe ninguna norma que diga que un abogado tiene
que revisar tus documentos. Lo obligatorio es que **los documentos existan y
sean correctos**, no quién los escribió.

Y ya existen: los tienes en `Legal/`, del 01 al 06.

### Lo que sí es obligatorio, y ya está cubierto

| Obligación | Dónde está | Estado |
|---|---|---|
| Contrato de encargado (art. 28) | `Legal/01` | ✅ Redactado |
| Registro de actividades (art. 30) | `Legal/05` | ✅ Redactado |
| Información al paciente (art. 13) | `Legal/03` y `Legal/06` | ✅ Redactado |
| Delegado de Protección de Datos | — | ❌ No te aplica |
| Evaluación de impacto (art. 35) | — | Le toca a la clínica, no a ti |

Sobre el DPO: la ley española lo exige a los centros sanitarios obligados a
mantener historias clínicas. **Ese es el dentista, no tú.** Tú eres el
encargado. Con un cliente, no te aplica.

### Entonces, ¿qué te estarías perdiendo?

Un abogado aporta tres cosas. **Dos ya las tienes y la tercera es gratis.**

**1. Que el contrato no te arruine.** Es lo más valioso, y ya está: la
cláusula 8 de `Legal/02` limita tu responsabilidad a lo facturado en 12 meses
y excluye el lucro cesante y las decisiones clínicas. Le he añadido hoy la
misma referencia al contrato de encargado, que era donde faltaba.

**2. Que los documentos digan lo que tienen que decir.** Están redactados
sobre los artículos correctos y con las notas de qué rellenar.

**3. Revisión externa.** Y aquí está la clave: **te la van a hacer gratis.**
Una clínica dental está obligada a tener su propio asesor de protección de
datos. Cuando le mandes el contrato de encargado, **lo va a revisar su
asesor**, no el dentista. Es exactamente la misma revisión que pagarías, hecha
por alguien a quien le paga otro.

### La decisión

**No contrates abogado ahora.** Pero haz estas cuatro cosas, que cubren la
mayor parte de lo que te daría:

- [ ] **Rellena el Anexo II del contrato de encargado con datos comprobados.**
      Es lo único de todo el paquete que está a medias, y es lo primero que
      mirará el asesor de la clínica. Entra en la web de cada proveedor
      (Supabase, n8n, Meta, Google, tu proveedor de IA), busca su DPA y apunta
      dónde alojan los datos.
- [ ] **Saca el proveedor de IA de Estados Unidos antes de que haya pacientes
      reales.** Ahora mismo es Groq. Estás mandando texto que puede contener
      datos de salud a una empresa estadounidense sin haber comprobado el
      mecanismo de transferencia. **Es el punto más débil de todo el paquete
      legal** y el único que un asesor competente te va a tumbar.
- [ ] **Seguro de responsabilidad civil profesional.** Para un servicio como el
      tuyo suele costar bastante menos que una consulta de abogado, y cubre
      justo lo que un abogado no puede evitar: que algo salga mal.
- [ ] **Manda el paquete al dentista y deja que lo revise su asesor.** Si te
      devuelven cambios, esa es la revisión gratis.

### Cuándo sí conviene pagar

Vuelve a plantearte el abogado en cualquiera de estos tres momentos:

1. **El asesor de la clínica te pone pegas serias.** Ahí pagas una hora de
   consulta con la pega concreta encima de la mesa. Es mucho más barato que
   una revisión completa y muchísimo más útil.
2. **Cliente número tres.** Con tres clínicas dejas de ser un experimento y el
   riesgo acumulado ya justifica el gasto.
3. **Hay una brecha de seguridad.** Ahí no lo dudes ni un segundo.

### Lo que sí es un riesgo real, y no lo arregla ningún abogado

Que se te filtren datos de pacientes. Un contrato no evita eso; solo reparte
la culpa después. Lo que lo evita es lo del Anexo I: contraseñas fuertes, dos
factores en todo, no compartir credenciales, y **no subir nunca una clave a
git**.

Eso es gratis y vale más que el contrato.
