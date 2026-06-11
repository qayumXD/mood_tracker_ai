import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { logMood } from '../services/api';
import toast from 'react-hot-toast';
import { Sparkles } from 'lucide-react';

const MOODS = [
  { level: 1, emoji: '😰', label: 'Terrible', color: 'var(--mood-1)' },
  { level: 2, emoji: '😢', label: 'Sad', color: 'var(--mood-2)' },
  { level: 3, emoji: '😐', label: 'Okay', color: 'var(--mood-3)' },
  { level: 4, emoji: '😊', label: 'Good', color: 'var(--mood-4)' },
  { level: 5, emoji: '🤩', label: 'Amazing', color: 'var(--mood-5)' },
];

export default function LogMoodPage() {
  const [selected, setSelected] = useState(3);
  const [note, setNote] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const navigate = useNavigate();

  const handleSubmit = async () => {
    setLoading(true);
    try {
      const data = await logMood(selected, note);
      setResult(data);
      toast.success('Mood logged successfully!');
    } catch (err) {
      toast.error(err.message || 'Failed to log mood');
    } finally {
      setLoading(false);
    }
  };

  const handleLogAnother = () => {
    setResult(null);
    setSelected(3);
    setNote('');
  };

  if (result) {
    return (
      <>
        <div className="page-header">
          <h1>Mood Logged ✨</h1>
          <p>Your mood has been recorded and analyzed by AI</p>
        </div>
        <div className="card" style={{ maxWidth: 600 }}>
          <div style={{ textAlign: 'center', marginBottom: 24 }}>
            <span style={{ fontSize: 64 }}>{MOODS.find((m) => m.level === result.level)?.emoji}</span>
            <h2 style={{ marginTop: 8 }}>{MOODS.find((m) => m.level === result.level)?.label}</h2>
            {result.note && <p style={{ color: 'var(--text-secondary)', marginTop: 8 }}>"{result.note}"</p>}
          </div>

          {result.ai_suggestion && (
            <div className="ai-insight" style={{
              padding: 20,
              background: 'linear-gradient(135deg, rgba(124,58,237,0.06), rgba(244,114,182,0.06))',
              borderRadius: 'var(--radius-md)',
              borderLeft: '3px solid var(--primary)',
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
                <Sparkles size={16} color="var(--primary)" />
                <span style={{ fontSize: 11, fontWeight: 700, color: 'var(--primary)', letterSpacing: '0.1em', textTransform: 'uppercase' }}>
                  AI Insight
                </span>
              </div>
              <p style={{ fontSize: 14, lineHeight: 1.7, color: 'var(--text-primary)' }}>
                {result.ai_suggestion}
              </p>
            </div>
          )}

          <div style={{ display: 'flex', gap: 12, marginTop: 24 }}>
            <button className="btn btn-primary" onClick={handleLogAnother} style={{ flex: 1 }}>
              Log Another
            </button>
            <button className="btn btn-secondary" onClick={() => navigate('/history')} style={{ flex: 1 }}>
              View History
            </button>
          </div>
        </div>
      </>
    );
  }

  return (
    <>
      <div className="page-header">
        <h1>How are you feeling? 🌱</h1>
        <p>Select your mood and optionally add a note for personalized AI insights</p>
      </div>

      <div className="card" style={{ maxWidth: 600 }}>
        <div className="mood-selector" style={{ marginBottom: 24 }}>
          {MOODS.map((mood) => (
            <button
              key={mood.level}
              className={`mood-btn ${selected === mood.level ? 'selected' : ''}`}
              onClick={() => setSelected(mood.level)}
            >
              <span className="emoji">{mood.emoji}</span>
              <span className="label">{mood.label}</span>
            </button>
          ))}
        </div>

        <div className="form-group">
          <label>What's on your mind? (optional)</label>
          <textarea
            className="form-input"
            placeholder="Share your thoughts, feelings, or what happened today..."
            value={note}
            onChange={(e) => setNote(e.target.value)}
            rows={4}
          />
        </div>

        <button className="btn btn-primary btn-full" onClick={handleSubmit} disabled={loading}>
          {loading ? (
            <>
              <span className="spinner" />
              Analyzing with AI...
            </>
          ) : (
            <>
              <Sparkles size={18} />
              Log Mood & Get AI Insight
            </>
          )}
        </button>
      </div>
    </>
  );
}
