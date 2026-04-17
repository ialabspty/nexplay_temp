# Ajustes planeados - Mereb / Panamerican

## Vigente desde
- effective_from: 2026-03-28

## Situaciones previstas y ajuste requerido

### 1. Modal o anuncio inicial
- El conector debe detectar overlays, anuncios, popups o modales iniciales.
- Debe intentar cerrarlos o descartarlos antes de extraer contenido académico.
- Si no logra cerrarlos, debe devolver error estructurado tipo `BLOCKING_MODAL_DETECTED` en lugar de responder con vista parcial como si fuera suficiente.

### 2. Selector de alumno en cuenta de acudiente
- El conector debe descubrir todos los alumnos visibles dentro de la cuenta del acudiente.
- Debe intentar hacer match con `studentExpectedName`.
- Si hay múltiples alumnos y no puede confirmar el correcto, debe devolver `MULTI_STUDENT_SELECTION_REQUIRED`.
- Aunque detecte varios alumnos, EduBridge solo puede responder sobre el alumno suscrito/autorizado.

### 3. Vista parcial después del login
- Si el login entra pero la vista no contiene módulos académicos esperados (materias, notas, tareas, avisos, etc.), el conector debe marcar `PARTIAL_VIEW_ONLY`.
- No debe interpretarse como ausencia real de datos académicos.
- La respuesta debe distinguir entre:
  - `no_data_detected_in_current_view`
  - `full_view_reached_no_data`

### 4. Sección académica no recorrida aún
- El conector debe intentar navegación interna a secciones candidatas:
  - notas/calificaciones
  - materias/cursos
  - agenda/tareas
  - avisos/comunicados
- Si la navegación no está implementada o falla, debe devolver `SECTION_NAVIGATION_INCOMPLETE`.

## Regla de implementación
- No responder como si un dato no existiera cuando solo se confirmó una vista parcial.
- Preferir estados explícitos de diagnóstico antes que falsos negativos.
