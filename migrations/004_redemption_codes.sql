-- Migration 004: add redemption codes and validation tracking to user_rewards

ALTER TABLE user_rewards
  ADD COLUMN redemption_code TEXT UNIQUE,
  ADD COLUMN validated_at    TIMESTAMPTZ,
  ADD COLUMN validated_by    UUID REFERENCES users(id);

-- Backfill existing rows so NOT NULL constraint can be applied
UPDATE user_rewards
SET redemption_code = 'ECO-' || UPPER(SUBSTRING(REPLACE(gen_random_uuid()::text, '-', ''), 1, 6))
WHERE redemption_code IS NULL;

ALTER TABLE user_rewards ALTER COLUMN redemption_code SET NOT NULL;

CREATE INDEX idx_user_rewards_code ON user_rewards(redemption_code);
