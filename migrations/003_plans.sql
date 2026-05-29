-- Migration 003: subscription plans

CREATE TYPE company_plan AS ENUM ('trial', 'basic', 'premium', 'total', 'completo');

ALTER TABLE companies ADD COLUMN IF NOT EXISTS plan company_plan NOT NULL DEFAULT 'trial';

-- Trial expires 10 days after company creation
ALTER TABLE companies ADD COLUMN IF NOT EXISTS trial_ends_at TIMESTAMPTZ;
UPDATE companies SET trial_ends_at = created_at + INTERVAL '10 days' WHERE plan = 'trial';
