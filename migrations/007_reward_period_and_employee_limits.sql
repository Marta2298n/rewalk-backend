-- Migration 007: período de límite + overrides por empleado
-- redemption_period: 'none' = acumulado total, 'monthly' = mensual, 'yearly' = anual

ALTER TABLE rewards
  ADD COLUMN IF NOT EXISTS redemption_period VARCHAR(20) NOT NULL DEFAULT 'none';

CREATE TABLE IF NOT EXISTS reward_employee_limits (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reward_id        UUID        NOT NULL REFERENCES rewards(id) ON DELETE CASCADE,
  user_id          UUID        NOT NULL REFERENCES users(id)   ON DELETE CASCADE,
  max_per_user     INTEGER     NOT NULL CHECK (max_per_user > 0),
  redemption_period VARCHAR(20) NOT NULL DEFAULT 'none',
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (reward_id, user_id)
);
