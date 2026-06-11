import { NavLink, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import {
  LayoutDashboard,
  PlusCircle,
  Clock,
  MessageCircle,
  BookOpen,
  BarChart3,
  LogOut,
} from 'lucide-react';

const navItems = [
  { to: '/', icon: LayoutDashboard, label: 'Dashboard' },
  { to: '/log', icon: PlusCircle, label: 'Log Mood' },
  { to: '/history', icon: Clock, label: 'History' },
  { to: '/chat', icon: MessageCircle, label: 'AI Chat' },
  { to: '/journal', icon: BookOpen, label: 'Journal' },
  { to: '/analytics', icon: BarChart3, label: 'Analytics' },
];

export default function Sidebar() {
  const { user, logout } = useAuth();
  const location = useLocation();

  const initial = user?.full_name?.charAt(0)?.toUpperCase() || user?.email?.charAt(0)?.toUpperCase() || 'U';

  return (
    <aside className="sidebar">
      <div className="sidebar-logo">
        <div className="logo-icon">🧠</div>
        <div className="logo-text">
          Mood<span>AI</span>
        </div>
      </div>

      <nav className="sidebar-nav">
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.to === '/'}
            className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}
          >
            <item.icon className="nav-icon" size={20} />
            {item.label}
          </NavLink>
        ))}
      </nav>

      <div className="sidebar-footer">
        <div className="user-info">
          <div className="user-avatar">{initial}</div>
          <div>
            <div className="user-name">{user?.full_name || 'User'}</div>
            <div className="user-email">{user?.email || ''}</div>
          </div>
        </div>
        <button className="btn btn-ghost btn-full" onClick={logout} style={{ marginTop: 8 }}>
          <LogOut size={16} />
          Sign Out
        </button>
      </div>
    </aside>
  );
}
