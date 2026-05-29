-- Migration 006: límite de canjes por persona en recompensas
-- max_per_user = NULL → sin límite
-- max_per_user = 1   → máximo 1 canje por persona (default)

ALTER TABLE rewards
  ADD COLUMN IF NOT EXISTS max_per_user INT DEFAULT 1;
