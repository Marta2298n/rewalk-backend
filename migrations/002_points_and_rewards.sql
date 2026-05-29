-- Migration 002: points balance on users + points_earned on activities

ALTER TABLE users ADD COLUMN IF NOT EXISTS points_balance INT NOT NULL DEFAULT 0;
ALTER TABLE activities ADD COLUMN IF NOT EXISTS points_earned INT NOT NULL DEFAULT 0;
