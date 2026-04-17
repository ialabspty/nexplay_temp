# Jardines Panamá — Plan de ejecución y checklist

## Objetivo
Checklist ejecutable para llevar a Jardines Panamá desde definición conceptual hasta activación controlada sobre RetailBridge.

---

## Fase 1. Crear tenant
- [ ] crear `jardines-panama`
- [ ] asociarlo a `RetailBridge`
- [ ] registrar `publicName = Jardines Panamá`
- [ ] registrar branding base
- [ ] registrar identidad pública
- [ ] registrar tenantKey y aislamiento

## Resultado esperado
Jardines Panamá existe como tenant identificable y aislado dentro del sistema.

---

## Fase 2. Catálogo mínimo viable
- [ ] cargar primeros SKUs de jardinería
- [ ] cargar primeros SKUs de conveniencia
- [ ] cargar primeros SKUs de ferretería
- [ ] validar categoría y familia por SKU
- [ ] validar precios reales
- [ ] validar disponibilidad real

## Resultado esperado
Se puede responder consulta, cotización y pedido básico con catálogo real mínimo.

---

## Fase 3. Reglas operativas
- [ ] definir zonas de entrega
- [ ] definir tiempos estimados
- [ ] definir métodos de pago
- [ ] definir reglas de sustitución
- [ ] definir productos delicados
- [ ] definir productos pesados o volumétricos
- [ ] definir productos técnicos

## Resultado esperado
El tenant opera sin improvisar promesas de entrega, sustitución o compatibilidad.

---

## Fase 4. Routing
- [ ] registrar señales de Jardines Panamá
- [ ] enrutar públicamente como Jardines Panamá
- [ ] enrutar internamente a RetailBridge
- [ ] validar que no caiga en otro dominio
- [ ] validar aislamiento frente a otros tenants

## Resultado esperado
Los mensajes correctos se atienden como Jardines Panamá y se ejecutan en RetailBridge.

---

## Fase 5. Mensajería
- [ ] saludo inicial
- [ ] respuesta de catálogo
- [ ] respuesta de cotización
- [ ] toma de pedido
- [ ] confirmación de pedido
- [ ] pedido en camino
- [ ] pedido entregado
- [ ] seguimiento

## Resultado esperado
La experiencia de marca es consistente, clara y comercial.

---

## Fase 6. QA
- [ ] prueba de consulta de jardinería
- [ ] prueba de conveniencia
- [ ] prueba de ferretería
- [ ] prueba de pedido mixto
- [ ] prueba de entrega hoy
- [ ] prueba de seguimiento
- [ ] validar tono
- [ ] validar claridad
- [ ] validar límites
- [ ] validar no invención de inventario o tiempos

## Resultado esperado
El tenant pasa pruebas funcionales mínimas antes de salir a operación.

---

## Fase 7. Activación limitada
- [ ] activar con pocos SKUs
- [ ] activar con cobertura acotada
- [ ] monitorear conversaciones iniciales
- [ ] ajustar routing
- [ ] ajustar copy
- [ ] ajustar operación

## Resultado esperado
Salida controlada con riesgo operativo acotado.

---

## Fase 8. Expansión
- [ ] ampliar SKUs
- [ ] ampliar categorías
- [ ] ampliar cobertura
- [ ] reforzar automatización
- [ ] consolidar métricas del tenant

## Resultado esperado
Crecimiento ordenado del tenant sin romper la operación base.

---

## Criterio de listo para salir
- [ ] branding correcto
- [ ] routing correcto
- [ ] catálogo real mínimo cargado
- [ ] pagos definidos
- [ ] cobertura definida
- [ ] pruebas mínimas aprobadas

---

## Recomendación ejecutiva
No avanzar a la siguiente fase si la anterior no está clara. Empezar pequeño, validar rápido y escalar después.
