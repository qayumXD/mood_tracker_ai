import { createContext, useContext, useState, useEffect } from 'react';
import { getStoredUser, isAuthenticated as checkAuth, logout as apiLogout } from '../services/api';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => getStoredUser());
  const [authenticated, setAuthenticated] = useState(() => checkAuth());

  useEffect(() => {
    setAuthenticated(checkAuth());
    setUser(getStoredUser());
  }, []);

  const loginSuccess = (userData) => {
    setUser(userData);
    setAuthenticated(true);
  };

  const logout = () => {
    apiLogout();
    setUser(null);
    setAuthenticated(false);
  };

  return (
    <AuthContext.Provider value={{ user, authenticated, loginSuccess, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider');
  return ctx;
}
