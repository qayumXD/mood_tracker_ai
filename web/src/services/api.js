const API_BASE = 'http://localhost:5000/api';

function getHeaders() {
  const headers = { 'Content-Type': 'application/json' };
  const token = localStorage.getItem('auth_token');
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  return headers;
}

async function request(path, options = {}) {
  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers: { ...getHeaders(), ...options.headers },
  });

  if (res.status === 401) {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user');
    window.location.href = '/login';
    throw new Error('Unauthorized');
  }

  const data = await res.json();

  if (!res.ok) {
    throw new Error(data.error || 'Request failed');
  }

  return data;
}

// ─── Auth ──────────────────────────────────────────────────────────────

export async function login(email, password) {
  const data = await request('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  });
  localStorage.setItem('auth_token', data.token);
  localStorage.setItem('user', JSON.stringify(data.user));
  return data;
}

export async function register(email, password, fullName) {
  const data = await request('/auth/register', {
    method: 'POST',
    body: JSON.stringify({ email, password, full_name: fullName }),
  });
  localStorage.setItem('auth_token', data.token);
  localStorage.setItem('user', JSON.stringify(data.user));
  return data;
}

export async function getCurrentUser() {
  return request('/auth/me');
}

export function logout() {
  localStorage.removeItem('auth_token');
  localStorage.removeItem('user');
}

export function getStoredUser() {
  const user = localStorage.getItem('user');
  return user ? JSON.parse(user) : null;
}

export function isAuthenticated() {
  return !!localStorage.getItem('auth_token');
}

// ─── Moods ─────────────────────────────────────────────────────────────

export async function fetchMoods() {
  return request('/moods');
}

export async function fetchMoodStats() {
  return request('/moods/stats');
}

export async function logMood(level, note) {
  return request('/moods', {
    method: 'POST',
    body: JSON.stringify({ level, note }),
  });
}

export async function deleteMood(id) {
  return request(`/moods/${id}`, { method: 'DELETE' });
}

// ─── Journals ──────────────────────────────────────────────────────────

export async function fetchJournals() {
  return request('/journals');
}

export async function createJournal(title, content, moodLevel, tags) {
  return request('/journals', {
    method: 'POST',
    body: JSON.stringify({ title, content, mood_level: moodLevel, tags }),
  });
}

export async function deleteJournal(id) {
  return request(`/journals/${id}`, { method: 'DELETE' });
}

// ─── AI ────────────────────────────────────────────────────────────────

export async function chatWithAI(message) {
  return request('/ai/chat', {
    method: 'POST',
    body: JSON.stringify({ message }),
  });
}

// ─── Analytics ─────────────────────────────────────────────────────────

export async function fetchAnalytics() {
  return request('/analytics');
}
