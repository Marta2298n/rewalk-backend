-- ============================================================
-- DEMO SEED COMPLETO — 3 empresas de ejemplo
-- Contraseña de todos los usuarios demo: Demo2025!
-- Ejecutar: psql $DATABASE_URL -f migrations/seed_demo_full.sql
-- ============================================================

\set PWHASH '$2b$10$2Gpu8bVTcdc9bJ2kShJsUurSQmGTDqOzmB2RBio18f19hEPYhT8cC'

-- UUIDs fijos para poder relanzar el seed sin duplicados
-- C1=Telefónica  C2=BBVA  C3=Mercadona
-- A1=admin Telefónica  A2=admin BBVA  A3=admin Mercadona
\set C1 'cdcf66b4-f0f8-4f03-8032-3c8552361963'
\set C2 'bbba0001-0000-0000-0000-000000000001'
\set C3 'c3c00001-0000-0000-0000-000000000001'
\set A1 '049c40c7-0fef-4e8f-9c52-c2864eda6e54'
\set A2 'bbba0001-0001-0000-0000-000000000001'
\set A3 'c3c00001-0001-0000-0000-000000000001'

BEGIN;

-- ── LIMPIAR TODO LO DEMO ────────────────────────────────────
DELETE FROM challenge_participants
  WHERE challenge_id IN (
    SELECT id FROM challenges WHERE company_id IN (:'C1',:'C2',:'C3')
  );
DELETE FROM challenges   WHERE company_id IN (:'C1',:'C2',:'C3');
DELETE FROM user_rewards WHERE user_id IN (SELECT id FROM users WHERE company_id IN (:'C1',:'C2',:'C3'));
DELETE FROM activities   WHERE user_id IN (SELECT id FROM users WHERE company_id IN (:'C1',:'C2',:'C3'));
DELETE FROM users        WHERE company_id IN (:'C1',:'C2',:'C3');
DELETE FROM rewards      WHERE company_id IN (:'C1',:'C2',:'C3');
DELETE FROM companies    WHERE id IN (:'C1',:'C2',:'C3');


-- ════════════════════════════════════════════════════════════
-- EMPRESA 1 — TELEFÓNICA S.A.  (plan: total, 14 empleados)
-- ════════════════════════════════════════════════════════════
INSERT INTO companies (id, name, tax_id, plan, subscription_status)
VALUES (:'C1', 'Telefónica S.A.', 'A-82018474', 'total', 'active');

INSERT INTO users (id, company_id, name, email, password_hash, role, status)
VALUES (:'A1', :'C1', 'Recursos Humanos Telefónica', 'rrhh@telefonica.es', :'PWHASH', 'company_admin', 'active');

INSERT INTO users (id, company_id, name, email, password_hash, role, status, points_balance) VALUES
  ('e1000001-0de0-0000-0000-000000000001',:'C1','Ana López',         'analopez@telefonica.es',   :'PWHASH','employee','active',0),
  ('e1000001-0de0-0000-0000-000000000002',:'C1','Carlos Ruiz',        'carlosruiz@telefonica.es', :'PWHASH','employee','active',0),
  ('e1000001-0de0-0000-0000-000000000003',:'C1','María Fernández',    'mfernandez@telefonica.es', :'PWHASH','employee','active',0),
  ('e1000001-0de0-0000-0000-000000000004',:'C1','David Martín',       'dmartin@telefonica.es',    :'PWHASH','employee','active',0),
  ('e1000001-0de0-0000-0000-000000000005',:'C1','Elena Rodríguez',    'erodriguez@telefonica.es', :'PWHASH','employee','active',0),
  ('e1000001-0de0-0000-0000-000000000006',:'C1','Pablo Jiménez',      'pjimenez@telefonica.es',   :'PWHASH','employee','active',0),
  ('e1000001-0de0-0000-0000-000000000007',:'C1','Laura Sánchez',      'lsanchez@telefonica.es',   :'PWHASH','employee','active',0),
  ('e1000001-0de0-0000-0000-000000000008',:'C1','Javier González',    'jgonzalez@telefonica.es',  :'PWHASH','employee','active',0),
  ('e1000001-0de0-0000-0000-000000000009',:'C1','Isabel Navarro',     'inavarro@telefonica.es',   :'PWHASH','employee','active',0),
  ('e1000001-0de0-0000-0000-000000000010',:'C1','Miguel Ángel Díez',  'madiez@telefonica.es',     :'PWHASH','employee','active',0),
  ('e1000001-0de0-0000-0000-000000000011',:'C1','Sofía Herrero',      'sherrero@telefonica.es',   :'PWHASH','employee','active',0),
  ('e1000001-0de0-0000-0000-000000000012',:'C1','Andrés Molina',      'amolina@telefonica.es',    :'PWHASH','employee','active',0),
  ('e1000001-0de0-0000-0000-000000000013',:'C1','Carmen Flores',      'cflores@telefonica.es',    :'PWHASH','employee','active',0),
  ('e1000001-0de0-0000-0000-000000000014',:'C1','Roberto Ortega',     'rortega@telefonica.es',    :'PWHASH','employee','active',0);

INSERT INTO activities (user_id,activity_type,distance_km,duration_seconds,calories_burned,co2_avoided_kg,points_earned,start_time,end_time,is_validated) VALUES
  ('e1000001-0de0-0000-0000-000000000001','run', 8.2,2640,492,1.7220, 82,NOW()-INTERVAL'72 days',NOW()-INTERVAL'72 days'+INTERVAL'44 min',true),
  ('e1000001-0de0-0000-0000-000000000001','run',10.5,3300,630,2.2050,105,NOW()-INTERVAL'67 days',NOW()-INTERVAL'67 days'+INTERVAL'55 min',true),
  ('e1000001-0de0-0000-0000-000000000001','cycle',22.0,3960,770,3.3000,220,NOW()-INTERVAL'61 days',NOW()-INTERVAL'61 days'+INTERVAL'66 min',true),
  ('e1000001-0de0-0000-0000-000000000001','run', 9.0,2880,540,1.8900, 90,NOW()-INTERVAL'55 days',NOW()-INTERVAL'55 days'+INTERVAL'48 min',true),
  ('e1000001-0de0-0000-0000-000000000001','run',12.3,3900,738,2.5830,123,NOW()-INTERVAL'48 days',NOW()-INTERVAL'48 days'+INTERVAL'65 min',true),
  ('e1000001-0de0-0000-0000-000000000001','run', 8.8,2700,528,1.8480, 88,NOW()-INTERVAL'22 days',NOW()-INTERVAL'22 days'+INTERVAL'45 min',true),
  ('e1000001-0de0-0000-0000-000000000001','run',11.0,3420,660,2.3100,110,NOW()-INTERVAL'12 days',NOW()-INTERVAL'12 days'+INTERVAL'57 min',true),
  ('e1000001-0de0-0000-0000-000000000001','run',13.5,4200,810,2.8350,135,NOW()-INTERVAL'3 days', NOW()-INTERVAL'3 days'+INTERVAL'70 min', true),
  ('e1000001-0de0-0000-0000-000000000002','cycle',35.0,6300,1225,5.2500,350,NOW()-INTERVAL'70 days',NOW()-INTERVAL'70 days'+INTERVAL'105 min',true),
  ('e1000001-0de0-0000-0000-000000000002','cycle',40.0,7200,1400,6.0000,400,NOW()-INTERVAL'45 days',NOW()-INTERVAL'45 days'+INTERVAL'120 min',true),
  ('e1000001-0de0-0000-0000-000000000002','cycle',32.0,5760,1120,4.8000,320,NOW()-INTERVAL'25 days',NOW()-INTERVAL'25 days'+INTERVAL'96 min', true),
  ('e1000001-0de0-0000-0000-000000000002','run',  9.0,2880, 540,1.8900, 90,NOW()-INTERVAL'10 days',NOW()-INTERVAL'10 days'+INTERVAL'48 min',true),
  ('e1000001-0de0-0000-0000-000000000002','cycle',38.0,6840,1330,5.7000,380,NOW()-INTERVAL'4 days', NOW()-INTERVAL'4 days'+INTERVAL'114 min',true),
  ('e1000001-0de0-0000-0000-000000000003','run', 4.0,1560,240,0.8400, 40,NOW()-INTERVAL'28 days',NOW()-INTERVAL'28 days'+INTERVAL'26 min',true),
  ('e1000001-0de0-0000-0000-000000000003','run', 5.2,1980,312,1.0920, 52,NOW()-INTERVAL'19 days',NOW()-INTERVAL'19 days'+INTERVAL'33 min',true),
  ('e1000001-0de0-0000-0000-000000000003','run', 7.2,2700,432,1.5120, 72,NOW()-INTERVAL'4 days', NOW()-INTERVAL'4 days'+INTERVAL'45 min', true),
  ('e1000001-0de0-0000-0000-000000000004','run', 15.0,4680, 900,3.1500,150,NOW()-INTERVAL'60 days',NOW()-INTERVAL'60 days'+INTERVAL'78 min', true),
  ('e1000001-0de0-0000-0000-000000000004','cycle',50.0,9000,1750,7.5000,500,NOW()-INTERVAL'44 days',NOW()-INTERVAL'44 days'+INTERVAL'150 min',true),
  ('e1000001-0de0-0000-0000-000000000004','run', 21.0,6600,1260,4.4100,210,NOW()-INTERVAL'27 days',NOW()-INTERVAL'27 days'+INTERVAL'110 min',true),
  ('e1000001-0de0-0000-0000-000000000004','cycle',55.0,9900,1925,8.2500,550,NOW()-INTERVAL'10 days',NOW()-INTERVAL'10 days'+INTERVAL'165 min',true),
  ('e1000001-0de0-0000-0000-000000000004','run', 20.0,6240,1200,4.2000,200,NOW()-INTERVAL'3 days', NOW()-INTERVAL'3 days'+INTERVAL'104 min',true),
  ('e1000001-0de0-0000-0000-000000000005','run', 7.0,2520,420,1.4700, 70,NOW()-INTERVAL'29 days',NOW()-INTERVAL'29 days'+INTERVAL'42 min',true),
  ('e1000001-0de0-0000-0000-000000000005','run',10.0,3600,600,2.1000,100,NOW()-INTERVAL'18 days',NOW()-INTERVAL'18 days'+INTERVAL'60 min',true),
  ('e1000001-0de0-0000-0000-000000000005','run',12.0,4320,720,2.5200,120,NOW()-INTERVAL'7 days', NOW()-INTERVAL'7 days'+INTERVAL'72 min', true),
  ('e1000001-0de0-0000-0000-000000000006','cycle',30.0,5400,1050,4.5000,300,NOW()-INTERVAL'37 days',NOW()-INTERVAL'37 days'+INTERVAL'90 min', true),
  ('e1000001-0de0-0000-0000-000000000006','cycle',36.0,6480,1260,5.4000,360,NOW()-INTERVAL'9 days', NOW()-INTERVAL'9 days'+INTERVAL'108 min',true),
  ('e1000001-0de0-0000-0000-000000000007','run', 3.5,1440,210,0.7350, 35,NOW()-INTERVAL'13 days',NOW()-INTERVAL'13 days'+INTERVAL'28 min',true),
  ('e1000001-0de0-0000-0000-000000000007','run', 4.8,1980,288,1.0080, 48,NOW()-INTERVAL'5 days', NOW()-INTERVAL'5 days'+INTERVAL'33 min', true),
  ('e1000001-0de0-0000-0000-000000000008','run',10.0,3180,600,2.1000,100,NOW()-INTERVAL'56 days',NOW()-INTERVAL'56 days'+INTERVAL'53 min',true),
  ('e1000001-0de0-0000-0000-000000000008','run', 8.0,2520,480,1.6800, 80,NOW()-INTERVAL'20 days',NOW()-INTERVAL'20 days'+INTERVAL'42 min',true),
  ('e1000001-0de0-0000-0000-000000000008','run',11.5,3600,690,2.4150,115,NOW()-INTERVAL'7 days', NOW()-INTERVAL'7 days'+INTERVAL'60 min', true),
  ('e1000001-0de0-0000-0000-000000000009','run', 6.0,2160,360,1.2600, 60,NOW()-INTERVAL'34 days',NOW()-INTERVAL'34 days'+INTERVAL'36 min',true),
  ('e1000001-0de0-0000-0000-000000000009','run', 9.0,3240,540,1.8900, 90,NOW()-INTERVAL'15 days',NOW()-INTERVAL'15 days'+INTERVAL'54 min',true),
  ('e1000001-0de0-0000-0000-000000000009','run',10.0,3600,600,2.1000,100,NOW()-INTERVAL'4 days', NOW()-INTERVAL'4 days'+INTERVAL'60 min', true),
  ('e1000001-0de0-0000-0000-000000000010','cycle',48.0,8640,1680,7.2000,480,NOW()-INTERVAL'60 days',NOW()-INTERVAL'60 days'+INTERVAL'144 min',true),
  ('e1000001-0de0-0000-0000-000000000010','cycle',55.0,9900,1925,8.2500,550,NOW()-INTERVAL'30 days',NOW()-INTERVAL'30 days'+INTERVAL'165 min',true),
  ('e1000001-0de0-0000-0000-000000000010','cycle',38.0,6840,1330,5.7000,380,NOW()-INTERVAL'10 days',NOW()-INTERVAL'10 days'+INTERVAL'114 min',true),
  ('e1000001-0de0-0000-0000-000000000010','run', 10.0,3120,600,2.1000,100,NOW()-INTERVAL'3 days', NOW()-INTERVAL'3 days'+INTERVAL'52 min', true),
  ('e1000001-0de0-0000-0000-000000000011','run', 3.0,1260,180,0.6300, 30,NOW()-INTERVAL'8 days', NOW()-INTERVAL'8 days'+INTERVAL'21 min', true),
  ('e1000001-0de0-0000-0000-000000000011','run', 3.5,1440,210,0.7350, 35,NOW()-INTERVAL'2 days', NOW()-INTERVAL'2 days'+INTERVAL'24 min', true),
  ('e1000001-0de0-0000-0000-000000000012','run', 9.0,2880,540,1.8900, 90,NOW()-INTERVAL'57 days',NOW()-INTERVAL'57 days'+INTERVAL'48 min',true),
  ('e1000001-0de0-0000-0000-000000000012','run',13.0,4080,780,2.7300,130,NOW()-INTERVAL'10 days',NOW()-INTERVAL'10 days'+INTERVAL'68 min',true),
  ('e1000001-0de0-0000-0000-000000000013','cycle',20.0,3600,700,3.0000,200,NOW()-INTERVAL'30 days',NOW()-INTERVAL'30 days'+INTERVAL'60 min',true),
  ('e1000001-0de0-0000-0000-000000000013','cycle',22.0,3960,770,3.3000,220,NOW()-INTERVAL'7 days', NOW()-INTERVAL'7 days'+INTERVAL'66 min', true);

UPDATE users SET points_balance = (
  SELECT COALESCE(SUM(points_earned),0) FROM activities WHERE user_id = users.id
) WHERE company_id = :'C1' AND role = 'employee';

INSERT INTO rewards (company_id,title,description,points_cost,stock,max_per_user,redemption_period,is_active) VALUES
  (:'C1','Día libre extra',       'Un día de descanso adicional a elegir libremente.',                  500,20,3,'yearly', true),
  (:'C1','Vale Decathlon 50€',    'Para zapatillas, ropa técnica o material deportivo.',                300,30,2,'yearly', true),
  (:'C1','Cena para 2',           'Experiencia gastronómica en restaurante seleccionado.',              400,15,1,'yearly', true),
  (:'C1','Sesión de masaje',      'Masaje deportivo de 60 minutos.',                                    250,25,4,'yearly', true),
  (:'C1','Tarde libre viernes',   'Sal antes el viernes que elijas, con 48h de preaviso.',             200,30,3,'monthly',true),
  (:'C1','Curso online',          'Acceso a Udemy, Coursera o similar.',                               200,40,1,'yearly', true);

INSERT INTO challenges (company_id,creator_id,title,description,type,status,date,location,max_participants) VALUES
  (:'C1',:'A1','Reto Mayo: 100 km en equipo','Entre todos alcanzamos 100 km acumulados en mayo. ¡Cada km cuenta!','challenge','open',NULL,NULL,NULL),
  (:'C1',:'A1','Vuelta al trabajo en bici — Junio','Acumula 50 km en bici en junio y gana puntos extra.','challenge','open','2026-06-30',NULL,NULL),
  (:'C1',:'A1','Carrera popular San Silvestre','La empresa cubre la inscripción a los primeros 10 apuntados.','challenge','open','2026-12-31','Madrid',10),
  (:'C1','e1000001-0de0-0000-0000-000000000004','¿Quién me sigue al triatlón?','Busco compañeros para un triatlón sprint en septiembre.','activity','open','2026-09-15','Parque del Retiro, Madrid',8),
  (:'C1','e1000001-0de0-0000-0000-000000000002','Ruta en bici por el Jarama','Salida grupal este domingo, 45 km. Nivel medio.','activity','open','2026-06-01','Madrid Norte',12);

INSERT INTO challenge_participants (challenge_id, user_id)
SELECT c.id, u.id FROM challenges c, users u
WHERE c.company_id=:'C1' AND u.company_id=:'C1' AND u.role='employee'
  AND c.title='Reto Mayo: 100 km en equipo'
  AND u.id IN ('e1000001-0de0-0000-0000-000000000001','e1000001-0de0-0000-0000-000000000002',
               'e1000001-0de0-0000-0000-000000000004','e1000001-0de0-0000-0000-000000000005',
               'e1000001-0de0-0000-0000-000000000008','e1000001-0de0-0000-0000-000000000010');

INSERT INTO challenge_participants (challenge_id, user_id)
SELECT c.id, u.id FROM challenges c, users u
WHERE c.company_id=:'C1' AND u.company_id=:'C1' AND u.role='employee'
  AND c.title='Ruta en bici por el Jarama'
  AND u.id IN ('e1000001-0de0-0000-0000-000000000002','e1000001-0de0-0000-0000-000000000006',
               'e1000001-0de0-0000-0000-000000000010');


-- ════════════════════════════════════════════════════════════
-- EMPRESA 2 — BBVA  (plan: premium, 8 empleados)
-- ════════════════════════════════════════════════════════════
INSERT INTO companies (id, name, tax_id, plan, subscription_status)
VALUES (:'C2', 'BBVA S.A.', 'A-48265169', 'premium', 'active');

INSERT INTO users (id, company_id, name, email, password_hash, role, status)
VALUES (:'A2', :'C2', 'RRHH BBVA', 'rrhh@bbva.es', :'PWHASH', 'company_admin', 'active');

INSERT INTO users (id, company_id, name, email, password_hash, role, status, points_balance) VALUES
  ('e2000001-0000-0000-0000-000000000001',:'C2','Lucía Moreno',     'lmoreno@bbva.es',    :'PWHASH','employee','active',0),
  ('e2000001-0000-0000-0000-000000000002',:'C2','Sergio Torres',    'storres@bbva.es',    :'PWHASH','employee','active',0),
  ('e2000001-0000-0000-0000-000000000003',:'C2','Natalia Vega',     'nvega@bbva.es',      :'PWHASH','employee','active',0),
  ('e2000001-0000-0000-0000-000000000004',:'C2','Francisco Reyes',  'freyes@bbva.es',     :'PWHASH','employee','active',0),
  ('e2000001-0000-0000-0000-000000000005',:'C2','Cristina Blanco',  'cblanco@bbva.es',    :'PWHASH','employee','active',0),
  ('e2000001-0000-0000-0000-000000000006',:'C2','Héctor Fuentes',   'hfuentes@bbva.es',   :'PWHASH','employee','active',0),
  ('e2000001-0000-0000-0000-000000000007',:'C2','Marta Castillo',   'mcastillo@bbva.es',  :'PWHASH','employee','active',0),
  ('e2000001-0000-0000-0000-000000000008',:'C2','Álvaro Guerrero',  'aguerrero@bbva.es',  :'PWHASH','employee','active',0);

INSERT INTO activities (user_id,activity_type,distance_km,duration_seconds,calories_burned,co2_avoided_kg,points_earned,start_time,end_time,is_validated) VALUES
  ('e2000001-0000-0000-0000-000000000001','run', 9.5,3060,570,1.9950, 95,NOW()-INTERVAL'25 days',NOW()-INTERVAL'25 days'+INTERVAL'51 min',true),
  ('e2000001-0000-0000-0000-000000000001','run',11.0,3540,660,2.3100,110,NOW()-INTERVAL'11 days',NOW()-INTERVAL'11 days'+INTERVAL'59 min',true),
  ('e2000001-0000-0000-0000-000000000001','run', 7.5,2400,450,1.5750, 75,NOW()-INTERVAL'3 days', NOW()-INTERVAL'3 days'+INTERVAL'40 min', true),
  ('e2000001-0000-0000-0000-000000000002','cycle',42.0,7560,1470,6.3000,420,NOW()-INTERVAL'20 days',NOW()-INTERVAL'20 days'+INTERVAL'126 min',true),
  ('e2000001-0000-0000-0000-000000000002','cycle',35.0,6300,1225,5.2500,350,NOW()-INTERVAL'6 days', NOW()-INTERVAL'6 days'+INTERVAL'105 min',true),
  ('e2000001-0000-0000-0000-000000000003','run', 6.0,2160,360,1.2600, 60,NOW()-INTERVAL'18 days',NOW()-INTERVAL'18 days'+INTERVAL'36 min',true),
  ('e2000001-0000-0000-0000-000000000003','run', 8.0,2880,480,1.6800, 80,NOW()-INTERVAL'7 days', NOW()-INTERVAL'7 days'+INTERVAL'48 min', true),
  ('e2000001-0000-0000-0000-000000000004','run',14.0,4320,840,2.9400,140,NOW()-INTERVAL'22 days',NOW()-INTERVAL'22 days'+INTERVAL'72 min',true),
  ('e2000001-0000-0000-0000-000000000004','cycle',28.0,5040,980,4.2000,280,NOW()-INTERVAL'9 days', NOW()-INTERVAL'9 days'+INTERVAL'84 min', true),
  ('e2000001-0000-0000-0000-000000000005','run', 5.0,1920,300,1.0500, 50,NOW()-INTERVAL'14 days',NOW()-INTERVAL'14 days'+INTERVAL'32 min',true),
  ('e2000001-0000-0000-0000-000000000005','run', 6.5,2460,390,1.3650, 65,NOW()-INTERVAL'4 days', NOW()-INTERVAL'4 days'+INTERVAL'41 min', true),
  ('e2000001-0000-0000-0000-000000000006','cycle',20.0,3600,700,3.0000,200,NOW()-INTERVAL'16 days',NOW()-INTERVAL'16 days'+INTERVAL'60 min',true),
  ('e2000001-0000-0000-0000-000000000007','run', 4.5,1800,270,0.9450, 45,NOW()-INTERVAL'10 days',NOW()-INTERVAL'10 days'+INTERVAL'30 min',true),
  ('e2000001-0000-0000-0000-000000000007','run', 5.5,2160,330,1.1550, 55,NOW()-INTERVAL'2 days', NOW()-INTERVAL'2 days'+INTERVAL'36 min', true);

UPDATE users SET points_balance = (
  SELECT COALESCE(SUM(points_earned),0) FROM activities WHERE user_id = users.id
) WHERE company_id = :'C2' AND role = 'employee';

INSERT INTO rewards (company_id,title,description,points_cost,stock,max_per_user,redemption_period,is_active) VALUES
  (:'C2','Tarde libre',            'Sal a las 14h cualquier día de tu elección.',           200,20,3,'monthly',true),
  (:'C2','Vale El Corte Inglés 40€','Para lo que quieras: deporte, moda, tecnología...',   300,15,2,'yearly', true),
  (:'C2','Clases de yoga (1 mes)', 'Acceso a un mes de clases de yoga en el centro BBVA.',  250,10,2,'yearly', true),
  (:'C2','Ticket restaurante 25€', 'Para comer bien sin mirar el precio.',                  150,30,NULL,    'none',  true),
  (:'C2','Día de teletrabajo extra','Un día adicional de trabajo desde casa al mes.',        100,50,4,'monthly',true);

INSERT INTO challenges (company_id,creator_id,title,description,type,status,date,location,max_participants) VALUES
  (:'C2',:'A2','Reto Kilómetros de Mayo','Acumula 30 km este mes. El top 3 recibe un premio especial.','challenge','open',NULL,NULL,NULL),
  (:'C2',:'A2','10.000 pasos diarios','Registra actividad cada día laboral de junio. Sin excusas.','challenge','open','2026-06-30',NULL,NULL),
  (:'C2','e2000001-0000-0000-0000-000000000002','Salida ciclista fin de semana','Ruta por la Sierra de Guadarrama, 60 km. ¡Plazas limitadas!','activity','open','2026-06-07','Madrid',8),
  (:'C2','e2000001-0000-0000-0000-000000000004','Grupo de running mañanero','Quedada lunes y miércoles a las 7:30h en Retiro. Todos los niveles.','activity','open',NULL,'Parque del Retiro, Madrid',15);

INSERT INTO challenge_participants (challenge_id, user_id)
SELECT c.id, u.id FROM challenges c, users u
WHERE c.company_id=:'C2' AND u.company_id=:'C2' AND u.role='employee'
  AND c.title='Reto Kilómetros de Mayo'
  AND u.id IN ('e2000001-0000-0000-0000-000000000001','e2000001-0000-0000-0000-000000000003',
               'e2000001-0000-0000-0000-000000000004','e2000001-0000-0000-0000-000000000005',
               'e2000001-0000-0000-0000-000000000007');

INSERT INTO challenge_participants (challenge_id, user_id)
SELECT c.id, u.id FROM challenges c, users u
WHERE c.company_id=:'C2' AND u.company_id=:'C2' AND u.role='employee'
  AND c.title='Salida ciclista fin de semana'
  AND u.id IN ('e2000001-0000-0000-0000-000000000002','e2000001-0000-0000-0000-000000000004',
               'e2000001-0000-0000-0000-000000000006');


-- ════════════════════════════════════════════════════════════
-- EMPRESA 3 — MERCADONA S.A.  (plan: basic, 5 empleados)
-- ════════════════════════════════════════════════════════════
INSERT INTO companies (id, name, tax_id, plan, subscription_status)
VALUES (:'C3', 'Mercadona S.A.', 'A-46103834', 'basic', 'active');

INSERT INTO users (id, company_id, name, email, password_hash, role, status)
VALUES (:'A3', :'C3', 'RRHH Mercadona', 'rrhh@mercadona.es', :'PWHASH', 'company_admin', 'active');

INSERT INTO users (id, company_id, name, email, password_hash, role, status, points_balance) VALUES
  ('e3000001-0000-0000-0000-000000000001',:'C3','Rosa Ibáñez',      'ribañez@mercadona.es',  :'PWHASH','employee','active',0),
  ('e3000001-0000-0000-0000-000000000002',:'C3','Pedro Cano',       'pcano@mercadona.es',    :'PWHASH','employee','active',0),
  ('e3000001-0000-0000-0000-000000000003',:'C3','Amparo Soler',     'asoler@mercadona.es',   :'PWHASH','employee','active',0),
  ('e3000001-0000-0000-0000-000000000004',:'C3','Ignacio Palma',    'ipalma@mercadona.es',   :'PWHASH','employee','active',0),
  ('e3000001-0000-0000-0000-000000000005',:'C3','Beatriz Llopis',   'bllopis@mercadona.es',  :'PWHASH','employee','active',0);

INSERT INTO activities (user_id,activity_type,distance_km,duration_seconds,calories_burned,co2_avoided_kg,points_earned,start_time,end_time,is_validated) VALUES
  ('e3000001-0000-0000-0000-000000000001','run', 5.0,1920,300,1.0500, 50,NOW()-INTERVAL'20 days',NOW()-INTERVAL'20 days'+INTERVAL'32 min',true),
  ('e3000001-0000-0000-0000-000000000001','run', 6.0,2280,360,1.2600, 60,NOW()-INTERVAL'8 days', NOW()-INTERVAL'8 days'+INTERVAL'38 min', true),
  ('e3000001-0000-0000-0000-000000000001','run', 7.0,2640,420,1.4700, 70,NOW()-INTERVAL'1 days', NOW()-INTERVAL'1 days'+INTERVAL'44 min', true),
  ('e3000001-0000-0000-0000-000000000002','cycle',18.0,3240,630,2.7000,180,NOW()-INTERVAL'15 days',NOW()-INTERVAL'15 days'+INTERVAL'54 min',true),
  ('e3000001-0000-0000-0000-000000000002','cycle',22.0,3960,770,3.3000,220,NOW()-INTERVAL'5 days', NOW()-INTERVAL'5 days'+INTERVAL'66 min', true),
  ('e3000001-0000-0000-0000-000000000003','run', 4.0,1680,240,0.8400, 40,NOW()-INTERVAL'12 days',NOW()-INTERVAL'12 days'+INTERVAL'28 min',true),
  ('e3000001-0000-0000-0000-000000000003','run', 5.5,2160,330,1.1550, 55,NOW()-INTERVAL'4 days', NOW()-INTERVAL'4 days'+INTERVAL'36 min', true),
  ('e3000001-0000-0000-0000-000000000004','run', 8.0,2640,480,1.6800, 80,NOW()-INTERVAL'9 days', NOW()-INTERVAL'9 days'+INTERVAL'44 min', true),
  ('e3000001-0000-0000-0000-000000000004','run',10.0,3240,600,2.1000,100,NOW()-INTERVAL'2 days', NOW()-INTERVAL'2 days'+INTERVAL'54 min', true);

UPDATE users SET points_balance = (
  SELECT COALESCE(SUM(points_earned),0) FROM activities WHERE user_id = users.id
) WHERE company_id = :'C3' AND role = 'employee';

INSERT INTO rewards (company_id,title,description,points_cost,stock,max_per_user,redemption_period,is_active) VALUES
  (:'C3','Tarde libre',       'Sal antes cualquier viernes del mes.',                   150,10,2,'monthly',true),
  (:'C3','Cesta de productos','Cesta con productos Mercadona valorada en 30€.',         200,20,1,'monthly',true),
  (:'C3','Vale gasolinera 20€','Para los que vienen al trabajo en coche o moto.',       180,15,2,'yearly', true),
  (:'C3','Día teletrabajo',   'Un día adicional de trabajo desde casa.',                100,20,4,'monthly',true);

INSERT INTO challenges (company_id,creator_id,title,description,type,status,date,location,max_participants) VALUES
  (:'C3',:'A3','Reto Caminata Solidaria','Caminamos juntos 200 km en mayo para donación a banco de alimentos.','challenge','open',NULL,NULL,NULL),
  (:'C3',:'A3','Reto Escaleras — sin ascensor','Durante todo junio, sube y baja siempre por las escaleras.','challenge','open','2026-06-30',NULL,NULL),
  (:'C3','e3000001-0000-0000-0000-000000000001','Grupo de running del barrio','Salimos a correr los martes y jueves a las 7h. ¡Apúntate!','activity','open',NULL,NULL,20);

INSERT INTO challenge_participants (challenge_id, user_id)
SELECT c.id, u.id FROM challenges c, users u
WHERE c.company_id=:'C3' AND u.company_id=:'C3' AND u.role='employee'
  AND c.title='Reto Caminata Solidaria';


-- ════════════════════════════════════════════════════════════
-- VERIFICACIÓN
-- ════════════════════════════════════════════════════════════
COMMIT;

SELECT e.name AS empresa, u.role, COUNT(*) AS total
FROM users u JOIN companies e ON e.id=u.company_id
WHERE e.id IN (:'C1',:'C2',:'C3')
GROUP BY e.name, u.role
ORDER BY e.name, u.role;
