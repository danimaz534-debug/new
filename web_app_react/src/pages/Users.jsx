import { useEffect, useMemo, useState } from "react";
import {
  fetchUsers,
  subscribeToTables,
  updateUser,
  deleteUser,
  createUser,
  resetUserPassword,
} from "../lib/api";
import { PageHeader, SectionCard } from "../components/ui/SectionCard";
import useUiStore from "../store/useUiStore";
import { STAFF_ROLES, getRoleLabel } from "../lib/roles";
import { t } from "../lib/i18n";
import { Search, Key } from "lucide-react";

const roles = ["admin", "sales", "marketing", "wholesale", "retail"];
const staffRoles = STAFF_ROLES;

export default function UsersPage() {
  const [users, setUsers] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [newUser, setNewUser] = useState({
    email: "",
    password: "",
    fullName: "",
    role: "sales",
  });
  const [isCreating, setIsCreating] = useState(false);
  const [resetPasswordId, setResetPasswordId] = useState(null);
  const [resetPasswordValue, setResetPasswordValue] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const { searchQuery, setSearchQuery, pushToast, language } = useUiStore();

  useEffect(() => {
    let isMounted = true;

    const load = async () => {
      if (!isMounted) return;
      setIsLoading(true);
      try {
        const data = await fetchUsers();
        if (isMounted) {
          setUsers(data);
        }
      } catch (error) {
        console.error("Failed to fetch users:", error);
        if (isMounted) {
          pushToast({
            tone: "danger",
            message: `Failed to load users: ${error.message}`,
          });
        }
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    };

    load();

    // Debounced subscription handler
    let debounceTimer;
    const debouncedLoad = () => {
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(load, 500);
    };

    const unsubscribe = subscribeToTables(
      "users-live",
      ["profiles", "orders"],
      debouncedLoad,
    );

    return () => {
      isMounted = false;
      clearTimeout(debounceTimer);
      unsubscribe();
    };
  }, [pushToast]);

  const filteredUsers = useMemo(
    () =>
      users.filter((user) =>
        [user.full_name, user.email, user.role]
          .join(" ")
          .toLowerCase()
          .includes(searchQuery.toLowerCase()),
      ),
    [users, searchQuery],
  );

  const highlightText = (text, search) => {
    if (!search || !text) return text;
    const regex = new RegExp(`(${search.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
    const parts = text.split(regex);
    return parts.map((part, i) =>
      regex.test(part) ? <mark key={i} style={{ backgroundColor: 'var(--primary-soft)', color: 'var(--primary)', padding: '0 2px', borderRadius: '2px' }}>{part}</mark> : part
    );
  };

const handleDeleteUser = async (id) => {
    if (!window.confirm(t('deleteThisUser', language))) return;
    try {
      await deleteUser(id);
      pushToast({ tone: "success", message: t('userDeleted', language) });
      const data = await fetchUsers();
      setUsers(data);
    } catch (error) {
      pushToast({ tone: "danger", message: error.message });
    }
  };

  const save = async (id, patch) => {
    try {
      await updateUser(id, patch);
      pushToast({ tone: "success", message: t('userUpdated', language) });
      const data = await fetchUsers();
      setUsers(data);
    } catch (error) {
      pushToast({ tone: "danger", message: error.message });
    }
  };

  const handleResetPassword = async (id) => {
    if (!resetPasswordValue) {
      pushToast({ tone: "danger", message: t('passwordMinChars', language) });
      return;
    }

    if (resetPasswordValue.length < 6) {
      pushToast({ tone: "danger", message: t('passwordMinChars', language) });
      return;
    }

    try {
      await resetUserPassword(id, resetPasswordValue);
      pushToast({ tone: "success", message: "Password reset successfully" });
      setResetPasswordId(null);
      setResetPasswordValue("");
    } catch (error) {
      pushToast({ tone: "danger", message: error.message });
    }
  };

  const handleCreateUser = async (e) => {
    e.preventDefault();

    if (!newUser.email || !newUser.password) {
      pushToast({ tone: "danger", message: t('emailPasswordRequired', language) });
      return;
    }

    if (newUser.password.length < 6) {
      pushToast({ tone: "danger", message: t('passwordMinChars', language) });
      return;
    }

    setIsCreating(true);
    try {
      await createUser(newUser.email, newUser.password, newUser.fullName, newUser.role);
      pushToast({ tone: "success", message: t('userCreated', language) });
      setNewUser({ email: "", password: "", fullName: "", role: "sales" });
      setShowCreateForm(false);
      const data = await fetchUsers();
      setUsers(data);
    } catch (error) {
      pushToast({ tone: "danger", message: error.message || "Failed to create user" });
      if (error.message?.includes("Session expired") || error.message?.includes("sign in again")) {
        setTimeout(() => { window.location.href = "/login"; }, 2000);
      }
    } finally {
      setIsCreating(false);
    }
  };

  return (
    <div className="page-grid">
      <PageHeader
        eyebrow={t('adminOnly', language)}
        title={t('users', language)}
        subtitle={t('manageStaff', language)}
      />

      <SectionCard
        title={t('createStaffAccount', language)}
        subtitle={t('adminCreateDashboard', language)}
      >
        <div className="chat-toolbar" style={{ marginBottom: "20px" }}>
          <label className="search-bar">
            <Search size={16} />
            <input
              value={searchQuery}
              onChange={(event) => setSearchQuery(event.target.value)}
              placeholder={t('searchUsersProducts', language)}
            />
          </label>
          {searchQuery && (
            <div style={{ fontSize: '0.8rem', color: 'var(--text-soft)', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <span>{t('searchingFor', language)}: <strong style={{ color: 'var(--primary)' }}>{searchQuery}</strong></span>
              <button className="ghost-button small" onClick={() => setSearchQuery('')}>{t('clear', language)}</button>
            </div>
          )}
        </div>
        {!showCreateForm && (
          <button
            className="primary-button"
            onClick={() => setShowCreateForm(true)}
          >
            {t('createNewUser', language)}
          </button>
        )}

        {showCreateForm && (
          <form onSubmit={handleCreateUser} className="form-grid" style={{ marginTop: "20px" }}>
            <label>
              {t('email', language)} *
              <input type="email" value={newUser.email} onChange={(e) => setNewUser({ ...newUser, email: e.target.value })} required placeholder="user@example.com" />
            </label>
            <label>
              {t('password', language)} *
              <input type="password" value={newUser.password} onChange={(e) => setNewUser({ ...newUser, password: e.target.value })} required minLength={6} placeholder="Min 6 characters" />
            </label>
            <label>
              {t('fullName', language)}
              <input type="text" value={newUser.fullName} onChange={(e) => setNewUser({ ...newUser, fullName: e.target.value })} placeholder="John Doe" />
            </label>
            <label>
              {t('role', language)} *
              <select value={newUser.role} onChange={(e) => setNewUser({ ...newUser, role: e.target.value })}>
                {staffRoles.map((role) => <option key={role} value={role}>{getRoleLabel(role, language)}</option>)}
              </select>
            </label>
            <div style={{ gridColumn: "1 / -1", display: "flex", gap: "10px", alignItems: "center" }}>
              <button type="submit" className="primary-button" disabled={isCreating}>
                {isCreating ? t('creating', language) : t('createNewUser', language)}
              </button>
              <button type="button" className="ghost-button" onClick={() => setShowCreateForm(false)}>
                {t('cancel', language)}
              </button>
            </div>
          </form>
        )}
      </SectionCard>

      <SectionCard
        title={t('userManagement', language)}
        subtitle={`${filteredUsers.length} ${t('users', language)}`}
      >
        {isLoading ? (
          <div className="loading-state">
            <div className="skeleton-card" style={{ height: "60px", marginBottom: "10px" }}></div>
            <div className="skeleton-card" style={{ height: "60px", marginBottom: "10px" }}></div>
            <div className="skeleton-card" style={{ height: "60px" }}></div>
          </div>
        ) : (
          <div className="table-wrap">
            <table className="data-table">
              <thead>
                <tr>
                  <th>{t('name', language)}</th>
                  <th>{t('email', language)}</th>
                  <th>{t('role', language)}</th>
                  <th>{t('status', language)}</th>
                  <th>{t('orders', language)}</th>
                  <th>{t('totalSpend', language)}</th>
                  <th>{t('actions', language)}</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.length === 0 ? (
                  <tr>
                    <td colSpan="7" style={{ textAlign: "center", padding: "40px", color: "var(--text-faint)" }}>
                      {t('noUsersFound', language)}
                    </td>
                  </tr>
                ) : (
                  filteredUsers.map((user) => (
                    <tr key={user.id}>
                      <td>{highlightText(user.full_name ?? t('unnamedUser', language), searchQuery)}</td>
                      <td>{highlightText(user.email, searchQuery)}</td>
                      <td>
                        <select value={user.role} onChange={(event) => save(user.id, { role: event.target.value })}>
                          {roles.map((role) => <option key={role} value={role}>{getRoleLabel(role, language)}</option>)}
                        </select>
                      </td>
                      <td>
                        <div className="table-actions">
                          <span className={`status-pill ${user.is_blocked ? "danger" : "success"}`}>{user.status}</span>
                          <button className="ghost-button" type="button" onClick={() => save(user.id, { is_blocked: !user.is_blocked })}>
                            {user.is_blocked ? t('block', language) : t('suspend', language)}
                          </button>
                          <button className="danger-button" type="button" onClick={() => handleDeleteUser(user.id)}>
                            {t('delete', language)}
                          </button>
                        </div>
                      </td>
                      <td>{user.orders}</td>
                      <td>${Number(user.totalSpend).toFixed(2)}</td>
                      <td>
                        <div className="table-actions">
                          {resetPasswordId === user.id ? (
                            <div style={{ display: 'flex', gap: '5px', alignItems: 'center' }}>
                              <input
                                type={showPassword ? "text" : "password"}
                                value={resetPasswordValue}
                                onChange={(e) => setResetPasswordValue(e.target.value)}
                                placeholder={t('newPassword', language)}
                                style={{ padding: '4px 8px', fontSize: '0.8rem' }}
                              />
                              <button
                                type="button"
                                className="ghost-button"
                                style={{ padding: '4px 8px', fontSize: '0.8rem' }}
                                onClick={() => setShowPassword(!showPassword)}
                                title={showPassword ? t('hidePassword', language) : t('showPassword', language)}
                              >
                                <Key size={14} />
                              </button>
                              <button className="primary-button" style={{ padding: '4px 8px', fontSize: '0.8rem' }} onClick={() => handleResetPassword(user.id)}>
                                {t('save', language)}
                              </button>
                              <button className="ghost-button" style={{ padding: '4px 8px', fontSize: '0.8rem' }} onClick={() => { setResetPasswordId(null); setResetPasswordValue(""); setShowPassword(false); }}>
                                {t('cancel', language)}
                              </button>
                            </div>
                          ) : (
                            <button className="ghost-button" type="button" onClick={() => { setResetPasswordId(user.id); setResetPasswordValue(""); setShowPassword(false); }} title={t('resetPassword', language)}>
                              <Key size={14} />
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </SectionCard>
    </div>
  );
}
