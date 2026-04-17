# ClinicBridge — operaciones base de persistencia

## Objetivo
Definir cómo persistir en `ClinicBridge` los datos que devuelvan los conectores de plataformas.

## Operaciones mínimas

### 1. Crear sesión de sync
Tabla:
- `platform_sync_sessions`

Campos mínimos:
- access_profile_id
- doctor_id
- sync_type
- session_status = running
- started_at

### 2. Insertar snapshot de agenda
Tabla:
- `doctor_schedule_snapshots`

Campos mínimos:
- doctor_id
- access_profile_id
- snapshot_date
- period_type
- available_slots
- booked_slots
- cancelled_slots
- no_show_count
- source_platform
- metadata

### 3. Insertar/actualizar métrica agregada
Tabla:
- `doctor_performance_metrics`

Campos mínimos:
- doctor_id
- metric_date
- period_type
- available_slots
- booked_slots
- occupancy_rate
- cancelled_appointments_count
- no_show_count
- agent_assisted_appointments_count
- agent_attributed_appointments_count
- metadata

### 4. Insertar baseline inicial
Tabla:
- `doctor_baselines`

Condición:
- solo si todavía no existe baseline para el periodo/meta elegida

Campos mínimos:
- doctor_id
- baseline_date
- period_type
- available_slots
- booked_slots
- occupancy_rate
- source_type
- notes
- metadata

### 5. Actualizar progreso del goal
Tabla:
- `doctor_goals`

Uso:
- actualizar `current_value`
- revisar si `target_value` fue alcanzado
- si sí, cambiar `status = achieved`

### 6. Cerrar sesión de sync
Tabla:
- `platform_sync_sessions`

Campos:
- session_status = completed o failed
- ended_at
- error_message si aplica

## Fórmulas base
### ocupación
- occupancy_rate = booked_slots / available_slots * 100

### avance hacia goal de ocupación
- current_value = occupancy_rate

## Reglas
- el snapshot es el dato granular
- la métrica es la agregación normalizada
- el baseline es la primera línea de comparación
- el goal se actualiza a partir de la métrica, no directamente del crawler

## Próxima fase
Crear scripts SQL parametrizables o procedimientos para:
- insertar snapshot
- upsert de performance metric
- insertar baseline si no existe
- actualizar goal automáticamente
