# NEXPLAY, contexto operativo para memberships y beneficios

## Propósito
Agregar un módulo de memberships para que cada tenant pueda vender o activar planes con beneficios reutilizables dentro del flujo actual de reservas y de la experiencia pública `play`.

## Objetivo funcional
La primera versión debe permitir:
- definir planes de memberships por tenant
- activar o vender memberships a clientes
- mostrar memberships activas dentro de `play`
- aplicar automáticamente horas, descuentos o prioridad en reservas
- medir ingresos, uso de beneficios y valor económico aplicado

## Principios de implementación
- reutilizar el modelo de cliente existente
- no duplicar lógica de reservas ni pricing
- usar el backend como fuente de verdad
- mantener compatibilidad con la experiencia actual de `play`
- dejar el módulo listo para evolucionar a pagos o validaciones más completas

## Alcance recomendado de V1

### Planes
- paquetes de horas
- suscripciones mensuales
- planes de beneficios
- precio, vigencia, horas, descuento, prioridad y estado activo

### Cliente y activación
- compra/activación simple desde `play`
- asociación con cliente existente o creación básica del cliente si hace falta
- resumen de memberships activas dentro de la cuenta del cliente

### Aplicación en reservas
- consumo de horas incluidas
- descuento automático en reserva
- prioridad aplicada cuando corresponda
- continuidad normal del flujo cuando no exista membership activa

### Operación y reportes
- overview de planes y memberships
- transacciones recientes
- trazabilidad de beneficios aplicados
- horas consumidas y valor económico del beneficio

## Modelo mental recomendado
### Flujo general
1. el tenant define planes
2. el cliente activa o compra una membership
3. la membership queda asociada al cliente
4. al reservar, el backend resuelve beneficios activos
5. el sistema aplica horas, descuentos o prioridad
6. el uso queda registrado para operación y reportes

### Datos mínimos a conservar
- plan comprado
- cliente asociado
- fechas de inicio y vencimiento o corte
- horas incluidas y restantes
- descuento vigente
- prioridad activa
- monto pagado o activado
- trazabilidad por transacción y por uso de beneficio

## Consideraciones clave
- una membership mensual debe poder renovar o recalcular beneficios por período
- una membership no debe otorgar beneficios fuera de su tenant
- el consumo de beneficios debe ser auditable
- el precio final visible al cliente debe ser coherente con los beneficios aplicados

## Riesgos a vigilar
- duplicar descuento o consumo de horas en distintos puntos del flujo
- perder sincronía entre estado de membership y cálculo de reserva
- mezclar memberships activas de distintos tenants
- dejar activaciones sin trazabilidad económica o sin cliente vinculado

## Entregable esperado de V1
Un módulo operativo de memberships integrado con backoffice, `play`, clientes, reservas y reportes, suficiente para pruebas reales y extensión posterior.

## Siguiente uso recomendado
Este documento debe servir como base para:
- evolución del módulo de memberships
- definición de pagos reales futuros
- integración fina con pricing y reportes
- reglas comerciales por tenant
