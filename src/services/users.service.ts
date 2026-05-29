import { pool } from '../config/database';
import { User, RegisterEmployeeDto } from '../types';
import { hashPassword } from './auth.service';

export async function listEmployees(companyId: string): Promise<Omit<User, 'password_hash'>[]> {
  const { rows } = await pool.query<User>(
    `SELECT id, company_id, name, email, role, status, created_at
     FROM users
     WHERE company_id = $1 AND role = 'employee'
     ORDER BY created_at DESC`,
    [companyId]
  );
  return rows as Omit<User, 'password_hash'>[];
}

export async function registerEmployee(
  companyId: string,
  dto: RegisterEmployeeDto
): Promise<Omit<User, 'password_hash'>> {
  const { name, email, password } = dto;

  const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
  if (existing.rows.length > 0) throw new Error('Email already in use');

  const password_hash = await hashPassword(password);

  const { rows } = await pool.query<User>(
    `INSERT INTO users (company_id, name, email, password_hash, role)
     VALUES ($1, $2, $3, $4, 'employee')
     RETURNING id, company_id, name, email, role, status, created_at`,
    [companyId, name, email, password_hash]
  );

  return rows[0] as Omit<User, 'password_hash'>;
}
