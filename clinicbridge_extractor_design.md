# ClinicBridge — diseño técnico del extractor de agenda

## Objetivo
Diseñar el extractor real para leer plataformas de agenda clínica, calcular baseline y evolución de ocupación, y persistir métricas en `ClinicBridge`.

## Alcance inicial
- Clinic Web
- Huli Practice

## Entrada mínima
- doctor
- access_profile
- sync_type
- rango/periodo objetivo

## Componentes
### 1. Resolver acceso
Fuente:
- platform_access_profiles
- doctor_platforms

Datos necesarios:
- platform_name
- login_identifier
- credential_ref
- login_mode

### 2. Abrir sync session
Tabla:
- platform_sync_sessions

Estados:
- created
- running
- completed
- failed
- expired

### 3. Login
Responsable:
- conector por plataforma

Modos posibles:
- email_password
- oauth (futuro)
- session_reuse (futuro)

### 4. Navegación y lectura
Objetivos mínimos:
- agenda visible
- slots disponibles
- slots ocupados
- canceladas
- no-show si la plataforma lo expone

### 5. Normalización
Campos estandarizados:
- available_slots
- booked_slots
- cancelled_slots
- no_show_count
- occupancy_rate
- snapshot_date
- period_type
- source_platform

### 6. Persistencia
Tablas destino:
- doctor_schedule_snapshots
- doctor_performance_metrics
- doctor_baselines (solo primera línea base)
- appointment_attribution (cuando aplique)

### 7. Actualización de objetivos
Cruzar con:
- doctor_goals
- doctor_goal_actions

Para medir progreso hacia metas como:
- occupancy_rate = 100%

### 8. Cierre de sesión
Actualizar:
- platform_sync_sessions

## Manejo de errores
Registrar en `platform_sync_sessions`:
- credencial inválida
- timeout
- cambio de UI
- extracción incompleta
- acceso denegado

## Frecuencia recomendada
- baseline inicial: ejecución manual/controlada
- refresh posterior: semanal

## Salida mínima esperada
- snapshot por médico
- métrica agregada
- comparación contra baseline
- estado de objetivo si existe

## Fase siguiente
Implementar el conector real por plataforma y probar primero con:
1. Juan Pablo Medina / Clinic Web
2. Liseth Alejandra Jones Ulate / Huli Practice
