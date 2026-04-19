# Roadmap de Proyecto SaaS

Este directorio queda como estructura canónica para documentar el contexto del proyecto, decisiones operativas, inventario de configuración y banco de prompts.

## Objetivo
Centralizar en GitHub la documentación viva del proyecto sin mezclarla con secretos sensibles en texto plano dentro del repo.

## Estructura
- `contexto-general.md`: contexto ejecutivo y criterios base del proyecto
- `github-secrets-inventory.md`: inventario de secrets y valores documentables
- `prompts/`: banco de prompts y entradas futuras

## Regla de trabajo
- los prompts grandes nuevos se almacenan dentro de `prompts/`
- cada prompt debe quedar con título, fecha de incorporación, fuente y contexto resumido
- no se deben guardar contraseñas o credenciales sensibles en texto plano dentro del repo
- sí se documentan nombres de secrets, propósito, formato esperado y valores no sensibles confirmados

## Convención recomendada
Para mantener esto ordenado, el nombre oficial de la estructura será:

**Roadmap de Proyecto SaaS**

Y su punto de entrada será este `README.md`.
