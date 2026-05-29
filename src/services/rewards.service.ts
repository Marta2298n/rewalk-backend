import { pool } from '../config/database';

export type RedemptionPeriod = 'none' | 'monthly' | 'yearly';

export interface Reward {
  id: string;
  company_id: string;
  title: string;
  description: string;
  points_cost: number;
  stock: number;
  is_active: boolean;
  max_per_user: number | null;        // null = sin límite
  redemption_period: RedemptionPeriod; // 'none' | 'monthly' | 'yearly'
}

export interface CreateRewardDto {
  title: string;
  description: string;
  points_cost: number;
  stock: number;
  max_per_user?: number | null;
  redemption_period?: RedemptionPeriod;
}

export interface EmployeeRedemption {
  id: string;
  reward_id: string;
  reward_title: string;
  points_cost: number;
  redemption_code: string;
  status: 'pending' | 'used';
  claimed_at: string;
  validated_at: string | null;
}

export interface EmployeeRewardLimit {
  reward_id: string;
  reward_title: string;
  // límite general de la recompensa
  default_max: number | null;
  default_period: RedemptionPeriod;
  // override para este empleado (null si no hay)
  override_max: number | null;
  override_period: RedemptionPeriod | null;
  // canjes que ya lleva este empleado
  times_redeemed: number;
}

export interface Redemption {
  id: string;
  user_id: string;
  user_name: string;
  reward_id: string;
  reward_title: string;
  points_cost: number;
  redemption_code: string;
  status: 'pending' | 'used';
  claimed_at: string;
  validated_at: string | null;
}

function generateCode(): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = 'ECO-';
  for (let i = 0; i < 6; i++) code += chars[Math.floor(Math.random() * chars.length)];
  return code;
}

export async function listRewards(companyId: string): Promise<Reward[]> {
  const { rows } = await pool.query<Reward>(
    `SELECT * FROM rewards WHERE company_id = $1 AND is_active = true ORDER BY points_cost ASC`,
    [companyId]
  );
  return rows;
}

export async function createReward(companyId: string, dto: CreateRewardDto): Promise<Reward> {
  const { title, description, points_cost, stock, max_per_user = 1, redemption_period = 'none' } = dto;
  const { rows } = await pool.query<Reward>(
    `INSERT INTO rewards (company_id, title, description, points_cost, stock, max_per_user, redemption_period)
     VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
    [companyId, title, description, points_cost, stock, max_per_user ?? null, redemption_period]
  );
  return rows[0];
}

export async function redeemReward(
  userId: string,
  companyId: string,
  rewardId: string
): Promise<{ message: string; points_remaining: number; redemption_code: string; reward_title: string }> {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const { rows: rewardRows } = await client.query<Reward>(
      `SELECT * FROM rewards WHERE id = $1 AND company_id = $2 AND is_active = true FOR UPDATE`,
      [rewardId, companyId]
    );
    const reward = rewardRows[0];
    if (!reward) throw new Error('Recompensa no encontrada o no disponible');
    if (reward.stock <= 0) throw new Error('Sin stock disponible');

    // Límite por persona (comprueba override individual, luego límite general)
    const { rows: overrideRows } = await client.query<{ max_per_user: number; redemption_period: RedemptionPeriod }>(
      `SELECT max_per_user, redemption_period FROM reward_employee_limits
       WHERE reward_id = $1 AND user_id = $2`,
      [rewardId, userId]
    );
    const effectiveMax    = overrideRows.length > 0 ? overrideRows[0].max_per_user    : reward.max_per_user;
    const effectivePeriod = overrideRows.length > 0 ? overrideRows[0].redemption_period : reward.redemption_period;

    if (effectiveMax !== null) {
      // Filtro de período para contar canjes previos
      let periodFilter = '';
      if (effectivePeriod === 'monthly') {
        periodFilter = `AND DATE_TRUNC('month', claimed_at) = DATE_TRUNC('month', NOW())`;
      } else if (effectivePeriod === 'yearly') {
        periodFilter = `AND DATE_TRUNC('year', claimed_at) = DATE_TRUNC('year', NOW())`;
      }
      const { rows: countRows } = await client.query<{ count: string }>(
        `SELECT COUNT(*) FROM user_rewards WHERE user_id = $1 AND reward_id = $2 ${periodFilter}`,
        [userId, rewardId]
      );
      const timesRedeemed = parseInt(countRows[0].count, 10);
      if (timesRedeemed >= effectiveMax) {
        const periodLabel = effectivePeriod === 'monthly' ? ' este mes' : effectivePeriod === 'yearly' ? ' este año' : '';
        throw new Error(
          effectiveMax === 1
            ? `Ya has canjeado esta recompensa (límite: 1 por persona${periodLabel})`
            : `Ya has alcanzado el límite de ${effectiveMax} canjes${periodLabel} para esta recompensa`
        );
      }
    }

    const { rows: userRows } = await client.query<{ points_balance: number }>(
      `SELECT points_balance FROM users WHERE id = $1 FOR UPDATE`,
      [userId]
    );
    const user = userRows[0];
    if (!user) throw new Error('Usuario no encontrado');
    if (user.points_balance < reward.points_cost) {
      throw new Error(`Puntos insuficientes. Necesitas ${reward.points_cost}, tienes ${user.points_balance}`);
    }

    await client.query(
      `UPDATE users SET points_balance = points_balance - $1 WHERE id = $2`,
      [reward.points_cost, userId]
    );
    await client.query(
      `UPDATE rewards SET stock = stock - 1 WHERE id = $1`,
      [rewardId]
    );

    // Generate unique code (retry on collision)
    let code = generateCode();
    let inserted = false;
    for (let attempt = 0; attempt < 5; attempt++) {
      const existing = await client.query(
        `SELECT id FROM user_rewards WHERE redemption_code = $1`,
        [code]
      );
      if (existing.rows.length === 0) { inserted = true; break; }
      code = generateCode();
    }
    if (!inserted) throw new Error('No se pudo generar un código único');

    await client.query(
      `INSERT INTO user_rewards (user_id, reward_id, status, redemption_code) VALUES ($1, $2, 'pending', $3)`,
      [userId, rewardId, code]
    );

    await client.query('COMMIT');

    const points_remaining = user.points_balance - reward.points_cost;
    return {
      message: `✅ Canjeado: ${reward.title}`,
      points_remaining,
      redemption_code: code,
      reward_title: reward.title,
    };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

export async function getMyPoints(userId: string): Promise<{ points_balance: number }> {
  const { rows } = await pool.query<{ points_balance: number }>(
    `SELECT points_balance FROM users WHERE id = $1`,
    [userId]
  );
  return rows[0];
}

export async function listMyRedemptions(userId: string): Promise<Redemption[]> {
  const { rows } = await pool.query<Redemption>(
    `SELECT ur.id, ur.user_id, u.name AS user_name,
            ur.reward_id, r.title AS reward_title, r.points_cost,
            ur.redemption_code, ur.status, ur.claimed_at, ur.validated_at
     FROM user_rewards ur
     JOIN rewards r ON r.id = ur.reward_id
     JOIN users u   ON u.id = ur.user_id
     WHERE ur.user_id = $1
     ORDER BY ur.claimed_at DESC`,
    [userId]
  );
  return rows;
}

export async function listCompanyRedemptions(companyId: string): Promise<Redemption[]> {
  const { rows } = await pool.query<Redemption>(
    `SELECT ur.id, ur.user_id, u.name AS user_name,
            ur.reward_id, r.title AS reward_title, r.points_cost,
            ur.redemption_code, ur.status, ur.claimed_at, ur.validated_at
     FROM user_rewards ur
     JOIN rewards r ON r.id = ur.reward_id AND r.company_id = $1
     JOIN users u   ON u.id = ur.user_id
     ORDER BY ur.status ASC, ur.claimed_at DESC`,
    [companyId]
  );
  return rows;
}

// ── Funciones para la vista de empleado (company_admin) ──────────────────────

export async function getEmployeeRedemptions(
  userId: string,
  companyId: string
): Promise<EmployeeRedemption[]> {
  const { rows } = await pool.query<EmployeeRedemption>(
    `SELECT ur.id, ur.reward_id, r.title AS reward_title, r.points_cost,
            ur.redemption_code, ur.status, ur.claimed_at, ur.validated_at
     FROM user_rewards ur
     JOIN rewards r ON r.id = ur.reward_id AND r.company_id = $2
     JOIN users   u ON u.id = ur.user_id   AND u.company_id = $2
     WHERE ur.user_id = $1
     ORDER BY ur.claimed_at DESC`,
    [userId, companyId]
  );
  return rows;
}

export async function getEmployeeRewardLimits(
  userId: string,
  companyId: string
): Promise<EmployeeRewardLimit[]> {
  const { rows } = await pool.query<EmployeeRewardLimit>(
    `SELECT
       r.id                  AS reward_id,
       r.title               AS reward_title,
       r.max_per_user        AS default_max,
       r.redemption_period   AS default_period,
       el.max_per_user       AS override_max,
       el.redemption_period  AS override_period,
       COUNT(ur.id)::int     AS times_redeemed
     FROM rewards r
     LEFT JOIN reward_employee_limits el ON el.reward_id = r.id AND el.user_id = $1
     LEFT JOIN user_rewards ur           ON ur.reward_id = r.id AND ur.user_id = $1
     WHERE r.company_id = $2 AND r.is_active = true
     GROUP BY r.id, r.title, r.max_per_user, r.redemption_period, el.max_per_user, el.redemption_period
     ORDER BY r.points_cost ASC`,
    [userId, companyId]
  );
  return rows;
}

export async function upsertEmployeeLimit(
  rewardId: string,
  userId: string,
  companyId: string,
  max_per_user: number,
  redemption_period: RedemptionPeriod
): Promise<void> {
  // Verificar que la recompensa pertenece a la empresa
  const { rows } = await pool.query(
    `SELECT id FROM rewards WHERE id = $1 AND company_id = $2`,
    [rewardId, companyId]
  );
  if (rows.length === 0) throw new Error('Recompensa no encontrada');
  // Verificar que el empleado pertenece a la empresa
  const { rows: uRows } = await pool.query(
    `SELECT id FROM users WHERE id = $1 AND company_id = $2`,
    [userId, companyId]
  );
  if (uRows.length === 0) throw new Error('Empleado no encontrado');

  await pool.query(
    `INSERT INTO reward_employee_limits (reward_id, user_id, max_per_user, redemption_period)
     VALUES ($1, $2, $3, $4)
     ON CONFLICT (reward_id, user_id)
     DO UPDATE SET max_per_user = $3, redemption_period = $4`,
    [rewardId, userId, max_per_user, redemption_period]
  );
}

export async function deleteEmployeeLimit(
  rewardId: string,
  userId: string,
  companyId: string
): Promise<void> {
  await pool.query(
    `DELETE FROM reward_employee_limits rel
     USING rewards r, users u
     WHERE rel.reward_id = $1 AND rel.user_id = $2
       AND r.id = rel.reward_id AND r.company_id = $3
       AND u.id = rel.user_id  AND u.company_id = $3`,
    [rewardId, userId, companyId]
  );
}

export async function validateRedemption(
  redemptionId: string,
  companyId: string,
  validatedBy: string
): Promise<{ ok: boolean }> {
  const { rows } = await pool.query(
    `UPDATE user_rewards ur
     SET status = 'used', validated_at = NOW(), validated_by = $3
     FROM rewards r
     WHERE ur.id = $1
       AND ur.reward_id = r.id
       AND r.company_id = $2
       AND ur.status = 'pending'
     RETURNING ur.id`,
    [redemptionId, companyId, validatedBy]
  );
  if (rows.length === 0) throw new Error('Canje no encontrado o ya validado');
  return { ok: true };
}
