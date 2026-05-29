-- ============================================================
-- DEMO SEED — Telefónica S.A
-- Ejecutar: psql $DATABASE_URL -f seed_demo_telefonica.sql
-- ============================================================

\set COMPANY 'cdcf66b4-f0f8-4f03-8032-3c8552361963'
\set ADMIN    '049c40c7-0fef-4e8f-9c52-c2864eda6e54'
\set PWHASH   '$2b$10$6xzsiUFFLDAtomQFDpO4yucFCodq/qyQWWaZjKCRRCdglx.hmFZei'

BEGIN;

-- ── 1. LIMPIAR DATOS DEMO ANTERIORES ────────────────────────
DELETE FROM challenge_participants
  WHERE challenge_id IN (SELECT id FROM challenges WHERE company_id = :'COMPANY');
DELETE FROM challenges   WHERE company_id = :'COMPANY';
DELETE FROM user_rewards WHERE user_id IN (SELECT id FROM users WHERE company_id = :'COMPANY');
DELETE FROM activities   WHERE user_id IN (SELECT id FROM users WHERE company_id = :'COMPANY');
DELETE FROM users
  WHERE company_id = :'COMPANY' AND role = 'employee';

-- ── 2. EMPLEADOS (14 personas realistas) ────────────────────
INSERT INTO users (id, company_id, name, email, password_hash, role, status, points_balance) VALUES
  ('e1000001-0de0-0000-0000-000000000001', :'COMPANY', 'Ana López',          'analopez@telefonica.es',    :'PWHASH', 'employee', 'active', 0),
  ('e1000001-0de0-0000-0000-000000000002', :'COMPANY', 'Carlos Ruiz',         'carlosruiz@telefonica.es',  :'PWHASH', 'employee', 'active', 0),
  ('e1000001-0de0-0000-0000-000000000003', :'COMPANY', 'María Fernández',     'mfernandez@telefonica.es',  :'PWHASH', 'employee', 'active', 0),
  ('e1000001-0de0-0000-0000-000000000004', :'COMPANY', 'David Martín',        'dmartin@telefonica.es',     :'PWHASH', 'employee', 'active', 0),
  ('e1000001-0de0-0000-0000-000000000005', :'COMPANY', 'Elena Rodríguez',     'erodriguez@telefonica.es',  :'PWHASH', 'employee', 'active', 0),
  ('e1000001-0de0-0000-0000-000000000006', :'COMPANY', 'Pablo Jiménez',       'pjimenez@telefonica.es',    :'PWHASH', 'employee', 'active', 0),
  ('e1000001-0de0-0000-0000-000000000007', :'COMPANY', 'Laura Sánchez',       'lsanchez@telefonica.es',    :'PWHASH', 'employee', 'active', 0),
  ('e1000001-0de0-0000-0000-000000000008', :'COMPANY', 'Javier González',     'jgonzalez@telefonica.es',   :'PWHASH', 'employee', 'active', 0),
  ('e1000001-0de0-0000-0000-000000000009', :'COMPANY', 'Isabel Navarro',      'inavarro@telefonica.es',    :'PWHASH', 'employee', 'active', 0),
  ('e1000001-0de0-0000-0000-000000000010', :'COMPANY', 'Miguel Ángel Díez',   'madiez@telefonica.es',      :'PWHASH', 'employee', 'active', 0),
  ('e1000001-0de0-0000-0000-000000000011', :'COMPANY', 'Sofía Herrero',       'sherrero@telefonica.es',    :'PWHASH', 'employee', 'active', 0),
  ('e1000001-0de0-0000-0000-000000000012', :'COMPANY', 'Andrés Molina',       'amolina@telefonica.es',     :'PWHASH', 'employee', 'active', 0),
  ('e1000001-0de0-0000-0000-000000000013', :'COMPANY', 'Carmen Flores',       'cflores@telefonica.es',     :'PWHASH', 'employee', 'active', 0),
  ('e1000001-0de0-0000-0000-000000000014', :'COMPANY', 'Roberto Ortega',      'rortega@telefonica.es',     :'PWHASH', 'employee', 'active', 0);

-- ── 3. ACTIVIDADES (últimos 75 días, mezcla realista) ────────
-- Ana López — corredora habitual, 3-4 actividades/mes
INSERT INTO activities (user_id, activity_type, distance_km, duration_seconds, calories_burned, co2_avoided_kg, points_earned, start_time, end_time, is_validated) VALUES
  ('e1000001-0de0-0000-0000-000000000001','run', 8.2, 2640, 492, 1.7220, 82, NOW()-INTERVAL'72 days', NOW()-INTERVAL'72 days'+INTERVAL'44 min', true),
  ('e1000001-0de0-0000-0000-000000000001','run', 10.5,3300, 630, 2.2050, 105,NOW()-INTERVAL'67 days', NOW()-INTERVAL'67 days'+INTERVAL'55 min', true),
  ('e1000001-0de0-0000-0000-000000000001','cycle',22.0,3960, 770, 3.3000, 220,NOW()-INTERVAL'61 days', NOW()-INTERVAL'61 days'+INTERVAL'66 min', true),
  ('e1000001-0de0-0000-0000-000000000001','run', 9.0, 2880, 540, 1.8900, 90, NOW()-INTERVAL'55 days', NOW()-INTERVAL'55 days'+INTERVAL'48 min', true),
  ('e1000001-0de0-0000-0000-000000000001','run', 12.3,3900, 738, 2.5830, 123,NOW()-INTERVAL'48 days', NOW()-INTERVAL'48 days'+INTERVAL'65 min', true),
  ('e1000001-0de0-0000-0000-000000000001','cycle',28.5,5100,998, 4.2750, 285,NOW()-INTERVAL'40 days', NOW()-INTERVAL'40 days'+INTERVAL'85 min', true),
  ('e1000001-0de0-0000-0000-000000000001','run', 8.8, 2700, 528, 1.8480, 88, NOW()-INTERVAL'32 days', NOW()-INTERVAL'32 days'+INTERVAL'45 min', true),
  ('e1000001-0de0-0000-0000-000000000001','run', 11.0,3420, 660, 2.3100, 110,NOW()-INTERVAL'22 days', NOW()-INTERVAL'22 days'+INTERVAL'57 min', true),
  ('e1000001-0de0-0000-0000-000000000001','cycle',25.0,4500, 875, 3.7500, 250,NOW()-INTERVAL'14 days', NOW()-INTERVAL'14 days'+INTERVAL'75 min', true),
  ('e1000001-0de0-0000-0000-000000000001','run', 13.5,4200, 810, 2.8350, 135,NOW()-INTERVAL'5 days',  NOW()-INTERVAL'5 days'+INTERVAL'70 min',  true);

-- Carlos Ruiz — ciclista, actividad regular
INSERT INTO activities (user_id, activity_type, distance_km, duration_seconds, calories_burned, co2_avoided_kg, points_earned, start_time, end_time, is_validated) VALUES
  ('e1000001-0de0-0000-0000-000000000002','cycle',35.0,6300,1225,5.2500,350,NOW()-INTERVAL'70 days',NOW()-INTERVAL'70 days'+INTERVAL'105 min',true),
  ('e1000001-0de0-0000-0000-000000000002','cycle',28.0,5040, 980,4.2000,280,NOW()-INTERVAL'62 days',NOW()-INTERVAL'62 days'+INTERVAL'84 min', true),
  ('e1000001-0de0-0000-0000-000000000002','run',  7.5, 2400, 450,1.5750, 75, NOW()-INTERVAL'54 days',NOW()-INTERVAL'54 days'+INTERVAL'40 min', true),
  ('e1000001-0de0-0000-0000-000000000002','cycle',40.0,7200,1400,6.0000,400,NOW()-INTERVAL'45 days',NOW()-INTERVAL'45 days'+INTERVAL'120 min',true),
  ('e1000001-0de0-0000-0000-000000000002','cycle',32.0,5760,1120,4.8000,320,NOW()-INTERVAL'36 days',NOW()-INTERVAL'36 days'+INTERVAL'96 min', true),
  ('e1000001-0de0-0000-0000-000000000002','cycle',22.0,3960, 770,3.3000,220,NOW()-INTERVAL'25 days',NOW()-INTERVAL'25 days'+INTERVAL'66 min', true),
  ('e1000001-0de0-0000-0000-000000000002','run',  9.0, 2880, 540,1.8900, 90, NOW()-INTERVAL'15 days',NOW()-INTERVAL'15 days'+INTERVAL'48 min', true),
  ('e1000001-0de0-0000-0000-000000000002','cycle',38.0,6840,1330,5.7000,380,NOW()-INTERVAL'6 days', NOW()-INTERVAL'6 days'+INTERVAL'114 min', true);

-- María Fernández — empezó hace 5 semanas, va cogiendo ritmo
INSERT INTO activities (user_id, activity_type, distance_km, duration_seconds, calories_burned, co2_avoided_kg, points_earned, start_time, end_time, is_validated) VALUES
  ('e1000001-0de0-0000-0000-000000000003','run', 4.0, 1560, 240,0.8400, 40, NOW()-INTERVAL'35 days',NOW()-INTERVAL'35 days'+INTERVAL'26 min', true),
  ('e1000001-0de0-0000-0000-000000000003','run', 5.2, 1980, 312,1.0920, 52, NOW()-INTERVAL'27 days',NOW()-INTERVAL'27 days'+INTERVAL'33 min', true),
  ('e1000001-0de0-0000-0000-000000000003','run', 6.0, 2280, 360,1.2600, 60, NOW()-INTERVAL'19 days',NOW()-INTERVAL'19 days'+INTERVAL'38 min', true),
  ('e1000001-0de0-0000-0000-000000000003','run', 6.5, 2460, 390,1.3650, 65, NOW()-INTERVAL'11 days',NOW()-INTERVAL'11 days'+INTERVAL'41 min', true),
  ('e1000001-0de0-0000-0000-000000000003','run', 7.2, 2700, 432,1.5120, 72, NOW()-INTERVAL'3 days', NOW()-INTERVAL'3 days'+INTERVAL'45 min',  true);

-- David Martín — triatleta, muy activo
INSERT INTO activities (user_id, activity_type, distance_km, duration_seconds, calories_burned, co2_avoided_kg, points_earned, start_time, end_time, is_validated) VALUES
  ('e1000001-0de0-0000-0000-000000000004','run',  15.0,4680, 900,3.1500,150,NOW()-INTERVAL'73 days',NOW()-INTERVAL'73 days'+INTERVAL'78 min', true),
  ('e1000001-0de0-0000-0000-000000000004','cycle',45.0,8100,1575,6.7500,450,NOW()-INTERVAL'68 days',NOW()-INTERVAL'68 days'+INTERVAL'135 min',true),
  ('e1000001-0de0-0000-0000-000000000004','run',  18.0,5640,1080,3.7800,180,NOW()-INTERVAL'60 days',NOW()-INTERVAL'60 days'+INTERVAL'94 min', true),
  ('e1000001-0de0-0000-0000-000000000004','cycle',50.0,9000,1750,7.5000,500,NOW()-INTERVAL'52 days',NOW()-INTERVAL'52 days'+INTERVAL'150 min',true),
  ('e1000001-0de0-0000-0000-000000000004','run',  21.0,6600,1260,4.4100,210,NOW()-INTERVAL'44 days',NOW()-INTERVAL'44 days'+INTERVAL'110 min',true),
  ('e1000001-0de0-0000-0000-000000000004','cycle',42.0,7560,1470,6.3000,420,NOW()-INTERVAL'36 days',NOW()-INTERVAL'36 days'+INTERVAL'126 min',true),
  ('e1000001-0de0-0000-0000-000000000004','run',  16.0,5040, 960,3.3600,160,NOW()-INTERVAL'27 days',NOW()-INTERVAL'27 days'+INTERVAL'84 min', true),
  ('e1000001-0de0-0000-0000-000000000004','cycle',38.0,6840,1330,5.7000,380,NOW()-INTERVAL'18 days',NOW()-INTERVAL'18 days'+INTERVAL'114 min',true),
  ('e1000001-0de0-0000-0000-000000000004','run',  20.0,6240,1200,4.2000,200,NOW()-INTERVAL'9 days', NOW()-INTERVAL'9 days'+INTERVAL'104 min', true),
  ('e1000001-0de0-0000-0000-000000000004','cycle',55.0,9900,1925,8.2500,550,NOW()-INTERVAL'2 days', NOW()-INTERVAL'2 days'+INTERVAL'165 min', true);

-- Elena Rodríguez — corredora de mañana, constante
INSERT INTO activities (user_id, activity_type, distance_km, duration_seconds, calories_burned, co2_avoided_kg, points_earned, start_time, end_time, is_validated) VALUES
  ('e1000001-0de0-0000-0000-000000000005','run', 7.0, 2520, 420,1.4700, 70, NOW()-INTERVAL'69 days',NOW()-INTERVAL'69 days'+INTERVAL'42 min', true),
  ('e1000001-0de0-0000-0000-000000000005','run', 8.5, 3060, 510,1.7850, 85, NOW()-INTERVAL'59 days',NOW()-INTERVAL'59 days'+INTERVAL'51 min', true),
  ('e1000001-0de0-0000-0000-000000000005','run', 10.0,3600, 600,2.1000,100,NOW()-INTERVAL'49 days',NOW()-INTERVAL'49 days'+INTERVAL'60 min', true),
  ('e1000001-0de0-0000-0000-000000000005','run', 9.5, 3420, 570,1.9950, 95, NOW()-INTERVAL'39 days',NOW()-INTERVAL'39 days'+INTERVAL'57 min', true),
  ('e1000001-0de0-0000-0000-000000000005','run', 11.0,3960, 660,2.3100,110,NOW()-INTERVAL'29 days',NOW()-INTERVAL'29 days'+INTERVAL'66 min', true),
  ('e1000001-0de0-0000-0000-000000000005','run', 8.0, 2880, 480,1.6800, 80, NOW()-INTERVAL'18 days',NOW()-INTERVAL'18 days'+INTERVAL'48 min', true),
  ('e1000001-0de0-0000-0000-000000000005','run', 12.0,4320, 720,2.5200,120,NOW()-INTERVAL'7 days', NOW()-INTERVAL'7 days'+INTERVAL'72 min',  true);

-- Pablo Jiménez — ciclista de fin de semana
INSERT INTO activities (user_id, activity_type, distance_km, duration_seconds, calories_burned, co2_avoided_kg, points_earned, start_time, end_time, is_validated) VALUES
  ('e1000001-0de0-0000-0000-000000000006','cycle',30.0,5400,1050,4.5000,300,NOW()-INTERVAL'65 days',NOW()-INTERVAL'65 days'+INTERVAL'90 min', true),
  ('e1000001-0de0-0000-0000-000000000006','cycle',25.0,4500, 875,3.7500,250,NOW()-INTERVAL'51 days',NOW()-INTERVAL'51 days'+INTERVAL'75 min', true),
  ('e1000001-0de0-0000-0000-000000000006','cycle',33.0,5940,1155,4.9500,330,NOW()-INTERVAL'37 days',NOW()-INTERVAL'37 days'+INTERVAL'99 min', true),
  ('e1000001-0de0-0000-0000-000000000006','cycle',28.0,5040, 980,4.2000,280,NOW()-INTERVAL'23 days',NOW()-INTERVAL'23 days'+INTERVAL'84 min', true),
  ('e1000001-0de0-0000-0000-000000000006','cycle',36.0,6480,1260,5.4000,360,NOW()-INTERVAL'9 days', NOW()-INTERVAL'9 days'+INTERVAL'108 min', true);

-- Laura Sánchez — acaba de empezar este mes
INSERT INTO activities (user_id, activity_type, distance_km, duration_seconds, calories_burned, co2_avoided_kg, points_earned, start_time, end_time, is_validated) VALUES
  ('e1000001-0de0-0000-0000-000000000007','run', 3.5, 1440, 210,0.7350, 35, NOW()-INTERVAL'20 days',NOW()-INTERVAL'20 days'+INTERVAL'24 min', true),
  ('e1000001-0de0-0000-0000-000000000007','run', 4.0, 1680, 240,0.8400, 40, NOW()-INTERVAL'13 days',NOW()-INTERVAL'13 days'+INTERVAL'28 min', true),
  ('e1000001-0de0-0000-0000-000000000007','run', 4.8, 1980, 288,1.0080, 48, NOW()-INTERVAL'6 days', NOW()-INTERVAL'6 days'+INTERVAL'33 min',  true);

-- Javier González — runner intermitente
INSERT INTO activities (user_id, activity_type, distance_km, duration_seconds, calories_burned, co2_avoided_kg, points_earned, start_time, end_time, is_validated) VALUES
  ('e1000001-0de0-0000-0000-000000000008','run', 10.0,3180, 600,2.1000,100,NOW()-INTERVAL'71 days',NOW()-INTERVAL'71 days'+INTERVAL'53 min', true),
  ('e1000001-0de0-0000-0000-000000000008','run', 12.0,3780, 720,2.5200,120,NOW()-INTERVAL'56 days',NOW()-INTERVAL'56 days'+INTERVAL'63 min', true),
  ('e1000001-0de0-0000-0000-000000000008','cycle',20.0,3600, 700,3.0000,200,NOW()-INTERVAL'41 days',NOW()-INTERVAL'41 days'+INTERVAL'60 min', true),
  ('e1000001-0de0-0000-0000-000000000008','run', 8.0, 2520, 480,1.6800, 80, NOW()-INTERVAL'28 days',NOW()-INTERVAL'28 days'+INTERVAL'42 min', true),
  ('e1000001-0de0-0000-0000-000000000008','run', 11.5,3600, 690,2.4150,115,NOW()-INTERVAL'12 days',NOW()-INTERVAL'12 days'+INTERVAL'60 min', true);

-- Isabel Navarro — nada y corre
INSERT INTO activities (user_id, activity_type, distance_km, duration_seconds, calories_burned, co2_avoided_kg, points_earned, start_time, end_time, is_validated) VALUES
  ('e1000001-0de0-0000-0000-000000000009','run', 6.0, 2160, 360,1.2600, 60, NOW()-INTERVAL'66 days',NOW()-INTERVAL'66 days'+INTERVAL'36 min', true),
  ('e1000001-0de0-0000-0000-000000000009','run', 7.5, 2700, 450,1.5750, 75, NOW()-INTERVAL'50 days',NOW()-INTERVAL'50 days'+INTERVAL'45 min', true),
  ('e1000001-0de0-0000-0000-000000000009','run', 8.0, 2880, 480,1.6800, 80, NOW()-INTERVAL'34 days',NOW()-INTERVAL'34 days'+INTERVAL'48 min', true),
  ('e1000001-0de0-0000-0000-000000000009','run', 9.0, 3240, 540,1.8900, 90, NOW()-INTERVAL'17 days',NOW()-INTERVAL'17 days'+INTERVAL'54 min', true),
  ('e1000001-0de0-0000-0000-000000000009','run', 10.0,3600, 600,2.1000,100,NOW()-INTERVAL'4 days', NOW()-INTERVAL'4 days'+INTERVAL'60 min',  true);

-- Miguel Ángel Díez — ciclista avanzado
INSERT INTO activities (user_id, activity_type, distance_km, duration_seconds, calories_burned, co2_avoided_kg, points_earned, start_time, end_time, is_validated) VALUES
  ('e1000001-0de0-0000-0000-000000000010','cycle',48.0,8640,1680,7.2000,480,NOW()-INTERVAL'74 days',NOW()-INTERVAL'74 days'+INTERVAL'144 min',true),
  ('e1000001-0de0-0000-0000-000000000010','cycle',42.0,7560,1470,6.3000,420,NOW()-INTERVAL'60 days',NOW()-INTERVAL'60 days'+INTERVAL'126 min',true),
  ('e1000001-0de0-0000-0000-000000000010','run',  14.0,4440, 840,2.9400,140,NOW()-INTERVAL'46 days',NOW()-INTERVAL'46 days'+INTERVAL'74 min', true),
  ('e1000001-0de0-0000-0000-000000000010','cycle',55.0,9900,1925,8.2500,550,NOW()-INTERVAL'32 days',NOW()-INTERVAL'32 days'+INTERVAL'165 min',true),
  ('e1000001-0de0-0000-0000-000000000010','cycle',38.0,6840,1330,5.7000,380,NOW()-INTERVAL'16 days',NOW()-INTERVAL'16 days'+INTERVAL'114 min',true),
  ('e1000001-0de0-0000-0000-000000000010','run',  10.0,3120, 600,2.1000,100,NOW()-INTERVAL'3 days', NOW()-INTERVAL'3 days'+INTERVAL'52 min',  true);

-- Sofía Herrero — empezó la semana pasada
INSERT INTO activities (user_id, activity_type, distance_km, duration_seconds, calories_burned, co2_avoided_kg, points_earned, start_time, end_time, is_validated) VALUES
  ('e1000001-0de0-0000-0000-000000000011','run', 3.0, 1260, 180,0.6300, 30, NOW()-INTERVAL'8 days', NOW()-INTERVAL'8 days'+INTERVAL'21 min',  true),
  ('e1000001-0de0-0000-0000-000000000011','run', 3.5, 1440, 210,0.7350, 35, NOW()-INTERVAL'3 days', NOW()-INTERVAL'3 days'+INTERVAL'24 min',  true);

-- Andrés Molina — runner con rachas
INSERT INTO activities (user_id, activity_type, distance_km, duration_seconds, calories_burned, co2_avoided_kg, points_earned, start_time, end_time, is_validated) VALUES
  ('e1000001-0de0-0000-0000-000000000012','run', 9.0, 2880, 540,1.8900, 90, NOW()-INTERVAL'68 days',NOW()-INTERVAL'68 days'+INTERVAL'48 min', true),
  ('e1000001-0de0-0000-0000-000000000012','run', 11.0,3480, 660,2.3100,110,NOW()-INTERVAL'57 days',NOW()-INTERVAL'57 days'+INTERVAL'58 min', true),
  ('e1000001-0de0-0000-0000-000000000012','cycle',18.0,3240, 630,2.7000,180,NOW()-INTERVAL'43 days',NOW()-INTERVAL'43 days'+INTERVAL'54 min', true),
  ('e1000001-0de0-0000-0000-000000000012','run', 13.0,4080, 780,2.7300,130,NOW()-INTERVAL'10 days',NOW()-INTERVAL'10 days'+INTERVAL'68 min', true);

-- Carmen Flores — ciclista ocasional
INSERT INTO activities (user_id, activity_type, distance_km, duration_seconds, calories_burned, co2_avoided_kg, points_earned, start_time, end_time, is_validated) VALUES
  ('e1000001-0de0-0000-0000-000000000013','cycle',20.0,3600, 700,3.0000,200,NOW()-INTERVAL'58 days',NOW()-INTERVAL'58 days'+INTERVAL'60 min', true),
  ('e1000001-0de0-0000-0000-000000000013','cycle',15.0,2700, 525,2.2500,150,NOW()-INTERVAL'30 days',NOW()-INTERVAL'30 days'+INTERVAL'45 min', true),
  ('e1000001-0de0-0000-0000-000000000013','cycle',22.0,3960, 770,3.3000,220,NOW()-INTERVAL'7 days', NOW()-INTERVAL'7 days'+INTERVAL'66 min',  true);

-- Roberto Ortega — aún no ha registrado nada (0 actividades) — perfecto para mostrar "em­pieza hoy"

-- ── 4. ACTUALIZAR PUNTOS DE CADA EMPLEADO ───────────────────
UPDATE users SET points_balance = (
  SELECT COALESCE(SUM(points_earned), 0) FROM activities WHERE user_id = users.id
) WHERE company_id = :'COMPANY' AND role = 'employee';

-- ── 5. RECOMPENSAS ───────────────────────────────────────────
DELETE FROM rewards WHERE company_id = :'COMPANY';

INSERT INTO rewards (company_id, title, description, points_cost, stock, is_active) VALUES
  (:'COMPANY', 'Día libre extra',         'Un día de descanso adicional a elegir libremente. El beneficio más valorado del catálogo.',                                    500, 20, true),
  (:'COMPANY', 'Vale Decathlon 50€',       'Para zapatillas, ropa técnica o cualquier material deportivo. Canjeable en todas las tiendas.',                               300, 30, true),
  (:'COMPANY', 'Cena para 2',              'Experiencia gastronómica en restaurante seleccionado. Para celebrar los hitos de actividad.',                                  400, 15, true),
  (:'COMPANY', 'Sesión de masaje',         'Recuperación activa con masaje deportivo de 60 minutos. Bienestar que se complementa con el ejercicio.',                      250, 25, true),
  (:'COMPANY', 'Mes de gimnasio',          'Cuota mensual en la red de gimnasios asociados: Anytime Fitness, Holmes Place o similar según ciudad.',                       350, 20, true),
  (:'COMPANY', 'Tarjeta regalo Amazon 30€','Libertad total para que cada empleado elija lo que más valora. Enviada por email en menos de 24h.',                          300, 50, true),
  (:'COMPANY', 'Tarde libre un viernes',   'Sal antes el viernes que elijas. Previa comunicación al responsable con 48h de antelación.',                                 200, 30, true),
  (:'COMPANY', 'Curso online',             'Acceso a cualquier curso de Udemy, Coursera o similar. Crecimiento personal y profesional recompensado.',                     200, 40, true);

-- ── 6. RETOS ─────────────────────────────────────────────────
INSERT INTO challenges (company_id, creator_id, title, description, type, status, date, location, max_participants) VALUES
  (:'COMPANY', :'ADMIN',
   'Reto Mayo: 100 km en equipo',
   'Entre todos los empleados de Telefónica, alcanzamos 100 km acumulados antes del 31 de mayo. Cada km cuenta. ¡Vamos!',
   'challenge', 'open', NULL, NULL, NULL),

  (:'COMPANY', :'ADMIN',
   'Vuelta al trabajo en bici — Junio',
   'Reto de ciclismo para este verano: acumula al menos 50 km en bici durante el mes de junio y consigue puntos extra.',
   'challenge', 'open', '2026-06-30', NULL, NULL),

  (:'COMPANY', :'ADMIN',
   'Carrera popular San Silvestre Madrid',
   'Apúntate a la San Silvestre Vallecana. La empresa cubre la inscripción a los primeros 10 que se registren aquí.',
   'challenge', 'open', '2026-12-31', 'Madrid', 10),

  (:'COMPANY', 'e1000001-0de0-0000-0000-000000000004',
   'Reto David: ¿Quién me sigue al triatlón?',
   'Busco compañeros para preparar un triatlón sprint en septiembre. Entrenos los sábados a las 8h en el Retiro.',
   'activity', 'open', '2026-09-15', 'Parque del Retiro, Madrid', 8),

  (:'COMPANY', 'e1000001-0de0-0000-0000-000000000002',
   'Ruta en bici por el Jarama',
   'Salida grupal en bici este domingo. 45 km por la ribera del Jarama. Nivel medio. Quedan 3 plazas.',
   'activity', 'open', '2026-06-01', 'Madrid Norte', 12),

  (:'COMPANY', 'e1000001-0de0-0000-0000-000000000005',
   'Parkrun sabatino — quien se apunte',
   'Cada sábado a las 9h en la Casa de Campo. 5 km cronometrados, para todos los niveles. ¡Sin excusas!',
   'activity', 'open', NULL, 'Casa de Campo, Madrid', 20);

-- Apuntar a algunos empleados a los retos
INSERT INTO challenge_participants (challenge_id, user_id)
SELECT c.id, u.id
FROM challenges c, users u
WHERE c.company_id = :'COMPANY'
  AND u.company_id = :'COMPANY'
  AND u.role = 'employee'
  AND c.title = 'Reto Mayo: 100 km en equipo'
  AND u.id IN (
    'e1000001-0de0-0000-0000-000000000001',
    'e1000001-0de0-0000-0000-000000000002',
    'e1000001-0de0-0000-0000-000000000004',
    'e1000001-0de0-0000-0000-000000000005',
    'e1000001-0de0-0000-0000-000000000008',
    'e1000001-0de0-0000-0000-000000000010'
  );

INSERT INTO challenge_participants (challenge_id, user_id)
SELECT c.id, u.id
FROM challenges c, users u
WHERE c.company_id = :'COMPANY'
  AND u.company_id = :'COMPANY'
  AND u.role = 'employee'
  AND c.title = 'Vuelta al trabajo en bici — Junio'
  AND u.id IN (
    'e1000001-0de0-0000-0000-000000000002',
    'e1000001-0de0-0000-0000-000000000006',
    'e1000001-0de0-0000-0000-000000000010'
  );

INSERT INTO challenge_participants (challenge_id, user_id)
SELECT c.id, u.id
FROM challenges c, users u
WHERE c.company_id = :'COMPANY'
  AND u.company_id = :'COMPANY'
  AND u.role = 'employee'
  AND c.title = 'Ruta en bici por el Jarama'
  AND u.id IN (
    'e1000001-0de0-0000-0000-000000000002',
    'e1000001-0de0-0000-0000-000000000004',
    'e1000001-0de0-0000-0000-000000000006',
    'e1000001-0de0-0000-0000-000000000010',
    'e1000001-0de0-0000-0000-000000000012'
  );

COMMIT;

-- Verificación rápida
SELECT 'Empleados' AS tipo, COUNT(*) FROM users WHERE company_id = 'cdcf66b4-f0f8-4f03-8032-3c8552361963' AND role='employee'
UNION ALL
SELECT 'Actividades', COUNT(*) FROM activities WHERE user_id IN (SELECT id FROM users WHERE company_id='cdcf66b4-f0f8-4f03-8032-3c8552361963')
UNION ALL
SELECT 'Recompensas', COUNT(*) FROM rewards WHERE company_id='cdcf66b4-f0f8-4f03-8032-3c8552361963'
UNION ALL
SELECT 'Retos', COUNT(*) FROM challenges WHERE company_id='cdcf66b4-f0f8-4f03-8032-3c8552361963';
