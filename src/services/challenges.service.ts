import { pool } from '../config/database';

export interface Challenge {
  id: string;
  company_id: string;
  creator_id: string;
  creator_name: string;
  creator_role: string;
  title: string;
  description: string | null;
  type: 'activity' | 'challenge';
  status: 'open' | 'completed' | 'cancelled';
  date: string | null;
  location: string | null;
  max_participants: number | null;
  participant_count: number;
  is_joined: boolean;
  created_at: string;
}

export interface CreateChallengeDto {
  title: string;
  description?: string;
  type: 'activity' | 'challenge';
  date?: string;
  location?: string;
  max_participants?: number;
}

export async function listChallenges(companyId: string, userId: string): Promise<Challenge[]> {
  const { rows } = await pool.query<Challenge>(
    `SELECT
       ch.id, ch.company_id, ch.creator_id,
       u.name AS creator_name, u.role AS creator_role,
       ch.title, ch.description, ch.type, ch.status,
       ch.date::text, ch.location, ch.max_participants,
       COUNT(cp.id)::INT AS participant_count,
       COALESCE(BOOL_OR(cp.user_id = $2), false) AS is_joined,
       ch.created_at
     FROM challenges ch
     JOIN users u ON u.id = ch.creator_id
     LEFT JOIN challenge_participants cp ON cp.challenge_id = ch.id
     WHERE ch.company_id = $1
     GROUP BY ch.id, u.name, u.role
     ORDER BY
       CASE ch.status WHEN 'open' THEN 0 ELSE 1 END,
       ch.date ASC NULLS LAST,
       ch.created_at DESC`,
    [companyId, userId]
  );
  return rows;
}

export async function createChallenge(
  companyId: string,
  creatorId: string,
  dto: CreateChallengeDto
): Promise<Challenge> {
  const { title, description, type, date, location, max_participants } = dto;
  const { rows } = await pool.query(
    `INSERT INTO challenges (company_id, creator_id, title, description, type, date, location, max_participants)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
     RETURNING id`,
    [companyId, creatorId, title, description || null, type, date || null, location || null, max_participants || null]
  );
  const [challenge] = await listChallenges(companyId, creatorId);
  const full = (await pool.query<Challenge>(
    `SELECT ch.id, ch.company_id, ch.creator_id,
            u.name AS creator_name, u.role AS creator_role,
            ch.title, ch.description, ch.type, ch.status,
            ch.date::text, ch.location, ch.max_participants,
            0::INT AS participant_count, false AS is_joined, ch.created_at
     FROM challenges ch JOIN users u ON u.id = ch.creator_id
     WHERE ch.id = $1`,
    [rows[0].id]
  ));
  return full.rows[0];
}

export async function joinChallenge(challengeId: string, userId: string, companyId: string): Promise<void> {
  const { rows } = await pool.query(
    `SELECT ch.id, ch.max_participants, COUNT(cp.id)::INT AS count
     FROM challenges ch
     LEFT JOIN challenge_participants cp ON cp.challenge_id = ch.id
     WHERE ch.id = $1 AND ch.company_id = $2 AND ch.status = 'open'
     GROUP BY ch.id`,
    [challengeId, companyId]
  );
  if (!rows[0]) throw new Error('Reto no encontrado o cerrado');
  if (rows[0].max_participants && rows[0].count >= rows[0].max_participants) {
    throw new Error('El aforo está completo');
  }
  await pool.query(
    `INSERT INTO challenge_participants (challenge_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
    [challengeId, userId]
  );
}

export async function leaveChallenge(challengeId: string, userId: string): Promise<void> {
  await pool.query(
    `DELETE FROM challenge_participants WHERE challenge_id = $1 AND user_id = $2`,
    [challengeId, userId]
  );
}

export async function updateChallengeStatus(
  challengeId: string,
  companyId: string,
  status: 'completed' | 'cancelled'
): Promise<void> {
  const { rows } = await pool.query(
    `UPDATE challenges SET status = $1 WHERE id = $2 AND company_id = $3 RETURNING id`,
    [status, challengeId, companyId]
  );
  if (!rows[0]) throw new Error('Reto no encontrado');
}

export async function deleteChallenge(challengeId: string, userId: string): Promise<void> {
  const { rows } = await pool.query(
    `DELETE FROM challenges WHERE id = $1 AND creator_id = $2 RETURNING id`,
    [challengeId, userId]
  );
  if (!rows[0]) throw new Error('No puedes eliminar este reto');
}
