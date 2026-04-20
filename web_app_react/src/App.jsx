import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { useEffect } from 'react';
import AppShell from './components/layout/AppShell';
import AuthPage from './pages/Auth';
import ChatPage from './pages/Chat';
import DashboardPage from './pages/Dashboard';
import MarketingPage from './pages/Marketing';
import OrdersPage from './pages/Orders';
import ProductsPage from './pages/Products';
import UsersPage from './pages/Users';
import AnalyticsPage from './pages/Analytics';
import RolesPage from './pages/Roles';
import SettingsPage from './pages/Settings';
import { canAccess } from './lib/roles';
import useAuthStore from './store/useAuthStore';

function ProtectedRoute({ children, roles }) {
  const { user, role, isLoading, error } = useAuthStore();

  if (isLoading) {
    return <div className="fullscreen-state">Loading dashboard...</div>;
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (error && !canAccess(role, roles)) {
    return (
      <div className="fullscreen-state restricted-state">
        <strong>Access restricted</strong>
        <p>{error}</p>
      </div>
    );
  }

  return canAccess(role, roles) ? children : <Navigate to="/dashboard" replace />;
}

export default function App() {
  const { checkSession } = useAuthStore();

  useEffect(() => {
    checkSession().catch(() => {});
  }, [checkSession]);

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<AuthPage />} />
        <Route
          path="/"
          element={
            <ProtectedRoute roles={['admin', 'sales', 'marketing']}>
              <AppShell />
            </ProtectedRoute>
          }
        >
          <Route index element={<Navigate to="/dashboard" replace />} />
          <Route path="dashboard" element={<DashboardPage />} />
          <Route path="users" element={<ProtectedRoute roles={['admin']}><UsersPage /></ProtectedRoute>} />
          <Route path="products" element={<ProtectedRoute roles={['admin', 'marketing']}><ProductsPage /></ProtectedRoute>} />
          <Route path="orders" element={<ProtectedRoute roles={['admin', 'sales']}><OrdersPage /></ProtectedRoute>} />
          <Route path="chat" element={<ProtectedRoute roles={['admin', 'sales']}><ChatPage /></ProtectedRoute>} />
          <Route path="analytics" element={<ProtectedRoute roles={['admin']}><AnalyticsPage /></ProtectedRoute>} />
          <Route path="marketing" element={<ProtectedRoute roles={['admin', 'marketing']}><MarketingPage /></ProtectedRoute>} />
          <Route path="roles" element={<ProtectedRoute roles={['admin']}><RolesPage /></ProtectedRoute>} />
          <Route path="settings" element={<SettingsPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
