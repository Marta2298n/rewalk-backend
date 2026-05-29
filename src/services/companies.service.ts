import { pool } from '../config/database';
import { hashPassword } from './auth.service';
import { PLANS, PlanName } from '../config/plans';

export interface CompanySummary {
  id: string;
  name: string;
  tax_id: string;
  subscription_status: string;
  plan: PlanName;
  trial_ends_at: string | null;
  created_at: string;
  employee_count: number;
  total_co2_kg: string;
  total_calories: number;
  admin_email: string;
}

export interface CreateCompanyDto {
  name: string;
  tax_id: string;
  admin_name: string;
  admin_email: string;
  admin_password: string;
}

export async function listCompanies(): Promise<CompanySummary[]> {
  const { rows } = await pool.query<CompanySummary>(
    `SELECT
       c.id,
       c.name,
       c.tax_id,
       c.subscription_status,
       c.plan,
       c.trial_ends_at,
       c.created_at,
       COUNT(DISTINCT u.id) FILTER (WHERE u.role = 'employee' AND u.status = 'active')::INT AS employee_count,
       COALESCE(SUM(a.co2_avoided_kg) FILTER (
         WHERE a.is_validated = true
           AND DATE_TRUNC('month', a.start_time) = DATE_TRUNC('month', NOW())
       ), 0) AS total_co2_kg,
       COALESCE(SUM(a.calories_burned) FILTER (
         WHERE a.is_validated = true
           AND DATE_TRUNC('month', a.start_time) = DATE_TRUNC('month', NOW())
       ), 0)::INT AS total_calories,
       MAX(u.email) FILTER (WHERE u.role = 'company_admin') AS admin_email
     FROM companies c
     LEFT JOIN users u ON u.company_id = c.id
     LEFT JOIN activities a ON a.user_id = u.id
     WHERE c.id != '00000000-0000-0000-0000-000000000001'
     GROUP BY c.id
     ORDER BY c.created_at DESC`
  );
  return rows;
}

const VALID_STATUSES = ['trial', 'active', 'suspended', 'cancelled'];

export async function updateSubscription(companyId: string, status: string) {
  if (!VALID_STATUSES.includes(status)) throw new Error('Estado no válido');
  const { rows } = await pool.query(
    `UPDATE companies SET subscription_status = $1 WHERE id = $2 AND id != '00000000-0000-0000-0000-000000000001' RETURNING id, name, subscription_status`,
    [status, companyId]
  );
  if (rows.length === 0) throw new Error('Empresa no encontrada');
  return rows[0];
}

export async function updatePlan(companyId: string, plan: string) {
  if (!Object.keys(PLANS).includes(plan)) throw new Error('Plan no válido');
  const { rows } = await pool.query(
    `UPDATE companies
     SET plan = $1::company_plan,
         subscription_status = 'active',
         trial_ends_at = CASE WHEN $1::text = 'trial' THEN NOW() + INTERVAL '10 days' ELSE NULL END
     WHERE id = $2 AND id != '00000000-0000-0000-0000-000000000001'
     RETURNING id, name, plan, subscription_status`,
    [plan, companyId]
  );
  if (rows.length === 0) throw new Error('Empresa no encontrada');
  return rows[0];
}

export async function createCompany(dto: CreateCompanyDto) {
  const { name, tax_id, admin_name, admin_email, admin_password } = dto;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const existing = await client.query('SELECT id FROM companies WHERE tax_id = $1', [tax_id]);
    if (existing.rows.length > 0) throw new Error('Ya existe una empresa con ese CIF/NIF');

    const emailCheck = await client.query('SELECT id FROM users WHERE email = $1', [admin_email]);
    if (emailCheck.rows.length > 0) throw new Error('Ya existe un usuario con ese email');

    const { rows: companyRows } = await client.query(
      `INSERT INTO companies (name, tax_id, subscription_status, plan, trial_ends_at)
       VALUES ($1, $2, 'active', 'trial', NOW() + INTERVAL '10 days') RETURNING *`,
      [name, tax_id]
    );
    const company = companyRows[0];

    const password_hash = await hashPassword(admin_password);
    const { rows: userRows } = await client.query(
      `INSERT INTO users (company_id, name, email, password_hash, role)
       VALUES ($1, $2, $3, $4, 'company_admin')
       RETURNING id, name, email, role`,
      [company.id, admin_name, admin_email, password_hash]
    );

    await client.query('COMMIT');
    return { company, admin: userRows[0] };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}
