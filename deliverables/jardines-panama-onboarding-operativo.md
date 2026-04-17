# Jardines Panamá — Onboarding operativo del tenant

## Objetivo
Checklist operativo para activar el tenant `jardines-panama` sobre RetailBridge sin omitir branding, catálogo, operación, routing y validación.

---

## 1. Identidad y branding

### Definir
- [ ] nombre público: **Jardines Panamá**
- [ ] slug interno: `jardines-panama`
- [ ] motor base: `RetailBridge`
- [ ] descripción corta comercial
- [ ] tono de comunicación
- [ ] saludo inicial
- [ ] mensajes transaccionales base

### Validar
- [ ] la salida pública responde como **Jardines Panamá**
- [ ] no aparece HQ/internal al cliente
- [ ] no aparece RetailBridge al cliente

---

## 2. Configuración del tenant

### Crear ficha operativa
- [ ] tenantKey / slug configurado
- [ ] branding separado por tenant
- [ ] políticas separadas por tenant
- [ ] catálogo separado por tenant
- [ ] pedidos separados por tenant
- [ ] contexto de clientes separado por tenant

### Confirmar aislamiento
- [ ] no mezcla datos con otros tenants
- [ ] no mezcla catálogo con otras marcas
- [ ] no mezcla pedidos con otras operaciones

---

## 3. Catálogo inicial

### Familias mínimas
- [ ] jardinería
- [ ] conveniencia
- [ ] ferretería

### Por cada SKU real
- [ ] nombre
- [ ] familia
- [ ] categoría
- [ ] descripción corta
- [ ] unidad
- [ ] precio
- [ ] disponibilidad
- [ ] sustitución permitida o no
- [ ] perfil de manejo
- [ ] entrega habilitada
- [ ] retiro habilitado
- [ ] notas operativas

### Validaciones
- [ ] no dejar precios inventados activos
- [ ] no cargar SKUs ambiguos sin categoría
- [ ] identificar productos delicados
- [ ] identificar productos pesados/volumétricos
- [ ] identificar productos técnicos

---

## 4. Operación comercial

### Habilitar flujos
- [ ] consulta de producto
- [ ] cotización
- [ ] toma de pedido
- [ ] entrega
- [ ] retiro si aplica
- [ ] seguimiento

### Confirmar reglas
- [ ] carrito mixto permitido
- [ ] reglas de sustitución por familia
- [ ] reglas de confirmación de pedido
- [ ] reglas de promesa de entrega

---

## 5. Logística

### Definir cobertura
- [ ] zonas activas
- [ ] zonas restringidas
- [ ] same-day condicional
- [ ] entregas programadas

### Definir manejo por perfil
- [ ] liviano
- [ ] delicado
- [ ] pesado
- [ ] técnico

### Reglas críticas
- [ ] ferretería pesada o volumétrica requiere validación previa
- [ ] conveniencia prioriza velocidad
- [ ] jardinería delicada prioriza cuidado y disponibilidad real

---

## 6. Pagos

### Confirmar métodos habilitados
- [ ] transferencia
- [ ] yappy
- [ ] efectivo contra entrega
- [ ] otros si aplican

### Validar operación
- [ ] métodos visibles al cliente
- [ ] instrucciones consistentes
- [ ] no prometer método no habilitado

---

## 7. Routing

### Señales de entrada
- [ ] Jardines Panamá
- [ ] plantas
- [ ] macetas
- [ ] jardinería
- [ ] sustrato
- [ ] fertilizante
- [ ] snacks
- [ ] bebidas
- [ ] hielo
- [ ] conveniencia
- [ ] ferretería
- [ ] tornillos
- [ ] herramientas
- [ ] pintura
- [ ] plomería
- [ ] electricidad

### Validar routing
- [ ] si el mensaje coincide, responde como Jardines Panamá
- [ ] el backend enruta a RetailBridge
- [ ] no cae por error en otro dominio

---

## 8. Mensajería

### Preparar mensajes base
- [ ] saludo inicial
- [ ] respuesta de catálogo
- [ ] respuesta de cotización
- [ ] confirmación de pedido
- [ ] pedido en camino
- [ ] pedido entregado
- [ ] solicitud de datos de entrega

### Revisar estilo
- [ ] claro
- [ ] cercano
- [ ] confiable
- [ ] no robótico
- [ ] no interno

---

## 9. Pruebas mínimas antes de activar

### Caso 1: consulta simple
- [ ] "¿Tienen plantas?"

### Caso 2: conveniencia
- [ ] "Quiero agua, hielo y snacks"

### Caso 3: ferretería
- [ ] "Necesito tornillos y adhesivo"

### Caso 4: pedido mixto
- [ ] "Quiero una maceta, agua y cinta adhesiva"

### Caso 5: entrega
- [ ] "¿Me lo pueden llevar hoy?"

### Caso 6: seguimiento
- [ ] "¿Cómo va mi pedido?"

### Validar en cada caso
- [ ] tono correcto
- [ ] dominio correcto
- [ ] no inventa disponibilidad
- [ ] no inventa tiempos
- [ ] no responde como HQ

---

## 10. Go-live controlado

### Activación recomendada
- [ ] activar con catálogo inicial acotado
- [ ] probar con pocos SKUs primero
- [ ] validar tiempos reales de respuesta
- [ ] validar promesa de entrega
- [ ] monitorear errores de routing

### Después de activar
- [ ] revisar conversaciones iniciales
- [ ] ajustar señales de routing
- [ ] ajustar copy comercial
- [ ] ajustar reglas de sustitución
- [ ] ampliar catálogo por fases

---

## Criterio de listo
Se considera listo para activar cuando:
- [ ] responde públicamente como Jardines Panamá
- [ ] enruta internamente a RetailBridge
- [ ] tiene catálogo mínimo real cargado
- [ ] tiene cobertura definida
- [ ] tiene pagos definidos
- [ ] supera pruebas mínimas de consulta, cotización, pedido y seguimiento
