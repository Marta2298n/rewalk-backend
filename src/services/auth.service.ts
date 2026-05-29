import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { pool } from '../config/database';
import { User, JwtPayload } from '../types';

const SALT_ROUNDS = 10;

export async function login(
  email: string,
  password: string
): Promise<{ token: string; role: string; userId: string; subscription_status: string }> {
  const { rows } = await pool.query<User & { subscription_status: string }>(
    `SELECT u.*, c.subscription_status
     FROM users u
     JOIN companies c ON c.id = u.company_id
     WHERE u.email = $1 AND u.status = $2`,
    [email, 'active']
  );

  const user = rows[0];
  if (!user) throw new Error('Invalid credentials');

  const match = await bcrypt.compare(password, user.password_hash);
  if (!match) throw new Error('Invalid credentials');

  const payload: JwtPayload = {
    userId: user.id,
    companyId: user.company_id,
    role: user.role,
    email: user.email,
  };

  const token = jwt.sign(payload, process.env.JWT_SECRET as string, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  } as jwt.SignOptions);

  return { token, role: user.role, userId: user.id, subscription_status: user.subscription_status };
}

export async function hashPassword(plain: string): Promise<string> {
  return bcrypt.hash(plain, SALT_ROUNDS);
}
