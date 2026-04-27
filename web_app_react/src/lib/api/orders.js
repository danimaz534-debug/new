import { requireClient, withRetry } from "./client";

export async function fetchOrders() {
  return withRetry(async () => {
    const client = requireClient();
    const { data, error } = await client
      .from("orders")
      .select("*, profiles(full_name, email)")
      .order("created_at", { ascending: false })
      .limit(500);
    if (error) throw error;
    return data ?? [];
  });
}

export async function updateOrder(id, patch) {
  const client = requireClient();
  const { data, error } = await client
    .from("orders")
    .update(patch)
    .eq("id", id)
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function fetchWholesaleCodes() {
  return withRetry(async () => {
    const client = requireClient();
    const { data, error } = await client
      .from("wholesale_codes")
      .select(
        "id, code, is_used, redeemed_at, created_at, creator:created_by(full_name, email), redeemer:redeemed_by(full_name, email)"
      )
      .order("created_at", { ascending: false })
      .limit(100);
    if (error) throw error;
    return data ?? [];
  });
}

export async function generateWholesaleCode() {
  const client = requireClient();
  const { data, error } = await client.rpc("generate_wholesale_code");
  if (error) throw error;
  return data;
}
