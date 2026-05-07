// Seed script for the e-commerce Supabase project
// Run with: node seed_ecommerce.cjs

const baseUrl = 'https://hqszihvjqscrwdzrwbyg.supabase.co/rest/v1';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhxc3ppaHZqcXNjcndkenJ3YnlnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NTQ3MDg3OSwiZXhwIjoyMDkxMDQ2ODc5fQ._PbwMQIffCfcjaDwAipc27gHgqu-zmBkVQPIlBudXCU';

const headers = {
  'apikey': key,
  'Authorization': `Bearer ${key}`,
  'Content-Type': 'application/json',
  'Prefer': 'return=representation'
};

const headersMinimal = {
  ...headers,
  'Prefer': 'return=minimal'
};

// ============================================================
// PRODUCTS
// ============================================================
const products = [
  {
    name: 'iPhone 15 Pro Max',
    slug: 'iphone-15-pro-max',
    description: 'The ultimate iPhone with aerospace-grade titanium design, A17 Pro chip, and 48MP main camera system.',
    price: 1199.00,
    discount_percent: 0,
    stock: 50,
    category: 'Phones',
    brand: 'Apple',
    tags: ['flagship', '5G', 'titanium'],
    image_url: 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?q=80&w=600',
    is_best_seller: true,
    is_featured: true,
    is_hot_deal: false
  },
  {
    name: 'Samsung Galaxy S24 Ultra',
    slug: 'samsung-galaxy-s24-ultra',
    description: 'AI-powered smartphone with titanium exterior, Galaxy AI features, and integrated S Pen.',
    price: 1299.00,
    discount_percent: 5,
    stock: 40,
    category: 'Phones',
    brand: 'Samsung',
    tags: ['flagship', 'AI', 'S-Pen'],
    image_url: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?q=80&w=600',
    is_best_seller: true,
    is_featured: false,
    is_hot_deal: true
  },
  {
    name: 'Google Pixel 8 Pro',
    slug: 'google-pixel-8-pro',
    description: 'The all-pro Google phone with Tensor G3, powerful AI photo editing, and amazing low-light camera.',
    price: 999.00,
    discount_percent: 10,
    stock: 30,
    category: 'Phones',
    brand: 'Google',
    tags: ['AI', 'camera', 'pure-android'],
    image_url: 'https://images.unsplash.com/photo-1696446702330-4e4b9fd5b0e0?q=80&w=600',
    is_best_seller: false,
    is_featured: false,
    is_hot_deal: true
  },
  {
    name: 'OnePlus 12',
    slug: 'oneplus-12',
    description: 'Blazing fast charging at 100W SUPERVOOC and silky smooth 120Hz AMOLED display.',
    price: 899.00,
    discount_percent: 0,
    stock: 25,
    category: 'Phones',
    brand: 'OnePlus',
    tags: ['fast-charge', '120Hz', 'flagship-killer'],
    image_url: 'https://images.unsplash.com/photo-1580910051074-3eb694886505?q=80&w=600',
    is_best_seller: false,
    is_featured: false,
    is_hot_deal: false
  },
  {
    name: 'Xiaomi 14 Ultra',
    slug: 'xiaomi-14-ultra',
    description: 'Professional Leica Summilux quad camera system with variable aperture and 1-inch sensor.',
    price: 1099.00,
    discount_percent: 8,
    stock: 20,
    category: 'Phones',
    brand: 'Xiaomi',
    tags: ['leica', 'camera', 'premium'],
    image_url: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=600',
    is_best_seller: false,
    is_featured: true,
    is_hot_deal: false
  },
  {
    name: 'Apple AirPods Pro (2nd Gen)',
    slug: 'airpods-pro-2',
    description: 'Rich, immersive audio with Active Noise Cancellation, Transparency mode, and USB-C.',
    price: 249.00,
    discount_percent: 0,
    stock: 100,
    category: 'Accessories',
    brand: 'Apple',
    tags: ['wireless', 'ANC', 'USB-C'],
    image_url: 'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?q=80&w=600',
    is_best_seller: true,
    is_featured: true,
    is_hot_deal: false
  },
  {
    name: 'Samsung Galaxy Watch 6 Classic',
    slug: 'galaxy-watch-6-classic',
    description: 'Premium smartwatch with rotating bezel, comprehensive health monitoring, and Wear OS.',
    price: 399.00,
    discount_percent: 15,
    stock: 60,
    category: 'Accessories',
    brand: 'Samsung',
    tags: ['smartwatch', 'health', 'wear-os'],
    image_url: 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?q=80&w=600',
    is_best_seller: false,
    is_featured: false,
    is_hot_deal: true
  },
  {
    name: 'Anker 737 Power Bank 24K',
    slug: 'anker-737-power-bank',
    description: 'Ultra-powerful 24,000mAh portable charger with 140W output and smart digital display.',
    price: 149.00,
    discount_percent: 5,
    stock: 80,
    category: 'Accessories',
    brand: 'Anker',
    tags: ['power-bank', 'fast-charge', '140W'],
    image_url: 'https://images.unsplash.com/photo-1609594040231-bb4860c8b6a2?q=80&w=600',
    is_best_seller: true,
    is_featured: false,
    is_hot_deal: false
  },
  {
    name: 'Sony WH-1000XM5',
    slug: 'sony-wh-1000xm5',
    description: 'Industry-leading noise canceling headphones with exceptional sound and 30-hour battery.',
    price: 399.00,
    discount_percent: 10,
    stock: 45,
    category: 'Accessories',
    brand: 'Sony',
    tags: ['headphones', 'ANC', 'premium'],
    image_url: 'https://images.unsplash.com/photo-1583394838336-acd977736f90?q=80&w=600',
    is_best_seller: false,
    is_featured: false,
    is_hot_deal: true
  },
  {
    name: 'Apple Watch Ultra 2',
    slug: 'apple-watch-ultra-2',
    description: 'The most rugged Apple Watch with precision dual-frequency GPS and 36-hour battery.',
    price: 799.00,
    discount_percent: 0,
    stock: 35,
    category: 'Accessories',
    brand: 'Apple',
    tags: ['smartwatch', 'rugged', 'GPS'],
    image_url: 'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?q=80&w=600',
    is_best_seller: false,
    is_featured: true,
    is_hot_deal: false
  },
  {
    name: 'Spigen Ultra Hybrid Case',
    slug: 'spigen-ultra-hybrid',
    description: 'Crystal clear military-grade protection with anti-yellowing technology.',
    price: 15.99,
    discount_percent: 0,
    stock: 200,
    category: 'Accessories',
    brand: 'Spigen',
    tags: ['case', 'protective', 'clear'],
    image_url: 'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?q=80&w=600',
    is_best_seller: true,
    is_featured: false,
    is_hot_deal: false
  },
  {
    name: 'Belkin MagSafe 3-in-1 Charger',
    slug: 'belkin-magsafe-3in1',
    description: 'Premium wireless charging stand for iPhone, Apple Watch, and AirPods simultaneously.',
    price: 149.99,
    discount_percent: 12,
    stock: 55,
    category: 'Accessories',
    brand: 'Belkin',
    tags: ['charger', 'MagSafe', 'wireless'],
    image_url: 'https://images.unsplash.com/photo-1586953208448-b95a79798f07?q=80&w=600',
    is_best_seller: false,
    is_featured: false,
    is_hot_deal: true
  },
  {
    name: 'MacBook Pro 16" (M3 Max)',
    slug: 'macbook-pro-16-m3-max',
    description: 'Mind-blowing performance with the M3 Max chip, stunning Liquid Retina XDR display, and up to 22 hours of battery life.',
    price: 3499.00,
    discount_percent: 0,
    stock: 15,
    category: 'Laptops',
    brand: 'Apple',
    tags: ['laptop', 'pro', 'm3-max'],
    image_url: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=600',
    is_best_seller: true,
    is_featured: true,
    is_hot_deal: false
  },
  {
    name: 'iPad Pro 12.9" (M2)',
    slug: 'ipad-pro-12-9-m2',
    description: 'The ultimate iPad experience with the astonishing performance of the M2 chip and a brilliant Liquid Retina XDR display.',
    price: 1099.00,
    discount_percent: 5,
    stock: 25,
    category: 'Tablets',
    brand: 'Apple',
    tags: ['tablet', 'pro', 'm2'],
    image_url: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?q=80&w=600',
    is_best_seller: true,
    is_featured: false,
    is_hot_deal: false
  },
  {
    name: 'Amazon Echo Dot (5th Gen)',
    slug: 'echo-dot-5th-gen',
    description: 'Our best-sounding Echo Dot yet with clearer vocals, deeper bass, and vibrant sound in any room.',
    price: 49.99,
    discount_percent: 20,
    stock: 150,
    category: 'Smart Home',
    brand: 'Amazon',
    tags: ['speaker', 'alexa', 'smart-home'],
    image_url: 'https://images.unsplash.com/photo-1543512214-318c7553f230?q=80&w=600',
    is_best_seller: true,
    is_featured: false,
    is_hot_deal: true
  },
  {
    name: 'Dell XPS 15',
    slug: 'dell-xps-15',
    description: 'The perfect balance of power and portability, featuring a stunning OLED display and powerful Intel Core processors.',
    price: 1899.00,
    discount_percent: 8,
    stock: 20,
    category: 'Laptops',
    brand: 'Dell',
    tags: ['laptop', 'oled', 'premium'],
    image_url: 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?q=80&w=600',
    is_best_seller: false,
    is_featured: true,
    is_hot_deal: false
  }
];

// ============================================================
// HELPERS
// ============================================================
async function apiCall(endpoint, method, body) {
  const res = await fetch(`${baseUrl}/${endpoint}`, {
    method,
    headers: method === 'GET' ? { ...headers, 'Content-Type': undefined } : headers,
    body: body ? JSON.stringify(body) : undefined
  });
  if (!res.ok) {
    const error = await res.text();
    throw new Error(`${method} ${endpoint} failed: ${error}`);
  }
  const text = await res.text();
  return text ? JSON.parse(text) : null;
}

async function insert(table, data) {
  return apiCall(table, 'POST', data);
}

async function query(table, params = '') {
  const res = await fetch(`${baseUrl}/${table}?${params}`, {
    headers: { ...headers }
  });
  return res.json();
}

function randomDate(daysBack) {
  const date = new Date();
  date.setDate(date.getDate() - Math.floor(Math.random() * daysBack));
  date.setHours(Math.floor(Math.random() * 24), Math.floor(Math.random() * 60));
  return date.toISOString();
}

function randomItem(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

// ============================================================
// SEED FUNCTIONS
// ============================================================
async function seedProducts() {
  console.log('🛒 Seeding products...');
  const inserted = [];
  for (const product of products) {
    try {
      const [data] = await insert('products', product);
      console.log(`  ✅ ${product.name}`);
      inserted.push(data);
    } catch (err) {
      console.error(`  ❌ ${product.name}: ${err.message}`);
    }
  }
  return inserted;
}

async function seedOrders(productIds) {
  console.log('\n📦 Seeding orders...');
  
  // Get existing profiles (auth users who signed in)
  const profiles = await query('profiles', 'select=id,role');
  
  // We'll create orders for any user that exists, or create mock orders with a real user
  const userIds = profiles.filter(p => p.role !== 'admin').map(p => p.id);
  const adminIds = profiles.filter(p => p.role === 'admin').map(p => p.id);
  const allUserIds = userIds.length > 0 ? userIds : adminIds;
  
  if (allUserIds.length === 0) {
    console.log('  ⚠️ No users found. Skipping orders.');
    return [];
  }
  
  const statuses = ['Preparing', 'Shipped', 'On the way', 'Delivered'];
  const orders = [];
  
  for (let i = 0; i < 15; i++) {
    const userId = randomItem(allUserIds);
    const numItems = Math.floor(Math.random() * 3) + 1;
    const selectedProducts = [];
    
    for (let j = 0; j < numItems; j++) {
      const prod = randomItem(productIds);
      if (!selectedProducts.find(p => p.id === prod.id)) {
        selectedProducts.push({ ...prod, qty: Math.floor(Math.random() * 3) + 1 });
      }
    }
    
    const subtotal = selectedProducts.reduce((sum, p) => {
      const discounted = p.price * (1 - (p.discount_percent || 0) / 100);
      return sum + discounted * p.qty;
    }, 0);
    
    const order = {
      user_id: userId,
      payment_method: randomItem(['Cash on Delivery', 'Market payment']),
      status: randomItem(statuses),
      tracking_code: `TRK-${Date.now().toString(36).toUpperCase()}${Math.random().toString(36).slice(2,6).toUpperCase()}`,
      subtotal: Math.round(subtotal * 100) / 100,
      total_amount: Math.round(subtotal * 100) / 100,
      created_at: randomDate(60)
    };
    
    try {
      const [orderData] = await insert('orders', order);
      console.log(`  ✅ Order ${orderData.tracking_code} ($${order.total_amount})`);
      orders.push({ ...orderData, items: selectedProducts });
      
      // Insert order items
      for (const item of selectedProducts) {
        await insert('order_items', {
          order_id: orderData.id,
          product_id: item.id,
          quantity: item.qty,
          unit_price: item.price,
          discount_percent: item.discount_percent || 0
        });
      }
    } catch (err) {
      console.error(`  ❌ Order: ${err.message}`);
    }
  }
  
  return orders;
}

async function seedFavorites(productIds) {
  console.log('\n❤️ Seeding favorites...');
  
  const profiles = await query('profiles', 'select=id,role');
  const userIds = profiles.map(p => p.id);
  
  if (userIds.length === 0) {
    console.log('  ⚠️ No users found. Skipping favorites.');
    return;
  }
  
  // Each user favorites random products
  for (const userId of userIds) {
    const numFavs = Math.floor(Math.random() * 5) + 1;
    const shuffled = [...productIds].sort(() => 0.5 - Math.random());
    const favProducts = shuffled.slice(0, numFavs);
    
    for (const prod of favProducts) {
      try {
        await insert('favorites', {
          user_id: userId,
          product_id: prod.id,
          created_at: randomDate(30)
        });
      } catch (err) {
        // Ignore duplicates
      }
    }
    const profile = profiles.find(p => p.id === userId);
    console.log(`  ✅ User (${profile?.role || 'unknown'}) → ${numFavs} favorites`);
  }
}

async function seedProductComments(productIds) {
  console.log('\n💬 Seeding product comments/reviews...');
  
  const profiles = await query('profiles', 'select=id,full_name');
  const userIds = profiles.map(p => p.id);
  
  if (userIds.length === 0) {
    console.log('  ⚠️ No users found. Skipping comments.');
    return;
  }
  
  const titles = [
    'Excellent product!', 'Worth every penny', 'Great value', 'Highly recommended',
    'Good but overpriced', 'Solid build quality', 'Amazing camera', 'Battery life is great',
    'Perfect for daily use', 'Premium feel', 'Fast delivery too', 'Love this!',
    'Decent quality', 'Exactly as described', 'Would buy again'
  ];
  
  const comments = [
    'Been using this for a month and couldn\'t be happier with my purchase.',
    'The build quality is exceptional. Feels premium in hand.',
    'Camera performance exceeded my expectations, especially in low light.',
    'Battery easily lasts a full day of heavy usage.',
    'Great value for money. Competes with more expensive options.',
    'Fast shipping and the product was well-packaged.',
    'Would definitely recommend to friends and family.',
    'Upgraded from the previous model and the difference is noticeable.',
    'Works seamlessly with my other devices.',
    'The design is sleek and modern. Gets compliments all the time.',
    'Sound quality is incredible for the price range.',
    'Very responsive and smooth performance overall.',
    'Setup was quick and easy, ready to use in minutes.',
    'Perfect companion for everyday carry.',
    null // some reviews have no comment
  ];
  
  for (let i = 0; i < 20; i++) {
    const prod = randomItem(productIds);
    const userId = randomItem(userIds);
    
    try {
      await insert('product_comments', {
        user_id: userId,
        product_id: prod.id,
        rating: Math.floor(Math.random() * 3) + 3, // 3-5 stars mostly
        title: randomItem(titles),
        comment: randomItem(comments),
        is_verified_purchase: Math.random() > 0.3,
        created_at: randomDate(45)
      });
      console.log(`  ✅ Review on ${prod.name}`);
    } catch (err) {
      console.error(`  ❌ Comment: ${err.message}`);
    }
  }
  
  // Build product_ratings aggregates
  console.log('\n⭐ Building product rating aggregates...');
  for (const prod of productIds) {
    const reviews = await query('product_comments', `product_id=eq.${prod.id}&select=rating`);
    if (reviews.length === 0) continue;
    const avg = reviews.reduce((s, r) => s + r.rating, 0) / reviews.length;
    try {
      await insert('product_ratings', {
        product_id: prod.id,
        average_rating: Math.round(avg * 100) / 100,
        total_ratings: reviews.length,
        updated_at: new Date().toISOString()
      });
      console.log(`  ✅ ${prod.name}: ${avg.toFixed(1)} (${reviews.length} reviews)`);
    } catch (err) {
      // Skip if already exists
    }
  }
}

async function seedNotifications() {
  console.log('\n🔔 Seeding notifications...');
  
  const profiles = await query('profiles', 'select=id,role');
  const adminIds = profiles.filter(p => ['admin', 'sales'].includes(p.role)).map(p => p.id);
  
  if (adminIds.length === 0) {
    console.log('  ⚠️ No staff found. Skipping notifications.');
    return;
  }
  
  const notifs = [
    { title: 'New order placed', body: 'A customer just placed an order for $1,299.00', type: 'order' },
    { title: 'Low stock alert', body: 'OnePlus 12 has only 5 units remaining', type: 'inventory' },
    { title: 'New review', body: 'A customer left a 5-star review on iPhone 15 Pro Max', type: 'review' },
    { title: 'Order delivered', body: 'Order TRK-ABC123 was successfully delivered', type: 'order' },
    { title: 'New user signup', body: 'jane.customer@email.com just created an account', type: 'user' },
    { title: 'Weekly sales report', body: 'Revenue is up 15% compared to last week', type: 'report' },
    { title: 'Payment received', body: 'Payment of $899.00 confirmed for order TRK-XYZ789', type: 'payment' },
    { title: 'Wholesale code redeemed', body: 'Code WHOLE-ABCDE12345 was just redeemed', type: 'wholesale' },
  ];
  
  for (const notif of notifs) {
    const userId = randomItem(adminIds);
    try {
      await insert('notifications', {
        ...notif,
        user_id: userId,
        created_at: randomDate(14)
      });
      console.log(`  ✅ ${notif.title}`);
    } catch (err) {
      console.error(`  ❌ ${notif.title}: ${err.message}`);
    }
  }
}

// ============================================================
// MAIN
// ============================================================
async function main() {
  console.log('🚀 Starting e-commerce data seeding...\n');
  console.log('Project: hqszihvjqscrwdzrwbyg\n');
  
  // 1. Seed products
  const insertedProducts = await seedProducts();
  
  if (insertedProducts.length === 0) {
    // Try to get existing products
    const existing = await query('products', 'select=id,name,price,discount_percent');
    if (existing.length === 0) {
      console.error('\n❌ No products could be created or found. Run the schema SQL first!');
      process.exit(1);
    }
    console.log(`\nUsing ${existing.length} existing products.`);
    insertedProducts.push(...existing);
  }
  
  const productRefs = insertedProducts.map(p => ({
    id: p.id,
    name: p.name,
    price: p.price,
    discount_percent: p.discount_percent || 0
  }));
  
  // 2. Seed orders
  await seedOrders(productRefs);
  
  // 3. Seed favorites
  await seedFavorites(productRefs);
  
  // 4. Seed product comments & ratings
  await seedProductComments(productRefs);
  
  // 5. Seed notifications
  await seedNotifications();
  
  console.log('\n✅ Seeding complete! Your app should now show real data.');
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
