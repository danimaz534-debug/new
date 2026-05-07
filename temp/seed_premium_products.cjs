const baseUrl = 'https://hqszihvjqscrwdzrwbyg.supabase.co/rest/v1';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhxc3ppaHZqcXNjcndkenJ3YnlnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NTQ3MDg3OSwiZXhwIjoyMDkxMDQ2ODc5fQ._PbwMQIffCfcjaDwAipc27gHgqu-zmBkVQPIlBudXCU';

const headers = {
  'apikey': key,
  'Authorization': `Bearer ${key}`,
  'Content-Type': 'application/json',
  'Prefer': 'return=representation'
};

const premiumProducts = [
  {
    name: 'Obsidian Masterpiece Q3',
    slug: 'obsidian-masterpiece-q3',
    description: 'A full-frame compact camera that combines heritage with modern precision. Featuring a 60MP sensor and a stunning fixed 28mm lens, finished in a deep matte obsidian black.',
    price: 5995.00,
    discount_percent: 0,
    stock: 5,
    category: 'Photography',
    brand: 'Leica',
    tags: ['luxury', 'professional', 'obsidian'],
    image_url: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&q=80&w=1000',
    is_best_seller: false,
    is_featured: true,
    is_hot_deal: false
  },
  {
    name: 'Ivory Acoustic Sculpture',
    slug: 'ivory-acoustic-sculpture',
    description: 'Open-back dynamic headphones designed for the purist. Hand-assembled in Germany with premium materials and an ivory-tinted mesh that breathes with the soundstage.',
    price: 1799.00,
    discount_percent: 0,
    stock: 12,
    category: 'Audio',
    brand: 'Sennheiser',
    tags: ['audiophile', 'luxury', 'ivory'],
    image_url: 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?auto=format&fit=crop&q=80&w=1000',
    is_best_seller: true,
    is_featured: true,
    is_hot_deal: false
  },
  {
    name: 'Obsidian Pro Keyboard',
    slug: 'obsidian-pro-keyboard',
    description: 'The ultimate typing experience. Top-reforming electrostatic capacitive switches in a minimalist obsidian layout. Designed for creators who value tactility and silence.',
    price: 349.00,
    discount_percent: 5,
    stock: 25,
    category: 'Accessories',
    brand: 'HHKB',
    tags: ['mechanical', 'minimalist', 'obsidian'],
    image_url: 'https://images.unsplash.com/photo-1587829741301-dc798b83dadc?auto=format&fit=crop&q=80&w=1000',
    is_best_seller: true,
    is_featured: false,
    is_hot_deal: true
  },
  {
    name: 'Ivory Vision Display',
    slug: 'ivory-vision-display',
    description: 'A 27-inch 5K Retina masterpiece. Minimalist aluminum stand finished in ivory white, delivering unparalleled color accuracy for the modern design studio.',
    price: 1599.00,
    discount_percent: 0,
    stock: 8,
    category: 'Computing',
    brand: 'Apple',
    tags: ['monitor', 'design', 'ivory'],
    image_url: 'https://images.unsplash.com/photo-1491933382434-500287f9b54b?auto=format&fit=crop&q=80&w=1000',
    is_best_seller: false,
    is_featured: true,
    is_hot_deal: false
  },
  {
    name: 'Obsidian Chronograph',
    slug: 'obsidian-chronograph',
    description: 'Timekeeping elevated to art. A ceramic obsidian case housing a mechanical movement that pulses with precision. The ultimate accessory for the modern professional.',
    price: 850.00,
    discount_percent: 10,
    stock: 15,
    category: 'Accessories',
    brand: 'Zenith',
    tags: ['watch', 'luxury', 'obsidian'],
    image_url: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=1000',
    is_best_seller: true,
    is_featured: false,
    is_hot_deal: false
  }
];

async function seed() {
  console.log('💎 Seeding premium "Obsidian & Ivory" collection...');
  for (const product of premiumProducts) {
    try {
      const res = await fetch(`${baseUrl}/products`, {
        method: 'POST',
        headers,
        body: JSON.stringify(product)
      });
      if (res.ok) {
        console.log(`  ✅ Added: ${product.name}`);
      } else {
        const err = await res.text();
        console.error(`  ❌ Failed: ${product.name} - ${err}`);
      }
    } catch (e) {
      console.error(`  ❌ Error: ${product.name} - ${e.message}`);
    }
  }
  console.log('✨ Premium seeding complete.');
}

seed();
