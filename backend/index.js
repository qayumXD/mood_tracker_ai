const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');
const crypto = require('crypto');
require('dotenv').config();

// ─── Local LLM (Ollama) configuration ────────────────────────────────────────
const OLLAMA_URL = process.env.OLLAMA_URL || 'http://localhost:11434';
const OLLAMA_MODEL = process.env.OLLAMA_MODEL || 'gemma4:e2b';
// ─────────────────────────────────────────────────────────────────────────────

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

const schemaPath = path.join(__dirname, '..', 'database', 'schema.sql');
const schemaSql = fs.readFileSync(schemaPath, 'utf8');

const initDB = async () => {
  try {
    await pool.query(schemaSql);
    console.log('Database schema ready.');
  } catch (err) {
    console.error('Failed to initialize database:', err.message);
    throw err;
  }
};

// ─── Password Utilities ───────────────────────────────────────────────────────
const hashPassword = (password) => {
  return crypto.createHash('sha256').update(password).digest('hex');
};

const verifyPassword = (password, hash) => {
  return hashPassword(password) === hash;
};

// ─── Session/Token Management (Simple for demo) ──────────────────────────────
// In production, use JWT with proper signing
const sessions = new Map();

const generateToken = (userId) => {
  const token = crypto.randomBytes(32).toString('hex');
  sessions.set(token, { userId, createdAt: Date.now() });
  return token;
};

const verifyToken = (token) => {
  return sessions.get(token);
};

const authenticate = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  const session = verifyToken(token);
  if (!session) return res.status(401).json({ error: 'Invalid or expired token' });

  req.userId = session.userId;
  next();
};

// ─── AI Suggestion Engine ─────────────────────────────────────────────────────
const MOOD_LABELS = ['', 'Terrible', 'Sad', 'Okay', 'Good', 'Amazing'];

const ruleBasedFallback = (note, level) => {
  const n = (note || '').toLowerCase();

  if (level === 5) {
    const tips = [
      "You're absolutely thriving today — hold onto that feeling. Write down 3 things that made you feel this way so you can revisit them when you need a lift.",
      "This kind of joy is worth celebrating. Share your positive energy with someone who might need it today.",
      "You're genuinely at your best right now. This is a perfect moment to take on something meaningful you've been putting off.",
    ];
    return tips[Math.floor(Math.random() * tips.length)];
  }

  if (level === 4) {
    const tips = [
      "It's great that today is going well — you deserve it. A short evening walk can carry that good energy right into tomorrow.",
      "Good days like this are worth understanding. Consider noting what went right today to reinforce these patterns.",
      "Glad you're feeling good. Stay hydrated, rest well tonight, and let this momentum carry forward.",
    ];
    return tips[Math.floor(Math.random() * tips.length)];
  }

  if (level === 3) {
    const tired = n.includes('tired') || n.includes('exhaust') || n.includes('sleep');
    const bored = n.includes('bored') || n.includes('empty') || n.includes('numb');
    if (tired)
      return "Feeling drained is your body asking for rest. A 20-minute nap or an earlier bedtime can make tomorrow feel noticeably lighter.";
    if (bored)
      return "Boredom often points toward a need for novelty or connection. Try one small thing that's different today.";
    return "A neutral day is still a day you showed up — and that counts.";
  }

  if (level === 2) {
    const anxious = n.includes('stress') || n.includes('anxious') || n.includes('overwhelm');
    if (anxious)
      return "Anxiety is genuinely exhausting. Box breathing can help: inhale 4s, hold 4s, exhale 4s, hold 4s — repeat 4 times.";
    return "Tough days are real. Be kind to yourself today — do one small thing you enjoy.";
  }

  if (level === 1) {
    return "What you're feeling is real and matters. Please reach out to someone you trust, or contact 988 (Suicide & Crisis Lifeline, 24/7).";
  }

  return "Remember to be kind to yourself. Small steps forward still count as progress.";
};

const buildMoodTrend = (recentMoods) => {
  if (!recentMoods || recentMoods.length === 0)
    return 'No previous entries — this is their very first mood log.';
  const labels = recentMoods.slice(0, 5).map(m => MOOD_LABELS[m.level] || m.level).join(', ');
  const avg = (recentMoods.slice(0, 7).reduce((s, m) => s + m.level, 0) / Math.min(7, recentMoods.length)).toFixed(1);
  return `Recent moods (newest first): ${labels}. Average: ${avg}/5.`;
};

const getTimeOfDay = () => {
  const h = new Date().getHours();
  if (h >= 5 && h < 12) return 'morning';
  if (h >= 12 && h < 17) return 'afternoon';
  if (h >= 17 && h < 21) return 'evening';
  return 'night';
};

const requestOllamaWithFallback = async (messages, options = {}) => {
  const modelsToTry = [OLLAMA_MODEL, 'qwen2.5:0.5b', 'gemma2:2b'];
  let lastError = null;

  for (const model of modelsToTry) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 60000);

    try {
      console.log(`[LLM] Attempting request with model: ${model}`);
      const response = await fetch(`${OLLAMA_URL}/api/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model,
          messages,
          stream: false,
          options: { temperature: 0.75, num_predict: 1024, ...options },
        }),
        signal: controller.signal,
      });

      if (!response.ok) {
        const errData = await response.json().catch(() => ({}));
        throw new Error(errData.error || `HTTP ${response.status}`);
      }

      const data = await response.json();
      const text = (data?.message?.content || '').trim();
      if (text) {
        return { text, modelUsed: model };
      }
      throw new Error('Empty response');
    } catch (err) {
      console.warn(`[LLM] Model ${model} failed:`, err.message);
      lastError = err;
      if (err.name === 'AbortError') {
        // Keep checking next models even on timeout
      }
    } finally {
      clearTimeout(timeout);
    }
  }
  throw lastError || new Error('All Ollama models failed');
};

const callOllama = async (note, level, recentMoods) => {
  const moodLabel = MOOD_LABELS[level] || level;
  const noteText = note && note.trim() ? `"${note.trim()}"` : 'No note provided.';
  const trendText = buildMoodTrend(recentMoods);

  const systemPrompt = `You are a kind, emotionally intelligent friend. Validate → Normalize → Suggest → Reflect. 4-6 sentences max. Never clinical.`;
  const messages = [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: `Mood: ${moodLabel}\nNote: ${noteText}\nContext: ${trendText}` },
  ];

  const result = await requestOllamaWithFallback(messages);
  return result.text;
};

const generateAiSuggestion = async (note, level, recentMoods = []) => {
  try {
    const response = await callOllama(note, level, recentMoods);
    console.log(`[LLM] ${OLLAMA_MODEL} responded successfully.`);
    return response;
  } catch (err) {
    console.error('[LLM] Ollama error:', err.message);
    console.warn(`[LLM] Ollama unavailable — using fallback.`);
    return ruleBasedFallback(note, level);
  }
};

// ─── AUTHENTICATION ROUTES ────────────────────────────────────────────────────

// Register new user
app.post('/api/auth/register', async (req, res) => {
  const { email, password, full_name } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' });
  }

  try {
    const existingUser = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'Email already registered' });
    }

    const passwordHash = hashPassword(password);
    const result = await pool.query(
      'INSERT INTO users (email, password_hash, full_name) VALUES ($1, $2, $3) RETURNING id, email, full_name',
      [email, passwordHash, full_name || 'User']
    );

    const token = generateToken(result.rows[0].id);
    res.json({
      token,
      user: result.rows[0],
    });
  } catch (err) {
    console.error('POST /api/auth/register error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Login user
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' });
  }

  try {
    const result = await pool.query('SELECT id, email, full_name, password_hash FROM users WHERE email = $1', [email]);

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = result.rows[0];
    if (!verifyPassword(password, user.password_hash)) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = generateToken(user.id);
    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        full_name: user.full_name,
      },
    });
  } catch (err) {
    console.error('POST /api/auth/login error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Get current user
app.get('/api/auth/me', authenticate, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, email, full_name, avatar_url, theme_preference, created_at FROM users WHERE id = $1',
      [req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('GET /api/auth/me error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Update user profile
app.put('/api/auth/profile', authenticate, async (req, res) => {
  const { full_name, theme_preference } = req.body;

  try {
    const result = await pool.query(
      'UPDATE users SET full_name = COALESCE($1, full_name), theme_preference = COALESCE($2, theme_preference), updated_at = NOW() WHERE id = $3 RETURNING id, email, full_name, theme_preference',
      [full_name, theme_preference, req.userId]
    );

    res.json(result.rows[0]);
  } catch (err) {
    console.error('PUT /api/auth/profile error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ─── MOOD ROUTES ─────────────────────────────────────────────────────────────

// Get all moods for authenticated user
app.get('/api/moods', authenticate, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM moods WHERE user_id = $1 ORDER BY created_at DESC LIMIT 50',
      [req.userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('GET /api/moods error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Get mood stats for user
app.get('/api/moods/stats', authenticate, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        COUNT(*) AS total,
        ROUND(AVG(level)::numeric, 1) AS avg_level,
        COUNT(CASE WHEN level >= 4 THEN 1 END) AS positive_count,
        COUNT(CASE WHEN level = 3 THEN 1 END) AS neutral_count,
        COUNT(CASE WHEN level <= 2 THEN 1 END) AS negative_count
      FROM moods
      WHERE user_id = $1
    `, [req.userId]);
    res.json(result.rows[0] || {});
  } catch (err) {
    console.error('GET /api/moods/stats error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Add new mood
app.post('/api/moods', authenticate, async (req, res) => {
  const { level, note } = req.body;

  if (!level || level < 1 || level > 5) {
    return res.status(400).json({ error: 'Level must be between 1 and 5' });
  }

  try {
    const recent = await pool.query(
      'SELECT level FROM moods WHERE user_id = $1 ORDER BY created_at DESC LIMIT 7',
      [req.userId]
    );
    const ai_suggestion = await generateAiSuggestion(note, parseInt(level), recent.rows);
    const result = await pool.query(
      'INSERT INTO moods (user_id, level, note, ai_suggestion) VALUES ($1, $2, $3, $4) RETURNING *',
      [req.userId, level, note || null, ai_suggestion]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error('POST /api/moods error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Delete mood
app.delete('/api/moods/:id', authenticate, async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      'DELETE FROM moods WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, req.userId]
    );
    if (result.rowCount === 0) return res.status(404).json({ error: 'Mood not found' });
    res.json({ deleted: id });
  } catch (err) {
    console.error('DELETE /api/moods/:id error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ─── JOURNAL ROUTES ──────────────────────────────────────────────────────────

// Get all journals for user
app.get('/api/journals', authenticate, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM journals WHERE user_id = $1 AND is_private = false ORDER BY created_at DESC LIMIT 100',
      [req.userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('GET /api/journals error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Create new journal entry
app.post('/api/journals', authenticate, async (req, res) => {
  const { title, content, mood_level, tags, is_private } = req.body;

  if (!title || !content) {
    return res.status(400).json({ error: 'Title and content required' });
  }

  try {
    const result = await pool.query(
      'INSERT INTO journals (user_id, title, content, mood_level, tags, is_private) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [req.userId, title, content, mood_level || null, tags || [], is_private || false]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error('POST /api/journals error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Get single journal
app.get('/api/journals/:id', authenticate, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM journals WHERE id = $1 AND user_id = $2',
      [req.params.id, req.userId]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Journal not found' });
    res.json(result.rows[0]);
  } catch (err) {
    console.error('GET /api/journals/:id error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Update journal
app.put('/api/journals/:id', authenticate, async (req, res) => {
  const { title, content, mood_level, tags, is_private } = req.body;

  try {
    const result = await pool.query(
      'UPDATE journals SET title = COALESCE($1, title), content = COALESCE($2, content), mood_level = COALESCE($3, mood_level), tags = COALESCE($4, tags), is_private = COALESCE($5, is_private), updated_at = NOW() WHERE id = $6 AND user_id = $7 RETURNING *',
      [title, content, mood_level, tags, is_private, req.params.id, req.userId]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Journal not found' });
    res.json(result.rows[0]);
  } catch (err) {
    console.error('PUT /api/journals/:id error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Delete journal
app.delete('/api/journals/:id', authenticate, async (req, res) => {
  try {
    const result = await pool.query(
      'DELETE FROM journals WHERE id = $1 AND user_id = $2 RETURNING id',
      [req.params.id, req.userId]
    );
    if (result.rowCount === 0) return res.status(404).json({ error: 'Journal not found' });
    res.json({ deleted: req.params.id });
  } catch (err) {
    console.error('DELETE /api/journals/:id error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ─── AI ROUTES ───────────────────────────────────────────────────────────────

// AI chat
app.post('/api/ai/chat', authenticate, async (req, res) => {
  const { message } = req.body;
  if (!message || !message.trim()) return res.status(400).json({ error: 'Message required' });

  try {
    let reply = ruleBasedFallback(message, 3);
    let modelUsed = 'fallback';

    try {
      const messages = [
        { role: 'system', content: 'You are a supportive friend. Be warm, brief, and empathetic.' },
        { role: 'user', content: message },
      ];
      const result = await requestOllamaWithFallback(messages, { temperature: 0.8 });
      reply = result.text;
      modelUsed = result.modelUsed;
    } catch (err) {
      console.error('[LLM] Chat Ollama error:', err.message);
    }

    res.json({ reply, modelUsed });
  } catch (err) {
    console.error('POST /api/ai/chat error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// AI insight
app.post('/api/ai/insight', authenticate, async (req, res) => {
  const { mood, note } = req.body;
  if (!mood) return res.status(400).json({ error: 'Mood required' });

  const levelMap = { terrible: 1, sad: 2, okay: 3, good: 4, amazing: 5 };
  const level = levelMap[(mood || '').toLowerCase()] || 3;

  try {
    const recent = await pool.query('SELECT level FROM moods WHERE user_id = $1 ORDER BY created_at DESC LIMIT 7', [req.userId]);
    const insight = await generateAiSuggestion(note || '', level, recent.rows);
    res.json({ insight });
  } catch (err) {
    console.error('POST /api/ai/insight error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// AI sentiment
app.post('/api/ai/sentiment', authenticate, async (req, res) => {
  const { note } = req.body;
  if (!note || !note.trim()) return res.json({ mood: 'okay' });

  const n = note.toLowerCase();
  let mood = 'okay';
  if (/\b(depress|hopeless|terrible|awful|panic|crisis)\b/.test(n)) mood = 'terrible';
  else if (/\b(sad|upset|cry|lonely|anxious|stressed|overwhelm)\b/.test(n)) mood = 'sad';
  else if (/\b(good|great|happy|calm|content|better)\b/.test(n)) mood = 'good';
  else if (/\b(amazing|fantastic|thriving|wonderful|ecstatic)\b/.test(n)) mood = 'amazing';

  res.json({ mood });
});

// ─── ANALYTICS ───────────────────────────────────────────────────────────────

app.get('/api/analytics', authenticate, async (req, res) => {
  try {
    const overall = await pool.query(`
      SELECT
        COUNT(*) AS total,
        ROUND(AVG(level)::numeric, 2) AS avg_level,
        COUNT(CASE WHEN level >= 4 THEN 1 END) AS positive_count,
        COUNT(CASE WHEN level = 3 THEN 1 END) AS neutral_count,
        COUNT(CASE WHEN level <= 2 THEN 1 END) AS negative_count
      FROM moods
      WHERE user_id = $1
    `, [req.userId]);

    const weekly = await pool.query(`
      SELECT
        DATE_TRUNC('day', created_at)::DATE AS day,
        ROUND(AVG(level)::numeric, 2) AS avg_level,
        COUNT(*) AS count
      FROM moods
      WHERE user_id = $1 AND created_at >= NOW() - INTERVAL '7 days'
      GROUP BY day
      ORDER BY day ASC
    `, [req.userId]);

    res.json({
      ...overall.rows[0],
      weekly_trend: weekly.rows,
    });
  } catch (err) {
    console.error('GET /api/analytics error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ─── Health Check ────────────────────────────────────────────────────────────

app.get('/api/health', (req, res) => res.json({ status: 'ok' }));

// ─────────────────────────────────────────────────────────────────────────────

initDB().then(() => {
  app.listen(port, () => {
    console.log(`✅ Server running on http://localhost:${port}`);
    console.log(`📚 API Documentation:`);
    console.log(`   POST   /api/auth/register  — Register new user`);
    console.log(`   POST   /api/auth/login     — Login user`);
    console.log(`   GET    /api/auth/me        — Get current user`);
    console.log(`   GET    /api/moods          — Get moods`);
    console.log(`   POST   /api/moods          — Add mood`);
    console.log(`   GET    /api/journals       — Get journals`);
    console.log(`   POST   /api/journals       — Create journal`);
    console.log(`   GET    /api/analytics      — Get analytics`);
  });
});
