-- Seed inicial DermaCos Panamá para ClinicBridge v2 monobase
-- Requiere esquema ya creado por clinicbridge_clean_rebuild.sql

USE ClinicBridge;

START TRANSACTION;

-- =========================
-- 1. TENANT Y BRANDING
-- =========================

INSERT INTO tenants (
  tenant_key,
  vertical,
  brand_name,
  legal_name,
  status,
  country_code,
  timezone,
  default_language,
  metadata
) VALUES (
  'dermacos-panama',
  'clinic',
  'DermaCos Panamá',
  'DermaCos Panamá',
  'active',
  'PA',
  'America/Panama',
  'es',
  JSON_OBJECT('description', 'Clínica de Dermatología')
);

INSERT INTO tenant_branding (
  tenant_id,
  public_name,
  legal_name,
  description,
  tone_profile,
  greeting_message,
  metadata
)
SELECT
  id,
  'DermaCos Panamá',
  'DermaCos Panamá',
  'Clínica de Dermatología',
  'profesional',
  'Bienvenido a Clínica DermaCos, ¿cómo podemos ayudarte?',
  JSON_OBJECT('vertical', 'dermatology')
FROM tenants
WHERE tenant_key = 'dermacos-panama';

INSERT INTO tenant_feature_flags (tenant_id, flag_key, flag_value)
SELECT id, 'use_hardcoded', 'true' FROM tenants WHERE tenant_key = 'dermacos-panama';

INSERT INTO tenant_feature_flags (tenant_id, flag_key, flag_value)
SELECT id, 'use_db', 'true' FROM tenants WHERE tenant_key = 'dermacos-panama';

INSERT INTO tenant_feature_flags (tenant_id, flag_key, flag_value)
SELECT id, 'use_cognitive', 'false' FROM tenants WHERE tenant_key = 'dermacos-panama';

INSERT INTO tenant_prompts (tenant_id, prompt_type, content, version, status, metadata)
SELECT
  id,
  'public_system',
  'Actúas como asistente administrativo de Clínica DermaCos Panamá. Puedes informar servicios disponibles, precio oficial de consulta, descuento de jubilados, seguros aceptados, horarios, ubicación y enlaces oficiales de agenda. No debes dar respuestas médicas, recomendaciones médicas, preparación previa, cuidados posteriores ni inventar precios no autorizados.',
  '2026.04.08',
  'active',
  JSON_OBJECT('source', 'seed')
FROM tenants
WHERE tenant_key = 'dermacos-panama';

-- =========================
-- 2. CLÍNICA Y SEDE
-- =========================

INSERT INTO clinics (
  tenant_id,
  code,
  name,
  legal_name,
  status,
  default_language,
  timezone,
  metadata
)
SELECT
  id,
  'dermacos-panama-main',
  'DermaCos Panamá',
  'DermaCos Panamá',
  'active',
  'es',
  'America/Panama',
  JSON_OBJECT('description', 'Clínica de Dermatología')
FROM tenants
WHERE tenant_key = 'dermacos-panama';

INSERT INTO locations (
  clinic_id,
  code,
  name,
  address_line1,
  city,
  country_code,
  phone,
  status,
  metadata
)
SELECT
  c.id,
  'pacific-center',
  'Consultorio Pacific Center',
  'The Panama Clinic, Torre A, piso 10, Consultorio 1001, Calle Ramón H. Jurado',
  'Ciudad de Panamá',
  'PA',
  NULL,
  'active',
  JSON_OBJECT('reference_name', 'Pacific Center')
FROM clinics c
JOIN tenants t ON t.id = c.tenant_id
WHERE t.tenant_key = 'dermacos-panama';

-- =========================
-- 3. ESPECIALIDAD Y SERVICIOS
-- =========================

INSERT INTO specialties (code, name, status, metadata)
VALUES ('dermatologia', 'Dermatología', 'active', JSON_OBJECT('seed', 'dermacos-panama'));

INSERT INTO services (clinic_id, specialty_id, code, name, service_type, duration_minutes, is_active, public_enabled, price_mode, listed_price, metadata)
SELECT c.id, s.id, 'consulta-inicial', 'Consulta inicial', 'consultation', 60, 1, 1, 'listed', 100.00,
JSON_OBJECT('discount_jubilados', 20, 'precio_jubilado', 80.00)
FROM clinics c, specialties s, tenants t
WHERE c.tenant_id = t.id AND t.tenant_key = 'dermacos-panama' AND s.code = 'dermatologia';

INSERT INTO services (clinic_id, specialty_id, code, name, service_type, duration_minutes, is_active, public_enabled, price_mode, listed_price, metadata)
SELECT c.id, s.id, 'consulta-seguimiento', 'Consulta de seguimiento', 'consultation', 60, 1, 1, 'hidden', NULL,
JSON_OBJECT()
FROM clinics c, specialties s, tenants t
WHERE c.tenant_id = t.id AND t.tenant_key = 'dermacos-panama' AND s.code = 'dermatologia';

INSERT INTO services (clinic_id, specialty_id, code, name, service_type, duration_minutes, is_active, public_enabled, price_mode, listed_price, metadata)
SELECT c.id, s.id, 'biopsia', 'Biopsia', 'procedure', NULL, 1, 1, 'hidden', NULL, JSON_OBJECT()
FROM clinics c, specialties s, tenants t
WHERE c.tenant_id = t.id AND t.tenant_key = 'dermacos-panama' AND s.code = 'dermatologia';

INSERT INTO services (clinic_id, specialty_id, code, name, service_type, duration_minutes, is_active, public_enabled, price_mode, listed_price, metadata)
SELECT c.id, s.id, 'infiltraciones', 'Infiltraciones', 'procedure', NULL, 1, 1, 'hidden', NULL, JSON_OBJECT()
FROM clinics c, specialties s, tenants t
WHERE c.tenant_id = t.id AND t.tenant_key = 'dermacos-panama' AND s.code = 'dermatologia';

INSERT INTO services (clinic_id, specialty_id, code, name, service_type, duration_minutes, is_active, public_enabled, price_mode, listed_price, metadata)
SELECT c.id, s.id, 'cirugia-dermatologica', 'Cirugía dermatológica', 'procedure', NULL, 1, 1, 'hidden', NULL, JSON_OBJECT()
FROM clinics c, specialties s, tenants t
WHERE c.tenant_id = t.id AND t.tenant_key = 'dermacos-panama' AND s.code = 'dermatologia';

INSERT INTO services (clinic_id, specialty_id, code, name, service_type, duration_minutes, is_active, public_enabled, price_mode, listed_price, metadata)
SELECT c.id, s.id, 'cancer-piel', 'Atención de cáncer de piel', 'treatment', NULL, 1, 1, 'hidden', NULL, JSON_OBJECT()
FROM clinics c, specialties s, tenants t
WHERE c.tenant_id = t.id AND t.tenant_key = 'dermacos-panama' AND s.code = 'dermatologia';

INSERT INTO services (clinic_id, specialty_id, code, name, service_type, duration_minutes, is_active, public_enabled, price_mode, listed_price, metadata)
SELECT c.id, s.id, 'tumores-quistes', 'Atención de tumores benignos y quistes', 'treatment', NULL, 1, 1, 'hidden', NULL, JSON_OBJECT()
FROM clinics c, specialties s, tenants t
WHERE c.tenant_id = t.id AND t.tenant_key = 'dermacos-panama' AND s.code = 'dermatologia';

INSERT INTO services (clinic_id, specialty_id, code, name, service_type, duration_minutes, is_active, public_enabled, price_mode, listed_price, metadata)
SELECT c.id, s.id, 'mesoterapia', 'Mesoterapia', 'procedure', NULL, 1, 1, 'hidden', NULL, JSON_OBJECT()
FROM clinics c, specialties s, tenants t
WHERE c.tenant_id = t.id AND t.tenant_key = 'dermacos-panama' AND s.code = 'dermatologia';

INSERT INTO services (clinic_id, specialty_id, code, name, service_type, duration_minutes, is_active, public_enabled, price_mode, listed_price, metadata)
SELECT c.id, s.id, 'extraccion-comedones', 'Extracción de comedones', 'procedure', NULL, 1, 1, 'hidden', NULL, JSON_OBJECT()
FROM clinics c, specialties s, tenants t
WHERE c.tenant_id = t.id AND t.tenant_key = 'dermacos-panama' AND s.code = 'dermatologia';

INSERT INTO services (clinic_id, specialty_id, code, name, service_type, duration_minutes, is_active, public_enabled, price_mode, listed_price, metadata)
SELECT c.id, s.id, 'crioterapia', 'Crioterapia', 'procedure', NULL, 1, 1, 'hidden', NULL, JSON_OBJECT()
FROM clinics c, specialties s, tenants t
WHERE c.tenant_id = t.id AND t.tenant_key = 'dermacos-panama' AND s.code = 'dermatologia';

INSERT INTO services (clinic_id, specialty_id, code, name, service_type, duration_minutes, is_active, public_enabled, price_mode, listed_price, metadata)
SELECT c.id, s.id, 'electrocirugia', 'Electrocirugía', 'procedure', NULL, 1, 1, 'hidden', NULL, JSON_OBJECT()
FROM clinics c, specialties s, tenants t
WHERE c.tenant_id = t.id AND t.tenant_key = 'dermacos-panama' AND s.code = 'dermatologia';

INSERT INTO services (clinic_id, specialty_id, code, name, service_type, duration_minutes, is_active, public_enabled, price_mode, listed_price, metadata)
SELECT c.id, s.id, 'depilacion-laser', 'Depilación láser', 'procedure', NULL, 1, 1, 'hidden', NULL, JSON_OBJECT()
FROM clinics c, specialties s, tenants t
WHERE c.tenant_id = t.id AND t.tenant_key = 'dermacos-panama' AND s.code = 'dermatologia';

INSERT INTO services (clinic_id, specialty_id, code, name, service_type, duration_minutes, is_active, public_enabled, price_mode, listed_price, metadata)
SELECT c.id, s.id, 'toxina-botulinica', 'Aplicación de toxina botulínica', 'procedure', NULL, 1, 1, 'hidden', NULL, JSON_OBJECT()
FROM clinics c, specialties s, tenants t
WHERE c.tenant_id = t.id AND t.tenant_key = 'dermacos-panama' AND s.code = 'dermatologia';

-- =========================
-- 4. MÉDICOS
-- =========================

INSERT INTO doctors (clinic_id, primary_location_id, full_name, specialty_id, status, accepts_new_patients, metadata)
SELECT c.id, l.id, 'Liseth Alejandra Jones Ulate', s.id, 'active', 1,
JSON_OBJECT(
  'booking_mode', 'external_link',
  'booking_url', 'https://widgets.hulilabs.com/es/doctor/calendars?did=26818'
)
FROM clinics c
JOIN locations l ON l.clinic_id = c.id
JOIN specialties s ON s.code = 'dermatologia'
JOIN tenants t ON t.id = c.tenant_id
WHERE t.tenant_key = 'dermacos-panama';

INSERT INTO doctors (clinic_id, primary_location_id, full_name, specialty_id, status, accepts_new_patients, metadata)
SELECT c.id, l.id, 'Juan Pablo Medina', s.id, 'active', 1,
JSON_OBJECT(
  'booking_mode', 'external_link',
  'booking_url', 'https://app.cliniweb.com/es/perfil/juan-pablo-medina-velazquez'
)
FROM clinics c
JOIN locations l ON l.clinic_id = c.id
JOIN specialties s ON s.code = 'dermatologia'
JOIN tenants t ON t.id = c.tenant_id
WHERE t.tenant_key = 'dermacos-panama';

-- asignar todos los servicios a ambos médicos
INSERT INTO doctor_services (doctor_id, service_id, location_id, status, metadata)
SELECT d.id, sv.id, d.primary_location_id, 'active', JSON_OBJECT()
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id
JOIN tenants t ON t.id = c.tenant_id
JOIN services sv ON sv.clinic_id = c.id
WHERE t.tenant_key = 'dermacos-panama';

-- =========================
-- 5. HORARIOS
-- =========================

INSERT INTO doctor_schedules (doctor_id, location_id, weekday, start_time, end_time, status, metadata)
SELECT d.id, d.primary_location_id, 2, '07:30:00', '19:00:00', 'active', JSON_OBJECT()
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id
JOIN tenants t ON t.id = c.tenant_id
WHERE t.tenant_key = 'dermacos-panama' AND d.full_name = 'Liseth Alejandra Jones Ulate';

INSERT INTO doctor_schedules (doctor_id, location_id, weekday, start_time, end_time, status, metadata)
SELECT d.id, d.primary_location_id, 4, '07:30:00', '19:00:00', 'active', JSON_OBJECT()
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id
JOIN tenants t ON t.id = c.tenant_id
WHERE t.tenant_key = 'dermacos-panama' AND d.full_name = 'Liseth Alejandra Jones Ulate';

INSERT INTO doctor_schedules (doctor_id, location_id, weekday, start_time, end_time, status, metadata)
SELECT d.id, d.primary_location_id, 3, '09:00:00', '18:00:00', 'active', JSON_OBJECT()
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id
JOIN tenants t ON t.id = c.tenant_id
WHERE t.tenant_key = 'dermacos-panama' AND d.full_name = 'Juan Pablo Medina';

INSERT INTO doctor_schedules (doctor_id, location_id, weekday, start_time, end_time, status, metadata)
SELECT d.id, d.primary_location_id, 4, '09:00:00', '18:00:00', 'active', JSON_OBJECT()
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id
JOIN tenants t ON t.id = c.tenant_id
WHERE t.tenant_key = 'dermacos-panama' AND d.full_name = 'Juan Pablo Medina';

INSERT INTO doctor_schedules (doctor_id, location_id, weekday, start_time, end_time, status, metadata)
SELECT d.id, d.primary_location_id, 6, '09:00:00', '18:00:00', 'active', JSON_OBJECT()
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id
JOIN tenants t ON t.id = c.tenant_id
WHERE t.tenant_key = 'dermacos-panama' AND d.full_name = 'Juan Pablo Medina';

-- =========================
-- 6. SEGUROS
-- =========================

INSERT INTO accepted_insurances (doctor_id, clinic_id, insurance_name, status, metadata)
SELECT d.id, c.id, 'Mapfre', 'active', JSON_OBJECT()
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id
JOIN tenants t ON t.id = c.tenant_id
WHERE t.tenant_key = 'dermacos-panama' AND d.full_name = 'Juan Pablo Medina';

INSERT INTO accepted_insurances (doctor_id, clinic_id, insurance_name, status, metadata)
SELECT d.id, c.id, 'Mapfre', 'active', JSON_OBJECT()
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id
JOIN tenants t ON t.id = c.tenant_id
WHERE t.tenant_key = 'dermacos-panama' AND d.full_name = 'Liseth Alejandra Jones Ulate';

INSERT INTO accepted_insurances (doctor_id, clinic_id, insurance_name, status, metadata)
SELECT d.id, c.id, 'Blue Cross and Blue Shield de Panamá', 'active', JSON_OBJECT()
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id
JOIN tenants t ON t.id = c.tenant_id
WHERE t.tenant_key = 'dermacos-panama' AND d.full_name = 'Liseth Alejandra Jones Ulate';

-- =========================
-- 7. CANAL WHATSAPP
-- =========================

INSERT INTO tenant_channels (
  tenant_id,
  clinic_id,
  channel_type,
  provider,
  purpose,
  business_account_id,
  phone_number_id,
  display_phone_number,
  display_name,
  status,
  metadata
)
SELECT
  t.id,
  c.id,
  'whatsapp',
  'meta-cloud-api',
  'public',
  NULL,
  '1025330757337645',
  '50760100089',
  'DermaCos',
  'active',
  JSON_OBJECT('notes', 'Canal productivo DermaCos Panamá')
FROM tenants t
JOIN clinics c ON c.tenant_id = t.id
WHERE t.tenant_key = 'dermacos-panama';

-- =========================
-- 8. COGNITIVE LAYER BASE
-- =========================

INSERT INTO tenant_cognitive_policies (
  tenant_id,
  clinic_id,
  policy_key,
  allowed_domains_json,
  blocked_topics_json,
  requires_db_grounding,
  allow_free_generation,
  fallback_mode,
  citation_mode,
  hallucination_guard_level,
  status,
  metadata
)
SELECT
  t.id,
  c.id,
  'dermacos-public-safe',
  JSON_ARRAY('services', 'price_official', 'discounts', 'insurance', 'schedules', 'location', 'booking_links', 'administrative_policies'),
  JSON_ARRAY('medical_advice', 'diagnosis', 'treatment_recommendation', 'pre_op_instructions', 'post_op_instructions', 'unauthorized_prices'),
  1,
  0,
  'hardcoded',
  'none',
  'high',
  'active',
  JSON_OBJECT('notes', 'Política pública segura DermaCos')
FROM tenants t
JOIN clinics c ON c.tenant_id = t.id
WHERE t.tenant_key = 'dermacos-panama';

-- =========================
-- 9. BASELINE Y GOALS INICIALES
-- =========================

INSERT INTO doctor_goals (
  doctor_id,
  goal_code,
  goal_type,
  goal_name,
  target_value,
  current_value,
  unit,
  status,
  priority,
  metadata
)
SELECT
  d.id,
  'occupancy_target',
  'occupancy',
  'Meta de ocupación',
  90.00,
  NULL,
  'percent',
  'active',
  'high',
  JSON_OBJECT('seed', 'initial')
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id
JOIN tenants t ON t.id = c.tenant_id
WHERE t.tenant_key = 'dermacos-panama' AND d.full_name = 'Liseth Alejandra Jones Ulate';

INSERT INTO doctor_goals (
  doctor_id,
  goal_code,
  goal_type,
  goal_name,
  target_value,
  current_value,
  unit,
  status,
  priority,
  metadata
)
SELECT
  d.id,
  'occupancy_target',
  'occupancy',
  'Meta de ocupación',
  100.00,
  NULL,
  'percent',
  'active',
  'high',
  JSON_OBJECT('seed', 'initial')
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id
JOIN tenants t ON t.id = c.tenant_id
WHERE t.tenant_key = 'dermacos-panama' AND d.full_name = 'Juan Pablo Medina';

COMMIT;
