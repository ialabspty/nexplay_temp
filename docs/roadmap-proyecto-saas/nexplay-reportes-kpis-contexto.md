# NEXPLAY, contexto operativo para módulo de reportes y KPIs

## Propósito
Dar a cada tenant una vista clara y útil del desempeño de su negocio usando los datos existentes de NEXPLAY, sin duplicar modelos ni romper la estructura actual.

## Objetivo funcional
La primera versión debe permitir responder estas preguntas:
- cuánto ingresé en un período
- cuántas reservas tuve
- cuántas horas vendí
- qué ocupación logré
- qué espacios generan más ingreso
- qué espacios son menos rentables
- qué horarios se usan más

## Base de datos y dominios a reutilizar
Este módulo debe apoyarse en dominios ya existentes:
- reservas
- espacios/puestos
- tiendas
- tenants
- clientes

La lógica debe salir de la operación real ya registrada, no de tablas duplicadas de analítica salvo que en una fase posterior se justifique materialización o caché.

## Modelo mental recomendado para la V1
### Métricas globales por tenant
- ingreso total
- número de reservas
- horas reservadas
- ocupación general
- clientes únicos
- ingreso por hora

### Métricas por espacio
- ingreso por espacio
- horas reservadas por espacio
- ocupación por espacio
- costo mensual estimado por espacio
- costo por hora estimado
- rentabilidad por espacio

### Series y visualizaciones
- ingresos por día
- ocupación por día
- uso por horario en heatmap básico
- ranking de espacios más utilizados
- ranking de espacios menos utilizados

## Reglas operativas clave
- aislamiento total por tenant
- filtros mínimos en V1: fecha, tienda, tipo de espacio
- cálculos consistentes con reservas reales
- interfaz clara antes que sofisticación visual
- mantener consultas eficientes

## Cálculos base sugeridos
### Ocupación general
`horas usadas / horas disponibles`

### Ingreso por hora
`ingreso total / horas reservadas`

### Costo por hora estimado
`costo mensual estimado del espacio / horas disponibles del espacio en el período base`

### Rentabilidad por espacio
`ingreso generado por espacio - costo estimado del espacio`

## Consideraciones de implementación
- evitar duplicar lógica ya resuelta en reservas
- si los precios o importes están distribuidos entre reserva y sesión, tomar una fuente canónica y documentarla
- si un espacio no tiene costo configurado, mostrar estado claro en vez de inventar rentabilidad
- si el tenant no tiene volumen suficiente, igual mostrar KPIs base con mensajes simples

## Entregable esperado de V1
Un dashboard funcional para tenants con KPIs base, filtros, análisis por espacio y visualización simple, suficiente para operar y detectar rentabilidad sin entrar todavía en BI complejo.

## Siguiente uso recomendado
Este documento debe servir como base para:
- diseño técnico
- plan de implementación por backend/frontend
- definición de endpoints
- definición de consultas agregadas
- diseño de UI del dashboard de reportes
