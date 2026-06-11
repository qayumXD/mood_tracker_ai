import { useState, useEffect } from 'react';
import { fetchJournals, createJournal, deleteJournal } from '../services/api';
import toast from 'react-hot-toast';
import { Plus, Trash2, X } from 'lucide-react';

export default function JournalPage() {
  const [journals, setJournals] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    loadJournals();
  }, []);

  async function loadJournals() {
    try {
      const data = await fetchJournals();
      setJournals(data);
    } catch {
      toast.error('Failed to load journals');
    } finally {
      setLoading(false);
    }
  }

  async function handleCreate(e) {
    e.preventDefault();
    if (!title.trim() || !content.trim()) return;
    setSaving(true);
    try {
      const entry = await createJournal(title, content);
      setJournals((prev) => [entry, ...prev]);
      setShowModal(false);
      setTitle('');
      setContent('');
      toast.success('Journal saved');
    } catch {
      toast.error('Failed to save');
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete(id) {
    if (!confirm('Delete this journal entry?')) return;
    try {
      await deleteJournal(id);
      setJournals((prev) => prev.filter((j) => j.id !== id));
      toast.success('Journal deleted');
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
      <div className="page-header" style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <h1>Journal 📖</h1>
          <p>Write down your thoughts and reflections</p>
        </div>
        <button className="btn btn-primary" onClick={() => setShowModal(true)}>
          <Plus size={18} />
          New Entry
        </button>
      </div>

      {journals.length === 0 ? (
        <div className="empty-state">
          <div className="empty-icon">📖</div>
          <h3>Your journal is empty</h3>
          <p>Start writing to capture your thoughts and feelings</p>
          <button className="btn btn-primary" onClick={() => setShowModal(true)} style={{ marginTop: 16 }}>
            <Plus size={18} />
            Write First Entry
          </button>
        </div>
      ) : (
        <div className="journal-grid">
          {journals.map((j) => (
            <div className="journal-card" key={j.id}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <h3>{j.title}</h3>
                <button className="btn btn-icon btn-ghost" onClick={() => handleDelete(j.id)} style={{ marginLeft: 8, flexShrink: 0 }}>
                  <Trash2 size={14} color="var(--mood-1)" />
                </button>
              </div>
              <p>{j.content}</p>
              <div className="journal-meta">
                {new Date(j.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                {j.tags?.map((tag, i) => (
                  <span className="tag" key={i}>{tag}</span>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Create Modal */}
      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
              <h2 style={{ margin: 0 }}>New Journal Entry</h2>
              <button className="btn btn-icon btn-ghost" onClick={() => setShowModal(false)}>
                <X size={20} />
              </button>
            </div>
            <form onSubmit={handleCreate}>
              <div className="form-group">
                <label>Title</label>
                <input
                  className="form-input"
                  placeholder="Give your entry a title..."
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  required
                />
              </div>
              <div className="form-group">
                <label>Content</label>
                <textarea
                  className="form-input"
                  placeholder="Write your thoughts..."
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  rows={6}
                  required
                />
              </div>
              <div style={{ display: 'flex', gap: 12 }}>
                <button className="btn btn-secondary" type="button" onClick={() => setShowModal(false)} style={{ flex: 1 }}>
                  Cancel
                </button>
                <button className="btn btn-primary" type="submit" disabled={saving} style={{ flex: 1 }}>
                  {saving ? <span className="spinner" /> : 'Save Entry'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
}
