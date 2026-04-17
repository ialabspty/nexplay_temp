# ClinicBridge Automation — estructura canónica mínima

## Objetivo
Dejar la automatización de plataformas clínicas en una forma simple, permanente y fácil de ejecutar por modelos cognitivos más pequeños.

## Principios
- Las credenciales viven en `ClinicBridge`, no en `.env`.
- Cada ejecución parte desde un `profile_code`.
- Cada plataforma usa un conector con dos responsabilidades mínimas:
  1. `login(page, profile)`
  2. `extractMetrics(page, options)`
- La persistencia ocurre en `ClinicBridge` usando las tablas canónicas del core.

## Archivos canónicos
- `lib/db.js` — conexión MySQL
- `lib/profile-resolver.js` — resolver perfil, login URL y secreto desde BD
- `connectors/clinicweb.js` — conector real inicial de Clinic Web
- `runner_clinicweb_juan_pablo_baseline.js` — runner operativo actual validado

## Fuente de verdad operativa
### BD
- `platform_registry`
- `platform_access_profiles`
- `platform_access_secrets`
- `platform_sync_sessions`
- `doctor_schedule_snapshots`
- `doctor_performance_metrics`
- `doctor_baselines`

## Contrato mínimo por perfil
Cada `profile_code` debe permitir resolver:
- doctor_id
- login_identifier
- login_url
- secret_value activo
- platform_code
- connector_code

## Ejecución mental simple para un modelo pequeño
1. resolver `profile_code`
2. obtener `login_identifier`, `login_url`, `secret_value`
3. abrir navegador
4. hacer login con el conector de plataforma
5. extraer métricas
6. persistir snapshot/métrica/baseline si aplica
7. cerrar `platform_sync_sessions`

## Estado actual
### Clinic Web
- login real validado
- perfil funcional de Juan Pablo
- persistencia base ya operativa
- extracción de agenda todavía susceptible a overlays

### Huli Practice
- arquitectura definida
- perfil esperado definido
- conector real pendiente

## Regla de expansión
Para nuevas plataformas o médicos:
- no duplicar lógica por médico
- reutilizar el conector por plataforma
- solo variar `profile_code` y contexto
