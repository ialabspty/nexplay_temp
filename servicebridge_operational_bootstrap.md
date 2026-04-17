# ServiceBridge — bootstrap operativo inicial

## Objetivo
Definir cómo el agente ServiceBridge debe usar su base `ServiceBridge` en operación real.

## Tablas principales
- contacts
- conversations
- messages
- service_types
- service_cases
- requirements
- case_documents
- case_status_history
- appointments
- assigned_operators
- settings
- file_assets
- file_links

## Flujos principales

### 1. Apertura de caso
1. identificar o crear `contact`
2. resolver `service_type`
3. crear `service_cases`

### 2. Revisión de requisitos
1. consultar `requirements`
2. registrar documentos en `case_documents`
3. actualizar estado del caso

### 3. Seguimiento
1. consultar `service_cases`
2. registrar cambios en `case_status_history`
3. si aplica, asignar operador en `assigned_operators`

### 4. Citas o comparecencias
1. registrar en `appointments`
2. vincular al caso

## Operaciones mínimas
- crear caso
- consultar requisitos
- adjuntar documento
- cambiar estado
- registrar cita
- asignar operador

## Reglas operativas
- cada cambio de estado debe quedar en `case_status_history`
- documentos deben vincularse al caso
- no mezclar tipos de trámite sin tipo de servicio claro

## Próxima fase sugerida
- consultas para apertura de caso
- actualización de estado
- checklist de requisitos por tipo
