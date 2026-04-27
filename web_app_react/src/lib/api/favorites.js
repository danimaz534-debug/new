import { requireClient } from "./client";

export async function fetchUserFavorites(userId) {
  const client = requireClient();
  const { data, error } = await client
    .from("favorites")
    .select("product_id")
    .eq("user_id", userId);
  
  if (error) throw error;
  return (data || []).map(f => f.product_id);
}

export async function toggleFavorite(userId, productId) {
  const client = requireClient();
  
  // Check if already favorited
  const { data: existing, error: checkError } = await client
    .from("favorites")
    .select("id")
    .eq("user_id", userId)
    .eq("product_id", productId)
    .maybeSingle();
  
  if (checkError) throw checkError;
  
  if (existing) {
    // Remove favorite
    const { error } = await client
      .from("favorites")
      .delete()
      .eq("id", existing.id);
    
    if (error) throw error;
    return { action: 'removed' };
  } else {
    // Add favorite
    const { error } = await client
      .from("favorites")
      .insert({
        user_id: userId,
        product_id: productId,
      });
    
    if (error) throw error;
    return { action: 'added' };
  }
}

/**
 * Returns a map of { [product_id]: favoriteCount } across all users.
 * Used by admin to see how popular each product is.
 */
export async function fetchFavoriteCountsByProduct() {
  const client = requireClient();
  const { data, error } = await client
    .from("favorites")
    .select("product_id");

  if (error) throw error;

  const counts = {};
  for (const row of data || []) {
    counts[row.product_id] = (counts[row.product_id] || 0) + 1;
  }
  return counts;
}

export async function fetchFavoritesWithDetails() {
  const client = requireClient();
  const { data, error } = await client
    .from("favorites")
    .select(`
      id,
      created_at,
      product:product_id (
        id,
        name,
        price,
        category,
        image_url
      ),
      user:user_id (
        id,
        email,
        full_name
      )
    `)
    .order("created_at", { ascending: false });
  
  if (error) throw error;
  return data || [];
}
