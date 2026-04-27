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

  // Call the Edge Function to reset password
  const { data, error } = await client.functions.invoke('reset-user-password', {
    body: {
      user_id: userId,
      new_password: newPassword,
    },
  });

  if (error) {
    throw new Error(error.message || "Failed to reset password");
  }

  return data;
}

export async function deleteChatMessages(threadId) {
  const client = requireClient();
  const { error } = await client
    .from("chat_messages")
    .delete()
    .eq("thread_id", threadId);
  if (error) throw error;
}