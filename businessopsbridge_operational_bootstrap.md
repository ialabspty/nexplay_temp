# BusinessOpsBridge — bootstrap operativo inicial

## Objetivo
Definir cómo el agente BusinessOpsBridge debe usar su base `BusinessOpsBridge` en operación real.

## Tablas principales
- contacts
- conversations
- messages
- businesses
- business_users
- customers
- inventory_items
- inventory_movements
- sales
- sale_items
- expenses
- cash_movements
- business_tasks
- daily_summaries
- settings
- file_assets
- file_links

## Flujos principales

### 1. Registro de negocio
1. crear `businesses`
2. registrar `business_users`

### 2. Clientes
1. identificar o crear `contacts`
2. registrar `customers`

### 3. Inventario
1. registrar `inventory_items`
2. registrar movimientos en `inventory_movements`

### 4. Venta
1. crear `sales`
2. agregar `sale_items`
3. reflejar movimiento de inventario si aplica
4. reflejar caja en `cash_movements`

### 5. Gasto
1. registrar `expenses`
2. registrar impacto en `cash_movements`

### 6. Tareas y resúmenes
1. crear `business_tasks`
2. generar `daily_summaries`

## Operaciones mínimas
- crear negocio
- registrar cliente
- registrar venta
- registrar gasto
- actualizar inventario
- generar resumen diario

## Reglas operativas
- toda venta importante debe reflejar inventario y caja
- todo gasto debe reflejar caja
- el resumen diario debe consolidar ventas y gastos

## Próxima fase sugerida
- consultas operativas para venta/gasto
- generación de resumen diario
- alertas de inventario bajo
