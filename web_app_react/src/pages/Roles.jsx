import { useEffect, useState } from 'react';
import { fetchUsers, subscribeToTables } from '../lib/commerce';
import { PageHeader, SectionCard } from '../components/ui/SectionCard';

export default function RolesPage() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    const load = () => fetchUsers().then(setUsers).catch(console.error);
    load();
    return subscribeToTables('roles-live', ['profiles'], load);
  }, []);

  const grouped = ['admin', 'superuser', 'sales', 'marketing'].map((role) => ({
    role,
    users: users.filter((user) => user.role === role),
  }));

  return (
    <div className="page-grid">
      <PageHeader eyebrow="Permissions" title="Roles" subtitle="Admin-only overview of staff role assignments." />
      <div className="content-grid three-up">
        {grouped.map((group) => (
          <SectionCard key={group.role} title={group.role} subtitle={`${group.users.length} account(s)`}>
            <div className="stack-list">
              {group.users.map((user) => (
                <article key={user.id} className="compact-card">
                  <strong>{user.full_name ?? user.email}</strong>
                  <span>{user.email}</span>
                </article>
              ))}
            </div>
          </SectionCard>
        ))}
      </div>
    </div>
  );
}
