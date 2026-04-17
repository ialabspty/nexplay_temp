# Jardines Panamá — Plantilla de catálogo inicial

## Objetivo
Definir una plantilla inicial de catálogo para el tenant `jardines-panama` sobre RetailBridge, organizada por familias y preparada para cargar SKUs reales después.

## Estructura sugerida por producto
Cada SKU debería incluir al menos:

```yaml
- sku: JP-XXXX
  nombre: ""
  familia: "jardineria | conveniencia | ferreteria"
  categoria: ""
  descripcion_corta: ""
  unidad: "unidad | bolsa | libra | litro | paquete | caja"
  precio: 0.00
  moneda: "USD"
  disponible: true
  stock_visible: optional
  sustitucion_permitida: true|false|conditional
  perfil_manejo: "liviano | delicado | pesado | tecnico"
  entrega_habilitada: true
  retiro_habilitado: true
  notas_operativas: ""
```

---

## 1. Jardinería

### Categorías sugeridas
- plantas
- macetas
- sustratos-y-tierra
- fertilizantes
- herramientas-de-jardin
- accesorios-de-jardin

### Ejemplos base
```yaml
- sku: JP-JAR-001
  nombre: "Planta ornamental mediana"
  familia: "jardineria"
  categoria: "plantas"
  descripcion_corta: "Planta ornamental para interiores o terrazas"
  unidad: "unidad"
  precio: 0.00
  moneda: "USD"
  disponible: true
  stock_visible: optional
  sustitucion_permitida: conditional
  perfil_manejo: "delicado"
  entrega_habilitada: true
  retiro_habilitado: true
  notas_operativas: "Validar especie, tamaño y estado antes de confirmar."

- sku: JP-JAR-002
  nombre: "Maceta plástica mediana"
  familia: "jardineria"
  categoria: "macetas"
  descripcion_corta: "Maceta plástica para uso doméstico"
  unidad: "unidad"
  precio: 0.00
  moneda: "USD"
  disponible: true
  stock_visible: optional
  sustitucion_permitida: true
  perfil_manejo: "liviano"
  entrega_habilitada: true
  retiro_habilitado: true
  notas_operativas: "Confirmar color o diseño si aplica."

- sku: JP-JAR-003
  nombre: "Sustrato para jardín"
  familia: "jardineria"
  categoria: "sustratos-y-tierra"
  descripcion_corta: "Sustrato para plantas y jardinería general"
  unidad: "bolsa"
  precio: 0.00
  moneda: "USD"
  disponible: true
  stock_visible: optional
  sustitucion_permitida: conditional
  perfil_manejo: "pesado"
  entrega_habilitada: true
  retiro_habilitado: true
  notas_operativas: "Validar peso/volumen para entrega."
```

---

## 2. Conveniencia

### Categorías sugeridas
- bebidas
- snacks
- hielo
- basicos-del-hogar
- conveniencia

### Ejemplos base
```yaml
- sku: JP-CON-001
  nombre: "Botella de agua"
  familia: "conveniencia"
  categoria: "bebidas"
  descripcion_corta: "Agua embotellada para consumo inmediato"
  unidad: "unidad"
  precio: 0.00
  moneda: "USD"
  disponible: true
  stock_visible: optional
  sustitucion_permitida: true
  perfil_manejo: "liviano"
  entrega_habilitada: true
  retiro_habilitado: true
  notas_operativas: "Priorizar despacho rápido."

- sku: JP-CON-002
  nombre: "Snack salado"
  familia: "conveniencia"
  categoria: "snacks"
  descripcion_corta: "Snack empacado de consumo rápido"
  unidad: "unidad"
  precio: 0.00
  moneda: "USD"
  disponible: true
  stock_visible: optional
  sustitucion_permitida: true
  perfil_manejo: "liviano"
  entrega_habilitada: true
  retiro_habilitado: true
  notas_operativas: "Confirmar sabor o marca si aplica."

- sku: JP-CON-003
  nombre: "Bolsa de hielo"
  familia: "conveniencia"
  categoria: "hielo"
  descripcion_corta: "Bolsa de hielo para uso doméstico o comercial"
  unidad: "bolsa"
  precio: 0.00
  moneda: "USD"
  disponible: true
  stock_visible: optional
  sustitucion_permitida: false
  perfil_manejo: "liviano"
  entrega_habilitada: true
  retiro_habilitado: true
  notas_operativas: "Priorizar tiempos cortos de entrega."
```

---

## 3. Ferretería

### Categorías sugeridas
- herramientas-basicas
- tornilleria
- adhesivos
- pintura-y-accesorios
- electricidad-basica
- plomeria-basica
- reparacion-rapida
- ferreteria

### Ejemplos base
```yaml
- sku: JP-FER-001
  nombre: "Martillo básico"
  familia: "ferreteria"
  categoria: "herramientas-basicas"
  descripcion_corta: "Martillo para uso doméstico general"
  unidad: "unidad"
  precio: 0.00
  moneda: "USD"
  disponible: true
  stock_visible: optional
  sustitucion_permitida: false
  perfil_manejo: "liviano"
  entrega_habilitada: true
  retiro_habilitado: true
  notas_operativas: "Confirmar especificación si el cliente pide uso técnico."

- sku: JP-FER-002
  nombre: "Tornillos surtidos"
  familia: "ferreteria"
  categoria: "tornilleria"
  descripcion_corta: "Paquete de tornillos de uso general"
  unidad: "paquete"
  precio: 0.00
  moneda: "USD"
  disponible: true
  stock_visible: optional
  sustitucion_permitida: false
  perfil_manejo: "tecnico"
  entrega_habilitada: true
  retiro_habilitado: true
  notas_operativas: "Pedir medida/tipo cuando aplique."

- sku: JP-FER-003
  nombre: "Adhesivo multipropósito"
  familia: "ferreteria"
  categoria: "adhesivos"
  descripcion_corta: "Adhesivo para reparaciones básicas"
  unidad: "unidad"
  precio: 0.00
  moneda: "USD"
  disponible: true
  stock_visible: optional
  sustitucion_permitida: false
  perfil_manejo: "tecnico"
  entrega_habilitada: true
  retiro_habilitado: true
  notas_operativas: "Confirmar uso o superficie si el cliente duda."
```

---

## Reglas de carga recomendadas
- No cargar precios inventados; usar `0.00` hasta tener dato real.
- No activar SKUs sin categoría y familia definidas.
- Marcar como `tecnico` todo producto que requiera especificación para evitar errores.
- Marcar como `pesado` o `delicado` los productos que afecten promesa de entrega.
- En conveniencia, priorizar SKUs de respuesta rápida y alta rotación.

## Siguientes pasos sugeridos
1. Completar SKUs reales por familia.
2. Asignar precios reales y disponibilidad.
3. Definir reglas de sustitución por categoría.
4. Identificar productos restringidos o de manejo especial.
5. Preparar importación al sistema que consuma el catálogo de RetailBridge.
