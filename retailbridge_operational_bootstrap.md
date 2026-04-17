# RetailBridge — bootstrap operativo inicial

## Objetivo
Definir cómo el agente RetailBridge debe usar su base `RetailBridge` en operación real.

## Tablas principales
- contacts
- conversations
- messages
- tenants
- catalog_categories
- catalog_products
- product_variants
- inventory_items
- inventory_movements
- customer_orders
- order_items
- delivery_zones
- price_lists
- settings
- file_assets
- file_links

## Flujos principales

### 1. Catálogo
1. resolver `tenant`
2. listar `catalog_categories`
3. listar `catalog_products`
4. usar `product_variants` cuando aplique

### 2. Inventario
1. consultar `inventory_items`
2. registrar cambios en `inventory_movements`

### 3. Pedido
1. identificar o crear `contact`
2. crear `customer_orders`
3. agregar `order_items`
4. asignar `delivery_zone`

### 4. Precio
1. resolver `price_lists`
2. calcular total por item y pedido

## Operaciones mínimas
- listar categorías
- listar productos
- registrar pedido
- actualizar inventario
- asignar zona de entrega

## Reglas operativas
- siempre operar por `tenant`
- no mezclar catálogo entre tenants
- validar stock antes de confirmar
- usar zonas de entrega para condiciones logísticas

## Próxima fase sugerida
- consultas de catálogo por tenant
- creación de pedido
- ajuste de inventario
