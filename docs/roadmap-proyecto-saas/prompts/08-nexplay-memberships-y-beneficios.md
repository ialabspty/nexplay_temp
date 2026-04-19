# 08. NEXPLAY, memberships y beneficios para clientes

## Fuente
- Prompt/contexto reconstruido y documentado a partir del requerimiento del usuario y de la implementación/promoción realizada el 2026-04-19

## Contexto resumido
NEXPLAY ya cuenta con reservas funcionales, aplicación `play`, modelo de cliente centralizado, pricing dinámico, reportes y arquitectura multi-tenant. El siguiente paso es incorporar memberships para que cada tenant pueda vender planes o paquetes con beneficios que se apliquen automáticamente al reservar.

## Prompt

### CONTEXTO

NEXPLAY ya cuenta con:
- sistema de reservas funcional
- aplicación pública `play`
- modelo de cliente centralizado
- pricing dinámico y cortesías
- reportes/KPIs
- arquitectura multi-tenant

Se requiere agregar un módulo de memberships y beneficios para clientes.

IMPORTANTE:
- debe funcionar por tenant
- no debe romper la lógica actual de reservas
- los beneficios deben aplicarse automáticamente usando el backend como fuente de verdad

---

### OBJETIVO

Implementar un módulo de memberships que permita a los tenants:

- crear planes o paquetes de beneficios
- venderlos o activarlos para clientes
- reflejar memberships activas en `play`
- aplicar horas incluidas, descuentos o prioridad durante la reserva
- medir uso y valor económico de los beneficios

---

### ALCANCE

#### 1. Planes de membership

Permitir crear planes con variantes como:

- paquete de horas
- suscripción mensual
- plan de beneficios

Cada plan puede definir:
- nombre
- descripción
- precio
- moneda
- vigencia
- horas incluidas
- horas ilimitadas
- descuento porcentual en reservas
- acceso prioritario
- estado activo/inactivo

---

#### 2. Gestión por tenant

- cada tenant administra sus propios planes
- no mezclar planes, clientes ni consumos entre tenants
- la administración debe vivir en backoffice

---

#### 3. Compra o activación desde `play`

En la experiencia pública debe existir una vista para:

- listar planes disponibles
- permitir compra/activación simple
- asociar la membership al cliente actual o crear/usar perfil existente
- mostrar memberships activas dentro de la cuenta del cliente

---

#### 4. Beneficios automáticos en reservas

Cuando un cliente con membership haga una reserva, el sistema debe poder aplicar automáticamente:

- consumo de horas incluidas
- descuento porcentual
- prioridad de atención o acceso

El flujo debe:
- validar membership activa
- descontar beneficios usados
- dejar trazabilidad del beneficio aplicado

---

#### 5. Estado y consumo

El sistema debe conservar al menos:

- fecha de inicio
- fecha de vencimiento o corte
- horas incluidas al momento de compra
- horas restantes
- descuento vigente
- prioridad activa o no
- estado de la membership

---

#### 6. Transacciones y trazabilidad

Registrar:

- compras/activaciones
- valor de la transacción
- estado
- referencia o nota si aplica
- uso de beneficios por reserva
- valor económico consumido o descuento otorgado

---

#### 7. Reportes y overview operativo

En backoffice debe existir una vista de overview que permita ver:

- cantidad de planes
- memberships activas
- clientes con memberships
- ingresos por memberships
- valor de beneficios aplicados
- horas consumidas
- transacciones recientes
- usos recientes de beneficios

---

#### 8. Compatibilidad con pricing y reservas

- no duplicar la lógica de cálculo de reserva
- integrar memberships con el pricing existente
- persistir el efecto económico real en snapshots o trazas equivalentes
- si no hay membership activa, la reserva debe seguir funcionando normal

---

#### 9. MVP comercial

Para la primera versión:

- se puede permitir compra/activación simple sin pasarela compleja
- dejar preparada la estructura para integrar pagos reales más adelante

---

### RESTRICCIONES

- no duplicar modelos de cliente o reservas
- no inventar datos fuera del backend
- no romper compatibilidad multi-tenant
- mantener V1 simple y operativa
- toda aplicación de beneficios debe quedar trazable

---

### CRITERIOS DE ACEPTACIÓN

- el backoffice puede crear y editar planes
- `play` puede listar planes disponibles
- el cliente puede activar/comprar una membership
- la cuenta del cliente muestra memberships activas
- los beneficios se aplican automáticamente al reservar
- el sistema registra consumo, descuentos y prioridad cuando corresponda
- el overview operativo muestra planes, memberships, transacciones y usos recientes
- funciona correctamente por tenant

---

### ENTREGABLES

- módulo de memberships por tenant
- gestión de planes en backoffice
- vista pública de memberships en `play`
- asociación de memberships a clientes
- aplicación automática de beneficios en reservas
- trazabilidad de transacciones y uso de beneficios
- overview operativo del módulo
