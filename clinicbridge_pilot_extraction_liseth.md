# ClinicBridge — piloto de extracción para Liseth Alejandra Jones Ulate

## Objetivo
Extraer desde Huli Practice el estado actual/base de la agenda de Liseth Alejandra Jones Ulate para calcular ocupación y guardar baseline/métricas en `ClinicBridge`.

## Médico objetivo
- Liseth Alejandra Jones Ulate
- Plataforma: Huli Practice
- Uso esperado: appointments

## Resultado deseado
Poder calcular y persistir:
- available_slots
- booked_slots
- occupancy_rate
- cancelled_slots si existe visibilidad
- no_show_count si existe visibilidad

## Tablas destino
- doctor_schedule_snapshots
- doctor_performance_metrics
- doctor_baselines (si se define baseline inicial)
- platform_sync_sessions

## Flujo propuesto
### 1. Resolver perfil de acceso
Consultar:
- platform_access_profiles
- doctor_platforms

Perfil esperado:
- profile_code: liseth-jones-huli

### 2. Crear sesión de sync
Insertar en:
- platform_sync_sessions

Campos sugeridos:
- access_profile_id
- doctor_id
- sync_type = baseline
- session_status = running
- started_at

### 3. Login en Huli Practice
Entrar con el perfil configurado.

### 4. Navegación mínima
Objetivo de lectura:
- agenda del médico
- disponibilidad visible
- citas confirmadas/ocupadas
- canceladas/no-show si la UI lo expone

### 5. Cálculo
Fórmula base:
- occupancy_rate = booked_slots / available_slots * 100

### 6. Persistencia
Guardar snapshot en:
- doctor_schedule_snapshots

Guardar métrica agregada en:
- doctor_performance_metrics

Si es primera medición base:
- insertar en doctor_baselines

### 7. Cerrar sesión de sync
Actualizar:
- platform_sync_sessions.session_status = completed o failed
- ended_at
- error_message si aplica

## Recomendación de primera medición
Usar:
- period_type = weekly
- snapshot_date = fecha de extracción
