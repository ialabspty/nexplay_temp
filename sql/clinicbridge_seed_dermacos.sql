SET NAMES utf8mb4;
SET time_zone = '+00:00';

INSERT INTO clinics (code, name, legal_name, status, metadata)
VALUES (
  'dermacos-panama',
  'DermaCos Panamá',
  'DermaCos Panamá',
  'active',
  JSON_OBJECT(
    'description', 'Clínica de Dermatología',
    'tone', 'professional'
  )
)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  legal_name = VALUES(legal_name),
  status = VALUES(status),
  metadata = VALUES(metadata);

INSERT INTO locations (clinic_id, code, name, address_line1, city, country_code, phone, status, metadata)
SELECT c.id,
       'consultorio-pacific-center',
       'Consultorio Pacific Center',
       'The Panama Clinic, Torre A, piso 10, Consultorio 1001, Calle Ramón H. Jurado',
       'Ciudad de Panamá',
       'PA',
       NULL,
       'active',
       JSON_OBJECT('full_address', 'The Panama Clinic, Torre A, piso 10, Consultorio 1001, Calle Ramón H. Jurado, Ciudad de Panamá')
FROM clinics c
WHERE c.code = 'dermacos-panama'
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  address_line1 = VALUES(address_line1),
  city = VALUES(city),
  country_code = VALUES(country_code),
  phone = VALUES(phone),
  status = VALUES(status),
  metadata = VALUES(metadata);

INSERT INTO specialties (code, name, status, metadata)
VALUES ('dermatology', 'Dermatología', 'active', JSON_OBJECT())
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  status = VALUES(status),
  metadata = VALUES(metadata);

INSERT INTO services (clinic_id, specialty_id, code, name, service_type, duration_minutes, is_active, metadata)
SELECT c.id, s.id, seed.code, seed.name, seed.service_type, seed.duration_minutes, 1, JSON_OBJECT()
FROM clinics c
JOIN specialties s ON s.code = 'dermatology'
JOIN (
  SELECT 'consulta-inicial' AS code, 'Consulta inicial' AS name, 'consultation' AS service_type, 60 AS duration_minutes
  UNION ALL SELECT 'consulta-seguimiento', 'Consulta de seguimiento', 'consultation', 60
  UNION ALL SELECT 'biopsia', 'Biopsia', 'procedure', NULL
  UNION ALL SELECT 'infiltraciones', 'Infiltraciones', 'procedure', NULL
  UNION ALL SELECT 'cirugia-dermatologica', 'Cirugía dermatológica', 'procedure', NULL
  UNION ALL SELECT 'cancer-de-piel', 'Atención de cáncer de piel', 'procedure', NULL
  UNION ALL SELECT 'tumores-benignos-y-quistes', 'Atención de tumores benignos y quistes', 'procedure', NULL
  UNION ALL SELECT 'mesoterapia', 'Mesoterapia', 'procedure', NULL
  UNION ALL SELECT 'extraccion-de-comedones', 'Extracción de comedones', 'procedure', NULL
  UNION ALL SELECT 'crioterapia', 'Crioterapia', 'procedure', NULL
  UNION ALL SELECT 'electrocirugia', 'Electrocirugía', 'procedure', NULL
  UNION ALL SELECT 'depilacion-laser', 'Depilación láser', 'procedure', NULL
  UNION ALL SELECT 'toxina-botulinica', 'Aplicación de toxina botulínica', 'procedure', NULL
) AS seed
WHERE c.code = 'dermacos-panama'
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  service_type = VALUES(service_type),
  duration_minutes = VALUES(duration_minutes),
  is_active = VALUES(is_active),
  metadata = VALUES(metadata);

INSERT INTO doctors (clinic_id, primary_location_id, full_name, license_number, status, metadata)
SELECT c.id, l.id, seed.full_name, NULL, 'active', seed.metadata
FROM clinics c
JOIN locations l ON l.clinic_id = c.id AND l.code = 'consultorio-pacific-center'
JOIN (
  SELECT 'Liseth Alejandra Jones Ulate' AS full_name,
         JSON_OBJECT(
           'specialty', 'Dermatología',
           'schedule', JSON_ARRAY(
             JSON_OBJECT('day', 'tuesday', 'from', '07:30', 'to', '19:00'),
             JSON_OBJECT('day', 'thursday', 'from', '07:30', 'to', '19:00')
           )
         ) AS metadata
  UNION ALL
  SELECT 'Juan Pablo Medina',
         JSON_OBJECT(
           'specialty', 'Dermatología',
           'schedule', JSON_ARRAY(
             JSON_OBJECT('day', 'wednesday', 'from', '09:00', 'to', '18:00'),
             JSON_OBJECT('day', 'thursday', 'from', '09:00', 'to', '18:00'),
             JSON_OBJECT('day', 'saturday', 'from', '09:00', 'to', '18:00')
           )
         )
) AS seed
WHERE c.code = 'dermacos-panama'
ON DUPLICATE KEY UPDATE
  primary_location_id = VALUES(primary_location_id),
  status = VALUES(status),
  metadata = VALUES(metadata);

INSERT INTO doctor_services (doctor_id, service_id, location_id, status, metadata)
SELECT d.id, sv.id, l.id, 'active', JSON_OBJECT()
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id AND c.code = 'dermacos-panama'
JOIN locations l ON l.id = d.primary_location_id
JOIN services sv ON sv.clinic_id = c.id
ON DUPLICATE KEY UPDATE
  status = VALUES(status),
  metadata = VALUES(metadata);

INSERT INTO doctor_platforms (doctor_id, clinic_id, location_id, service_id, module_type, platform_name, access_url, resolution_priority, status, metadata)
SELECT d.id,
       c.id,
       l.id,
       NULL,
       'appointments',
       seed.platform_name,
       seed.access_url,
       seed.resolution_priority,
       'active',
       seed.metadata
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id AND c.code = 'dermacos-panama'
JOIN locations l ON l.id = d.primary_location_id
JOIN (
  SELECT 'Juan Pablo Medina' AS doctor_name,
         'Clinic Web' AS platform_name,
         'https://app.cliniweb.com/es/perfil/juan-pablo-medina-velazquez' AS access_url,
         10 AS resolution_priority,
         JSON_OBJECT('module', 'appointments') AS metadata
  UNION ALL
  SELECT 'Liseth Alejandra Jones Ulate',
         'Huli Practice',
         'https://widgets.hulilabs.com/es/doctor/calendars?did=26818',
         10,
         JSON_OBJECT('module', 'appointments')
) AS seed ON seed.doctor_name = d.full_name
ON DUPLICATE KEY UPDATE
  platform_name = VALUES(platform_name),
  access_url = VALUES(access_url),
  resolution_priority = VALUES(resolution_priority),
  status = VALUES(status),
  metadata = VALUES(metadata);

INSERT INTO doctor_platforms (doctor_id, clinic_id, location_id, service_id, module_type, platform_name, access_url, resolution_priority, status, metadata)
SELECT NULL,
       c.id,
       l.id,
       NULL,
       'medical_records',
       'Huli Practice',
       NULL,
       100,
       'active',
       JSON_OBJECT('scope', 'clinic_default')
FROM clinics c
JOIN locations l ON l.clinic_id = c.id AND l.code = 'consultorio-pacific-center'
WHERE c.code = 'dermacos-panama';

INSERT INTO accepted_insurances (doctor_id, clinic_id, insurance_name, status, metadata)
SELECT d.id, c.id, seed.insurance_name, 'active', JSON_OBJECT()
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id AND c.code = 'dermacos-panama'
JOIN (
  SELECT 'Juan Pablo Medina' AS doctor_name, 'Mapfre' AS insurance_name
  UNION ALL SELECT 'Liseth Alejandra Jones Ulate', 'Mapfre'
  UNION ALL SELECT 'Liseth Alejandra Jones Ulate', 'Blue Cross and Blue Shield de Panamá'
) AS seed ON seed.doctor_name = d.full_name;

SHOW TABLES;
