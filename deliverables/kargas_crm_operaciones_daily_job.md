# Job diario — CRM → operaciones KargasPTY

## Objetivo
Revisar diariamente el CRM de Panacarga para detectar mercancías recibidas por KargasPTY, actualizar `trackings`, crear o completar `operaciones` y enviar un resumen ejecutivo.

## Hora
- Todos los días a las 8:00 PM

## Instrucción operativa del job
1. iniciar sesión en el CRM de Panacarga
2. revisar los trackings relevantes del día
3. identificar cuáles están en **status 8**
4. interpretar `status 8` como:
   - **Recibido por KargasPTY**
   - **Facturado a nosotros**
5. para cada tracking en status 8:
   - actualizar o crear registro en `trackings`
   - crear o actualizar registro en `operaciones`
6. evitar duplicados usando el tracking como clave principal
7. si la operación ya existe:
   - no crear otra
   - solo completar datos faltantes
8. registrar en `operaciones` al menos:
   - `tracking`
   - `modo`
   - `fuente_creacion = crm_diario`
   - `origen_confirmacion = crm`
   - `tracking_estado_crm = 8`
   - `titulo_estado_crm = Recibido por KargasPTY`
   - `estado_operacion = pendiente`
   - `operacion_unica_key = tracking`
   - `fecha_recepcion_kargas`
   - `fecha_operacion`
9. después de terminar, enviar un resumen ejecutivo

## Resumen que debe enviar
### Resumen diario CRM → operaciones
- Hora de ejecución
- Trackings revisados
- Nuevos trackings detectados en status 8
- Registros creados en `trackings`
- Operaciones nuevas creadas
- Duplicados evitados
- Errores o casos incompletos

Si hubo incidencias, incluir los trackings afectados.

## Reglas adicionales
- antes de status 8, el CRM sigue siendo la fuente principal
- desde status 8, la hoja interna pasa a ser la fuente principal
- no duplicar operaciones
- si falta información, marcar el caso como revisión pendiente o incidencia según corresponda

## Complemento
Este job no reemplaza el aviso interno de `tracking recibido`.
Lo complementa como:
- control diario
- reconciliación
- respaldo operativo
