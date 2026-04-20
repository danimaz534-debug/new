import { Bell, Menu, Moon, Search, Sun } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import { fetchNotifications, markNotificationRead } from "../../lib/commerce";
import { ROLE_LABELS } from "../../lib/roles";
import useAuthStore from "../../store/useAuthStore";
import useUiStore from "../../store/useUiStore";

export default function Navbar() {
  const { user, role, signOut } = useAuthStore();
  const {
    theme,
    toggleTheme,
    openMobileSidebar,
    searchQuery,
    setSearchQuery,
    pushToast,
  } = useUiStore();
  const [notifications, setNotifications] = useState([]);
  const [showNotifications, setShowNotifications] = useState(false);

  useEffect(() => {
    fetchNotifications()
      .then(setNotifications)
      .catch(() => {});
  }, []);

  const unread = useMemo(
    () => notifications.filter((item) => !item.is_read),
    [notifications],
  );

  const handleNotificationClick = async (notification) => {
    if (!notification.is_read) {
      try {
        await markNotificationRead(notification.id);
        setNotifications((current) =>
          current.map((item) =>
            item.id === notification.id ? { ...item, is_read: true } : item,
          ),
        );
      } catch (error) {
        pushToast({ tone: "danger", message: error.message });
      }
    }
  };

  return (
    <header className="topbar">
      <div className="topbar-left">
        <button
          className="icon-button mobile-only"
          type="button"
          onClick={openMobileSidebar}
          aria-label="Open navigation"
        >
          <Menu size={18} />
        </button>

        <label className="search-bar">
          <Search size={16} />
          <input
            id="global-search"
            name="global-search"
            value={searchQuery}
            onChange={(event) => setSearchQuery(event.target.value)}
            placeholder="Search users, products, orders..."
            autoComplete="off"
          />
        </label>
      </div>

      <div className="topbar-right">
        <button
          className="icon-button"
          type="button"
          onClick={toggleTheme}
          aria-label="Toggle theme"
        >
          {theme === "dark" ? <Sun size={18} /> : <Moon size={18} />}
        </button>

        <div className="notification-wrap">
          <button
            className="icon-button"
            type="button"
            onClick={() => setShowNotifications((current) => !current)}
            aria-label="Show notifications"
          >
            <Bell size={18} />
            {unread.length > 0 && (
              <span className="notification-count">{unread.length}</span>
            )}
          </button>
          {showNotifications && (
            <div className="dropdown-panel notifications-panel">
              <div className="dropdown-header">
                <strong>Notifications</strong>
                <span>{unread.length} unread</span>
              </div>
              <div className="notification-list">
                {notifications.length === 0 && (
                  <p className="muted-copy">No notifications yet.</p>
                )}
                {notifications.map((notification) => (
                  <button
                    key={notification.id}
                    type="button"
                    className={`notification-item${notification.is_read ? "" : " unread"}`}
                    onClick={() => handleNotificationClick(notification)}
                  >
                    <strong>{notification.title}</strong>
                    <span>{notification.body}</span>
                    <small>
                      {new Date(notification.created_at).toLocaleString()}
                    </small>
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>

        <div className="profile-chip">
          <div className="profile-copy">
            <strong>{user?.full_name ?? "Staff user"}</strong>
            <span>{ROLE_LABELS[role] ?? role}</span>
          </div>
          <button className="ghost-button" type="button" onClick={signOut}>
            Logout
          </button>
        </div>
      </div>
    </header>
  );
}
