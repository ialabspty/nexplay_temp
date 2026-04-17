# LogisticsBridge — bootstrap operativo inicial

## Objetivo
Definir cómo el agente LogisticsBridge debe usar su base `LogisticsBridge` en operación real.

## Tablas principales
- contacts
- conversations
- messages
- warehouses
- lockers
- shipments
- tracking_events
- delivery_routes
- delivery_attempts
- carrier_integrations
- settings
- file_assets
- file_links

## Flujos principales

### 1. Prealerta / registro de envío
1. identificar o crear `contact`
2. resolver `locker`
3. crear `shipments`

### 2. Recepción y tracking
1. actualizar estado de `shipments`
2. registrar eventos en `tracking_events`

### 3. Ruta de entrega
1. crear `delivery_routes`
2. registrar `delivery_attempts`
3. guardar prueba si aplica

### 4. Integración de carrier
1. resolver `carrier_integrations`
2. normalizar tracking y eventos

## Operaciones mínimas
- crear shipment
- consultar shipment por tracking
- registrar tracking event
- crear delivery route
- registrar intento de entrega

## Reglas operativas
- cada cambio importante debe reflejarse en tracking
- locker y warehouse deben resolverse antes de operar
- no marcar entregado sin intento o evidencia cuando aplique

## Próxima fase sugerida
- consultas por tracking
- inserción de eventos
- registro de intento de entrega
