# NEXPLAY AI Agent, primeras pruebas HTTP sugeridas

## 1. Resolver tenant
```bash
curl -X POST 'https://nexplay-api.servialpa.com/internal/ai-agent/resolve' \
  -H 'Content-Type: application/json' \
  -H 'x-ai-agent-token: <NEXPLAY_AI_AGENT_TOKEN>' \
  -d '{
    "channel": "whatsapp",
    "externalNumberId": "<phone_number_id>"
  }'
```

## 2. Buscar cliente por teléfono
```bash
curl -X POST 'https://nexplay-api.servialpa.com/internal/ai-agent/customers/access' \
  -H 'Content-Type: application/json' \
  -H 'x-ai-agent-token: <NEXPLAY_AI_AGENT_TOKEN>' \
  -d '{
    "tenantCode": "pnt507",
    "phone": "+50760000000"
  }'
```

## 3. Consultar disponibilidad
```bash
curl -X POST 'https://nexplay-api.servialpa.com/internal/ai-agent/availability' \
  -H 'Content-Type: application/json' \
  -H 'x-ai-agent-token: <NEXPLAY_AI_AGENT_TOKEN>' \
  -d '{
    "tenantCode": "pnt507",
    "storeId": "<store_id>",
    "date": "2026-04-20",
    "durationMinutes": "120",
    "intervalMinutes": "30"
  }'
```

## 4. Crear reserva
```bash
curl -X POST 'https://nexplay-api.servialpa.com/internal/ai-agent/reservations' \
  -H 'Content-Type: application/json' \
  -H 'x-ai-agent-token: <NEXPLAY_AI_AGENT_TOKEN>' \
  -d '{
    "tenantCode": "pnt507",
    "storeId": "<store_id>",
    "positionId": "<position_id>",
    "reservationDate": "2026-04-20",
    "startTime": "19:00",
    "endTime": "21:00",
    "phone": "+50760000000",
    "fullName": "Cliente Prueba",
    "notes": "[ai_agent_whatsapp] prueba piloto"
  }'
```

## 5. Verificación final
- confirmar respuesta exitosa del backend
- revisar que la reserva exista en backoffice
- revisar que el tenant correcto reciba la operación
