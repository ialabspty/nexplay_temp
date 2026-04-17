# ClinicBridge — guía para pasar de skeleton a ejecución real

## Objetivo
Traducir los esqueletos actuales de Clinic Web y Huli Practice en automatización real ejecutable.

## Archivos base existentes
- clinicbridge_sync_runner_clinicweb.js
- clinicbridge_sync_runner_huli.js
- clinicweb_adapter_playwright_skeleton.js
- huli_adapter_playwright_skeleton.js
- clinicbridge_persistence_operations.md
- clinicbridge_platform_connectors.md

## Pasos para ejecución real

### 1. Preparar entorno con browser automation
Recomendado:
- Node.js
- Playwright

### 2. Implementar resolución segura de credenciales
Pendiente en runners:
- resolver `credential_ref`
- inyectar password de forma segura

### 3. Mapear selectores reales
Para cada plataforma:
- login
- menú de agenda
- selector de médico
- selector de periodo
- slots/citas
- señales de cancelación
- señales de no-show

### 4. Implementar adaptadores
#### Clinic Web
Completar:
- loginClinicWeb
- navigateToSchedule
- ensureDoctorContext
- selectPeriod
- extractClinicWebSchedule

#### Huli Practice
Completar:
- loginHuli
- navigateToSchedule
- ensureDoctorContext
- selectPeriod
- extractHuliSchedule

### 5. Validar extracción local
Para cada plataforma validar que el adaptador devuelva:
- availableSlots
- bookedSlots
- cancelledSlots
- noShowCount

### 6. Conectar al runner
El runner debe:
- crear sync session
- llamar adaptador
- persistir snapshot/métrica/baseline
- actualizar goal
- cerrar sync

### 7. Ejecutar baseline inicial
Orden recomendado:
1. Juan Pablo Medina / Clinic Web
2. Liseth Alejandra Jones Ulate / Huli Practice

## Resultado esperado
Poder responder con datos reales como:
- ocupación actual
- baseline inicial
- evolución posterior
- progreso hacia objetivo

## Reglas de implementación
- no hardcodear contraseñas
- usar `credential_ref`
- validar contexto del médico antes de medir
- registrar errores en `platform_sync_sessions`
- mantener contrato de salida uniforme entre plataformas

## Fase siguiente
Una vez probado el baseline:
- automatizar refresh semanal
- empezar a poblar métricas históricas
- activar comparación antes/después del agente
