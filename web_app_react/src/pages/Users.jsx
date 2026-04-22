import { useEffect, useMemo, useState } from "react";
import {
  fetchUsers,
  subscribeToTables,
  updateUser,
  createUser,
} from "../lib/commerce";
import { PageHeader, SectionCard } from "../components/ui/SectionCard";
import useUiStore from "../store/useUiStore";
import { STAFF_ROLES } from "../lib/roles";

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
  const { searchQuery, pushToast } = useUiStore();

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

  const save = async (id, patch) => {
    try {
      await updateUser(id, patch);
      pushToast({ tone: "success", message: "User updated." });
      // Refresh users
      const data = await fetchUsers();
      setUsers(data);
    } catch (error) {
      pushToast({ tone: "danger", message: error.message });
    }
  };

  const handleCreateUser = async (e) => {
    e.preventDefault();

    if (!newUser.email || !newUser.password) {
      pushToast({ tone: "danger", message: "Email and password are required" });
      return;
    }

    if (newUser.password.length < 6) {
      pushToast({
        tone: "danger",
        message: "Password must be at least 6 characters",
      });
      return;
    }

    setIsCreating(true);
    try {
      await createUser(
        newUser.email,
        newUser.password,
        newUser.fullName,
        newUser.role,
      );
      pushToast({ tone: "success", message: "User created successfully." });
      setNewUser({ email: "", password: "", fullName: "", role: "sales" });
      setShowCreateForm(false);
      // Reload users
      const data = await fetchUsers();
      setUsers(data);
    } catch (error) {
      pushToast({
        tone: "danger",
        message: error.message || "Failed to create user",
      });

      // If session expired, redirect to login page
      if (error.message?.includes("Session expired") || error.message?.includes("sign in again")) {
        setTimeout(() => {
          window.location.href = "/login";
        }, 2000);
      }
    } finally {
      setIsCreating(false);
    }
  };

  return (
    <div className="page-grid">
      <PageHeader
        eyebrow="Admin only"
        title="Users"
        subtitle="Manage staff access, customer status, and role assignments from one place."
      />

      <SectionCard
        title="Create staff account"
        subtitle="Admin can create dashboard users for Admin, Sales, and Marketing roles."
      >
        <button
          className="primary-button"
          onClick={() => setShowCreateForm(!showCreateForm)}
        >
          {showCreateForm ? "Cancel" : "Create New User"}
        </button>

        {showCreateForm && (
          <form
            onSubmit={handleCreateUser}
            className="form-grid"
            style={{ marginTop: "20px" }}
          >
            <label>
              Email *
              <input
                type="email"
                value={newUser.email}
                onChange={(e) =>
                  setNewUser({ ...newUser, email: e.target.value })
                }
                required
                placeholder="user@example.com"
              />
            </label>
            <label>
              Password *
              <input
                type="password"
                value={newUser.password}
                onChange={(e) =>
                  setNewUser({ ...newUser, password: e.target.value })
                }
                required
                minLength={6}
                placeholder="Min 6 characters"
              />
            </label>
            <label>
              Full Name
              <input
                type="text"
                value={newUser.fullName}
                onChange={(e) =>
                  setNewUser({ ...newUser, fullName: e.target.value })
                }
                placeholder="John Doe"
              />
            </label>
            <label>
              Role *
              <select
                value={newUser.role}
                onChange={(e) =>
                  setNewUser({ ...newUser, role: e.target.value })
                }
              >
                {staffRoles.map((role) => (
                  <option key={role} value={role}>
                    {role}
                  </option>
                ))}
              </select>
            </label>
            <div style={{ gridColumn: "1 / -1", display: "flex", gap: "10px" }}>
              <button
                type="submit"
                className="primary-button"
                disabled={isCreating}
              >
                {isCreating ? "Creating..." : "Create User"}
              </button>
              <button
                type="button"
                className="ghost-button"
                onClick={() => setShowCreateForm(false)}
              >
                Cancel
              </button>
            </div>
          </form>
        )}
      </SectionCard>

      <SectionCard
        title="User management"
        subtitle={`${filteredUsers.length} users found`}
      >
        {isLoading ? (
          <div className="loading-state">
            <div
              className="skeleton-card"
              style={{ height: "60px", marginBottom: "10px" }}
            ></div>
            <div
              className="skeleton-card"
              style={{ height: "60px", marginBottom: "10px" }}
            ></div>
            <div className="skeleton-card" style={{ height: "60px" }}></div>
          </div>
        ) : (
          <div className="table-wrap">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Role</th>
                  <th>Status</th>
                  <th>Orders</th>
                  <th>Total spend</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.length === 0 ? (
                  <tr>
                    <td
                      colSpan="6"
                      style={{
                        textAlign: "center",
                        padding: "40px",
                        color: "var(--text-faint)",
                      }}
                    >
                      No users found
                    </td>
                  </tr>
                ) : (
                  filteredUsers.map((user) => (
                    <tr key={user.id}>
                      <td>{user.full_name ?? "Unnamed user"}</td>
                      <td>{user.email}</td>
                      <td>
                        <select
                          value={user.role}
                          onChange={(event) =>
                            save(user.id, { role: event.target.value })
                          }
                        >
                          {roles.map((role) => (
                            <option key={role} value={role}>
                              {role}
                            </option>
                          ))}
                        </select>
                      </td>
                      <td>
                        <div className="table-actions">
                          <span
                            className={`status-pill ${user.is_blocked ? "danger" : "success"}`}
                          >
                            {user.status}
                          </span>
                          <button
                            className="ghost-button"
                            type="button"
                            onClick={() =>
                              save(user.id, { is_blocked: !user.is_blocked })
                            }
                          >
                            {user.is_blocked ? "Unblock" : "Suspend"}
                          </button>
                        </div>
                      </td>
                      <td>{user.orders}</td>
                      <td>${Number(user.totalSpend).toFixed(2)}</td>
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
