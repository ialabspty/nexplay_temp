SET NAMES utf8mb4;
SET time_zone = '+00:00';

INSERT INTO service_types (code, name, description, status, metadata)
VALUES
  ('orientacion-inicial', 'Orientación inicial', 'Orientación inicial sobre el trámite o servicio requerido', 'active', JSON_OBJECT()),
  ('revision-de-requisitos', 'Revisión de requisitos', 'Validación preliminar de requisitos y documentos necesarios', 'active', JSON_OBJECT()),
  ('gestion-documental', 'Gestión documental', 'Recepción, organización y seguimiento de documentos del caso', 'active', JSON_OBJECT()),
  ('seguimiento-de-caso', 'Seguimiento de caso', 'Seguimiento operativo del estado del caso o trámite', 'active', JSON_OBJECT()),
  ('citas-y-comparecencias', 'Citas y comparecencias', 'Coordinación de citas, comparecencias o pasos presenciales', 'active', JSON_OBJECT()),
  ('tramites-generales', 'Trámites generales', 'Gestión general de trámites dentro del alcance operativo', 'active', JSON_OBJECT())
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  description = VALUES(description),
  status = VALUES(status),
  metadata = VALUES(metadata);

SHOW TABLES;
