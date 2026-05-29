import { pool } from '../config/database';

export interface DashboardMetrics {
  total_employees: number;
  active_this_month: number;
  total_km: string;
  total_calories_burned: number;
  total_minutes: number;
  period: string;
}

export async function getDashboardMetrics(companyId: string): Promise<DashboardMetrics> {
  const { rows } = await pool.query<DashboardMetrics>(
    `SELECT
       (SELECT COUNT(*)::INT FROM users WHERE company_id = $1 AND role = 'employee' AND status = 'active') AS total_employees,
       COUNT(DISTINCT a.user_id)::INT                             AS active_this_month,
       COALESCE(SUM(a.distance_km), 0)::NUMERIC(10,2)::TEXT      AS total_km,
       COALESCE(SUM(a.calories_burned), 0)::INT                   AS total_calories_burned,
       COALESCE(SUM(a.duration_seconds) / 60, 0)::INT             AS total_minutes,
       TO_CHAR(DATE_TRUNC('month', NOW()), 'YYYY-MM')             AS period
     FROM activities a
     JOIN users u ON u.id = a.user_id
     WHERE u.company_id = $1
       AND a.is_validated = true
       AND DATE_TRUNC('month', a.start_time) = DATE_TRUNC('month', NOW())`,
    [companyId]
  );

  return rows[0];
}

export async function getCompanyPlan(companyId: string) {
  const { rows } = await pool.query(
    `SELECT c.name, c.plan, c.subscription_status, c.trial_ends_at, c.created_at,
            COUNT(u.id) FILTER (WHERE u.role = 'employee' AND u.status = 'active')::INT AS employee_count
     FROM companies c
     LEFT JOIN users u ON u.company_id = c.id
     WHERE c.id = $1
     GROUP BY c.id`,
    [companyId]
  );
  return rows[0];
}
