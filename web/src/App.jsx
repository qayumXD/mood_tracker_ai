import { BrowserRouter, Routes, Route, Navigate, Outlet } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { AuthProvider, useAuth } from './context/AuthContext';
import Sidebar from './components/Sidebar';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import DashboardPage from './pages/DashboardPage';
import LogMoodPage from './pages/LogMoodPage';
import HistoryPage from './pages/HistoryPage';
import ChatPage from './pages/ChatPage';
import JournalPage from './pages/JournalPage';
import AnalyticsPage from './pages/AnalyticsPage';

function ProtectedLayout() {
  const { authenticated } = useAuth();
  if (!authenticated) return <Navigate to="/login" replace />;

  return (
    <div className="app-layout">
      <Sidebar />
      <main className="main-content">
        <Outlet />
      </main>
    </div>
  );
}

function PublicRoute({ children }) {
  const { authenticated } = useAuth();
  if (authenticated) return <Navigate to="/" replace />;
  return children;
}

function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Toaster
          position="top-right"
          toastOptions={{
            style: {
              fontFamily: 'var(--font)',
              borderRadius: 'var(--radius-md)',
              boxShadow: 'var(--shadow-md)',
            },
          }}
        />
        <Routes>
          {/* Public routes */}
          <Route path="/login" element={<PublicRoute><LoginPage /></PublicRoute>} />
          <Route path="/register" element={<PublicRoute><RegisterPage /></PublicRoute>} />

          {/* Protected routes */}
          <Route element={<ProtectedLayout />}>
            <Route path="/" element={<DashboardPage />} />
            <Route path="/log" element={<LogMoodPage />} />
            <Route path="/history" element={<HistoryPage />} />
            <Route path="/chat" element={<ChatPage />} />
            <Route path="/journal" element={<JournalPage />} />
            <Route path="/analytics" element={<AnalyticsPage />} />
          </Route>

          {/* Fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
}

export default App;
