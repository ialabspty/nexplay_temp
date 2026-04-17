# Plan de implementación de bases de datos OpenClaw

## Bases productivas por core
- hq
- LogisticsBridge
- ServiceBridge
- EduBridge
- SupplyBridge
- BusinessOpsBridge
- RetailBridge
- ClinicBridge

## Base compartida de testing
- openclaw_test

## Modelo híbrido
### La base de datos guarda
- entidades principales
- relaciones
- estados
- colas
- auditoría
- configuraciones estructuradas
- referencias a archivos

### El filesystem guarda
- documentos
- imágenes
- PDFs
- exports
- adjuntos pesados
- artefactos de proceso

## Tablas comunes recomendadas para cores productivos
- contacts
- conversations
- messages
- attachments
- task_queue
- audit_logs
- settings
- file_assets
- file_links

## Tablas adicionales exclusivas de HQ
- users
- roles
- user_roles
- agents
- workspaces
- channel_accounts
- system_events
- routing_rules
- agent_registry
- handoff_events
- global_metrics

## Tablas específicas por core
### LogisticsBridge
- shipments
- tracking_events
- warehouses
- lockers
- delivery_routes
- delivery_attempts
- carrier_integrations

### ServiceBridge
- service_cases
- service_types
- requirements
- case_documents
- case_status_history
- appointments
- assigned_operators

### EduBridge
- schools
- school_aliases
- platforms
- school_platforms
- students
- guardians
- guardian_students
- subscriptions
- student_access_profiles
- crawler_sessions
- school_documents
- student_summaries

### SupplyBridge
- orders
- order_items
- suppliers
- supplier_quotes
- purchase_requests
- deliveries
- delivery_addresses
- settlements

### BusinessOpsBridge
- businesses
- business_users
- sales
- sale_items
- expenses
- cash_movements
- customers
- inventory_items
- inventory_movements
- business_tasks
- daily_summaries

### RetailBridge
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

### ClinicBridge
- clinics
- locations
- specialties
- services
- doctors
- doctor_services
- doctor_platforms
- appointments
- patient_contacts
- accepted_insurances

## Testing compartido
Tablas con segregación lógica por:
- core_code
- agent_code
- workspace_code
- environment = test

## Orden de implementación
1. Auditar hq
2. Normalizar/ajustar hq
3. Crear esquema común reutilizable
4. Aplicar esquema común al resto de cores
5. Aplicar tablas específicas por core
6. Crear openclaw_test
