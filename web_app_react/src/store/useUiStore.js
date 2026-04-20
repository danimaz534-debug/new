import { create } from 'zustand';

const getStoredTheme = () => {
  if (typeof window === 'undefined') {
    return 'light';
  }
  return window.localStorage.getItem('dashboard-theme') ?? 'light';
};

const useUiStore = create((set) => ({
  theme: getStoredTheme(),
  sidebarCollapsed: false,
  mobileSidebarOpen: false,
  searchQuery: '',
  toasts: [],
  setTheme(theme) {
    if (typeof window !== 'undefined') {
      window.localStorage.setItem('dashboard-theme', theme);
    }
    set({ theme });
  },
  toggleTheme() {
    set((state) => {
      const theme = state.theme === 'dark' ? 'light' : 'dark';
      if (typeof window !== 'undefined') {
        window.localStorage.setItem('dashboard-theme', theme);
      }
      return { theme };
    });
  },
  toggleSidebar() {
    set((state) => ({ sidebarCollapsed: !state.sidebarCollapsed }));
  },
  openMobileSidebar() {
    set({ mobileSidebarOpen: true });
  },
  closeMobileSidebar() {
    set({ mobileSidebarOpen: false });
  },
  setSearchQuery(searchQuery) {
    set({ searchQuery });
  },
  pushToast(toast) {
    const id = crypto.randomUUID();
    set((state) => ({ toasts: [...state.toasts, { id, tone: 'info', ...toast }] }));
    return id;
  },
  removeToast(id) {
    set((state) => ({ toasts: state.toasts.filter((toast) => toast.id !== id) }));
  },
}));

export default useUiStore;
