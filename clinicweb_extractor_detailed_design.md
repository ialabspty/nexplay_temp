# Clinic Web extractor — diseño técnico detallado

## Objetivo
Diseñar el flujo técnico real para extraer agenda y ocupación desde Clinic Web y persistir la información en `ClinicBridge`.

## Caso inicial
- médico: Juan Pablo Medina
- plataforma: Clinic Web
- perfil: `juan-pablo-medina-clinicweb`

## Entrada requerida
- access_profile_id
- doctor_id
- sync_type (`baseline` o `metrics_refresh`)
- period_type (`weekly` recomendado al inicio)
- target_date o rango visible

## Resolución previa
1. leer `platform_access_profiles`
2. validar `platform_registry` = `clinic-web`
3. obtener:
   - login_identifier
   - credential_ref
   - login_mode
4. abrir `platform_sync_sessions`

## Flujo técnico
### 1. Login
- abrir la URL de acceso de Clinic Web
- completar credenciales
- validar acceso exitoso
- detectar errores de login

### 2. Ir a agenda
- navegar al módulo de agenda/citas
- resolver la vista del médico correcto si la cuenta tiene más de un contexto

### 3. Selección de periodo
- preferencia inicial: semana actual
- si la UI solo permite calendario mensual, derivar vista semanal o consolidar lectura

### 4. Extracción de datos
Objetos a detectar:
- slots totales visibles
- slots ocupados
- slots libres
- cancelaciones visibles
- no-show visibles

### 5. Normalización
Calcular:
- available_slots
- booked_slots
- cancelled_slots
- no_show_count
- occupancy_rate

Fórmula:
- occupancy_rate = booked_slots / available_slots * 100

### 6. Persistencia
1. insertar `doctor_schedule_snapshots`
2. upsert `doctor_performance_metrics`
3. si es primera línea base, insertar `doctor_baselines`
4. si hay `doctor_goals` activos, actualizar `current_value`

### 7. Cierre
- marcar `platform_sync_sessions.session_status = completed`
- guardar `ended_at`
- si falla, guardar `error_message`

## Errores a manejar
- credencial inválida
- MFA o paso extra no previsto
- cambio de layout
- agenda vacía
- acceso a otro perfil distinto del médico esperado
- timeout

## Reglas importantes
- no asumir que una cuenta solo ve un médico
- verificar contexto del médico antes de medir
- registrar en metadata cualquier limitación de lectura
- guardar evidencia resumida del rango medido

## Salida esperada
- snapshot persistido
- métrica persistida
- baseline si corresponde
- sync auditada

## Próxima fase
Implementar un flujo equivalente para:
- Huli Practice
