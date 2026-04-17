# EduBridge — bootstrap operativo inicial

## Objetivo
Definir cómo el agente EduBridge debe usar su base `EduBridge` en operación real.

## Tablas principales
- contacts
- conversations
- messages
- guardians
- students
- guardian_students
- schools
- school_aliases
- platforms
- school_platforms
- subscriptions
- student_access_profiles
- crawler_sessions
- student_summaries
- settings
- file_assets
- file_links

## Flujos operativos principales

### 1. Onboarding inicial
Orden sugerido:
1. identificar o crear `contact` del acudiente
2. crear o localizar `guardian`
3. resolver colegio:
   - buscar en `school_aliases`
   - si hay match claro, usar `schools`
   - si no hay match, registrar necesidad de alta controlada
4. crear `student`
5. vincular `guardian_students`
6. crear `subscriptions` según estado comercial
7. crear `student_access_profiles` si ya hay credenciales

### 2. Resolución de colegio
Regla:
- usar alias + normalización + confirmación controlada

Tablas:
- `school_aliases`
- `schools`
- `school_platforms`

### 3. Validación de autorización
Antes de prestar servicio al alumno:
1. verificar relación `guardian_students`
2. verificar suscripción activa en `subscriptions`
3. si no está activo, bloquear servicio

### 4. Ejecución crawler
Cuando haya acceso disponible:
1. identificar `student_access_profiles`
2. resolver `school_platforms`
3. crear `crawler_sessions`
4. ejecutar navegación
5. guardar salida resumida en `student_summaries`
6. vincular artefactos con `file_assets` / `file_links` si aplica

### 5. Respuesta estándar
La respuesta final al acudiente debe salir desde datos normalizados.
Fuente típica:
- `student_summaries`
- `crawler_sessions`
- `subscriptions`

## Operaciones mínimas que el agente debe soportar
- crear acudiente
- crear alumno
- vincular acudiente↔alumno
- registrar/consultar suscripción
- resolver colegio por alias
- registrar acceso por alumno
- crear sesión crawler
- almacenar resumen por alumno

## Reglas operativas
- nunca responder sobre un alumno no suscrito
- no mezclar alumnos aunque una cuenta vea varios
- resolver alumno objetivo antes de responder
- no inventar colegio ni plataforma
- si el colegio no existe, escalar como incorporación pendiente

## Próxima fase sugerida
Crear scripts o consultas operativas para:
- alta de acudiente
- alta de alumno
- asociación acudiente/alumno
- check de suscripción activa
- creación de crawler session
- inserción de resumen
