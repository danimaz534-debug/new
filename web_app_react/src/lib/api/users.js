import { requireClient } from "./client";

export async function ensureProfile(role = "retail", existingUser = null) {
  const client = requireClient();
  let user = existingUser;

  if (!user) {
    const { data, error: authError } = await client.auth.getUser();
    if (authError) throw authError;
    user = data.user;
  }

  if (!user) return null;

  const normalizedRole = ["admin", "sales", "marketing"].includes(role)
    ? role
    : "retail";

  const { error } = await client.rpc("ensure_profile", {
    p_full_name: null,
    p_role: normalizedRole,
    p_language: "en",
  });

  if (!error) {
    return fetchCurrentProfile(user);
  }

  if (
    error.code !== "PGRST202" &&
    !error.message?.includes("Could not find the function")
  ) {
    throw error;
  }

  const profilePayload = {
    id: user.id,
    email: user.email ?? "",
    full_name:
      user.user_metadata?.full_name ?? user.user_metadata?.name ?? "Staff user",
    role: normalizedRole,
    preferred_language: "en",
    last_seen_at: new Date().toISOString(),
  };

  const existingProfile = await client
    .from("profiles")
    .select("id, email, full_name, role, is_blocked, preferred_language, last_seen_at")
    .eq("id", user.id)
    .maybeSingle();

  if (existingProfile.error) {
    throw existingProfile.error;
  }

  if (existingProfile.data) {
    const { data, error: updateError } = await client
      .from("profiles")
      .update({
        email: profilePayload.email,
        full_name: existingProfile.data.full_name ?? profilePayload.full_name,
        preferred_language: existingProfile.data.preferred_language ?? "en",
        last_seen_at: profilePayload.last_seen_at,
      })
      .eq("id", user.id)
      .select("id, email, full_name, role, is_blocked, preferred_language, last_seen_at")
      .single();
    if (updateError) throw updateError;
    return data;
  }

  const { data, error: insertError } = await client
    .from("profiles")
    .insert(profilePayload)
    .select("id, email, full_name, role, is_blocked, preferred_language, last_seen_at")
    .single();
  if (insertError) throw insertError;
  return data;
}

export async function fetchCurrentProfile(existingUser = null) {
  const client = requireClient();
  let user = existingUser;

  if (!user) {
    const { data, error: authError } = await client.auth.getUser();
    if (authError) throw authError;
    user = data.user;
  }

  if (!user) return null;

  const { data, error } = await client
    .from("profiles")
    .select("id, email, full_name, role, is_blocked, preferred_language, last_seen_at, avatar_url")
    .eq("id", user.id)
    .maybeSingle();
  if (error) throw error;
  return data;
}

export async function updateCurrentProfile(patch) {
  const client = requireClient();
  const {
    data: { user },
  } = await client.auth.getUser();
  const { data, error } = await client
    .from("profiles")
    .update(patch)
    .eq("id", user?.id)
    .select("id, email, full_name, role, is_blocked, preferred_language, last_seen_at, avatar_url")
    .single();
  if (error) throw error;
  return data;
}

export async function fetchUsers() {
  const withRetry = (await import("./client.js")).withRetry;
  return withRetry(async () => {
    const client = requireClient();
    const [profilesRes, ordersRes] = await Promise.all([
      client.from("profiles").select("*").limit(1000),
      client.from("orders").select("user_id, total_amount").limit(500),
    ]);
    if (profilesRes.error) throw profilesRes.error;

    const ordersByUser = (ordersRes.data ?? []).reduce((acc, order) => {
      const userId = order.user_id;
      if (!acc[userId]) {
        acc[userId] = { count: 0, total: 0 };
      }
      acc[userId].count += 1;
      acc[userId].total += Number(order.total_amount ?? 0);
      return acc;
    }, {});

    return (profilesRes.data ?? []).map((user) => ({
      ...user,
      orders: ordersByUser[user.id]?.count ?? 0,
      totalSpend: ordersByUser[user.id]?.total ?? 0,
      status: user.is_blocked ? "Blocked" : "Active",
    }));
  });
}

export async function updateUser(id, patch) {
  const client = requireClient();
  const { data, error } = await client
    .from("profiles")
    .update(patch)
    .eq("id", id)
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function deleteUser(id) {
  const client = requireClient();
  const { error } = await client.from("profiles").delete().eq("id", id);
  if (error) throw error;
}

export async function createUser(email, password, fullName, role) {
  const client = requireClient();

  // Validate input
  if (!email || !password || !role) {
    throw new Error("Email, password, and role are required");
  }

  // Validate email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    throw new Error("Invalid email format");
  }

  // Validate password length
  if (password.length < 6) {
    throw new Error("Password must be at least 6 characters");
  }

  // Check if current user is admin
  const { data: { user }, error: userError } = await client.auth.getUser();
  if (userError || !user) {
    throw new Error("Not authenticated. Please sign in again.");
  }

  // Get current user's profile to verify admin role
  const { data: currentProfile, error: profileError } = await client
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();

  if (profileError) {
    throw new Error("Failed to verify admin status");
  }

  if (currentProfile.role !== "admin") {
    throw new Error("Insufficient permissions - admin role required");
  }

  // Call the Edge Function to create the user
  const { data, error } = await client.functions.invoke('create-user', {
    body: {
      email: email.trim(),
      password: password,
      full_name: fullName?.trim() ?? "",
      role: role,
    },
  });

  if (error) {
    throw new Error(error.message || "Failed to create user");
  }

  return data;
}

export async function resetUserPassword(userId, newPassword) {
  const client = requireClient();

  // Check if current user is admin
  const { data: { user }, error: userError } = await client.auth.getUser();
  if (userError || !user) {
    throw new Error("Not authenticated. Please sign in again.");
  }

  // Get current user's profile to verify admin role
  const { data: currentProfile, error: profileError } = await client
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();

  if (profileError) {
    throw new Error("Failed to verify admin status");
  }

  if (currentProfile.role !== "admin") {
    throw new Error("Insufficient permissions - admin role required");
  }

  // Validate password length
  if (newPassword.length < 6) {
    throw new Error("Password must be at least 6 characters");
  }

  // Call Edge Function to reset password
  try {
    const { data, error } = await client.functions.invoke('reset-user-password', {
      body: {
        user_id: userId,
        new_password: newPassword,
      },
    });

    if (error) {
      if (error.message?.includes("Failed to send") || error.status === 404) {
        throw new Error("Edge Function 'reset-user-password' not found. Please deploy the Edge Function first.");
      }
      throw new Error(error.message || "Failed to reset password");
    }

    return data;
  } catch (err) {
    if (err.message?.includes("Edge Function")) {
      throw err;
    }
    throw new Error("Failed to reset password: " + err.message);
  }
}
