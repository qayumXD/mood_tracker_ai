-- AI Mood Tracker database schema.
-- Safe to re-run: it both creates fresh tables and upgrades older minimal ones.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           TEXT UNIQUE NOT NULL,
    password_hash   TEXT NOT NULL,
    full_name       VARCHAR(255),
    avatar_url      TEXT,
    theme_preference VARCHAR(10) DEFAULT 'system', -- 'light', 'dark', 'system'
    created_at      TIMESTAMP DEFAULT NOW(),
    updated_at      TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS moods (
    id            SERIAL PRIMARY KEY,
    user_id       UUID REFERENCES users(id) ON DELETE SET NULL,
    level         INTEGER NOT NULL CHECK (level >= 1 AND level <= 5),
    mood          VARCHAR(20) GENERATED ALWAYS AS (
                    CASE level
                      WHEN 1 THEN 'terrible'
                      WHEN 2 THEN 'sad'
                      WHEN 3 THEN 'okay'
                      WHEN 4 THEN 'good'
                      WHEN 5 THEN 'amazing'
                    END
                  ) STORED,
    note          TEXT,
    ai_suggestion TEXT,
    tags          TEXT[],
    created_at    TIMESTAMP DEFAULT NOW()
);

ALTER TABLE moods
    ADD COLUMN IF NOT EXISTS user_id UUID,
    ADD COLUMN IF NOT EXISTS note TEXT,
    ADD COLUMN IF NOT EXISTS ai_suggestion TEXT,
    ADD COLUMN IF NOT EXISTS tags TEXT[],
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();

ALTER TABLE moods
    ALTER COLUMN level SET NOT NULL,
    ALTER COLUMN created_at SET DEFAULT NOW();

UPDATE moods
SET created_at = NOW()
WHERE created_at IS NULL;

ALTER TABLE moods
    ADD COLUMN IF NOT EXISTS mood VARCHAR(20) GENERATED ALWAYS AS (
        CASE level
          WHEN 1 THEN 'terrible'
          WHEN 2 THEN 'sad'
          WHEN 3 THEN 'okay'
          WHEN 4 THEN 'good'
          WHEN 5 THEN 'amazing'
        END
    ) STORED;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'moods_level_check'
          AND conrelid = 'moods'::regclass
    ) THEN
        ALTER TABLE moods
            ADD CONSTRAINT moods_level_check
            CHECK (level >= 1 AND level <= 5);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'moods_user_id_fkey'
          AND conrelid = 'moods'::regclass
    ) THEN
        ALTER TABLE moods
            ADD CONSTRAINT moods_user_id_fkey
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_moods_user_id ON moods (user_id);
CREATE INDEX IF NOT EXISTS idx_moods_created_at ON moods (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_moods_level ON moods (level);

-- Journals table for detailed reflections
CREATE TABLE IF NOT EXISTS journals (
    id              SERIAL PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title           VARCHAR(255) NOT NULL,
    content         TEXT NOT NULL,
    mood_level      INTEGER CHECK (mood_level >= 1 AND mood_level <= 5),
    tags            TEXT[],
    is_private      BOOLEAN DEFAULT false,
    created_at      TIMESTAMP DEFAULT NOW(),
    updated_at      TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_journals_user_id ON journals (user_id);
CREATE INDEX IF NOT EXISTS idx_journals_created_at ON journals (created_at DESC);

CREATE OR REPLACE FUNCTION weekly_avg_mood(p_user_id UUID DEFAULT NULL)
RETURNS NUMERIC AS $$
  SELECT ROUND(AVG(level)::numeric, 2)
  FROM moods
  WHERE created_at >= NOW() - INTERVAL '7 days'
    AND (p_user_id IS NULL OR user_id = p_user_id);
$$ LANGUAGE sql STABLE;
