export const STAFF_ROLES = ['admin', 'sales', 'marketing'];

export const ROLE_LABELS = {
  admin: 'Admin',
  sales: 'Sales',
  marketing: 'Marketing',
};

export const NAV_ITEMS = [
  { to: '/dashboard', label: 'Dashboard', icon: 'layout', roles: STAFF_ROLES },
  { to: '/users', label: 'Users', icon: 'users', roles: ['admin'] },
  { to: '/products', label: 'Products', icon: 'package', roles: ['admin', 'marketing'] },
  { to: '/orders', label: 'Orders', icon: 'shopping-cart', roles: ['admin', 'sales'] },
  { to: '/chat', label: 'Chat', icon: 'messages-square', roles: ['admin', 'sales'] },
  { to: '/analytics', label: 'Analytics', icon: 'chart-column', roles: ['admin'] },
  { to: '/marketing', label: 'Marketing', icon: 'badge-percent', roles: ['admin', 'marketing'] },
  { to: '/roles', label: 'Roles', icon: 'shield-check', roles: ['admin'] },
  { to: '/settings', label: 'Settings', icon: 'settings', roles: STAFF_ROLES },
];

export function isStaffRole(role) {
  return STAFF_ROLES.includes(role);
}

export function canAccess(role, allowedRoles) {
  return allowedRoles.includes(role);
}
