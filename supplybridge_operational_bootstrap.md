# SupplyBridge — bootstrap operativo inicial

## Objetivo
Definir cómo el agente SupplyBridge debe usar su base `SupplyBridge` en operación real.

## Tablas principales
- contacts
- conversations
- messages
- suppliers
- delivery_addresses
- orders
- order_items
- supplier_quotes
- purchase_requests
- deliveries
- settlements
- settings
- file_assets
- file_links

## Flujos operativos principales

### 1. Creación de orden
1. identificar o crear `contact`
2. registrar `delivery_addresses`
3. crear `orders`
4. agregar `order_items`

### 2. Cotización
1. identificar proveedores posibles en `suppliers`
2. registrar `supplier_quotes`
3. actualizar estado de `orders` y `order_items`

### 3. Compra
1. crear `purchase_requests`
2. marcar items comprados
3. actualizar `orders` a `purchased`

### 4. Entrega
1. crear `deliveries`
2. asociar `delivery_address_id`
3. actualizar estados operativos
4. guardar pruebas en `file_assets` si aplica

### 5. Liquidación
1. registrar movimientos en `settlements`
2. clasificar: customer_charge, supplier_payment, delivery_payment, refund, adjustment

## Operaciones mínimas
- crear orden
- agregar items
- registrar dirección
- registrar cotización
- crear solicitud de compra
- registrar entrega
- registrar settlement

## Reglas operativas
- no cerrar una orden sin dirección si el flujo requiere entrega
- no inventar cotizaciones
- separar pedido, compra y entrega como etapas distintas
- usar `settlements` para trazabilidad financiera

## Próxima fase sugerida
- consultas operativas para crear orden
- actualizar estado de orden
- registrar cotización
- registrar entrega y prueba
