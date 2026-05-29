CREATE TYPE challenge_type AS ENUM ('activity', 'challenge');
CREATE TYPE challenge_status AS ENUM ('open', 'completed', 'cancelled');

CREATE TABLE challenges (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id      UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    creator_id      UUID NOT NULL REFERENCES users(id),
    title           TEXT NOT NULL,
    description     TEXT,
    type            challenge_type NOT NULL DEFAULT 'activity',
    status          challenge_status NOT NULL DEFAULT 'open',
    date            DATE,
    location        TEXT,
    max_participants INT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE challenge_participants (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    user_id      UUID NOT NULL REFERENCES users(id),
    joined_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(challenge_id, user_id)
);

CREATE INDEX idx_challenges_company ON challenges(company_id);
CREATE INDEX idx_challenge_participants_challenge ON challenge_participants(challenge_id);
CREATE INDEX idx_challenge_participants_user ON challenge_participants(user_id);
