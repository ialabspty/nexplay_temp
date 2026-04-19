# 05. NEXPLAY, módulo de reportes y KPIs multi-tenant

## Fuente
- Prompt/contexto compartido por el usuario el 2026-04-19

## Contexto resumido
NEXPLAY ya cuenta con reservas funcionales, aplicación `play`, modelo de cliente, sistema multi-tenant y base de suscripción SaaS en implementación. Falta un módulo robusto de reportes y análisis de desempeño de espacios para que cada tenant entienda el rendimiento de su negocio sin duplicar lógica ni romper la estructura actual.

## Prompt

### CONTEXTO

NEXPLAY ya cuenta con:
- reservas funcionales
- aplicación "play"
- modelo de cliente
- sistema multi-tenant
- base de suscripción SaaS en implementación

Actualmente no existe un módulo robusto de reportes ni análisis de desempeño de los espacios.

Se requiere crear un sistema de métricas y reportes que permita a los tenants entender el rendimiento de su negocio.

IMPORTANTE:
- reutilizar datos existentes (reservas, espacios, clientes)
- no duplicar lógica
- mantener compatibilidad con la estructura actual

---

### OBJETIVO

Implementar un módulo de reportes y KPIs que permita:

- visualizar ingresos
- medir ocupación
- analizar rendimiento por espacio
- entender rentabilidad

---

### ALCANCE

#### 1. Dashboard general

Crear un dashboard principal que muestre:

- ingresos totales (por rango de fecha)
- número de reservas
- horas reservadas
- ocupación general

---

#### 2. KPIs clave

Calcular y mostrar:

- ocupación:
 (horas usadas / horas disponibles)

- ingreso total

- ingreso por hora

- número de clientes únicos

---

#### 3. Costo por espacio (NUEVO)

Permitir configurar por espacio:

- costo mensual estimado

Calcular automáticamente:

- costo por hora (basado en horas disponibles)

---

#### 4. Rentabilidad por espacio

Calcular:

- ingreso generado por espacio
- costo estimado
- rentabilidad (ingreso - costo)

---

#### 5. Desempeño por espacio

Mostrar:

- top espacios más utilizados
- espacios menos utilizados
- ocupación por espacio

---

#### 6. Visualización

- incluir gráficas:
 - ingresos por día
 - ocupación por día
 - uso por horario (heatmap básico)

---

#### 7. Filtros

Permitir filtrar por:

- fecha
- tienda
- tipo de espacio

---

#### 8. Multi-tenant

- cada tenant solo ve su información
- no mezclar datos entre tenants

---

### RESTRICCIONES

- no modificar estructura existente de reservas
- no duplicar datos innecesariamente
- mantener consultas eficientes
- no sobrecomplicar (versión inicial clara y funcional)

---

### CRITERIOS DE ACEPTACIÓN

- el tenant puede ver ingresos y ocupación fácilmente
- puede identificar qué espacios son rentables
- los datos son consistentes con las reservas reales
- la interfaz es clara y visual
- los filtros funcionan correctamente

---

### ENTREGABLES

- dashboard de reportes funcional
- cálculo de KPIs
- configuración de costo por espacio
- visualización gráfica básica
- análisis por espacio
