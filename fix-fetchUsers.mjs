import fs from 'fs';

let content = fs.readFileSync('web_app_react/src/lib/api/users.js', 'utf8');

const newFn = `export async function fetchUsers() {
  const withRetry = (await import("./client.js")).withRetry;
  return withRetry(async () => {
    const client = requireClient();
    const [profilesRes, ordersRes, authUsersRes] = await Promise.all([
      client.from("profiles").select("*").limit(1000),
      client.from("orders").select("user_id, total_amount").limit(500),
      client.rpc("get_auth_users").catch(() => ({ data: [] })),
    ]);
    if (profilesRes.error) throw profilesRes.error;

    const ordersByUser = (ordersRes.data ?? []).reduce((acc, order) => {
      const userId = order.user_id;
      if (!acc[userId]) acc[userId] = { count: 0, total: 0 };
      acc[userId].count += 1;
      acc[userId].total += Number(order.total_amount ?? 0);
      return acc;
    }, {});

    const providerByUser = (authUsersRes.data ?? []).reduce((acc, u) => {
      const appProvider = u?.app_metadata?.provider;
      const identityProvider = u?.identities?.[0]?.provider;
      const provider = appProvider || identityProvider || "email";
      acc[u.id] = provider;
      return acc;
    }, {});

    return (profilesRes.data ?? []).map((user) => ({
      ...user,
      orders: ordersByUser[user.id]?.count ?? 0,
      totalSpend: ordersByUser[user.id]?.total ?? 0,
      status: user.is_blocked ? "Blocked" : "Active",
      provider: providerByUser[user.id] ?? "email",
    }));
  });
}`;

// Replace the entire fetchUsers function using regex
const pattern = /export async function fetchUsers\(\)[\s\S]*?\n\}/;
if (pattern.test(content)) {
  content = content.replace(pattern, newFn);
  fs.writeFileSync('web_app_react/src/lib/api/users.js', content);
  console.log('Updated fetchUsers successfully');
} else {
  console.log('ERROR: Could not find fetchUsers function');
}
