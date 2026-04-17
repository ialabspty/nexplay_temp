# Jardines Panamá — Modelo de doble modo

## Objetivo
Definir la operación de Jardines Panamá sobre RetailBridge con dos contextos separados: atención pública comercial y operación interna del negocio.

---

## 1. Modo público comercial

### Clave sugerida
`jardines-panama-public`

### Rol
Atención pública de clientes.

### Objetivo
- consultas de productos
- cotizaciones
- pedidos
- entregas
- seguimiento

### Tipo de mensajes esperados
- "¿Tienen plantas?"
- "Quiero una maceta"
- "¿Cuánto cuesta?"
- "¿Me lo pueden llevar hoy?"
- "¿Cómo va mi pedido?"

### Tono
- comercial
- cercano
- claro
- confiable

---

## 2. Modo operativo interno

### Clave sugerida
`jardines-panama-ops`

### Rol
Canal operativo interno del negocio.

### Objetivo
- onboarding del negocio
- registro de ventas diarias
- registro de compras
- registro de gastos
- actualización de precios
- resúmenes
- alertas útiles

### Tipo de mensajes esperados
- "Venta 125"
- "Compra 40 en bebidas"
- "Gasto 18 en transporte"
- "Actualiza precio de maceta grande a 12"
- "Dame resumen de hoy"

### Tono
- práctico
- breve
- estructurado
- orientado a control operativo

---

## 3. Flujo para el grupo operativo

### Etapa 1. Onboarding
Orden sugerido:
1. nombre comercial
2. qué vende exactamente
3. familias del catálogo
4. productos iniciales
5. precios
6. horarios
7. zonas de entrega
8. métodos de pago
9. reglas especiales
10. contacto responsable

### Etapa 2. Operación diaria
Permitir captura de:
- ventas
- compras
- gastos
- precios
- resúmenes
- alertas

Ejemplos:
- "Venta de hoy 140"
- "Se vendieron 3 aguas y 2 plantas"
- "Compra 60 en snacks"
- "Gasto 12 en gasolina"
- "Actualiza precio de agua a 0.75"
- "Resumen semanal"

---

## 4. Reglas de clasificación

### Tratar como `jardines-panama-ops` si hay señales como:
- venta
- compra
- gasto
- precio
- resumen
- alerta
- balance
- hoy vendimos
- registra
- actualiza precio

### Tratar como `jardines-panama-public` si hay señales como:
- quiero comprar
- cuánto cuesta
- tienen
- me cotizas
- delivery
- pedido
- entrega
- seguimiento de pedido

---

## 5. Regla crítica
Si el canal corresponde al grupo operativo interno de Jardines Panamá, priorizar siempre `jardines-panama-ops`, aunque el mensaje sea corto o ambiguo.

Esto evita mezclar captura operativa con atención comercial.

---

## 6. Manejo de ambigüedad en el grupo operativo
Si el mensaje no está claro, responder breve y estructurado.

Ejemplos:
- "¿Quieres registrar una venta, compra, gasto o actualizar un precio?"
- "Indícame si esto es una venta del negocio o una consulta de producto."

---

## 7. Recomendación operativa
- grupo interno del negocio -> `jardines-panama-ops`
- canal público/comercial -> `jardines-panama-public`

No mezclar ambos contextos en un mismo canal si se busca operación clara y trazable.
