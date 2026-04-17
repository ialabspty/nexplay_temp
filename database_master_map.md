# Database Master Map — OpenClaw cores

## Resumen general
Arquitectura implementada con un modelo híbrido:
- MySQL para entidades, relaciones, estados, colas, configuración y auditoría
- filesystem para archivos/artefactos referenciados desde la BD

## Bases implementadas
- hq
- LogisticsBridge
- ServiceBridge
- EduBridge
- SupplyBridge
- BusinessOpsBridge
- RetailBridge
- ClinicBridge
- openclaw_test

---

## 1. HQ
### Base
- `hq`

### Rol
Centro de coordinación, routing, gobernanza y control transversal.

### Tablas clave
- users
- roles
- user_roles
- agents
- workspaces
- channel_accounts
- contacts
- conversations
- messages
- attachments
- task_queue
- audit_logs
- settings
- file_assets
- file_links
- system_events
- routing_rules
- agent_registry
- handoff_events
- global_metrics
- db_connection_profiles
- db_connection_permissions
- db_connection_audit

### Seeds / config aplicados
- settings globales base
- perfiles de conexión por core
- permisos de conexión base por agente

---

## 2. LogisticsBridge
### Marca pública principal
- KargasPTY

### Base
- `LogisticsBridge`

### Tablas clave
- warehouses
- lockers
- shipments
- tracking_events
- delivery_routes
- delivery_attempts
- carrier_integrations
- contacts
- conversations
- messages
- attachments
- task_queue
- audit_logs
- settings
- file_assets
- file_links

### Seed/config aplicada
- configuración operativa base

### Bootstrap operativo
- `logisticsbridge_operational_bootstrap.md`

---

## 3. ServiceBridge
### Marca pública principal
- Servialpa

### Base
- `ServiceBridge`

### Tablas clave
- service_types
- service_cases
- requirements
- case_documents
- case_status_history
- appointments
- assigned_operators
- contacts
- conversations
- messages
- attachments
- task_queue
- audit_logs
- settings
- file_assets
- file_links

### Seed/config aplicada
- catálogo base de tipos de servicio

### Bootstrap operativo
- `servicebridge_operational_bootstrap.md`

---

## 4. EduBridge
### Marca pública principal
- EduBridge

### Base
- `EduBridge`

### Tablas clave
- platforms
- schools
- school_aliases
- school_platforms
- guardians
- students
- guardian_students
- subscriptions
- student_access_profiles
- crawler_sessions
- school_documents
- student_summaries
- contacts
- conversations
- messages
- attachments
- task_queue
- audit_logs
- settings
- file_assets
- file_links

### Seed/config aplicada
- configuración base del core

### Bootstrap operativo
- `edubridge_operational_bootstrap.md`

---

## 5. SupplyBridge
### Marca pública principal
- TeLoLLevo

### Base
- `SupplyBridge`

### Tablas clave
- suppliers
- delivery_addresses
- orders
- order_items
- supplier_quotes
- purchase_requests
- deliveries
- settlements
- contacts
- conversations
- messages
- attachments
- task_queue
- audit_logs
- settings
- file_assets
- file_links

### Seed/config aplicada
- configuración operativa base

### Bootstrap operativo
- `supplybridge_operational_bootstrap.md`

---

## 6. BusinessOpsBridge
### Marca pública principal
- Tu negocio al día

### Base
- `BusinessOpsBridge`

### Tablas clave
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
- contacts
- conversations
- messages
- attachments
- task_queue
- audit_logs
- settings
- file_assets
- file_links

### Seed/config aplicada
- configuración operativa base

### Bootstrap operativo
- `businessopsbridge_operational_bootstrap.md`

---

## 7. RetailBridge
### Marca pública principal
- Jardines Panamá

### Base
- `RetailBridge`

### Tablas clave
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
- contacts
- conversations
- messages
- attachments
- task_queue
- audit_logs
- settings
- file_assets
- file_links

### Seed/config aplicada
- tenant `jardines-panama`
- categorías base
- zona de entrega placeholder
- lista de precios base

### Bootstrap operativo
- `retailbridge_operational_bootstrap.md`

---

## 8. ClinicBridge
### Marca pública principal
- DermaCos

### Base
- `ClinicBridge`

### Tablas clave
- clinics
- locations
- specialties
- services
- doctors
- doctor_services
- doctor_platforms
- patient_contacts
- appointments
- accepted_insurances
- contacts
- conversations
- messages
- attachments
- task_queue
- audit_logs
- settings
- file_assets
- file_links

### Seed/config aplicada
- seed real de DermaCos Panamá
- sede
- especialidad
- servicios
- médicos
- plataformas
- seguros aceptados

### Bootstrap operativo
- `clinicbridge_operational_bootstrap.md`

---

## 9. Testing compartido
### Base
- `openclaw_test`

### Propósito
Entorno lógico compartido de pruebas con segregación por core/agente/workspace.

### Tablas clave
- test_workspaces
- test_contacts
- test_conversations
- test_messages
- test_tasks
- test_file_assets
- test_audit_logs

---

## Gobernanza de conexiones
La base `hq` contiene:
- `db_connection_profiles`
- `db_connection_permissions`
- `db_connection_audit`

Propósito:
- registrar perfiles de conexión por core
- definir permisos por agente
- auditar uso de conexiones/transacciones

---

## Siguiente fase recomendada
1. crear queries y operaciones base por core
2. integrar cada agente con su core correspondiente
3. profundizar seeds reales por negocio/tenant
4. añadir índices/performance según uso real
5. formalizar migraciones/versionado de esquema
