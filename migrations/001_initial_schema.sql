-- ============================================================
-- Eco-Wellness Corporate Platform — Initial Schema
-- PostgreSQL Migration 001
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ENUM types
CREATE TYPE subscription_status AS ENUM ('trial', 'active', 'suspended', 'cancelled');
CREATE TYPE user_role AS ENUM ('superadmin', 'company_admin', 'employee');
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'pending');
CREATE TYPE activity_type AS ENUM ('walk', 'run', 'cycle');
CREATE TYPE reward_claim_status AS ENUM ('pending', 'redeemed');

-- ============================================================
-- companies
-- ============================================================
CREATE TABLE companies (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(255) NOT NULL,
    tax_id          VARCHAR(20)  NOT NULL UNIQUE,   -- CIF/NIF
    subscription_status subscription_status NOT NULL DEFAULT 'trial',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- users
-- ============================================================
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id      UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name            VARCHAR(255) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    password_hash   TEXT NOT NULL,
    role            user_role NOT NULL DEFAULT 'employee',
    status          user_status NOT NULL DEFAULT 'active',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_company_id ON users(company_id);
CREATE INDEX idx_users_email ON users(email);

-- ============================================================
-- activities
-- ============================================================
CREATE TABLE activities (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_type       activity_type NOT NULL,
    distance_km         DECIMAL(8, 3) NOT NULL CHECK (distance_km > 0),
    duration_seconds    INT NOT NULL CHECK (duration_seconds > 0),
    calories_burned     INT NOT NULL DEFAULT 0,
    co2_avoided_kg      DECIMAL(8, 4) NOT NULL DEFAULT 0,
    start_time          TIMESTAMPTZ NOT NULL,
    end_time            TIMESTAMPTZ NOT NULL,
    is_validated        BOOLEAN NOT NULL DEFAULT true,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT end_after_start CHECK (end_time > start_time)
);

CREATE INDEX idx_activities_user_id ON activities(user_id);
CREATE INDEX idx_activities_start_time ON activities(start_time);

-- ============================================================
-- rewards
-- ============================================================
CREATE TABLE rewards (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id      UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    points_cost     INT NOT NULL CHECK (points_cost > 0),
    stock           INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rewards_company_id ON rewards(company_id);

-- ============================================================
-- user_rewards  (redemption log)
-- ============================================================
CREATE TABLE user_rewards (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reward_id   UUID NOT NULL REFERENCES rewards(id) ON DELETE CASCADE,
    status      reward_claim_status NOT NULL DEFAULT 'pending',
    claimed_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_rewards_user_id ON user_rewards(user_id);
CREATE INDEX idx_user_rewards_reward_id ON user_rewards(reward_id);

-- ============================================================
-- Seed: superadmin company + user (change password in prod!)
-- ============================================================
INSERT INTO companies (id, name, tax_id, subscription_status)
VALUES ('00000000-0000-0000-0000-000000000001', 'Platform Admin', 'PLATFORM-ADMIN', 'active');

-- Password: 'superadmin123' — CHANGE BEFORE DEPLOYING
INSERT INTO users (company_id, name, email, password_hash, role)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'Super Admin',
    'admin@rewalk.es',
    '$2b$10$placeholder_hash_change_me',
    'superadmin'
);
