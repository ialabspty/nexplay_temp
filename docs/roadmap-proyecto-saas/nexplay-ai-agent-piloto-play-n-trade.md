# NEXPLAY AI Agent, configuración sugerida de tenant piloto (Play N Trade)

## Candidato de piloto
Usar como primer tenant piloto:
- tenant: `Play N Trade`
- tenantCode: `PnT507`
- tenantId: `969f46f3-f93b-4807-aa28-dd9836e748a6`
- store por defecto: `Town Center`
- storeId: `f5079133-c36e-460b-9977-a14057ab0368`

## Qué falta definir manualmente
Solo faltan dos datos sensibles/operativos:
- `NEXPLAY_AI_AGENT_TOKEN`
- `externalNumberId` real del número/phone_number_id de WhatsApp

## Configuración recomendada del piloto
### Opción rápida
Para arrancar sin depender del plan completo:
- dejar `plan.features.aiAgent` como esté
- forzar en el tenant:
  - `tenant.features.aiAgent = true`

### Binding recomendado
Crear un binding así:
```json
{
  "channel": "whatsapp",
  "externalNumberId": "<PHONE_NUMBER_ID_REAL>",
  "externalDisplayName": "Play N Trade WhatsApp Piloto",
  "storeId": "f5079133-c36e-460b-9977-a14057ab0368",
  "active": true
}
```

## Secuencia exacta de configuración
### 1. Activar AI Agent en tenant
Desde backoffice:
- ir a `/nexplay/dashboard/tenants/`
- seleccionar `Play N Trade`
- en `Módulo AI Agent`
  - escoger `Forzar activo`
- guardar

### 2. Crear binding de WhatsApp
En el mismo tenant:
- `externalNumberId`: valor real del número o `phone_number_id`
- `Nombre visible`: `Play N Trade WhatsApp Piloto`
- `Store por defecto`: `Town Center`
- `Activo`: sí
- guardar

### 3. Confirmar que resuelve
Request sugerido:
```bash
curl -X POST 'https://nexplay-api.servialpa.com/internal/ai-agent/resolve' \
  -H 'Content-Type: application/json' \
  -H 'x-ai-agent-token: <NEXPLAY_AI_AGENT_TOKEN>' \
  -d '{
    "channel": "whatsapp",
    "externalNumberId": "<PHONE_NUMBER_ID_REAL>"
  }'
```

Esperado:
- `resolved: true`
- `tenantCode: "PnT507"`
- `tenantName: "Play N Trade"`
- `aiAgentEnabled: true`
- `defaultStoreId: "f5079133-c36e-460b-9977-a14057ab0368"`

### 4. Confirmar access customer
```bash
curl -X POST 'https://nexplay-api.servialpa.com/internal/ai-agent/customers/access' \
  -H 'Content-Type: application/json' \
  -H 'x-ai-agent-token: <NEXPLAY_AI_AGENT_TOKEN>' \
  -d '{
    "tenantCode": "PnT507",
    "phone": "+50760000000"
  }'
```

### 5. Confirmar availability
```bash
curl -X POST 'https://nexplay-api.servialpa.com/internal/ai-agent/availability' \
  -H 'Content-Type: application/json' \
  -H 'x-ai-agent-token: <NEXPLAY_AI_AGENT_TOKEN>' \
  -d '{
    "tenantCode": "PnT507",
    "storeId": "f5079133-c36e-460b-9977-a14057ab0368",
    "date": "2026-04-20",
    "durationMinutes": "120",
    "intervalMinutes": "30"
  }'
```

### 6. Confirmar reservation
```bash
curl -X POST 'https://nexplay-api.servialpa.com/internal/ai-agent/reservations' \
  -H 'Content-Type: application/json' \
  -H 'x-ai-agent-token: <NEXPLAY_AI_AGENT_TOKEN>' \
  -d '{
    "tenantCode": "PnT507",
    "storeId": "f5079133-c36e-460b-9977-a14057ab0368",
    "positionId": "<POSITION_ID_VALIDO>",
    "reservationDate": "2026-04-20",
    "startTime": "19:00",
    "endTime": "21:00",
    "phone": "+50760000000",
    "fullName": "Cliente Prueba Piloto",
    "notes": "[ai_agent_whatsapp] piloto Play N Trade"
  }'
```

## Primera conversación sugerida del piloto
### Caso 1. Disponibilidad
Usuario:
- `¿Tienen disponibilidad hoy a las 7 pm?`

Esperado:
- resolve OK
- availability OK
- 2 o 3 opciones concretas

### Caso 2. Reserva
Usuario:
- `Reserva 2 horas`

Esperado:
- access/register customer
- revalidación
- reservation OK
- confirmación clara

## Regla de contención del piloto
Para la primera prueba:
- un solo tenant
- un solo número de WhatsApp
- un solo store por defecto
- horario controlado
- operador mirando backoffice en paralelo

## Resultado esperado
Si este piloto sale bien, ya queda validado:
- routing multi-tenant
- feature gating
- consulta real de disponibilidad
- creación real de reservas
- integración operativa OpenClaw -> Nexplay
