import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { fetchMoods, fetchMoodStats, fetchAnalytics } from '../services/api';
import { useAuth } from '../context/AuthContext';
import { TrendingUp, Smile, Frown, Meh, Activity, PlusCircle } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';

const MOOD_EMOJIS = { 1: '😰', 2: '😢', 3: '😐', 4: '😊', 5: '🤩' };
const MOOD_LABELS = { 1: 'Terrible', 2: 'Sad', 3: 'Okay', 4: 'Good', 5: 'Amazing' };
const MOOD_COLORS = { 1: 'var(--mood-1)', 2: 'var(--mood-2)', 3: 'var(--mood-3)', 4: 'var(--mood-4)', 5: 'var(--mood-5)' };

export default function DashboardPage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [moods, setMoods] = useState([]);
  const [stats, setStats] = useState(null);
  const [analytics, setAnalytics] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      try {
        const [m, s, a] = await Promise.all([fetchMoods(), fetchMoodStats(), fetchAnalytics()]);
        setMoods(m);
        setStats(s);
        setAnalytics(a);
      } catch {
        /* handled by empty states */
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  if (loading) {
    return (
      <div className="loading-page">
        <div className="spinner spinner-dark" style={{ width: 32, height: 32 }} />
        <span>Loading dashboard...</span>
      </div>
    );
  }

  const recentMoods = moods.slice(0, 5);
  const chartData = (analytics?.weekly_trend || []).map((d) => ({
    day: new Date(d.day).toLocaleDateString('en-US', { weekday: 'short' }),
    level: parseFloat(d.avg_level),
  }));

  const greeting = () => {
    const h = new Date().getHours();
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  };

  return (
    <>
      {/* Hero greeting */}
      <div style={{
        background: 'var(--gradient-hero)',
        borderRadius: 'var(--radius-xl)',
        padding: '36px 40px',
        color: 'white',
        marginBottom: 32,
        position: 'relative',
        overflow: 'hidden',
      }}>
        <div style={{ position: 'absolute', top: -40, right: -40, width: 200, height: 200, borderRadius: '50%', background: 'rgba(255,255,255,0.08)' }} />
        <div style={{ position: 'absolute', bottom: -60, right: 80, width: 140, height: 140, borderRadius: '50%', background: 'rgba(255,255,255,0.05)' }} />
        <div style={{ position: 'relative', zIndex: 1 }}>
          <h1 style={{ fontSize: 28, fontWeight: 800, marginBottom: 4 }}>
            {greeting()}, {user?.full_name || 'there'} 👋
          </h1>
          <p style={{ opacity: 0.85, fontSize: 15 }}>
            Here's your emotional wellness overview
          </p>
          <button
            className="btn"
            onClick={() => navigate('/log')}
            style={{ marginTop: 20, background: 'rgba(255,255,255,0.2)', backdropFilter: 'blur(8px)', color: 'white', border: '1px solid rgba(255,255,255,0.3)' }}
          >
            <PlusCircle size={18} />
            Log Your Mood
          </button>
        </div>
      </div>

      {/* Stats */}
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-icon" style={{ background: 'rgba(124,58,237,0.1)' }}>
            <Activity size={24} color="var(--primary)" />
          </div>
          <div>
            <div className="stat-value">{stats?.total || 0}</div>
            <div className="stat-label">Total Entries</div>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: 'rgba(34,197,94,0.1)' }}>
            <TrendingUp size={24} color="var(--mood-4)" />
          </div>
          <div>
            <div className="stat-value">{stats?.avg_level ? parseFloat(stats.avg_level).toFixed(1) : '—'}</div>
            <div className="stat-label">Avg Mood Level</div>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: 'rgba(6,182,212,0.1)' }}>
            <Smile size={24} color="var(--mood-5)" />
          </div>
          <div>
            <div className="stat-value">{stats?.positive_count || 0}</div>
            <div className="stat-label">Positive Days</div>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: 'rgba(239,68,68,0.1)' }}>
            <Frown size={24} color="var(--mood-1)" />
          </div>
          <div>
            <div className="stat-value">{stats?.negative_count || 0}</div>
            <div className="stat-label">Tough Days</div>
          </div>
        </div>
      </div>

      {/* Chart + Recent Activity */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr', gap: 24, marginBottom: 32 }}>
        {/* Weekly Trend Chart */}
        <div className="card">
          <div className="card-header">
            <div>
              <div className="card-title">Weekly Mood Trend</div>
              <div className="card-subtitle">Your mood levels over the past 7 days</div>
            </div>
          </div>
          {chartData.length > 0 ? (
            <ResponsiveContainer width="100%" height={220}>
              <AreaChart data={chartData}>
                <defs>
                  <linearGradient id="moodGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="var(--primary)" stopOpacity={0.3} />
                    <stop offset="100%" stopColor="var(--primary)" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fill: '#9ca3af', fontSize: 12 }} />
                <YAxis domain={[1, 5]} axisLine={false} tickLine={false} tick={{ fill: '#9ca3af', fontSize: 12 }} />
                <Tooltip
                  contentStyle={{ borderRadius: 12, border: '1px solid var(--border)', boxShadow: 'var(--shadow-md)' }}
                  formatter={(value) => [value.toFixed(1), 'Avg Mood']}
                />
                <Area
                  type="monotone"
                  dataKey="level"
                  stroke="var(--primary)"
                  strokeWidth={2.5}
                  fill="url(#moodGradient)"
                  dot={{ fill: 'var(--primary)', r: 4 }}
                  activeDot={{ r: 6 }}
                />
              </AreaChart>
            </ResponsiveContainer>
          ) : (
            <div className="empty-state" style={{ padding: 32 }}>
              <p>Log moods to see your weekly trend</p>
            </div>
          )}
        </div>

        {/* Recent Activity */}
        <div className="card">
          <div className="card-header">
            <div>
              <div className="card-title">Recent Activity</div>
              <div className="card-subtitle">Your latest mood entries</div>
            </div>
          </div>
          {recentMoods.length > 0 ? (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              {recentMoods.map((mood) => (
                <div key={mood.id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '10px 0', borderBottom: '1px solid var(--border-light)' }}>
                  <span style={{ fontSize: 24 }}>{MOOD_EMOJIS[mood.level] || '😐'}</span>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontWeight: 600, fontSize: 14, color: MOOD_COLORS[mood.level] }}>
                      {MOOD_LABELS[mood.level]}
                    </div>
                    {mood.note && (
                      <div style={{ fontSize: 12, color: 'var(--text-tertiary)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', maxWidth: 200 }}>
                        {mood.note}
                      </div>
                    )}
                  </div>
                  <span style={{ fontSize: 11, color: 'var(--text-tertiary)' }}>
                    {new Date(mood.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                  </span>
                </div>
              ))}
            </div>
          ) : (
            <div className="empty-state" style={{ padding: 32 }}>
              <p>No mood entries yet</p>
            </div>
          )}
        </div>
      </div>
    </>
  );
}
