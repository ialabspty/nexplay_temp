# Listas canónicas de teléfonos — borrador inicial

Estado: borrador consolidado a partir de la lista enviada por el operador. Pendiente completar dominios vacíos si aplica.

## Reglas base
- `admin-internal`: acceso interno real.
- `test-public-multiagent`: usuarios públicos de prueba con acceso al menú multiagente.
- `test-public-domain-specific`: usuarios públicos de prueba limitados a un dominio concreto.
- Todo número fuera de `admin-internal` debe tratarse como usuario público general de prueba, sin permisos administrativos ni acceso a memoria, configuración o routing.

---

## admin-internal
- +50766147683

---

## test-public-multiagent
- +50769630676

---

## test-public-domain-specific

### KargasPTY
- +50769808579

### Servialpa
- +50767803722

### EduBridge
- +50766712321
- +50766792900

### TeLoLLevo
- (sin números definidos por ahora)

### Tu negocio al día
- (sin números definidos por ahora)

### Jardines Panamá
- +50765934149
- +50768554124
- +50763648111

---

## Observaciones
- Se normalizó `dmin-internal` a `admin-internal`.
- Se interpretó `* +50763648111` como un número válido adicional bajo Jardines Panamá.
- `+50769630676` se movió a `test-public-multiagent`, por lo que ya no queda duplicado entre Servialpa y EduBridge.
- TeLoLLevo y Tu negocio al día siguen sin números definidos por ahora.

## Siguientes pasos sugeridos
1. Confirmar si TeLoLLevo y Tu negocio al día tendrán números propios.
2. Aplicar esta lista a la configuración activa del router/orquestador.
