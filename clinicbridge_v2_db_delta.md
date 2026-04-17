# ClinicBridge v2 - delta entre BD actual y esquema v2

Base revisada: `ClinicBridge`
Host: `www.servialpa.com`
Motor: MySQL
Fecha de revisión: 2026-04-08

## Resumen ejecutivo
La base actual de `ClinicBridge` ya tiene una base sólida del dominio clínico y del módulo de plataformas/crawling.

### Ya existe y es reutilizable
- `clinics`
- `locations`
- `services`
- `doctors`
- `doctor_services`
- `accepted_insurances`
- `appointments`
- `doctor_platforms`
- `platform_registry`
- `platform_access_profiles`
- `platform_access_secrets`
- `platform_sync_sessions`
- tablas transversales de contactos, conversaciones, mensajes, archivos, tareas y auditoría
- tablas de métricas/impacto del agente por médico

### Falta para v2
- capa multitenant explícita por marca blanca/configuración dinámica
- channels por tenant y routing por `phone_number_id`
- RBAC formal por usuario y por número de teléfono
- auditoría específica de cambios de configuración
- templates de tenant
- capa cognitiva multitenant configurable
- observabilidad formal de resolución de mensajes
- generalización explícita de plataformas por tenant más allá del modelo actual centrado en clínica/médico

## 1. Tablas actuales alineadas con v2

### Clínicas / tenant base clínica
#### actual
- `clinics`

#### observación
Hoy `clinics` ya funciona como entidad raíz de clínica. Puede reutilizarse como base del tenant clínico si se extiende con branding/estado/configuración multitenant.

#### campos actuales relevantes
- `id`
- `code`
- `name`
- `legal_name`
- `status`
- `metadata`

#### recomendación
No duplicar con `tenants` de inmediato. Mejor:
- Opción A: extender `clinics` para que sea la entidad tenant clínica principal.
- Opción B: crear `tenants` y enlazar `clinics.tenant_id`.

Recomendación práctica: **crear `tenants` y relacionarlo con `clinics`** para mantener ClinicBridge compatible con otros usos futuros.

---

### Sedes
#### actual
- `locations`

#### observación
Ya cubre la base de sedes.

#### gap principal
- faltan coordenadas y quizá algunos campos operativos finos
- pero se puede reutilizar sin problema

---

### Médicos
#### actual
- `doctors`

#### observación
Ya existe `clinic_id` y `primary_location_id`, lo cual encaja bien con el modelo v2.

#### gap principal
- faltan algunos flags/atributos operativos si se desean
- no hay tabla explícita de membresía por tenant, porque hoy todo cuelga de `clinic_id`

---

### Servicios
#### actual
- `services`
- `doctor_services`

#### observación
Ya está muy cerca de lo necesario. `services` incluye `clinic_id`, `specialty_id`, `duration_minutes` y tipo de servicio.

#### gap principal
- faltan flags más explícitos de publicación/comercialización y precio por tenant si se quiere manejar desde BD

---

### Seguros
#### actual
- `accepted_insurances`

#### observación
Ya existe por doctor y clínica. Reutilizable.

---

### Citas
#### actual
- `appointments`
- `appointment_attribution`

#### observación
Ya existe una buena base operativa y de medición atribuible al agente.

---

## 2. Plataformas y crawling, estado actual

### Muy buena noticia
El núcleo de plataformas está más avanzado de lo que exige un v2 inicial.

### Tablas existentes
- `doctor_platforms`
- `platform_registry`
- `platform_access_profiles`
- `platform_access_secrets`
- `platform_sync_sessions`
- `doctor_schedule_snapshots`

### Lectura
Ya existe una base bastante útil para:
- catálogo de plataformas
- vínculo doctor/plataforma
- perfil de acceso
- secretos de acceso
- sesiones de sync
- snapshots de agenda

### Fortalezas
- `doctor_platforms` ya contempla:
  - `doctor_id`
  - `clinic_id`
  - `location_id`
  - `service_id`
  - `module_type`
  - `platform_name`
  - `access_url`
  - `resolution_priority`

Eso ya cubre buena parte de la resolución contextual.

### Gap principal
Para v2 faltaría formalizar mejor:
- origen de herencia (`doctor`, `location`, `clinic`)
- scopes más expresivos por especialidad y módulo
- relación más estricta con `platform_registry`
- soporte explícito multitenant si una misma plataforma/connector se usa en muchas clínicas

### Recomendación
No reemplazar estas tablas. **Extenderlas**.

#### cambios sugeridos
`doctor_platforms`
- agregar `origin_scope` (`doctor|location|clinic`)
- agregar `platform_registry_id` nullable o backfill formal
- agregar `specialty_scope_id` nullable si aplica
- revisar si `platform_name` debe seguir o derivarse del registry

`platform_access_profiles`
- ya está bien encaminada
- revisar si `clinic_id` basta o si debe agregar `location_id`
- considerar `scope_type` y `scope_id` explícitos en vez de solo `doctor_id/clinic_id`

`platform_access_secrets`
- ya existe y es clave
- idealmente mover `secret_value` a esquema más seguro o cifrado robusto si aún no lo está

---

## 3. Lo que NO existe todavía y hay que crear

## A. Multitenancy / white-label explícito
### nuevas tablas sugeridas
- `tenants`
- `tenant_branding`
- `tenant_feature_flags`
- `tenant_prompts`
- `tenant_templates`

### por qué
Hoy existe `clinics`, pero no una capa formal para:
- branding white-label
- flags por tenant
- prompts por tenant
- activación rápida por plantilla

---

## B. Canales por tenant
### nuevas tablas sugeridas
- `tenant_channels`

### por qué
Hoy la BD no tiene una tabla formal para mapear:
- `phone_number_id`
- número visible de WhatsApp
- business account
- token refs
- verify token refs
- purpose (`public`, `ops`, `platform_admin`)

Esto es indispensable para routing dinámico por número.

---

## C. RBAC / administración
### nuevas tablas sugeridas
- `platform_users`
- `roles`
- `tenant_memberships`
- `phone_authorizations`

### por qué
Hoy la base tiene contactos y conversaciones, pero no una capa formal de:
- usuario de plataforma
- rol
- membresía por tenant
- autorización por número de teléfono

Esto es indispensable para permitir:
- owners globales
- supervisores de clínica
- operadores
- edición segura por chat/admin

---

## D. Auditoría de cambios de configuración
### nueva tabla sugerida
- `config_change_log`

### por qué
`audit_logs` actual es útil, pero para administración de configuración conviene un registro más estructurado de before/after y entidad cambiada.

---

## E. Capa cognitiva multitenant
### nuevas tablas sugeridas
- `tenant_cognitive_providers`
- `tenant_cognitive_policies`
- `message_resolution_logs`

### por qué
Hoy no existe persistencia formal para:
- qué provider/model usa cada tenant
- para qué propósito
- con qué prioridad
- con qué política
- cuánto costó
- si hubo fallback

---

## 4. Tablas existentes que conviene extender

### `clinics`
Agregar según decisión de arquitectura:
- `tenant_id` nullable al inicio
- `brand_name` o delegarlo a `tenant_branding`
- `default_language`
- `timezone`

### `locations`
Agregar opcionalmente:
- `latitude`
- `longitude`

### `services`
Agregar opcionalmente:
- `public_enabled`
- `price_mode`
- `listed_price`

### `doctor_platforms`
Agregar:
- `platform_registry_id`
- `origin_scope`
- `specialty_id` o `specialty_scope_id` si hace falta

### `platform_access_profiles`
Evaluar agregar:
- `location_id`
- `scope_type`
- `scope_id`

### `settings`
Puede servir como soporte temporal para parámetros, pero no debería reemplazar tablas especializadas de tenant/cognitive/channels.

---

## 5. Propuesta de estrategia de migración

## Fase 1 - no destructiva
Crear sin tocar tablas actuales:
- `tenants`
- `tenant_branding`
- `tenant_feature_flags`
- `tenant_prompts`
- `tenant_templates`
- `tenant_channels`
- `platform_users`
- `roles`
- `tenant_memberships`
- `phone_authorizations`
- `config_change_log`
- `tenant_cognitive_providers`
- `tenant_cognitive_policies`
- `message_resolution_logs`

## Fase 2 - vinculación con lo existente
- agregar `tenant_id` a `clinics`
- backfill: 1 tenant por clínica inicial
- poblar `tenant_branding` desde `clinics`
- poblar `tenant_channels` desde números activos por clínica

## Fase 3 - plataformas
- extender `doctor_platforms`
- extender `platform_access_profiles` si hace falta
- formalizar reglas de herencia/origen

## Fase 4 - runtime
- routing por `phone_number_id`
- carga de tenant por DB
- decisión `hardcoded/db/cognitive/hybrid`

## Fase 5 - administración
- dar alta de owners/supervisores
- comandos admin seguros
- persistencia y auditoría

---

## 6. Recomendaciones concretas

### Reutilizar
- `clinics`
- `locations`
- `doctors`
- `services`
- `doctor_services`
- `accepted_insurances`
- `appointments`
- `doctor_platforms`
- `platform_registry`
- `platform_access_profiles`
- `platform_access_secrets`
- `platform_sync_sessions`
- `doctor_schedule_snapshots`

### Crear nuevo
- todo lo relacionado con tenant branding, channels, RBAC, cognitive y config audit

### Evitar
- duplicar tablas clínicas existentes sin necesidad
- reemplazar `doctor_platforms` o `platform_access_profiles`
- seguir metiendo configuración viva en `.env` o en código

---

## 7. Conclusión
La BD actual de `ClinicBridge` ya está bien posicionada para v2.

El gap principal no está en el dominio clínico ni en crawling.
El gap principal está en:
- multitenancy explícito
- canales por tenant
- administración por roles
- onboarding rápido
- capa cognitiva configurable
- auditoría estructurada de configuración

La estrategia correcta es **extender** la base actual, no rehacerla desde cero.
