# KargasPTY — Plantilla Google Sheets + lógica operativa

## Objetivo
Usar una Google Sheet como base interna de consulta para complementar el tracking del proveedor y permitir respuestas claras a clientes de KargasPTY.

## Archivo principal
Importar `kargas_tracking_sheet_template.csv` en Google Sheets.

Nombre sugerido del archivo en Drive:
- `KargasPTY - Tracking Master`

Nombre sugerido de la hoja:
- `trackings`

---

## Columnas de la hoja

### Datos del proveedor
- `tracking`: número único de tracking
- `status_proveedor`: estado visible en el portal del proveedor
- `mode`: modalidad de envío
- `wr`: referencia WR
- `shipment`: referencia de shipment
- `fecha_registrado`: fecha registrada en portal
- `tienda_comercio`: tienda o comercio origen
- `factura`: número de factura asociado
- `pcs`: cantidad de piezas
- `unidad`: tipo de unidad
- `peso`: peso del paquete
- `length`: largo
- `width`: ancho
- `height`: alto
- `volumen`: volumen
- `cubiclaje`: cubicaje/cubaje
- `costo_tarifa`: costo base o tarifa del proveedor

### Datos internos KargasPTY
- `estado_interno`: estado operativo real de KargasPTY
- `fecha_estimada`: fecha estimada para cliente
- `entregado`: `si` o `no`
- `fecha_entrega`: fecha real de entrega
- `precio`: precio al cliente
- `estado_pago`: `pagado`, `pendiente`, `parcial`, `exonerado`
- `observaciones`: notas útiles internas
- `ultima_actualizacion`: fecha/hora de última edición

---

## Reglas de llenado
- `tracking` debe ser único.
- Si `entregado = si`, llenar `fecha_entrega`.
- Si el tracking existe en proveedor y también en KargasPTY, conservar ambos estados.
- `estado_interno` manda sobre `status_proveedor` para comunicar al cliente.
- `ultima_actualizacion` debe actualizarse en cada cambio.

---

## Catálogo sugerido para `estado_interno`
Usar solo valores controlados:
- `recibido_proveedor`
- `en_transito`
- `recibido_bodega`
- `en_clasificacion`
- `listo_para_entrega`
- `en_ruta`
- `entregado`
- `incidencia`
- `retenido`
- `pendiente_pago`

---

## Prioridad de fuentes
1. **Google Sheets interna**
2. **Portal del proveedor**
3. **Humano** si hay contradicción o un caso sensible

### Qué significa esto
- Si el proveedor dice `En tránsito`, pero la hoja interna dice `entregado`, se responde `entregado`.
- Si el proveedor muestra un estado general, pero KargasPTY ya tiene un estado interno más avanzado, se usa el estado interno.
- Si no aparece en proveedor pero sí en la hoja, se usa la hoja.
- Si no aparece en ninguno, se pide validar el tracking.

---

## Lógica de respuesta al cliente

### Caso 1 — Tracking encontrado, estado normal
Condición:
- aparece en proveedor o en hoja
- no está entregado
- no hay incidencia

Respuesta sugerida:
- informar estado actual
- incluir fecha estimada si existe

Ejemplo:
> Su paquete se encuentra actualmente en proceso. La fecha estimada disponible es **[fecha_estimada]**.

### Caso 2 — Estado interno más avanzado
Condición:
- `estado_interno` aporta más información que `status_proveedor`

Respuesta sugerida:
- priorizar el estado interno

Ejemplo:
> Su paquete ya fue recibido por nuestro equipo y se encuentra en proceso interno.

### Caso 3 — Entregado
Condición:
- `entregado = si`

Respuesta sugerida:
- confirmar entrega
- incluir fecha si está disponible

Ejemplo:
> Su paquete ya fue entregado el **[fecha_entrega]**.

### Caso 4 — Listo para entrega con pago pendiente
Condición:
- `estado_interno = listo_para_entrega`
- `estado_pago = pendiente` o `parcial`

Respuesta sugerida:
- informar disponibilidad
- informar saldo con cortesía

Ejemplo:
> Su paquete ya se encuentra listo para entrega. Según nuestro registro, mantiene un saldo pendiente de **[precio]**.

### Caso 5 — Pagado y listo
Condición:
- `estado_interno = listo_para_entrega`
- `estado_pago = pagado`

Respuesta sugerida:
> Su paquete ya se encuentra listo para entrega. Si desea, podemos orientarle con el siguiente paso.

### Caso 6 — No encontrado
Condición:
- no aparece en proveedor
- no aparece en hoja

Respuesta sugerida:
> No logramos ubicar el tracking indicado. Por favor, verifique el número y compártalo nuevamente.

### Caso 7 — Incidencia o contradicción
Condición:
- `estado_interno = incidencia`
- o hay contradicción fuerte entre proveedor y hoja

Respuesta sugerida:
- no prometer
- no inventar
- informar revisión
- escalar a humano si aplica

Ejemplo:
> Estamos validando la información más reciente de su paquete para brindarle una respuesta precisa.

---

## Reglas sobre precio, tarifa y pago

### `costo_tarifa`
- es referencia operativa o del proveedor
- no siempre debe mostrarse al cliente
- usarlo si el flujo requiere explicar composición del cobro

### `precio`
- es el valor que normalmente corresponde comunicar al cliente
- usar cuando el cliente pregunte costo o cuando el pago afecte la entrega

### `estado_pago`
- `pagado`: no insistir en cobro
- `pendiente`: mencionar si impide entrega o si el cliente pregunta por costo
- `parcial`: indicar que aún hay saldo pendiente
- `exonerado`: no cobrar

---

## Reglas de tono
Toda respuesta al cliente debe ser:
- cortés
- clara
- sensible
- sin palabras vulgares ni confrontación
- dentro del marco legal de la República de Panamá

---

## Flujo operativo simple
1. cliente comparte tracking
2. consultar portal del proveedor
3. consultar Google Sheet interna
4. resolver cuál es la fuente principal
5. responder al cliente
6. escalar si hay incidencia o contradicción

---

## Recomendaciones de uso en Google Sheets
- congelar la fila 1
- activar filtros
- proteger columnas clave si varias personas editan
- validar datos para `estado_interno`, `estado_pago` y `entregado`
- usar formato de fecha consistente

---

## Hoja adicional opcional: `catalogos`
Crear una segunda hoja con listas válidas para:
- `estado_interno`
- `estado_pago`
- `entregado`

Valores sugeridos:

### estado_interno
- recibido_proveedor
- en_transito
- recibido_bodega
- en_clasificacion
- listo_para_entrega
- en_ruta
- entregado
- incidencia
- retenido
- pendiente_pago

### estado_pago
- pagado
- pendiente
- parcial
- exonerado

### entregado
- si
- no
