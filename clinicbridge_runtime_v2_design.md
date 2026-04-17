# ClinicBridge runtime v2 - diseño para consumo de BD monobase

## Objetivo
Adaptar el runtime Node productivo para que use `ClinicBridge` como fuente de verdad, resolviendo tenant, branding, políticas y respuestas base desde BD.

## Estado actual
El runtime productivo actual:
- recibe webhook de Meta
- responde con lógica hardcoded simple
- no consulta la BD `ClinicBridge`
- no resuelve tenant por `phone_number_id` desde BD

## Objetivo inmediato v2
Mantener el runtime simple, pero cambiar la fuente de verdad hacia MySQL.

## Flujo de resolución propuesto
1. recibir webhook de Meta
2. extraer `phone_number_id`
3. buscar `tenant_channels.phone_number_id`
4. resolver `tenant_id` y `clinic_id`
5. cargar branding y prompt base del tenant
6. clasificar intención básica
7. responder desde BD cuando aplique
8. registrar mensaje y resolución
9. fallback a hardcoded si algo falla

## Variables de entorno mínimas
- PORT
- META_VERIFY_TOKEN
- META_PHONE_NUMBER_ID
- META_ACCESS_TOKEN
- DB_HOST
- DB_PORT
- DB_NAME
- DB_USER
- DB_PASSWORD
- OPENAI_API_KEY (fase posterior)

## Dependencias sugeridas
- express
- dotenv
- mysql2
- openai (fase posterior)

## Queries mínimas para fase inicial

### Resolver canal/tenant
```sql
SELECT
  tc.id AS channel_id,
  tc.tenant_id,
  tc.clinic_id,
  tc.display_phone_number,
  tc.display_name,
  t.tenant_key,
  t.brand_name,
  t.status AS tenant_status,
  c.name AS clinic_name
FROM tenant_channels tc
JOIN tenants t ON t.id = tc.tenant_id
LEFT JOIN clinics c ON c.id = tc.clinic_id
WHERE tc.phone_number_id = ?
  AND tc.status = 'active'
LIMIT 1;
```

### Greeting/branding
```sql
SELECT greeting_message, tone_profile
FROM tenant_branding
WHERE tenant_id = ?
LIMIT 1;
```

### Prompt público activo
```sql
SELECT content
FROM tenant_prompts
WHERE tenant_id = ?
  AND prompt_type = 'public_system'
  AND status = 'active'
ORDER BY id DESC
LIMIT 1;
```

### Servicios activos
```sql
SELECT name, service_type, listed_price, price_mode
FROM services
WHERE clinic_id = ?
  AND is_active = 1
  AND public_enabled = 1
ORDER BY name;
```

### Médicos activos
```sql
SELECT full_name
FROM doctors
WHERE clinic_id = ?
  AND status = 'active'
ORDER BY full_name;
```

### Seguros
```sql
SELECT d.full_name, ai.insurance_name
FROM accepted_insurances ai
LEFT JOIN doctors d ON d.id = ai.doctor_id
WHERE ai.clinic_id = ?
  AND ai.status = 'active'
ORDER BY d.full_name, ai.insurance_name;
```

### Horarios
```sql
SELECT d.full_name, ds.weekday, ds.start_time, ds.end_time
FROM doctor_schedules ds
JOIN doctors d ON d.id = ds.doctor_id
WHERE d.clinic_id = ?
  AND ds.status = 'active'
  AND d.status = 'active'
ORDER BY d.full_name, ds.weekday, ds.start_time;
```

### Ubicación principal
```sql
SELECT name, address_line1, city, country_code
FROM locations
WHERE clinic_id = ?
  AND status = 'active'
ORDER BY id
LIMIT 1;
```

## Clasificación inicial de intención
La fase inicial puede seguir con heurística simple:
- precio
- ubicación
- horarios
- seguros
- agenda/citas
- servicios
- fallback general

## Resolvedores base

### getPriceReply(clinicId)
- leer servicio `consulta-inicial`
- leer `listed_price`
- leer descuento de metadata si aplica

### getLocationReply(clinicId)
- leer primera sede activa

### getScheduleReply(clinicId)
- leer horarios por médico y formatear

### getInsuranceReply(clinicId)
- agrupar seguros por médico

### getBookingReply(clinicId)
- leer médicos y `metadata.booking_url`

### getServicesReply(clinicId)
- listar servicios activos

## Registro mínimo recomendado

### inbound
- insertar `contacts` si no existe
- insertar o reutilizar `conversations`
- insertar `messages` inbound

### resolución
- insertar en `message_resolution_logs`

### outbound
- insertar `messages` outbound con `provider_message_id`

## Fallback
Si falla MySQL o una query:
- responder con greeting hardcoded seguro
- registrar error en `message_resolution_logs`

## Fase posterior
Una vez esto esté estable:
1. activar provider cognitivo desde `tenant_cognitive_providers`
2. usar `gpt-4o-mini` según policy
3. conservar fallback DB/hardcoded

## Recomendación técnica
No mezclar de una vez:
- MySQL
- OpenAI
- crawling
- administración conversacional

Orden recomendado:
1. DB lookup + respuestas base
2. persistencia inbound/outbound
3. cognitive layer
4. platform resolver / crawling
5. admin commands
