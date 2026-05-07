const baseUrl = 'https://hqszihvjqscrwdzrwbyg.supabase.co/rest/v1';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhxc3ppaHZqcXNjcndkenJ3YnlnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NTQ3MDg3OSwiZXhwIjoyMDkxMDQ2ODc5fQ._PbwMQIffCfcjaDwAipc27gHgqu-zmBkVQPIlBudXCU';

const products = [
  {name: 'iPhone 15 Pro Max', description: 'The ultimate iPhone with aerospace-grade titanium design and A17 Pro chip.', price: 1199.00, discount_percent: 0, stock: 50, category: 'Phones', brand: 'Apple', is_best_seller: true, image_url: 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?q=80&w=600'},
  {name: 'Samsung Galaxy S24 Ultra', description: 'AI-powered smartphone with titanium exterior and Galaxy AI features.', price: 1299.00, discount_percent: 5, stock: 40, category: 'Phones', brand: 'Samsung', is_best_seller: true, image_url: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?q=80&w=600'},
  {name: 'Google Pixel 8 Pro', description: 'The all-pro Google phone with powerful AI and amazing camera.', price: 999.00, discount_percent: 10, stock: 30, category: 'Phones', brand: 'Google', is_best_seller: false, image_url: 'https://images.unsplash.com/photo-1696446702330-4e4b9fd5b0e0?q=80&w=600'},
  {name: 'OnePlus 12', description: 'Fast charging and smooth performance with OxygenOS.', price: 899.00, discount_percent: 0, stock: 25, category: 'Phones', brand: 'OnePlus', is_best_seller: false, image_url: 'https://images.unsplash.com/photo-1580910051074-3eb694886505?q=80&w=600'},
  {name: 'Apple AirPods Pro (2nd Gen)', description: 'Rich, high-quality audio and magic like you’ve never heard.', price: 249.00, discount_percent: 0, stock: 100, category: 'Accessories', brand: 'Apple', is_best_seller: true, image_url: 'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?q=80&w=600'},
  {name: 'Samsung Galaxy Watch 6', description: 'Know your health, learn your sleep, and keep your fitness in check.', price: 299.00, discount_percent: 15, stock: 60, category: 'Accessories', brand: 'Samsung', is_best_seller: false, image_url: 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?q=80&w=600'},
  {name: 'Anker 737 Power Bank', description: 'Ultra-powerful 24K portable charger with smart digital display.', price: 149.00, discount_percent: 5, stock: 80, category: 'Accessories', brand: 'Anker', is_best_seller: true, image_url: 'https://images.unsplash.com/photo-1609594040231-bb4860c8b6a2?q=80&w=600'},
  {name: 'Sony WH-1000XM5 Headphones', description: 'Industry-leading noise canceling with premium sound.', price: 399.00, discount_percent: 10, stock: 45, category: 'Accessories', brand: 'Sony', is_best_seller: false, image_url: 'https://images.unsplash.com/photo-1583394838336-acd977736f90?q=80&w=600'},
  {name: 'Logitech MX Master 3S Mouse', description: 'Advanced wireless mouse with customizable buttons.', price: 99.00, discount_percent: 0, stock: 70, category: 'Accessories', brand: 'Logitech', is_best_seller: false, image_url: 'https://images.unsplash.com/photo-1527814050087-3793815479db?q=80&w=600'},
  {name: 'MacBook Pro 16" M3', description: 'Powerful laptop with M3 chip and stunning Liquid Retina XDR display.', price: 2499.00, discount_percent: 5, stock: 15, category: 'Phones', brand: 'Apple', is_best_seller: false, is_featured: true, image_url: 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?q=80&w=600'},
];

const profiles = [
  {id: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', email: 'admin@voltcart.com', full_name: 'Admin User', role: 'admin', is_blocked: false, preferred_language: 'en'},
  {id: 'b2c3d4e5-f6a7-8901-bcde-f23456789012', email: 'sales@voltcart.com', full_name: 'Sales Manager', role: 'sales', is_blocked: false, preferred_language: 'en'},
  {id: 'c3d4e5f6-a7b8-9012-cdef-345678901234', email: 'marketing@voltcart.com', full_name: 'Marketing Lead', role: 'marketing', is_blocked: false, preferred_language: 'en'},
  {id: 'd4e5f6a7-b8c9-0123-def0-456789012345', email: 'john.doe@example.com', full_name: 'John Doe', role: 'retail', is_blocked: false, preferred_language: 'en'},
  {id: 'e5f6a7b8-c9d0-1234-ef01-567890123456', email: 'jane.smith@example.com', full_name: 'Jane Smith', role: 'wholesale', is_blocked: false, preferred_language: 'ar'},
];

async function seedProducts() {
  for (const product of products) {
    const res = await fetch(`${baseUrl}/products`, {
      method: 'POST',
      headers: {
        'apikey': key,
        'Authorization': `Bearer ${key}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal'
      },
      body: JSON.stringify(product)
    });
    if (!res.ok) {
      const error = await res.text();
      console.error('Error inserting product', product.name, error);
    } else {
      console.log('Inserted product', product.name);
    }
    await new Promise(resolve => setTimeout(resolve, 500));
  }
}

async function seedProfiles() {
  for (const profile of profiles) {
    const res = await fetch(`${baseUrl}/profiles`, {
      method: 'POST',
      headers: {
        'apikey': key,
        'Authorization': `Bearer ${key}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal'
      },
      body: JSON.stringify(profile)
    });
    if (!res.ok) {
      const error = await res.text();
      console.error('Error inserting profile', profile.email, error);
    } else {
      console.log('Inserted profile', profile.email);
    }
    await new Promise(resolve => setTimeout(resolve, 500));
  }
}

async function updateProducts() {
  // Update some products to have flags
  const updates = [
    { name: 'Samsung Galaxy S24 Ultra', is_hot_deal: true },
    { name: 'Apple AirPods Pro (2nd Gen)', is_featured: true },
    { name: 'Anker 737 Power Bank', is_featured: true },
    { name: 'Sony WH-1000XM5 Headphones', is_hot_deal: true },
  ];

  for (const update of updates) {
    // First get the product id
    const getRes = await fetch(`${baseUrl}/products?name=eq.${encodeURIComponent(update.name)}`, {
      headers: {
        'apikey': key,
        'Authorization': `Bearer ${key}`,
      }
    });
    if (!getRes.ok) {
      console.error('Error fetching', update.name);
      continue;
    }
    const data = await getRes.json();
    if (data.length === 0) continue;
    const productId = data[0].id;

    const res = await fetch(`${baseUrl}/products?id=eq.${productId}`, {
      method: 'PATCH',
      headers: {
        'apikey': key,
        'Authorization': `Bearer ${key}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal'
      },
      body: JSON.stringify(update)
    });
    if (!res.ok) {
      const error = await res.text();
      console.error('Error updating', update.name, error);
    } else {
      console.log('Updated', update.name);
    }
    await new Promise(resolve => setTimeout(resolve, 500));
  }
}

async function seed() {
  console.log('Seeding products...');
  await seedProducts();
  console.log('Updating product flags...');
  await updateProducts();
  console.log('Seeding complete.');
}

seed();
