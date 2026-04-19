# Contexto general

## Estado actual
El proyecto se está manejando en modo operativo de desarrollo con despliegue sobre un entorno único llamado `production`, tratado internamente como un casi producción.

## Criterio operativo aprobado
- un solo ambiente operativo por ahora
- deploys y desarrollo como se han venido trabajando
- secrets administrados desde GitHub Actions Secrets
- evitar complejidad prematura en GitHub Environments hasta estabilizar el flujo

## Criterio de documentación
La documentación de roadmap debe servir para:
- conservar decisiones
- acumular prompts grandes
- dejar contexto reutilizable
- facilitar continuidad cuando se agreguen nuevos requerimientos

## Criterio de seguridad
No se almacenan contraseñas reales ni credenciales sensibles en el repo.
Se documenta:
- qué secret existe
- para qué sirve
- qué formato debe tener
- qué valores no sensibles ya están confirmados
