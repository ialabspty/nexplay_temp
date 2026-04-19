# 06. NEXPLAY, pricing dinámico y cortesías

## Fuente
- Prompt/contexto compartido por el usuario el 2026-04-19

## Contexto resumido
NEXPLAY ya cuenta con sistema de reservas funcional, aplicación `play`, modelo de cliente, reportes/KPIs en implementación y arquitectura multi-tenant. Falta un sistema flexible de pricing y cortesías para optimizar ingresos sin romper la lógica actual de reservas ni la compatibilidad con precios existentes.

## Prompt

### CONTEXTO

NEXPLAY ya cuenta con:
- sistema de reservas funcional
- aplicación "play"
- modelo de cliente
- reportes y KPIs en implementación
- modelo multi-tenant

Actualmente el sistema maneja precios básicos o estáticos y no cuenta con herramientas avanzadas para optimizar ingresos.

Se requiere implementar un modelo flexible de precios y manejo de cortesías.

IMPORTANTE:
- no romper lógica actual de reservas
- mantener compatibilidad con precios existentes
- permitir evolución futura

---

### OBJETIVO

Implementar un sistema de pricing dinámico y cortesías que permita a los tenants:

- ajustar precios según condiciones
- ofrecer beneficios controlados
- optimizar ocupación e ingresos

---

### ALCANCE

#### 1. Pricing base

- mantener precio base por espacio o tipo de espacio

---

#### 2. Reglas de pricing

Permitir definir reglas como:

- precio por:
 - horario (ej: horas pico vs valle)
 - día de la semana
 - tipo de espacio

Ejemplo:
- 6pm–10pm → +20%
- lunes–jueves → -10%

---

#### 3. Aplicación de precios

- calcular precio automáticamente al momento de reservar
- mostrar precio actualizado en "play" antes de confirmar

---

#### 4. Cortesías (V1)

Permitir:

- crear reservas sin costo (0$)
- registrar motivo de cortesía
- asociar cortesía a cliente (opcional)

---

#### 5. Registro y control

- todas las cortesías deben quedar registradas
- incluir en reportes como:
 - ingreso potencial perdido

---

#### 6. Visualización

En reportes:

- total de cortesías
- impacto en ingresos

---

#### 7. Configuración por tenant

- cada tenant puede definir sus reglas de pricing
- activar o desactivar cortesías

---

### RESTRICCIONES

- no modificar estructura base de reservas
- no romper compatibilidad con precios actuales
- no crear lógica duplicada
- mantener implementación simple (reglas básicas)

---

### CRITERIOS DE ACEPTACIÓN

- el precio se calcula correctamente según reglas
- el usuario ve el precio antes de confirmar
- se pueden crear cortesías fácilmente
- las cortesías quedan registradas
- los reportes reflejan correctamente ingresos y cortesías

---

### ENTREGABLES

- sistema de pricing dinámico básico funcional
- reglas configurables por tenant
- manejo de cortesías
- integración con flujo de reservas
- integración con reportes
