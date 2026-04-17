# ClinicBridge v2 - blueprint de marcas blancas, administración y resolución de plataformas

## Objetivo
Convertir ClinicBridge en una plataforma multitenant operable en producción con activación rápida de nuevas clínicas y marcas blancas, números propios por cliente, administración por roles y persistencia formal en BD.

## Principios
- un solo runtime productivo multitenant
- activación por configuración y BD, no por edición manual de código
- separación estricta entre core, runtime y tenant
- canal público separado de canal administrativo
- RBAC por usuario y por número de teléfono
- auditoría obligatoria de cambios
- resolución contextual de plataformas por clínica, sede, médico y módulo
- uso de fuentes por costo/calidad: hardcoded -> DB -> cognitive

## Estado de partida confirmado
El core de ClinicBridge ya contempla:
- capacidades reutilizables de operación clínica
- capas domain, scheduling, metrics, adapters, automation y persistence
- adapters iniciales Clinic Web y Huli
- arquitectura de resolución de plataformas por médico, sede y consultorio
- soporte para crawling mediante links y credenciales por contexto

## Problema actual a resolver
El core existe, pero el despliegue de nuevos clientes sigue siendo demasiado manual.
Actualmente abrir un cliente puede implicar:
- tocar el droplet manualmente
- editar runtime a mano
- reconfigurar webhooks y variables manualmente
- depender de cambios fuera de BD

El objetivo v2 es que el alta de nuevos clientes sea un proceso parametrizado y persistente.

## Arquitectura objetivo

### 1. Core ClinicBridge
Responsabilidad:
- reglas del dominio clínico
- scheduling
- métricas
- políticas comunes
- resolución de plataformas
- adapters de crawling

No debe contener:
- branding específico por tenant
- números de WhatsApp hardcodeados
- secretos productivos por cliente

### 2. Runtime multitenant
Responsabilidad:
- recibir webhooks de canales
- identificar tenant por binding
- cargar config activa del tenant desde BD
- decidir fuente de respuesta
- invocar DB/adapters/modelo
- responder por el canal adecuado
- registrar auditoría, trazas y métricas

Debe ser único para múltiples tenants.

### 3. Tenant / marca blanca
Responsabilidad:
- branding
- médicos
- servicios
- seguros
- sedes
- horarios
- políticas
- prompts
- bindings de canal
- feature flags

Debe vivir en BD y/o config persistente versionada.

## Capas de respuesta por eficiencia
DermaCos y futuros tenants deben responder por capas:

### hardcoded
Usar cuando la respuesta sea fija y autorizada.
Ejemplos:
- ubicación
- precio oficial autorizado
- horarios estáticos
- links oficiales
- políticas simples

### DB
Usar cuando la respuesta cambie o dependa de datos persistidos.
Ejemplos:
- médicos activos
- seguros activos
- servicios activos
- horarios variables
- disponibilidad ya consolidada
- configuración del tenant

### cognitive
Usar cuando haga falta:
- clasificación de intención
- redacción natural
- composición de respuesta desde varias fuentes
- manejo de ambigüedad
- fallback conversacional

La capa cognitiva debe ser configurable por tenant y permitir múltiples providers/modelos simultáneos por propósito.

Modelo inicial sugerido:
- OpenAI `gpt-4o-mini`

### hybrid
Cuando combine DB + modelo o hardcoded + modelo.

## Configuración cognitiva multitenant
No modelar la capa cognitiva como un simple booleano por tenant. Debe soportar múltiples providers/modelos, prioridades y propósitos.

### tenant_cognitive_providers
- id
- tenant_id
- provider_key
- model_key
- purpose
- priority
- status
- temperature
- max_tokens
- timeout_ms
- cost_tier
- secret_ref
- policy_profile
- enabled

### Propósitos sugeridos
- intent_classification
- response_generation
- summarization
- fallback
- admin_assist
- faq_rewrite
- slot_explainer

### Reglas
- un tenant puede tener cero, una o varias capas cognitivas
- un tenant puede usar diferentes modelos para distintos propósitos
- la prioridad define el orden de intento
- si la capa cognitiva falla, debe existir fallback a hardcoded/DB cuando aplique

### tenant_cognitive_policies
- id
- tenant_id
- policy_key
- allowed_domains_json
- blocked_topics_json
- requires_db_grounding
- allow_free_generation
- fallback_mode
- citation_mode
- hallucination_guard_level
- status

## Decision router sugerido
Antes de responder, el runtime debe ejecutar:
1. identificar tenant
2. identificar rol/contexto del remitente
3. clasificar intención
4. decidir fuente (`hardcoded|db|cognitive|hybrid`)
5. si la fuente incluye cognitive, resolver provider/modelo por tenant y propósito
6. resolver contenido
7. aplicar guardrails del tenant
8. responder
9. auditar

## Modelo multitenant base

### tenants
- id
- tenant_key
- brand_name
- business_name
- status
- country
- timezone
- default_language
- vertical
- created_at
- updated_at

### tenant_branding
- id
- tenant_id
- public_name
- legal_name
- description
- logo_url
- primary_color
- tone_profile
- greeting_message

### tenant_locations
- id
- tenant_id
- name
- address_line
- city
- country
- latitude
- longitude
- status

### tenant_doctors
- id
- tenant_id
- full_name
- slug
- specialty
- status
- accepts_new_patients

### tenant_services
- id
- tenant_id
- name
- category
- status
- public_enabled
- price_mode
- listed_price

### tenant_schedules
- id
- tenant_id
- doctor_id nullable
- location_id nullable
- weekday
- start_time
- end_time
- status

### tenant_insurances
- id
- tenant_id
- doctor_id nullable
- insurance_name
- status

### tenant_policies
- id
- tenant_id
- policy_key
- policy_value_json
- status

### tenant_prompts
- id
- tenant_id
- prompt_type
- content
- version
- status

### tenant_feature_flags
- id
- tenant_id
- flag_key
- flag_value
- updated_at

## Canal por cliente
Cada cliente puede tener su propio número.

### tenant_channels
- id
- tenant_id
- channel_type (`whatsapp`)
- provider (`meta-cloud-api`)
- business_account_id
- phone_number_id
- display_phone_number
- display_name
- webhook_path
- access_token_ref
- verify_token_ref
- status
- created_at
- updated_at

## Routing dinámico por número
El runtime debe leer `phone_number_id` del webhook y buscar el tenant en `tenant_channels`.
No debe haber números hardcodeados en el runtime.

## Administración y permisos
Necesitamos RBAC real y persistido.

### platform_users
- id
- full_name
- email nullable
- phone_e164 nullable
- status
- created_at
- updated_at

### roles
- id
- role_key
- description

Roles iniciales:
- platform_owner
- platform_admin
- clinic_supervisor
- clinic_operator
- audit_readonly

### tenant_memberships
- id
- tenant_id
- user_id
- role_id
- status
- created_at

### phone_authorizations
- id
- phone_e164
- user_id nullable
- tenant_id nullable
- role_scope (`platform`|`tenant`)
- role_id
- status
- created_at
- updated_at

## Reglas de acceso por número
- un número platform_owner puede operar sobre toda la plataforma
- un número clinic_supervisor solo sobre su tenant
- un número clinic_operator solo sobre funciones limitadas
- un número no autorizado no puede hacer cambios sensibles

## Separación de canales
No mezclar público y administración.

### channel purposes
- `public_channel`: atención a pacientes
- `clinic_ops_channel`: administración interna de la clínica
- `platform_admin_channel`: administración global de la plataforma

## Configuración administrable por roles

### platform owner / platform admin
Puede:
- crear clínica
- activar/desactivar tenant
- asociar número de WhatsApp
- crear superusuarios de clínica
- definir flags de tenant
- gestionar bindings y secretos

### clinic supervisor
Puede:
- editar médicos
- horarios
- seguros
- servicios
- branding operativo menor
- links públicos
- políticas permitidas

### clinic operator
Puede:
- hacer cambios operativos acotados
- registrar o actualizar datos permitidos

## Auditoría obligatoria

### config_change_log
- id
- actor_user_id nullable
- actor_phone_e164
- tenant_id nullable
- entity_type
- entity_id
- action_type
- before_json
- after_json
- source_channel
- created_at

Todo cambio administrativo debe registrarse.

## Plataformas por clínica y por médico
Este bloque es crítico y debe preservarse en v2.

### Catálogo de plataformas
#### platforms
- id
- platform_key
- display_name
- vendor_type
- supports_crawling
- supports_schedule
- supports_emr
- status

Ejemplos:
- clinic-web
- huli-practice

### Entry points de acceso
#### platform_entrypoints
- id
- tenant_id
- platform_id
- scope_type (`clinic`|`location`|`doctor`)
- scope_id
- login_url
- base_url
- module_type
- status

### Perfiles de acceso
#### platform_access_profiles
- id
- tenant_id
- platform_id
- scope_type (`clinic`|`location`|`doctor`)
- scope_id
- login_identifier
- credential_ref
- inheritance_mode
- status

### Asignaciones médico-plataforma
#### doctor_platform_assignments
- id
- tenant_id
- doctor_id
- platform_id
- origin (`doctor`|`location`|`clinic`)
- location_scope nullable
- specialty_scope nullable
- service_scope nullable
- module_scope
- priority
- status

### Secretos de acceso
#### platform_access_secrets
- id
- tenant_id
- platform_id
- scope_type
- scope_id
- secret_ref
- auth_type
- rotation_status
- updated_at

## Orden de resolución de plataforma
Regla canónica del core:
1. asignación específica del médico para el contexto exacto
2. plataforma propia general del médico
3. plataforma heredada de la sede
4. plataforma heredada del consultorio/clínica

El contexto puede incluir:
- sede
- especialidad
- servicio
- módulo (`agenda`, `expediente`, etc.)

## Crawling y conectores
Los adapters deben poder resolver credenciales y entrypoints dinámicamente desde BD.
No deben depender de `.env` por médico.

Pipeline sugerido:
1. runtime identifica tenant
2. runtime resuelve médico/contexto
3. platform resolver decide plataforma aplicable
4. obtiene `login_url`, `login_identifier` y `credential_ref`
5. ejecuta adapter correspondiente
6. normaliza salida
7. responde o persiste

## Provisioning rápido de nuevos clientes
Objetivo: activar una nueva clínica en 15-30 minutos.

### Flujo de alta
1. crear tenant
2. seleccionar plantilla de vertical
3. registrar branding básico
4. registrar sedes
5. registrar médicos
6. registrar servicios y seguros
7. registrar número de WhatsApp
8. guardar binding del canal
9. crear clinic supervisor
10. activar tenant
11. smoke test
12. apertura controlada

## Plantillas de tenant sugeridas
### tenant_templates
- id
- template_key
- vertical
- base_branding_json
- base_policies_json
- base_prompt
- base_services_json
- feature_flags_json

Ejemplos:
- dermatology-standard
- clinic-general-basic
- multidoctor-premium

## Runtime del canal público
Responsabilidades mínimas:
- recibir Meta webhook
- resolver tenant por `phone_number_id`
- identificar si el remitente es público o admin
- cargar capacidades del tenant
- elegir fuente de respuesta
- responder con identidad del tenant
- registrar source used y auditoría

## Runtime del canal administrativo
Debe soportar comandos seguros por rol.

Ejemplos:
- crear clínica
- crear supervisor
- agregar médico
- actualizar horario
- activar seguro
- asociar número de atención

Todo cambio sensible debe pedir confirmación y registrar auditoría.

## Observabilidad
Registrar al menos:
- tenant_id
- phone_number_id
- inbound_message_id
- source_used (`hardcoded|db|cognitive|hybrid`)
- provider_key si hubo capa cognitiva
- model_key si hubo capa cognitiva
- purpose si hubo capa cognitiva
- response_latency_ms
- token_usage si hubo modelo
- cost_estimate si hubo modelo
- fallback_triggered
- adapter_used si hubo crawling
- success/failure

## Roadmap recomendado

### Fase 1 - estabilización del runtime
- mover runtime productivo a repo fuente de verdad
- externalizar configuración a `.env` y BD
- documentar deploy/rollback

### Fase 2 - multitenant base
- tablas `tenants`, `tenant_channels`, `tenant_branding`, `tenant_doctors`, `tenant_services`, `tenant_schedules`, `tenant_insurances`
- routing por `phone_number_id`
- tenant loading dinámico

### Fase 3 - RBAC y administración
- `platform_users`, `roles`, `tenant_memberships`, `phone_authorizations`
- canal administrativo
- auditoría de cambios

### Fase 4 - platform resolution + crawling
- `platforms`, `platform_entrypoints`, `platform_access_profiles`, `doctor_platform_assignments`, `platform_access_secrets`
- resolver contextual
- adapters conectados por BD

### Fase 5 - cognitive layer
- integración OpenAI `gpt-4o-mini`
- soporte multitenant para múltiples providers/modelos por propósito
- decision router hardcoded/db/cognitive/hybrid
- fallback local obligatorio
- políticas cognitivas por tenant

### Fase 6 - provisioning ágil
- scripts o panel de alta
- templates por vertical
- smoke tests automáticos
- activación en minutos

## Decisiones operativas recomendadas
- no crear un runtime distinto por cliente
- no duplicar `server.js` por marca blanca
- no guardar credenciales de plataformas por médico en `.env`
- no usar modelo para preguntas determinísticas
- mantener separación entre público, ops de clínica y admin de plataforma

## Resultado esperado
ClinicBridge v2 debe permitir:
- crear nuevas marcas blancas por parámetros
- asignar un número de WhatsApp propio a cada cliente
- delegar configuraciones a supervisores de clínica con permisos controlados
- conservar configuraciones en BD de forma permanente
- resolver plataformas por clínica o por médico según contexto
- usar crawling real cuando haga falta
- balancear costo y calidad con capas hardcoded/DB/cognitive
