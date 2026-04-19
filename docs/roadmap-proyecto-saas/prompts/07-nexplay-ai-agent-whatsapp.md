# 07. NEXPLAY, AI Agent por WhatsApp como módulo premium opcional

## Fuente
- Prompt/contexto compartido por el usuario el 2026-04-19

## Contexto resumido
NEXPLAY ya cuenta con reservas funcionales, aplicación `play`, modelo de cliente, pricing dinámico, reportes y arquitectura multi-tenant. El nuevo objetivo es incorporar un agente de IA conectado a WhatsApp que atienda clientes y genere reservas automáticamente, pero siempre como módulo opcional y cobrable por tenant.

## Prompt

### CONTEXTO

NEXPLAY ya cuenta con:
- sistema de reservas funcional
- aplicación "play"
- modelo de cliente
- pricing dinámico
- reportes
- arquitectura multi-tenant

Se requiere incorporar un agente de IA que atienda clientes vía WhatsApp y permita generar reservas automáticamente.

IMPORTANTE:
Este agente NO debe ser obligatorio.
Debe implementarse como un módulo adicional (feature premium) que puede activarse o desactivarse por tenant.

---

### OBJETIVO

Implementar un agente de IA conectado a WhatsApp que funcione como módulo opcional, permitiendo:

- responder consultas de clientes
- consultar disponibilidad en tiempo real
- crear reservas automáticamente

---

### ALCANCE

#### 1. Módulo opcional (CRÍTICO)

- implementar como feature flag a nivel tenant:

 tenant.features.aiAgent = true/false

- si está en false:
 - el agente NO debe operar
 - no se deben consumir recursos

- si está en true:
 - el agente se activa completamente

---

#### 2. Integración con WhatsApp

- integrar canal WhatsApp (usando OpenClaw o proveedor existente)
- recibir y enviar mensajes

---

#### 3. Capacidades del agente (MVP)

El agente debe poder:

- responder preguntas básicas:
 - horarios
 - precios
 - ubicación

- consultar disponibilidad:
 - por fecha
 - por hora
 - por espacio

- sugerir opciones disponibles

- crear reservas

---

#### 4. Integración con backend

El agente debe:

- consultar endpoints existentes:
 - disponibilidad
 - reservas
 - clientes

- crear reservas usando la lógica existente

---

#### 5. Flujo conversacional

Ejemplo:

Usuario:
"¿Tienen disponibilidad hoy a las 7pm?"

Agente:
- consulta disponibilidad
- responde con opciones

Usuario:
"Reserva 2 horas"

Agente:
- crea reserva
- confirma

---

#### 6. Identificación del cliente

- asociar número de WhatsApp a cliente existente
- crear cliente si no existe

---

#### 7. Validaciones

- evitar reservas duplicadas
- validar disponibilidad antes de confirmar
- manejar errores de forma clara

---

#### 8. Multi-tenant

- el agente debe operar en contexto del tenant correcto
- no mezclar datos entre tenants

---

#### 9. Control por plan (IMPORTANTE)

- el acceso al agente depende del plan o módulo contratado
- preparar la lógica para que pueda ser cobrado como add-on

---

#### 10. Escalabilidad futura

Preparar para:

- promociones automáticas
- recuperación de clientes
- venta de paquetes

---

### RESTRICCIONES

- no duplicar lógica de reservas
- no inventar datos
- usar siempre el backend como fuente de verdad
- no romper funcionalidad existente
- mantener implementación simple (MVP)

---

### CRITERIOS DE ACEPTACIÓN

- el agente solo funciona si el feature está activo
- el usuario puede interactuar vía WhatsApp
- el agente responde correctamente
- puede consultar disponibilidad real
- puede crear reservas válidas
- las reservas aparecen en el sistema
- funciona correctamente en multi-tenant

---

### ENTREGABLES

- módulo de IA configurable por tenant
- integración WhatsApp funcional
- agente IA básico operativo
- conexión con reservas y clientes
- control por feature flag
