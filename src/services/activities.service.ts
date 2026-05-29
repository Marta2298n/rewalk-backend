import { pool } from '../config/database';
import { Activity, ActivityType, CreateActivityDto } from '../types';

const CO2_FACTOR_KG_PER_KM = 0.12;

// ── Hybrid points: time + distance, normalized per sport ─────────────────────
// Objetivo: ~100-120 pts por hora de esfuerzo real independientemente del deporte
// run  1h/10km  → 60 + 60  = 120 pts
// cycle 1h/25km → 60 + 37  =  97 pts
// swim  1h/2km  → 60 + 40  = 100 pts
const POINTS_PER_MIN: Record<ActivityType, number> = {
  run:   1.0,
  swim:  1.0,
  cycle: 1.0,
  walk:  0.5,
};
const POINTS_PER_KM: Record<ActivityType, number> = {
  run:   6.0,
  swim:  20.0,
  cycle: 1.5,
  walk:  4.0,
};

// ── Calorie burn rates (kcal per km, approximate averages) ────────────────────
const CALORIE_RATE: Record<ActivityType, number> = {
  walk:  60,   // ~60 kcal/km
  run:   80,   // ~80 kcal/km
  cycle: 40,   // ~40 kcal/km
  swim:  300,  // ~300 kcal/km (cubre ~2 km/h, muy intenso)
};

// ── Antifraude speed limits (km/h) ────────────────────────────────────────────
const MAX_SPEED_KMH: Record<ActivityType, number> = {
  walk:  8,
  run:   30,
  cycle: 50,
  swim:  5,
};

function calcSpeedKmh(distanceKm: number, durationSeconds: number): number {
  const hours = durationSeconds / 3600;
  return distanceKm / hours;
}

function calcCo2Avoided(distanceKm: number): number {
  return parseFloat((distanceKm * CO2_FACTOR_KG_PER_KM).toFixed(4));
}

function calcCalories(distanceKm: number, type: ActivityType): number {
  return Math.round(distanceKm * CALORIE_RATE[type]);
}

function isValidSpeed(type: ActivityType, distanceKm: number, durationSeconds: number): boolean {
  const speed = calcSpeedKmh(distanceKm, durationSeconds);
  return speed <= MAX_SPEED_KMH[type];
}

export async function createActivity(
  userId: string,
  dto: CreateActivityDto
): Promise<Activity> {
  const { activity_type, distance_km, duration_seconds, start_time, end_time } = dto;

  const calories_burned = calcCalories(distance_km, activity_type);
  const co2_avoided_kg = calcCo2Avoided(distance_km);
  const is_validated = true; // GPS/HealthKit will validate in production
  const points_earned = Math.round(
    (duration_seconds / 60) * POINTS_PER_MIN[activity_type] +
    distance_km * POINTS_PER_KM[activity_type]
  );

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const { rows } = await client.query<Activity>(
      `INSERT INTO activities
         (user_id, activity_type, distance_km, duration_seconds,
          calories_burned, co2_avoided_kg, start_time, end_time, is_validated, points_earned)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [userId, activity_type, distance_km, duration_seconds,
       calories_burned, co2_avoided_kg, start_time, end_time, is_validated, points_earned]
    );

    if (points_earned > 0) {
      await client.query(
        'UPDATE users SET points_balance = points_balance + $1 WHERE id = $2',
        [points_earned, userId]
      );
    }

    await client.query('COMMIT');
    return rows[0];
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

export async function getMyActivities(userId: string): Promise<Activity[]> {
  const { rows } = await pool.query<Activity>(
    `SELECT * FROM activities
     WHERE user_id = $1
     ORDER BY start_time DESC`,
    [userId]
  );
  return rows;
}

export async function getCompanyLeaderboard(userId: string) {
  const { rows } = await pool.query<{
    user_id: string;
    name: string;
    total_points: number;
    total_km: string;
    total_minutes: number;
    activity_count: number;
    is_me: boolean;
  }>(
    `SELECT
       u.id                                              AS user_id,
       u.name,
       COALESCE(SUM(a.points_earned), 0)::INT           AS total_points,
       COALESCE(SUM(a.distance_km), 0)                  AS total_km,
       COALESCE(SUM(a.duration_seconds) / 60, 0)::INT   AS total_minutes,
       COUNT(a.id)::INT                                  AS activity_count,
       (u.id = $1)                                       AS is_me
     FROM users u
     LEFT JOIN activities a
       ON a.user_id = u.id
       AND a.is_validated = true
       AND DATE_TRUNC('month', a.start_time) = DATE_TRUNC('month', NOW())
     WHERE u.company_id = (SELECT company_id FROM users WHERE id = $1)
       AND u.role = 'employee'
       AND u.status = 'active'
     GROUP BY u.id, u.name
     ORDER BY total_points DESC
     LIMIT 10`,
    [userId]
  );
  return rows;
}

export async function getMyMonthlyStats(userId: string) {
  const { rows } = await pool.query<{
    total_km: string;
    total_calories: number;
    total_minutes: number;
    total_points: number;
    activity_count: number;
  }>(
    `SELECT
       COALESCE(SUM(distance_km), 0)               AS total_km,
       COALESCE(SUM(calories_burned), 0)::INT       AS total_calories,
       COALESCE(SUM(duration_seconds) / 60, 0)::INT AS total_minutes,
       COALESCE(SUM(points_earned), 0)::INT         AS total_points,
       COUNT(*)::INT                                AS activity_count
     FROM activities
     WHERE user_id = $1
       AND is_validated = true
       AND DATE_TRUNC('month', start_time) = DATE_TRUNC('month', NOW())`,
    [userId]
  );
  return rows[0];
}
