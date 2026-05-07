import { create } from "zustand";
import { ensureProfile, fetchCurrentProfile, touchStaffPresence } from "../lib/api";
import { supabase } from "../lib/supabase";
import { isStaffRole } from "../lib/roles";

const useAuthStore = create((set, get) => ({
  user: null,
  role: "guest",
  profile: null,
  isLoading: true,
  isChecking: false,
  error: "",

  checkSession() {
    if (get().isChecking) return Promise.resolve();

    if (!supabase) {
      set({ user: null, role: "guest", profile: null, isLoading: false, error: "Supabase is not configured." });
      return Promise.resolve();
    }

    set({ isChecking: true, error: "" });

    return supabase.auth.getSession().then(async ({ data: { session }, error }) => {
      if (error) {
        set({ isLoading: false, isChecking: false, error: error.message });
        return;
      }

      if (!session?.user) {
        set({ user: null, role: "guest", profile: null, isLoading: false, isChecking: false, error: "" });
        return;
      }

      const provider = _getProvider(session.user);

      if (provider === "google" || provider === "github") {
        set({
          user: null, role: "guest", profile: null,
          isLoading: false, isChecking: false,
          error: "This dashboard is for staff only. Please sign in with your staff email and password.",
        });
        await supabase.auth.signOut();
        return;
      }

      set({ isLoading: true });

      let profile = await fetchCurrentProfile(session.user);

      if (!profile) {
        const metadataRole = session.user.user_metadata?.role;
        const bootstrapRole = isStaffRole(metadataRole) ? metadataRole : "retail";
        profile = await ensureProfile(bootstrapRole, session.user);
      }

      const nextError = profile?.is_blocked
        ? "This account is blocked."
        : !isStaffRole(profile?.role)
          ? "This web dashboard is restricted to admin, sales, and marketing accounts."
          : "";

      if (profile && isStaffRole(profile.role) && !profile.is_blocked) {
        touchStaffPresence(true).catch(() => {});
      }

      set({
        user: {
          id: session.user.id,
          email: session.user.email,
          full_name: profile?.full_name ?? session.user.user_metadata?.full_name ?? "Staff user",
          provider,
        },
        role: profile?.role ?? "guest",
        profile,
        isLoading: false,
        isChecking: false,
        error: nextError,
      });
    }).catch((error) => {
      set({ user: null, role: "guest", profile: null, isLoading: false, isChecking: false, error: error?.message ?? "Failed to initialize session." });
    });
  },

  async signIn(email, password) {
    if (!supabase) {
      set({ error: "Supabase is not configured." });
      return false;
    }
    set({ error: "", isLoading: true });
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) {
      set({ error: error.message, isLoading: false });
      return false;
    }
    return true;
  },

  async signOut() {
    set({ user: null, role: "guest", profile: null, error: "", isLoading: false });
    if (supabase) await supabase.auth.signOut();
  },
}));

function _getProvider(user) {
  const appProvider = user?.app_metadata?.provider;
  if (appProvider === "google" || appProvider === "github") return appProvider;
  const identities = user?.identities;
  if (identities && identities.length > 0) {
    const p = identities[0].provider;
    if (p === "google" || p === "github") return p;
  }
  return "email";
}

if (supabase) {
  useAuthStore.getState().checkSession().catch(() => {});
  supabase.auth.onAuthStateChange((event) => {
    if (["SIGNED_IN", "USER_UPDATED", "TOKEN_REFRESHED"].includes(event)) {
      useAuthStore.getState().checkSession().catch(() => {});
    }
    if (event === "SIGNED_OUT") {
      useAuthStore.setState({ user: null, role: "guest", profile: null, error: "", isLoading: false });
    }
  });
}

export default useAuthStore;
