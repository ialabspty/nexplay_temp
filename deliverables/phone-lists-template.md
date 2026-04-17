# Plantilla de listas de teléfonos

Usa esta plantilla para definir de forma canónica qué números tienen acceso interno, cuáles prueban el hub multiagente y cuáles quedan limitados por dominio.

## Reglas base
- `admin-internal`: números con acceso interno real.
- `test-public-multiagent`: números públicos de prueba que pueden escoger agente desde el menú.
- `test-public-domain-specific`: números públicos de prueba limitados a un dominio concreto.
- Todo número de prueba que no esté en `admin-internal` debe tratarse como **usuario público general**, sin permisos administrativos ni acceso a configuración, memoria o routing.

---

## admin-internal
Números con permisos internos reales.

```txt
admin-internal
- +507
- +507
- +507
```

---

## test-public-multiagent
Números que entran al hub de pruebas y pueden escoger entre los agentes habilitados del menú.

```txt
test-public-multiagent
- +507
- +507
- +507
- +507
- +507
```

Menú asociado:
- KargasPTY
- Servialpa
- EduBridge
- TeLoLLevo
- Tu negocio al día
- Jardines Panamá

---

## test-public-domain-specific
Números de prueba limitados a un dominio concreto.

```txt
test-public-domain-specific

KargasPTY
- +507
- +507

Servialpa
- +507
- +507

EduBridge
- +507
- +507

TeLoLLevo
- +507
- +507

Tu negocio al día
- +507
- +507

Jardines Panamá
- +507
- +507
```

---

## Recomendaciones de llenado
- No mezclar admins con testers.
- No duplicar números sin necesidad entre listas.
- Si un número va a probar varios agentes, ponerlo en `test-public-multiagent` en lugar de repetirlo en varios dominios.
- Si un número solo debe probar una marca concreta, ponerlo en `test-public-domain-specific` bajo ese dominio.
- Mantener una sola fuente canónica y luego aplicar esa lista a la configuración activa.

---

## Versión compacta para enviarme rellenada
Puedes devolvérmela así:

```txt
admin-internal
- +507...


test-public-multiagent
- +507...


test-public-domain-specific
KargasPTY
- +507...

Servialpa
- +507...

EduBridge
- +507...

TeLoLLevo
- +507...

Tu negocio al día
- +507...

Jardines Panamá
- +507...
```
