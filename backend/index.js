const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// DB connection pool
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'mood_tracker',
  password: process.env.DB_PASSWORD || 'postgres',
  port: parseInt(process.env.DB_PORT) || 5432,
});

// Auto-create tables on startup
const initDB = async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS moods (
        id SERIAL PRIMARY KEY,
        level INTEGER NOT NULL CHECK (level >= 1 AND level <= 5),
        note TEXT,
        ai_suggestion TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('Database tables ready.');
  } catch (err) {
    console.error('Failed to initialize database tables:', err.message);
    console.error('Make sure PostgreSQL is running and DB credentials in .env are correct.');
  }
};

// AI Suggestion Engine (rule-based, expandable to LLM)
const generateAiSuggestion = (note, level) => {
  const n = (note || '').toLowerCase();

  if (level === 5) {
    const tips = [
      "You're absolutely thriving today! Capture this energy — write down 3 things that made you feel amazing.",
      "Incredible mood! Share your positivity with someone who needs it today.",
      "You're at your best! This is a great time to tackle a goal you've been putting off.",
    ];
    return tips[Math.floor(Math.random() * tips.length)];
  }

  if (level === 4) {
    const tips = [
      "Great day! Keep the momentum going — a short evening walk can top it off perfectly.",
      "You're doing well! Consider journaling what went right today to reinforce these positive patterns.",
      "Happy to hear you're feeling good! Stay hydrated and keep that positive energy flowing.",
    ];
    return tips[Math.floor(Math.random() * tips.length)];
  }

  if (level === 3) {
    if (n.includes('tired') || n.includes('exhaust') || n.includes('sleep'))
      return "Fatigue can really flatten your mood. Try a 20-minute power nap or go to bed 30 minutes earlier tonight.";
    if (n.includes('bored'))
      return "Boredom is a signal to try something new. Pick up a book, call a friend, or take a short walk outside.";
    return "A neutral day is still a good day. A 10-minute mindfulness or breathing exercise can help shift your baseline upward.";
  }

  if (level === 2) {
    if (n.includes('stress') || n.includes('anxious') || n.includes('anxiety') || n.includes('overwhelm'))
      return "Anxiety is tough. Try box breathing: inhale 4s, hold 4s, exhale 4s, hold 4s. Repeat 4 times. It genuinely helps.";
    if (n.includes('work') || n.includes('boss') || n.includes('deadline'))
      return "Work pressure is draining. Step away from your screen for 5 minutes — a short break boosts focus and mood more than pushing through.";
    if (n.includes('lonely') || n.includes('alone') || n.includes('miss'))
      return "Loneliness is hard. Reach out to one person today — even a quick message can make a real difference for you both.";
    if (n.includes('sad') || n.includes('upset') || n.includes('cry'))
      return "It's okay to feel sad. Allow yourself to feel it without judgment. Consider talking to someone you trust about what's on your mind.";
    return "Tough day. Be kind to yourself — do one small thing you enjoy, whether it's music, food, or a short walk.";
  }

  if (level === 1) {
    if (n.includes('depress') || n.includes('hopeless') || n.includes('worthless'))
      return "I hear you, and your feelings are valid. Please consider reaching out to a mental health professional or a trusted person today. You deserve support.";
    if (n.includes('panic') || n.includes('attack'))
      return "If you're having a panic attack: ground yourself by naming 5 things you can see, 4 you can touch, 3 you can hear. You are safe.";
    return "It sounds like a really hard day. You don't have to face it alone — please reach out to someone you trust or a helpline if you need to talk.";
  }

  return "Remember to be kind to yourself today. Small steps forward still count as progress.";
};

// ─── ROUTES ──────────────────────────────────────────────

// Health check
app.get('/api/health', (req, res) => res.json({ status: 'ok' }));

// Get all moods
app.get('/api/moods', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM moods ORDER BY created_at DESC LIMIT 50');
    res.json(result.rows);
  } catch (err) {
    console.error('GET /api/moods error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Get mood stats
app.get('/api/moods/stats', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        COUNT(*) AS total,
        ROUND(AVG(level)::numeric, 1) AS avg_level,
        COUNT(CASE WHEN level >= 4 THEN 1 END) AS positive_count,
        COUNT(CASE WHEN level = 3 THEN 1 END) AS neutral_count,
        COUNT(CASE WHEN level <= 2 THEN 1 END) AS negative_count
      FROM moods
    `);
    res.json(result.rows[0]);
  } catch (err) {
    console.error('GET /api/moods/stats error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Add a new mood
app.post('/api/moods', async (req, res) => {
  const { level, note } = req.body;

  if (!level || level < 1 || level > 5) {
    return res.status(400).json({ error: 'Level must be between 1 and 5' });
  }

  try {
    const ai_suggestion = generateAiSuggestion(note, parseInt(level));
    const result = await pool.query(
      'INSERT INTO moods (level, note, ai_suggestion) VALUES ($1, $2, $3) RETURNING *',
      [level, note || null, ai_suggestion]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error('POST /api/moods error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Delete a mood
app.delete('/api/moods/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('DELETE FROM moods WHERE id = $1 RETURNING id', [id]);
    if (result.rowCount === 0) return res.status(404).json({ error: 'Mood not found' });
    res.json({ deleted: id });
  } catch (err) {
    console.error('DELETE /api/moods/:id error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────

initDB().then(() => {
  app.listen(port, () => {
    console.log(`✅ Server running on http://localhost:${port}`);
  });
});
