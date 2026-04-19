# NEXPLAY AI Agent, flujo operativo concreto para OpenClaw

## Objetivo
Conectar OpenClaw al backend de NEXPLAY para atender WhatsApp como módulo premium, respetando tenant, feature flag y fuente de verdad del backend.

## Requisitos mínimos
### Backend NEXPLAY
- deploy activo con módulo AI Agent
- `NEXPLAY_AI_AGENT_TOKEN` configurado
- tenant piloto con `aiAgent` activo
- binding de WhatsApp activo para ese tenant

### OpenClaw
- canal WhatsApp operativo
- acceso HTTP al backend NEXPLAY
- mismo secret usado en header `x-ai-agent-token`

## Secuencia operacional exacta
### Paso 1. Recibir webhook
Normalizar entrada a esta shape mínima:
```json
{
  "channel": "whatsapp",
  "externalNumberId": "<phone_number_id>",
  "from": "+5076...",
  "messageId": "wamid...",
  "text": "¿Tienen disponibilidad hoy a las 7?"
}
```

### Paso 2. Resolver tenant
Llamar inmediatamente:

`POST https://nexplay-api.servialpa.com/internal/ai-agent/resolve`

Headers:
```http
Content-Type: application/json
x-ai-agent-token: <NEXPLAY_AI_AGENT_TOKEN>
```

Body:
```json
{
  "channel": "whatsapp",
  "externalNumberId": "<phone_number_id>"
}
```

### Paso 3. Gate temprano
Si la respuesta es:
- `resolved = false`, terminar
- `aiAgentEnabled = false`, terminar

No abrir LLM ni hacer reasoning costoso si el tenant no está habilitado.

### Paso 4. Crear contexto corto de conversación
Guardar solo:
```json
{
  "tenantId": "...",
  "tenantCode": "pnt507",
  "tenantName": "Play N Trade",
  "defaultStoreId": "...",
  "customerPhone": "+5076...",
  "channel": "whatsapp"
}
```

### Paso 5. Clasificar intención
MVP, solo cuatro rutas:
- saludo/FAQ
- disponibilidad
- reserva
- fallback

## Rutas MVP
### A. FAQ básica
Usar contexto del tenant y, si hace falta, `GET /public/tenant/resolve?code=...`.

Responder solo sobre:
- horarios
- ubicación
- precios visibles/configurados
- cómo reservar

### B. Disponibilidad
Llamar:

`POST /internal/ai-agent/availability`

Body sugerido:
```json
{
  "tenantCode": "pnt507",
  "storeId": "<defaultStoreId>",
  "date": "2026-04-20",
  "durationMinutes": "120",
  "intervalMinutes": "30"
}
```

Si el usuario pidió tipo de espacio, incluir `positionType`.

Responder con 2 o 3 opciones máximas, claras y concretas.

### C. Reserva
#### 1. Identificar cliente
Primero:

`POST /internal/ai-agent/customers/access`

Body:
```json
{
  "tenantCode": "pnt507",
  "phone": "+5076..."
}
```

#### 2. Si no existe
Pedir solo datos faltantes mínimos.

Registro sugerido:
```json
{
  "tenantCode": "pnt507",
  "firstName": "Juan",
  "lastName": "Pérez",
  "phone": "+5076...",
  "birthDate": "1995-01-15"
}
```

#### 3. Revalidar disponibilidad
Antes de reservar, volver a consultar disponibilidad.

#### 4. Crear reserva
`POST /internal/ai-agent/reservations`

Body ejemplo:
```json
{
  "tenantCode": "pnt507",
  "storeId": "<store>",
  "positionId": "<position>",
  "reservationDate": "2026-04-20",
  "startTime": "19:00",
  "endTime": "21:00",
  "phone": "+5076...",
  "fullName": "Juan Pérez",
  "notes": "[ai_agent_whatsapp] Reserva creada desde agente"
}
```

#### 5. Confirmar
Responder con:
- fecha
- hora
- duración
- espacio
- tienda
- mensaje breve de confirmación

## Decisiones conversacionales obligatorias
### Nunca hacer
- inventar slots
- inventar precios
- decir “listo” antes de respuesta del backend
- mezclar tenant o store equivocado

### Siempre hacer
- resolver tenant primero
- validar feature flag
- usar backend como verdad
- si hay error, decirlo claro y ofrecer reintento

## Fallbacks recomendados
### Tenant no resuelto
No responder como si conociera el negocio. Escalar o salir silenciosamente según la política del canal.

### Feature apagado
No continuar con IA. Responder mensaje fijo o no responder, según política operativa.

### Error de backend
Respuesta sugerida:
"No pude confirmar eso en este momento. Si quieres, intento de nuevo o te doy otra opción disponible."

## Estado sugerido para TaskFlow
Usarlo solo si:
- el usuario deja datos incompletos
- hay que esperar confirmación
- hay que retomar luego
- hay handoff humano

No usarlo para una interacción simple de una sola consulta si no hace falta.

## Checklist técnico de primera prueba
1. resolver tenant con `externalNumberId` real
2. probar `customers/access`
3. probar `availability`
4. probar `reservations`
5. verificar que la reserva aparezca en backoffice
6. revisar que el tenant incorrecto no responda al mismo flujo
