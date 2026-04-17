# KargasPTY — Flujo CRM + Google Sheets

## Objetivo
Consultar trackings desde el CRM autenticado, extraer los datos logísticos y consolidarlos con la Google Sheet interna para responder al cliente con criterio operativo.

## Flujo base
1. recibir número de tracking
2. iniciar sesión en el CRM
3. entrar a warehouse management
4. buscar tracking
5. abrir el detalle de carga si aplica
6. extraer campos logísticos disponibles
7. consultar Google Sheet interna
8. consolidar respuesta
9. responder al cliente o escalar

## URLs operativas
- Login CRM: `https://crm.panacargalogistic.com/authentication/login`
- Consulta tracking: `https://crm.panacargalogistic.com/client/warehouse/management`

## Datos a extraer del CRM
Campos mínimos esperados:
- tracking
- status_proveedor
- mode
- wr
- shipment
- fecha_registrado
- tienda_comercio
- factura
- pcs
- unidad
- peso
- length
- width
- height
- volumen
- cubiclaje
- costo_tarifa
- cualquier campo adicional visible en el detalle de carga

## Datos internos en Google Sheets
- estado_interno
- fecha_estimada
- entregado
- fecha_entrega
- precio
- estado_pago
- observaciones
- ultima_actualizacion

## Regla principal
La hoja interna sigue siendo la fuente principal para responder al cliente.
El CRM sirve como fuente de datos logísticos y de detalle.

## Prioridad de datos
1. Google Sheets interna
2. CRM autenticado
3. humano si hay contradicción o incidencia

## Casos clave
### Entregado
Si la hoja dice entregado, se responde entregado aunque el CRM no esté actualizado.

### Listo para entrega con pago pendiente
Si la hoja indica listo para entrega y pago pendiente, se informa con cortesía.

### Tracking no encontrado
Si no aparece en CRM ni en la hoja, se pide validar el tracking.

### Contradicción
Si hay diferencia fuerte entre CRM y hoja, no inventar. Responder prudente y escalar si hace falta.

## Reglas de tono
- cortés
- claro
- sensible con clientes externos
- sin lenguaje vulgar
- dentro del marco legal de Panamá
