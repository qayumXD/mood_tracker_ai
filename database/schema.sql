-- schema.sql
-- Create users table (Optional: if we want multi-user support)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create moods table
CREATE TABLE IF NOT EXISTS moods (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL, -- optional
    level INTEGER NOT NULL CHECK (level >= 1 AND level <= 5),
    note TEXT,
    ai_suggestion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating a dummy user for our single-user test
INSERT INTO users (username, email) VALUES ('testuser', 'test@example.com') ON CONFLICT DO NOTHING;
