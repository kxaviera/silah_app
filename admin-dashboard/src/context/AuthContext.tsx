import { createContext, useContext, useState, useEffect } from 'react';
import type { ReactNode } from 'react';
import { authService } from '../services/auth.service';

interface Admin { _id: string; email: string; role: string; }

interface AuthContextType {
  admin: Admin | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<{ success: boolean; message?: string }>;
  logout: () => Promise<void>;
  refresh: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [admin, setAdmin] = useState<Admin | null>(null);
  const [loading, setLoading] = useState(true);

  const refresh = async () => {
    if (!authService.isAuthenticated()) { setAdmin(null); setLoading(false); return; }
    try {
      const res = await authService.getMe();
      setAdmin(res?.admin || res?.data || null);
    } catch { setAdmin(null); }
    setLoading(false);
  };

  useEffect(() => { refresh(); }, []);

  const login = async (email: string, password: string) => {
    const res = await authService.login(email, password);
    if (res.success) await refresh();
    return { success: !!res.success, message: res.message };
  };

  const logout = async () => {
    await authService.logout();
    setAdmin(null);
  };

  return (
    <AuthContext.Provider value={{ admin, loading, login, logout, refresh }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const c = useContext(AuthContext);
  if (!c) throw new Error('useAuth must be used within AuthProvider');
  return c;
}
