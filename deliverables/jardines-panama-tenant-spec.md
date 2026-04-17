# Jardines Panamá — Tenant Spec

## Resumen
Jardines Panamá se define como una **marca pública/tenant** montada sobre el core de **RetailBridge**, no como un motor aparte. Su operación debe mantenerse aislada por tenant a nivel de branding, catálogo, pedidos, clientes, políticas y routing.

## Identidad base
```yaml
tenant:
  slug: jardines-panama
  engine: RetailBridge
  mode: white-label
  publicName: "Jardines Panamá"
  internalLabel: "RetailBridge / Jardines Panamá"
```

## Posicionamiento
```yaml
brand:
  tone: "cercano, claro, confiable"
  shortDescription: "Productos de jardinería, ferretería, conveniencia y delivery"
  welcomeMessage: "Hola, te atiende Jardines Panamá. Puedo ayudarte con productos, cotizaciones, pedidos y entregas. Cuéntame qué necesitas."
```

## Catálogo
```yaml
catalog:
  enabled: true
  visibility: tenant-only
  families:
    jardineria:
      categories:
        - plantas
        - macetas
        - sustratos-y-tierra
        - fertilizantes
        - herramientas-de-jardin
        - accesorios-de-jardin

    conveniencia:
      categories:
        - bebidas
        - snacks
        - hielo
        - basicos-del-hogar
        - conveniencia

    ferreteria:
      categories:
        - herramientas-basicas
        - tornilleria
        - adhesivos
        - pintura-y-accesorios
        - electricidad-basica
        - plomeria-basica
        - reparacion-rapida
        - ferreteria
```

## Operación comercial
```yaml
operations:
  quoteFlow: enabled
  orderFlow: standard-retail
  deliveryFlow: enabled
  pickupFlow: optional
  mixedCart: true
```

## Reglas logísticas
```yaml
logistics:
  handlingProfiles:
    - liviano
    - delicado
    - pesado
    - tecnico
  substitutions:
    jardineria: conditional
    conveniencia: allowed-with-confirmation
    ferreteria: restricted
```

## Cobertura
```yaml
delivery:
  zones:
    - ciudad-de-panama
    - panama-oeste
  serviceModes:
    - scheduled
    - same-day-conditional
```

## Pagos
```yaml
payments:
  methods:
    - transferencia
    - yappy
    - efectivo-contra-entrega
```

## Políticas
```yaml
policies:
  cancellations: "según etapa del pedido"
  returns: "según tipo de producto y condición de entrega"
  substitutions: "según categoría y con confirmación cuando aplique"
```

## Mensajería
```yaml
messaging:
  orderConfirmed: "Tu pedido con Jardines Panamá fue confirmado."
  outForDelivery: "Tu pedido de Jardines Panamá va en camino."
  delivered: "Tu pedido de Jardines Panamá fue entregado."
```

## Routing
```yaml
routing:
  publicIdentity: "Jardines Panamá"
  internalEngine: "RetailBridge"
  tenantKey: "jardines-panama"
  detectionSignals:
    - jardines panama
    - plantas
    - macetas
    - jardineria
    - sustrato
    - fertilizante
    - snacks
    - bebidas
    - hielo
    - conveniencia
    - ferreteria
    - tornillos
    - herramientas
    - pintura
    - plomeria
    - electricidad
```

## Reglas de aislamiento
```yaml
isolation:
  separateCatalog: true
  separateOrders: true
  separateCustomerContext: true
  separateBranding: true
  separatePolicies: true
```

## Reglas operativas adicionales
- Validar condiciones especiales antes de prometer entrega en ferretería pesada o volumétrica.
- Priorizar velocidad en pedidos de conveniencia.
- Priorizar cuidado y disponibilidad real en jardinería delicada.
- Mantener respuesta pública como Jardines Panamá y routing interno hacia RetailBridge.

## Siguientes pasos sugeridos
1. Crear configuración real del tenant `jardines-panama` en el sistema que consuma tenants de RetailBridge.
2. Definir catálogo inicial por familia con SKUs reales.
3. Definir zonas, tiempos y recargos por entrega.
4. Redactar prompt/identidad pública final de Jardines Panamá.
5. Probar flujo de consulta, cotización, pedido y seguimiento.
