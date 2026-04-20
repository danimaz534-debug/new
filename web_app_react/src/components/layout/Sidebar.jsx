import {
  BadgePercent,
  ChartColumn,
  LayoutDashboard,
  MenuSquare,
  MessageSquareText,
  Package,
  Settings,
  ShieldCheck,
  ShoppingCart,
  Users,
  X,
} from 'lucide-react';
import { NavLink } from 'react-router-dom';
import { NAV_ITEMS, ROLE_LABELS } from '../../lib/roles';
import useAuthStore from '../../store/useAuthStore';
import useUiStore from '../../store/useUiStore';

const iconMap = {
  layout: LayoutDashboard,
  users: Users,
  package: Package,
  'shopping-cart': ShoppingCart,
  'messages-square': MessageSquareText,
  'chart-column': ChartColumn,
  'badge-percent': BadgePercent,
  'shield-check': ShieldCheck,
  settings: Settings,
};

export default function Sidebar({ mobile }) {
  const { role, user } = useAuthStore();
  const {
    sidebarCollapsed,
    toggleSidebar,
    mobileSidebarOpen,
    closeMobileSidebar,
  } = useUiStore();

  const items = NAV_ITEMS.filter((item) => item.roles.includes(role));

  return (
    <aside
      className={[
        'sidebar',
        sidebarCollapsed && !mobile ? 'collapsed' : '',
        mobile ? 'mobile' : '',
        mobile && mobileSidebarOpen ? 'mobile-open' : '',
      ].filter(Boolean).join(' ')}
    >
      <div className="sidebar-header">
        <div className="sidebar-logo">
          <div className="icon">VD</div>
          {!(sidebarCollapsed && !mobile) && <span>VoltDash</span>}
        </div>
        <div className="sidebar-controls">
          {!mobile && (
            <button className="icon-button" type="button" onClick={toggleSidebar} aria-label="Toggle sidebar">
              <MenuSquare size={18} />
            </button>
          )}
          {mobile && (
            <button className="icon-button" type="button" onClick={closeMobileSidebar} aria-label="Close sidebar">
              <X size={18} />
            </button>
          )}
        </div>
      </div>

      <nav className="sidebar-nav">
        {items.map((item) => {
          const Icon = iconMap[item.icon];
          return (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive }) => `sidebar-link${isActive ? ' active' : ''}`}
              onClick={mobile ? closeMobileSidebar : undefined}
            >
              <Icon size={18} />
              {!(sidebarCollapsed && !mobile) && <span>{item.label}</span>}
            </NavLink>
          );
        })}
      </nav>

      <div className="sidebar-footer">
        {!(sidebarCollapsed && !mobile) && (
          <>
            <div className="user-info">
              <strong>{user?.full_name ?? 'Staff member'}</strong>
              <span className="role-tag">{ROLE_LABELS[role] ?? role}</span>
            </div>
            <span className="user-email">{user?.email ?? ''}</span>
          </>
        )}
      </div>
    </aside>
  );
}
