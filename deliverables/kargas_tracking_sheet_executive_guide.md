# KargasPTY — Guía ejecutiva de uso

## Qué es
Una base simple en Google Sheets para consultar tracking, validar estado interno y responder a clientes con información clara.

## Para qué sirve
- consultar un tracking por número
- comparar estado del proveedor con estado interno
- saber si el paquete ya fue entregado
- validar precio y estado de pago
- responder al cliente con criterio uniforme

## Fuente principal
La hoja interna de Google Sheets es la fuente principal para responder al cliente.

## Fuente secundaria
El portal del proveedor se usa como apoyo para:
- status visible
- referencias del envío
- peso, medidas y datos logísticos

## Regla clave
Si la hoja interna contradice al proveedor, prevalece la hoja interna.

## Cuándo usar cada dato
### Para informar al cliente
Usar principalmente:
- tracking
- estado_interno
- fecha_estimada
- entregado
- fecha_entrega
- precio
- estado_pago

### Para validación operativa
Usar también:
- status_proveedor
- mode
- wr
- shipment
- tienda_comercio
- factura
- pcs
- unidad
- peso
- medidas
- volumen
- cubiclaje
- costo_tarifa

## Reglas de respuesta
### Estado normal
Informar estado actual y fecha estimada si existe.

### Entregado
Confirmar que ya fue entregado e incluir fecha si está disponible.

### Listo para entrega con pago pendiente
Informar disponibilidad y saldo pendiente con cortesía.

### No encontrado
Pedir validar nuevamente el tracking.

### Incidencia o contradicción
No prometer ni inventar. Escalar revisión humana si hace falta.

## Reglas de tono
Toda comunicación al cliente debe ser:
- cortés
- clara
- sensible
- sin lenguaje vulgar
- dentro del marco legal de la República de Panamá

## Estructura recomendada en Drive
Archivo sugerido:
- `KargasPTY - Tracking Master`

Hojas sugeridas:
1. `trackings`
2. `catalogos`

## Flujo simple
1. cliente comparte tracking
2. revisar portal del proveedor
3. revisar Google Sheet
4. tomar la hoja interna como referencia principal
5. responder al cliente
6. escalar si hay incidencia

## Qué no hacer
- no responder solo con el status crudo del proveedor
- no prometer fechas no confirmadas
- no marcar entregado sin validación interna
- no confrontar al cliente
