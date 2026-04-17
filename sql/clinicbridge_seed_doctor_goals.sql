SET NAMES utf8mb4;
SET time_zone = '+00:00';

INSERT INTO doctor_goals (
  doctor_id,
  goal_code,
  goal_type,
  goal_name,
  target_value,
  current_value,
  unit,
  start_date,
  target_date,
  status,
  priority,
  strategy_notes,
  metadata
)
SELECT d.id,
       seed.goal_code,
       'occupancy_rate',
       seed.goal_name,
       seed.target_value,
       NULL,
       '%',
       CURRENT_DATE(),
       DATE_ADD(CURRENT_DATE(), INTERVAL 90 DAY),
       'active',
       'high',
       seed.strategy_notes,
       JSON_OBJECT('source', 'initial_goal_seed')
FROM doctors d
JOIN (
  SELECT 'Juan Pablo Medina' AS doctor_name,
         'goal-jpm-occupancy-100' AS goal_code,
         'Llevar ocupación de Juan Pablo Medina al 100%' AS goal_name,
         100.00 AS target_value,
         'Llenar huecos disponibles, reducir cancelaciones y aumentar conversiones a cita.' AS strategy_notes
  UNION ALL
  SELECT 'Liseth Alejandra Jones Ulate',
         'goal-laju-occupancy-90',
         'Llevar ocupación de Liseth Alejandra Jones Ulate al 90%',
         90.00,
         'Optimizar horarios disponibles, mejorar conversión y reforzar seguimiento.'
) AS seed ON seed.doctor_name = d.full_name
ON DUPLICATE KEY UPDATE
  goal_name = VALUES(goal_name),
  target_value = VALUES(target_value),
  unit = VALUES(unit),
  start_date = VALUES(start_date),
  target_date = VALUES(target_date),
  status = VALUES(status),
  priority = VALUES(priority),
  strategy_notes = VALUES(strategy_notes),
  metadata = VALUES(metadata);

SHOW TABLES;
