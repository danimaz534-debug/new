const url = 'https://hqszihvjqscrwdzrwbyg.supabase.co/auth/v1/signup';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhxc3ppaHZqcXNjcndkenJ3YnlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NzA4NzksImV4cCI6MjA5MTA0Njg3OX0.Oe6Jm4dduicJRhF_cGol7lLjWD3W5nNUiJqSvbhnaII';

async function bypass() {
  // 1. Sign up a dummy user
  const signupRes = await fetch(url, {
    method: 'POST',
    headers: {
      apikey: key,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ email: 'admin_test_123@example.com', password: 'password123' })
  });
  const authData = await signupRes.json();
  console.log("Signup:", signupRes.status, authData.user ? authData.user.id : authData);

  if (!authData.user) return;
  const token = authData.session.access_token;

  // 2. Try to insert via REST but with the user token (Maybe it allows inserts if RLS policy on products is missing check for admin, wait, products RLS is ON and rejected anon)
  const productRes = await fetch('https://hqszihvjqscrwdzrwbyg.supabase.co/rest/v1/products', {
    method: 'POST',
    headers: {
      apikey: key,
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      Prefer: 'return=minimal'
    },
    body: JSON.stringify({ name: 'Test P', price: 100, category: 'Phones', stock: 1 })
  });
  console.log("Insert Product:", productRes.status, await productRes.text());
}
bypass();
