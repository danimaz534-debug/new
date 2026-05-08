import fs from 'fs';
let c = fs.readFileSync('web_app_react/src/lib/api/users.js', 'utf8');

// Replace the entire fetchUsers function with a robust version
const oldPattern = /export async function fetchUsers\(\)[\s\S]*?\n\}/;
const newFn = `export async function fetchUsers() {
  const withRetry = (await import("./client.js")).withRetry;
  return withRetry(async () => {
    const client = requireClient();

    const [profilesRes, ordersRes] = await Promise.all([
      client.from("profiles").select("*").limit(1000),
      client.from("orders").select("user_id, total_amount").limit(500),
    ]);
    if (profilesRes.error) throw profilesRes.error;

    let providerByUser = {};
    try {
      const { data: authData } = await client.rpc("get_auth_users");
      if (authData) {
        providerByUser = authData.reduce((acc, u) => {
          const appProvider = u?.app_metadata?.provider;
          const identityProvider = u?.identities?.[0]?.provider;
          acc[u.id] = appProvider || identityProvider || "email";
          return acc;
        }, {});
      }
    } catch (e) {
      console.warn("get_auth_users RPC not available, falling back to email");
    }

    const ordersByUser = (ordersRes.data ?? []).reduce((acc, order) => {
      const userId = order.user_id;
      if (!acc[userId]) acc[userId] = { count: 0, total: 0 };
      acc[userId].count += 1;
      acc[userId].total += Number(order.total_amount ?? 0);
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

if (oldPattern.test(c)) {
  c = c.replace(oldPattern, newFn);
  fs.writeFileSync('web_app_react/src/lib/api/users.js', c);
  console.log('Fixed fetchUsers with robust RPC handling');
} else {
  console.log('ERROR: Could not find fetchUsers');
}
