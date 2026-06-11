import { useState, useEffect } from 'react';
import { fetchMoods, deleteMood } from '../services/api';
import toast from 'react-hot-toast';
import { Trash2, Sparkles } from 'lucide-react';

const MOOD_EMOJIS = { 1: '😰', 2: '😢', 3: '😐', 4: '😊', 5: '🤩' };
const MOOD_LABELS = { 1: 'Terrible', 2: 'Sad', 3: 'Okay', 4: 'Good', 5: 'Amazing' };
const MOOD_COLORS = { 1: 'var(--mood-1)', 2: 'var(--mood-2)', 3: 'var(--mood-3)', 4: 'var(--mood-4)', 5: 'var(--mood-5)' };
const MOOD_BGS = { 1: 'rgba(239,68,68,0.08)', 2: 'rgba(249,115,22,0.08)', 3: 'rgba(234,179,8,0.08)', 4: 'rgba(34,197,94,0.08)', 5: 'rgba(6,182,212,0.08)' };

export default function HistoryPage() {
  const [moods, setMoods] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadMoods();
  }, []);

  async function loadMoods() {
    try {
      const data = await fetchMoods();
      setMoods(data);
    } catch {
      toast.error('Failed to load mood history');
    } finally {
      setLoading(false);
    }
  }

  async function handleDelete(id) {
    if (!confirm('Delete this mood entry?')) return;
    try {
      await deleteMood(id);
      setMoods((prev) => prev.filter((m) => m.id !== id));
      toast.success('Mood deleted');
    } catch {
      toast.error('Failed to delete');
    }
  }

  if (loading) {
    return (
      <div className="loading-page">
        <div className="spinner spinner-dark" style={{ width: 32, height: 32 }} />
      </div>
    );
  }

  return (
    <>
      <div className="page-header">
        <h1>Mood History 📋</h1>
        <p>{moods.length} total entries</p>
      </div>

      {moods.length === 0 ? (
        <div className="empty-state">
          <div className="empty-icon">📝</div>
          <h3>No mood entries yet</h3>
          <p>Start logging your moods to see your history here</p>
        </div>
      ) : (
        <div className="mood-list">
          {moods.map((mood) => (
            <div className="mood-item" key={mood.id}>
              <div className="mood-emoji" style={{ background: MOOD_BGS[mood.level] }}>
                {MOOD_EMOJIS[mood.level]}
              </div>
              <div className="mood-details">
                <div className="mood-header">
                  <span className="mood-label" style={{ color: MOOD_COLORS[mood.level] }}>
                    {MOOD_LABELS[mood.level]}
                  </span>
                  <span className="mood-date">
                    {new Date(mood.created_at).toLocaleDateString('en-US', {
                      month: 'short',
                      day: 'numeric',
                      hour: 'numeric',
                      minute: '2-digit',
                    })}
                  </span>
                </div>
                {mood.note && <p className="mood-note">{mood.note}</p>}
                {mood.ai_suggestion && (
                  <div className="ai-insight">
                    <div className="ai-label">
                      <Sparkles size={12} style={{ marginRight: 4, verticalAlign: 'middle' }} />
                      AI Insight
                    </div>
                    <p className="ai-text">{mood.ai_suggestion}</p>
                  </div>
                )}
              </div>
              <button className="btn btn-icon btn-ghost" onClick={() => handleDelete(mood.id)} title="Delete">
                <Trash2 size={16} color="var(--mood-1)" />
              </button>
            </div>
          ))}
        </div>
      )}
    </>
  );
}
