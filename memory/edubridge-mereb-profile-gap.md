# Gap operativo Mereb - perfil/materias

## Vigente desde
- effective_from: 2026-03-28

## Hallazgo
- Para Panamerican (`tenantId=panamerican`, `platform=mereb`), el contrato de Mereb sí define `getStudentProfile(input)` para leer perfil visible del alumno.
- Sin embargo, en la implementación actual del backend mínimo (`adapter-backend/src/adapters/mereb/MerebAdapter.ts`), `getStudentProfile` todavía responde `status: not_implemented`.
- Sí están operativas al menos `validateStudentAccess` y `getStudentTasks`.

## Implicación
- Se puede validar acceso y consultar tareas visibles.
- No se pueden confirmar todavía materias/grado/sección desde este flujo actual hasta implementar `getStudentProfile` real.
