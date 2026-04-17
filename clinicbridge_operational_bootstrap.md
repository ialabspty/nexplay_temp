# ClinicBridge — bootstrap operativo inicial

## Objetivo
Definir cómo el agente ClinicBridge debe usar su base `ClinicBridge` en operación real.

## Tablas principales
- contacts
- conversations
- messages
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
- settings
- file_assets
- file_links

## Flujos operativos principales

### 1. Consulta de servicios
Orden sugerido:
1. identificar clínica y sede
2. consultar `services`
3. filtrar por `is_active`
4. si aplica, cruzar con `doctor_services`

### 2. Consulta de médicos
1. listar `doctors` activos
2. resolver sede con `locations`
3. cruzar con `doctor_services`
4. usar `accepted_insurances` si el paciente pregunta por seguros

### 3. Solicitud de cita
1. identificar o crear `contact`
2. crear o localizar `patient_contacts`
3. resolver médico
4. resolver servicio
5. resolver sede
6. crear `appointments` con estado `requested` o `scheduled`
7. si el modelo operativo exige link externo, usar `doctor_platforms`

### 4. Resolución de plataforma
Orden de resolución recomendado:
1. plataforma específica del médico para el contexto exacto
2. plataforma general del médico
3. plataforma heredada de sede
4. plataforma heredada de clínica

Tablas:
- `doctor_platforms`
- `doctors`
- `locations`
- `services`
- `clinics`

### 5. Información administrativa
Usar:
- `services`
- `doctors`
- `locations`
- `accepted_insurances`

No usar la BD para improvisar:
- indicaciones médicas
- preparación clínica
- cuidados posteriores
- respuestas médicas no autorizadas

## Operaciones mínimas que el agente debe soportar
- listar médicos
- listar servicios
- validar seguros por médico
- registrar solicitud de cita
- consultar sede y ubicación
- resolver plataforma de agenda

## Reglas operativas
- el agente es administrativo, no clínico
- no inventar precios no autorizados
- no inventar cuidados o recomendaciones médicas
- si no hay resolución directa, priorizar el link oficial del médico
- registrar contacto/paciente antes de la cita si el flujo lo requiere

## Próxima fase sugerida
Crear scripts o consultas operativas para:
- búsqueda de médico por nombre
- servicios por médico
- seguros aceptados por médico
- creación de appointment request
- resolución de plataforma de agenda
