# NEXPLAY, contexto operativo para pricing dinámico y cortesías

## Propósito
Agregar un motor básico de pricing dinámico y manejo controlado de cortesías sobre la base actual de reservas, sin romper compatibilidad y dejando una ruta clara de evolución.

## Objetivo funcional
La primera versión debe permitir responder estas necesidades:
- mantener un precio base actual por espacio o tipo de espacio
- ajustar precio según reglas simples
- mostrar al usuario el precio calculado antes de confirmar en `play`
- permitir cortesías controladas y trazables
- reflejar cortesías e impacto económico dentro de reportes

## Principios de implementación
- reutilizar la lógica actual de reservas
- no duplicar el modelo base de pricing si ya existe una tarifa canónica
- mantener compatibilidad con pricing estático actual
- priorizar reglas simples en V1
- diseñar estructura extensible para futuras promociones, bundles o pricing más avanzado

## Alcance recomendado de V1
### Pricing base
- precio base por espacio o por tipo de espacio
- fallback limpio al precio estático actual cuando no existan reglas activas

### Reglas dinámicas
- recargo o descuento porcentual
- aplicación por franja horaria
- aplicación por día de semana
- aplicación por tipo de espacio
- reglas activas/inactivas por tenant

### Cortesías
- reserva con total 0
- motivo obligatorio de cortesía
- cliente opcionalmente asociado
- control por tenant sobre si las cortesías están habilitadas

### Reportes
- total de cortesías
- ingreso potencial perdido
- trazabilidad de reservas con cortesía

## Modelo mental recomendado
### Pricing evaluation order
1. identificar precio base
2. resolver reglas activas que aplican al contexto de la reserva
3. calcular precio ajustado
4. si la reserva es cortesía, registrar precio potencial y total final 0
5. devolver al flujo de reserva el precio visible antes de confirmar

### Datos mínimos a conservar
- precio base aplicado
- reglas aplicadas
- precio potencial calculado
- total final
- bandera de cortesía
- motivo de cortesía

## Consideraciones clave
- no romper reservas existentes ni requerir rehacer histórico anterior
- si no hay regla aplicable, usar precio base
- si varias reglas aplican en V1, definir combinación simple y documentada
- para cortesías, no borrar el valor económico potencial; debe seguir visible para reportes
- mantener aislamiento por tenant en reglas, activación y reportes

## Riesgos a vigilar
- mezclar pricing mostrado con pricing realmente persistido
- permitir cortesías sin trazabilidad ni motivo
- crear reglas ambiguas o conflictivas sin una prioridad definida
- introducir cálculos duplicados entre backoffice, API y `play`

## Entregable esperado de V1
Un sistema básico y funcional de pricing dinámico con cortesías, integrado al flujo de reservas y a reportes, suficiente para pruebas reales y evolución posterior.

## Siguiente uso recomendado
Este documento debe servir como base para:
- diseño técnico de pricing
- definición de estructura de reglas
- integración con reserva/backoffice/play
- extensión del módulo de reportes para cortesías e ingreso potencial perdido
