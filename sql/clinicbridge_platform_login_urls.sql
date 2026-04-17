SET NAMES utf8mb4;
SET time_zone = '+00:00';

UPDATE platform_registry
SET metadata = JSON_SET(
  COALESCE(metadata, JSON_OBJECT()),
  '$.login_url', 'https://professional.cliniweb.com/inicio_sesion.aspx?ReturnUrl=%2f'
)
WHERE platform_code = 'clinic-web';

UPDATE platform_registry
SET metadata = JSON_SET(
  COALESCE(metadata, JSON_OBJECT()),
  '$.login_url', 'https://app.hulipractice.com/es/login?next=https%3A%2F%2Fapp.hulipractice.com%2Fes'
)
WHERE platform_code = 'huli-practice';

UPDATE platform_access_profiles
SET metadata = JSON_SET(
  COALESCE(metadata, JSON_OBJECT()),
  '$.login_url', 'https://professional.cliniweb.com/inicio_sesion.aspx?ReturnUrl=%2f'
)
WHERE profile_code = 'juan-pablo-medina-clinicweb';

UPDATE platform_access_profiles
SET metadata = JSON_SET(
  COALESCE(metadata, JSON_OBJECT()),
  '$.login_url', 'https://app.hulipractice.com/es/login?next=https%3A%2F%2Fapp.hulipractice.com%2Fes'
)
WHERE profile_code = 'liseth-jones-huli';

SHOW TABLES;
