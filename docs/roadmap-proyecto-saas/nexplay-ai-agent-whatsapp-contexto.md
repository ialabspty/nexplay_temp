# NEXPLAY, contexto operativo para AI Agent por WhatsApp

## Propósito
Agregar un agente de IA por WhatsApp como módulo premium opcional, sin duplicar lógica de reservas, manteniendo aislamiento multi-tenant y usando el backend de NEXPLAY como fuente de verdad.

## Decisión de arquitectura
### Fuente de verdad
- NEXPLAY define si el tenant existe
- NEXPLAY define si el módulo `aiAgent` está activo
- NEXPLAY define a qué tenant pertenece cada canal/número de WhatsApp
- OpenClaw orquesta la conversación y llama al backend

### Principio de ejecución
Siempre resolver tenant y entitlement antes de invocar IA costosa.

Flujo canónico:
`WhatsApp webhook -> OpenClaw intake -> Nexplay resolve/gate -> agente -> Nexplay availability/customers/reservations -> respuesta`

## Base técnica ya implementada en NEXPLAY
### Entitlements
Se incorporó soporte para:
- `Plan.features`
- `Tenant.features`
- resolución efectiva `tenant.features.aiAgent ?? plan.features.aiAgent ?? false`

### Routing de canal
Se incorporó `TenantChannelBinding` para mapear:
- tenant
- store por defecto opcional
- canal (`whatsapp`)
- `externalNumberId`
- nombre visible
- activo/inactivo

### Backoffice
Se incorporó base de configuración en:
- planes, para incluir `AI Agent`
- tenants, para heredar/forzar activo/forzar apagado
- bindings de WhatsApp por tenant

### Endpoints internos creados para OpenClaw
Header esperado:
- `x-ai-agent-token: <secret>`

Endpoints:
- `POST /internal/ai-agent/resolve`
- `POST /internal/ai-agent/customers/access`
- `POST /internal/ai-agent/customers/register`
- `POST /internal/ai-agent/availability`
- `POST /internal/ai-agent/reservations`

### Endpoints admin/JWT creados
- `GET /tenants/:tenantId/ai-agent`
- `GET /tenants/:tenantId/ai-agent/bindings`
- `POST /tenants/:tenantId/ai-agent/bindings`
- `PATCH /tenants/:tenantId/ai-agent/bindings/:bindingId`

## Contrato MVP OpenClaw -> NEXPLAY
### 1. Resolver tenant y gating
`POST /internal/ai-agent/resolve`

Request:
```json
{
  "channel": "whatsapp",
  "externalNumberId": "<phone_number_id_o_numero>"
}
```

Response esperada:
```json
{
  "resolved": true,
  "tenantId": "...",
  "tenantCode": "pnt507",
  "tenantName": "Play N Trade",
  "aiAgentEnabled": true,
  "defaultStoreId": "...",
  "effectiveFeatures": {
    "aiAgent": true
  },
  "binding": {
    "id": "...",
    "channel": "whatsapp",
    "externalNumberId": "...",
    "storeId": "...",
    "active": true
  }
}
```

Si `resolved=false` o `aiAgentEnabled=false`, OpenClaw debe cortar el flujo sin invocar LLM ni tareas costosas.

### 2. Identificar cliente
Primero intentar acceso:
`POST /internal/ai-agent/customers/access`

Request sugerido:
```json
{
  "tenantCode": "pnt507",
  "phone": "+5076..."
}
```

Si no existe, registrar:
`POST /internal/ai-agent/customers/register`

Request sugerido:
```json
{
  "tenantCode": "pnt507",
  "firstName": "Juan",
  "lastName": "Pérez",
  "phone": "+5076...",
  "birthDate": "1995-01-15"
}
```

## 3. Consultar disponibilidad real
`POST /internal/ai-agent/availability`

Request sugerido:
```json
{
  "tenantCode": "pnt507",
  "storeId": "...",
  "date": "2026-04-20",
  "positionType": "console_station",
  "durationMinutes": "120",
  "intervalMinutes": "30"
}
```

OpenClaw debe responder con opciones concretas, no inventadas.

## 4. Crear reserva
`POST /internal/ai-agent/reservations`

Request sugerido:
```json
{
  "tenantCode": "pnt507",
  "storeId": "...",
  "positionId": "...",
  "reservationDate": "2026-04-20",
  "startTime": "19:00",
  "endTime": "21:00",
  "phone": "+5076...",
  "fullName": "Juan Pérez",
  "notes": "[ai_agent_whatsapp] Reserva creada desde agente"
}
```

La validación de disponibilidad y solapes debe seguir ocurriendo en el backend existente.

## Flujo conversacional MVP recomendado
### Paso 1. Entrada
Usuario escribe por WhatsApp.

### Paso 2. Resolver tenant
OpenClaw llama a `resolve` con el número destino.

### Paso 3. Gate temprano
Si el tenant no tiene `aiAgent`, terminar rápido.

### Paso 4. Clasificar intención
Solo tres rutas MVP:
- FAQ básica
- consultar disponibilidad
- reservar

### Paso 5. Ejecutar contra backend
- FAQ: responder con datos del tenant ya resueltos
- disponibilidad: consultar endpoint real
- reserva: resolver/crear cliente y luego reservar

### Paso 6. Confirmar
Responder con datos concretos de fecha, hora, puesto y tienda.

## FAQ MVP permitidas
- horarios
- ubicación
- precios base o pricing disponible en backend
- disponibilidad

No inventar:
- promociones
- descuentos
- condiciones no configuradas
- horarios no confirmados

## Validaciones obligatorias
- jamás mezclar tenants
- jamás reservar sin revalidar disponibilidad
- jamás crear reserva fuera del backend
- si falta dato del cliente, pedirlo
- si falla el backend, responder error claro y no prometer confirmación

## Recomendación de implementación en OpenClaw
### Router/entrypoint
Crear un agente/entrypoint específico para Nexplay WhatsApp que haga primero:
1. leer payload del webhook
2. extraer `externalNumberId`, `from`, texto
3. llamar a `resolve`
4. si está apagado, terminar
5. si está activo, continuar con el agente

### Estado mínimo por conversación
```json
{
  "tenantId": "...",
  "tenantCode": "pnt507",
  "storeId": "...",
  "customerPhone": "+5076...",
  "channel": "whatsapp",
  "featureEnabled": true
}
```

### Uso de TaskFlow
Usarlo solo si la conversación necesita continuidad real:
- follow-up
- espera de datos faltantes
- reintento posterior
- handoff humano

Para FAQ simple o consulta/reserva rápida, puede operar sin TaskFlow pesado.

## Estado actual sugerido
Con la base ya implementada en NEXPLAY, la siguiente fase natural es:
1. configurar `NEXPLAY_AI_AGENT_TOKEN`
2. desplegar backend/frontend
3. montar intake WhatsApp en OpenClaw
4. conectar el agente a estos endpoints internos
5. probar end-to-end con un tenant piloto
