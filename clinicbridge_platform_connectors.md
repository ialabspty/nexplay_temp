# ClinicBridge — conectores generales por plataforma

## Objetivo
Definir el contrato reusable de conectores por plataforma clínica para que múltiples médicos puedan usar la misma integración de mercado.

## Principio arquitectónico
Las plataformas de mercado no se modelan como integraciones exclusivas de un médico.
Se modelan como:
1. plataforma compartida (`platform_registry`)
2. perfil de acceso por médico o contexto (`platform_access_profiles`)
3. sesión de sync por ejecución (`platform_sync_sessions`)
4. snapshots y métricas por médico (`doctor_schedule_snapshots`, `doctor_performance_metrics`)

## Plataformas iniciales
- Clinic Web
- Huli Practice

## Contrato general del conector
### Entrada mínima
- platform_registry_id o platform_code
- access_profile_id
- doctor_id
- sync_type
- period_type
- target_date o rango

### Resolución previa
1. resolver plataforma en `platform_registry`
2. resolver perfil en `platform_access_profiles`
3. validar médico/alcance
4. abrir `platform_sync_sessions`

### Salida mínima estandarizada
- available_slots
- booked_slots
- cancelled_slots
- no_show_count
- occupancy_rate
- snapshot_date
- period_type
- source_platform

### Persistencia estándar
- `doctor_schedule_snapshots`
- `doctor_performance_metrics`
- `doctor_baselines` (si corresponde a baseline inicial)
- `platform_sync_sessions`

## Conector: Clinic Web
### connector_code
- `clinicbridge-clinic-web-v1`

### Responsabilidades
- login con perfil asignado
- navegar agenda visible
- detectar espacios disponibles
- detectar citas ocupadas
- captar cancelaciones/no-show si la UI lo permite
- normalizar salida al contrato general

## Conector: Huli Practice
### connector_code
- `clinicbridge-huli-practice-v1`

### Responsabilidades
- login con perfil asignado
- navegar agenda visible
- detectar espacios disponibles
- detectar citas ocupadas
- captar cancelaciones/no-show si la UI lo permite
- normalizar salida al contrato general

## Reglas de diseño
- la lógica de extracción vive en el conector, no en el médico
- el médico solo aporta el perfil de acceso y el contexto
- el contrato de salida debe ser el mismo para todas las plataformas
- si una plataforma no expone un dato, registrar el faltante en metadata

## Frecuencia sugerida
- baseline inicial: manual / controlada
- refresh operativo: semanal
- refresh intensivo: diario si el negocio lo requiere

## Manejo de errores
Registrar en `platform_sync_sessions`:
- credencial inválida
- timeout
- cambio de interfaz
- permisos insuficientes
- extracción parcial

## Próxima fase
Implementar los conectores reales:
1. Clinic Web connector
2. Huli Practice connector
