# NEXPLAY AI Agent WhatsApp, checklist de despliegue y piloto

## Objetivo
Desplegar la base del módulo AI Agent de NEXPLAY y validarlo con un tenant piloto sin romper operación existente.

## Estado previo esperado
Debe existir en el repo real `ialabspty/nexplay`:
- `Plan.features`
- `Tenant.features`
- `TenantChannelBinding`
- `AiAgentModule`
- backoffice base para plan/tenant/bindings
- migraciones manuales nuevas incluidas en `deploy-backend.yml`

## Variables/secretos requeridos
### Backend NEXPLAY
Agregar en entorno backend:
- `NEXPLAY_AI_AGENT_TOKEN=<secret-interno-fuerte>`

Nota:
- el backend ya acepta fallback a `NEXPLAY_PORTAL_TOKEN`, pero para producción sana conviene secreto separado.

### OpenClaw / agente
Configurar el mismo secreto para consumir:
- header `x-ai-agent-token: <NEXPLAY_AI_AGENT_TOKEN>`

## Checklist de despliegue
### 1. Validación local antes de push
- backend: `npx prisma generate && npm run build`
- frontend: `npm run build`
- revisar que `git status` solo tenga cambios esperados

### 2. Push a `production`
Esto debe disparar:
- deploy backend droplet
- deploy frontend GoDaddy

### 3. Verificar backend en vivo
Checks mínimos:
- `https://nexplay-api.servialpa.com/` -> 200
- `POST /internal/ai-agent/resolve` con token correcto -> responde JSON, no 404
- `GET /tenants/:tenantId/ai-agent` con JWT admin -> responde configuración

### 4. Verificar frontend en vivo
Checks mínimos:
- `/nexplay/dashboard/plans/`
- `/nexplay/dashboard/tenants/`
- edición de plan con AI Agent
- edición de tenant con herencia/override AI Agent
- creación/edición de bindings

## Checklist de configuración de piloto
### 1. Elegir tenant piloto
Criterios sugeridos:
- una sola tienda para simplificar
- horarios claros
- operador disponible para validar
- volumen bajo o controlado

### 2. Activar feature
Opción A, por plan:
- marcar `AI Agent` en el plan del tenant

Opción B, por tenant:
- en tenant, forzar `AI Agent = activo`

### 3. Crear binding de WhatsApp
Configurar en tenant:
- `channel = whatsapp`
- `externalNumberId = <phone_number_id o número configurado>`
- `storeId = <store por defecto>` si aplica
- `active = true`

### 4. Confirmar resolución
Probar:
`POST /internal/ai-agent/resolve`

Body ejemplo:
```json
{
  "channel": "whatsapp",
  "externalNumberId": "<id>"
}
```

Esperado:
- `resolved = true`
- `aiAgentEnabled = true`
- `tenantCode` correcto
- `defaultStoreId` correcto

## Checklist de integración OpenClaw
### 1. Intake del canal
El runtime debe extraer como mínimo:
- `externalNumberId`
- `from`
- `messageId`
- `text`

### 2. Gate temprano
Antes de usar LLM:
- llamar `resolve`
- si `resolved=false`, terminar
- si `aiAgentEnabled=false`, terminar

### 3. Flujo MVP del agente
Orden sugerido:
1. resolver tenant
2. identificar intención
3. consultar disponibilidad si aplica
4. resolver/crear cliente si aplica
5. crear reserva si el usuario confirma
6. responder confirmación final

### 4. Fuente de verdad
Nunca:
- inventar disponibilidad
- inventar precio
- crear reservas fuera del backend

Siempre:
- consultar Nexplay
- confirmar con respuesta del backend

## Casos de prueba del piloto
### Caso 1. Feature apagado
- tenant con `aiAgent=false`
- resolve debe devolver apagado
- OpenClaw no debe consumir IA ni continuar

### Caso 2. Consulta de disponibilidad
Mensaje:
- “¿Tienen disponibilidad hoy a las 7 pm?”

Esperado:
- resolve OK
- consulta real a availability
- respuesta con opciones concretas

### Caso 3. Reserva con cliente existente
Mensaje:
- “Reserva 2 horas hoy a las 7 pm”

Esperado:
- access customer por teléfono
- create reservation
- confirmación con fecha/hora/puesto/tienda

### Caso 4. Reserva con cliente nuevo
Mensaje:
- usuario no existe

Esperado:
- solicitar datos faltantes mínimos
- registrar cliente
- reservar
- confirmar

### Caso 5. Slot ya no disponible
Esperado:
- backend rechaza
- agente responde con error claro y opciones alternas

## Criterios de salida del piloto
Se considera listo para siguiente fase si:
- resuelve tenant correctamente
- respeta feature flag
- responde FAQs básicas útiles
- consulta disponibilidad real
- crea reservas válidas
- las reservas aparecen en backoffice
- no mezcla tenants
- no produce falsos positivos de confirmación

## Recomendación final
No arrancar con múltiples tenants a la vez.
Hacer primero:
- 1 tenant
- 1 número
- 1 store por defecto
- 3 a 5 conversaciones de prueba controladas

Cuando eso esté estable, expandir a:
- más tenants
- más stores
- follow-ups automáticos
- campañas/promos/recuperación
