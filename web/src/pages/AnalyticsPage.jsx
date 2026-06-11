import { useState, useEffect } from 'react';
import { fetchAnalytics } from '../services/api';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';
import { TrendingUp, Smile, Meh, Frown } from 'lucide-react';
import toast from 'react-hot-toast';

const PIE_COLORS = ['var(--mood-4)', 'var(--mood-3)', 'var(--mood-1)'];

export default function AnalyticsPage() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      try {
        const d = await fetchAnalytics();
        setData(d);
      } catch {
        toast.error('Failed to load analytics');
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
      </div>
    );
  }

  if (!data || parseInt(data.total) === 0) {
    return (
      <>
        <div className="page-header">
          <h1>Analytics 📊</h1>
          <p>Insights into your emotional patterns</p>
        </div>
        <div className="empty-state">
          <div className="empty-icon">📊</div>
          <h3>No data yet</h3>
          <p>Start logging moods to see your analytics</p>
        </div>
      </>
    );
  }

  const weeklyData = (data.weekly_trend || []).map((d) => ({
    day: new Date(d.day).toLocaleDateString('en-US', { weekday: 'short' }),
    level: parseFloat(d.avg_level),
    count: parseInt(d.count),
  }));

  const pieData = [
    { name: 'Positive', value: parseInt(data.positive_count) || 0 },
    { name: 'Neutral', value: parseInt(data.neutral_count) || 0 },
    { name: 'Negative', value: parseInt(data.negative_count) || 0 },
  ].filter((d) => d.value > 0);

  return (
    <>
      <div className="page-header">
        <h1>Analytics 📊</h1>
        <p>Insights into your emotional patterns</p>
      </div>

      {/* Summary Stats */}
      <div className="stats-grid" style={{ marginBottom: 32 }}>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: 'rgba(124,58,237,0.1)' }}>
            <TrendingUp size={24} color="var(--primary)" />
          </div>
          <div>
            <div className="stat-value">{parseFloat(data.avg_level).toFixed(1)}</div>
            <div className="stat-label">Average Mood</div>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: 'rgba(34,197,94,0.1)' }}>
            <Smile size={24} color="var(--mood-4)" />
          </div>
          <div>
            <div className="stat-value">{data.positive_count}</div>
            <div className="stat-label">Positive Entries</div>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: 'rgba(234,179,8,0.1)' }}>
            <Meh size={24} color="var(--mood-3)" />
          </div>
          <div>
            <div className="stat-value">{data.neutral_count}</div>
            <div className="stat-label">Neutral Entries</div>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: 'rgba(239,68,68,0.1)' }}>
            <Frown size={24} color="var(--mood-1)" />
          </div>
          <div>
            <div className="stat-value">{data.negative_count}</div>
            <div className="stat-label">Tough Days</div>
          </div>
        </div>
      </div>

      {/* Charts */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr', gap: 24 }}>
        {/* Weekly Bar Chart */}
        <div className="card">
          <div className="card-header">
            <div>
              <div className="card-title">Weekly Breakdown</div>
              <div className="card-subtitle">Average mood per day this week</div>
            </div>
          </div>
          {weeklyData.length > 0 ? (
            <ResponsiveContainer width="100%" height={260}>
              <BarChart data={weeklyData}>
                <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fill: '#9ca3af', fontSize: 12 }} />
                <YAxis domain={[0, 5]} axisLine={false} tickLine={false} tick={{ fill: '#9ca3af', fontSize: 12 }} />
                <Tooltip
                  contentStyle={{ borderRadius: 12, border: '1px solid var(--border)', boxShadow: 'var(--shadow-md)' }}
                  formatter={(value, name) => [name === 'level' ? value.toFixed(1) : value, name === 'level' ? 'Avg Mood' : 'Entries']}
                />
                <Bar dataKey="level" fill="var(--primary)" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="empty-state" style={{ padding: 32 }}>
              <p>No data for this week</p>
            </div>
          )}
        </div>

        {/* Pie Chart */}
        <div className="card">
          <div className="card-header">
            <div>
              <div className="card-title">Mood Distribution</div>
              <div className="card-subtitle">Overall breakdown of your entries</div>
            </div>
          </div>
          {pieData.length > 0 ? (
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
              <ResponsiveContainer width="100%" height={220}>
                <PieChart>
                  <Pie data={pieData} cx="50%" cy="50%" outerRadius={80} innerRadius={45} dataKey="value" paddingAngle={4}>
                    {pieData.map((_, i) => (
                      <Cell key={i} fill={PIE_COLORS[i]} />
                    ))}
                  </Pie>
                  <Tooltip contentStyle={{ borderRadius: 12, border: '1px solid var(--border)' }} />
                </PieChart>
              </ResponsiveContainer>
              <div style={{ display: 'flex', gap: 24, marginTop: 8 }}>
                {pieData.map((d, i) => (
                  <div key={d.name} style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 13 }}>
                    <span style={{ width: 10, height: 10, borderRadius: '50%', background: PIE_COLORS[i], display: 'inline-block' }} />
                    {d.name} ({d.value})
                  </div>
                ))}
              </div>
            </div>
          ) : (
            <div className="empty-state" style={{ padding: 32 }}>
              <p>No data yet</p>
            </div>
          )}
        </div>
      </div>
    </>
  );
}
