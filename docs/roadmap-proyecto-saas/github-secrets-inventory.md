# GitHub Secrets, inventario documentado

> Nota operativa: este archivo sí vive en GitHub como documentación, pero **no** debe incluir contraseñas reales ni credenciales sensibles en texto plano. Para esos casos, el valor queda almacenado únicamente en GitHub Secrets.

## Secrets base del proyecto

| Secret | Valor documentable | Uso | Estado |
|---|---|---|---|
| `NEXT_PUBLIC_API_BASE_URL` | `https://nexplay-api.servialpa.com` | URL pública base del backend para frontend | Confirmado |
| `DATABASE_URL` | `mysql://USUARIO:CLAVE@HOST:PUERTO/NOMBRE_DB` | Conexión a base de datos del backend | Documentar formato, no el valor real |
| `FTP_SERVER` | Host FTP del hosting correcto de `servialpa.com` | Destino de despliegue frontend por FTP | Documentar host real fuera del repo si es sensible |
| `FTP_USERNAME` | Usuario FTP cuyo root real cae en `public_html` | Autenticación FTP | No guardar en repo |
| `FTP_PASSWORD` | `***` | Autenticación FTP | No guardar en repo |
| `FTP_PORT` | `21` | Puerto FTP | Base recomendada |
| `REMOTE_DIR` | `/` | Root correcto del chroot FTP | Confirmado |
| `DROPLET_HOST` | IP o dominio del droplet | Destino deploy backend | No guardar en repo si se quiere reserva operacional |
| `DROPLET_USER` | Usuario SSH/SCP del droplet | Autenticación backend deploy | No guardar en repo |
| `DROPLET_PASSWORD` | `***` | Autenticación backend deploy | No guardar en repo |
| `DROPLET_PORT` | `22` | Puerto SSH/SCP | Base recomendada |

## Valores confirmados por memoria operativa
- `NEXT_PUBLIC_API_BASE_URL=https://nexplay-api.servialpa.com`
- `REMOTE_DIR=/`

## Criterio de almacenamiento
- valores sensibles reales, solo en GitHub Secrets
- valores públicos o no sensibles, sí pueden quedar documentados aquí
- este archivo funciona como inventario y guía de carga, no como vault
