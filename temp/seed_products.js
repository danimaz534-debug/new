import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://hqszihvjqscrwdzrwbyg.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhxc3ppaHZqcXNjcndkenJ3YnlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NzA4NzksImV4cCI6MjA5MTA0Njg3OX0.Oe6Jm4dduicJRhF_cGol7lLjWD3W5nNUiJqSvbhnaII';
const supabase = createClient(supabaseUrl, supabaseKey);

const products = [
  {
    name: 'iPhone 15 Pro Max',
    description: 'The ultimate iPhone with aerospace-grade titanium design, A17 Pro chip, and a more advanced 48MP Main camera system.',
    category: 'Electronics',
    brand: 'Apple',
    price: 1199.99,
    discount_percent: 5,
    stock: 50,
    tags: ['smartphone', 'apple', 'ios', '5g'],
    image_url: 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?q=80&w=1000&auto=format&fit=crop',
    is_best_seller: true,
    is_featured: true,
    is_hot_deal: false
  },
  {
    name: 'Sony WH-1000XM5',
    description: 'Industry-leading noise canceling headphones with Auto NC Optimizer, crystal clear hands-free calling, and up to 30 hours of battery life.',
    category: 'Audio',
    brand: 'Sony',
    price: 398.00,
    discount_percent: 15,
    stock: 120,
    tags: ['headphones', 'wireless', 'noise-canceling', 'audio'],
    image_url: 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?q=80&w=1000&auto=format&fit=crop',
    is_best_seller: true,
    is_featured: false,
    is_hot_deal: true
  },
  {
    name: 'MacBook Air M3',
    description: 'Supercharged by M3, the 13-inch MacBook Air is incredibly portable and features a Liquid Retina display, delivering up to 18 hours of battery life.',
    category: 'Computers',
    brand: 'Apple',
    price: 1099.00,
    discount_percent: 0,
    stock: 45,
    tags: ['laptop', 'macbook', 'apple', 'm3'],
    image_url: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=1000&auto=format&fit=crop',
    is_best_seller: false,
    is_featured: true,
    is_hot_deal: false
  },
  {
    name: 'Samsung 65" Class OLED 4K S90C',
    description: 'Experience deep blacks, clean whites, and lively colors powered by Quantum Dot technology on this gorgeous ultra-thin 4K Smart TV.',
    category: 'Home Entertainment',
    brand: 'Samsung',
    price: 1599.99,
    discount_percent: 20,
    stock: 15,
    tags: ['tv', 'oled', '4k', 'smart-tv'],
    image_url: 'https://images.unsplash.com/photo-1593305841991-05c297ba4575?q=80&w=1000&auto=format&fit=crop',
    is_best_seller: false,
    is_featured: true,
    is_hot_deal: true
  },
  {
    name: 'Dyson V15 Detect Vacuum',
    description: 'The most powerful, intelligent cordless vacuum. Counts and sizes particles, automatically adapting suction power.',
    category: 'Home Appliances',
    brand: 'Dyson',
    price: 749.99,
    discount_percent: 10,
    stock: 30,
    tags: ['vacuum', 'home', 'cleaning', 'cordless'],
    image_url: 'https://images.unsplash.com/photo-1558317374-067fb5f30001?q=80&w=1000&auto=format&fit=crop',
    is_best_seller: true,
    is_featured: false,
    is_hot_deal: false
  },
  {
    name: 'Nike Air Max 270',
    description: 'The Nike Air Max 270 delivers visible air under every step. Updated for modern comfort with nods to the original 1991 Air Max 180.',
    category: 'Footwear',
    brand: 'Nike',
    price: 160.00,
    discount_percent: 0,
    stock: 200,
    tags: ['shoes', 'sneakers', 'sports', 'running'],
    image_url: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1000&auto=format&fit=crop',
    is_best_seller: true,
    is_featured: false,
    is_hot_deal: false
  },
  {
    name: 'Apple Watch Series 9',
    description: 'The most powerful chip in Apple Watch ever. A magical new way to use your watch without touching the screen.',
    category: 'Wearables',
    brand: 'Apple',
    price: 399.00,
    discount_percent: 5,
    stock: 85,
    tags: ['watch', 'smartwatch', 'fitness', 'apple'],
    image_url: 'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?q=80&w=1000&auto=format&fit=crop',
    is_best_seller: false,
    is_featured: true,
    is_hot_deal: false
  },
  {
    name: 'DJI Air 3 Drone',
    description: 'Compact foldable drone with dual cameras, 46-min max flight time, omnidirectional obstacle sensing, and O4 HD video transmission.',
    category: 'Cameras',
    brand: 'DJI',
    price: 1099.00,
    discount_percent: 0,
    stock: 20,
    tags: ['drone', 'camera', 'photography', 'video'],
    image_url: 'https://images.unsplash.com/photo-1507582020474-9a35b7d455d9?q=80&w=1000&auto=format&fit=crop',
    is_best_seller: false,
    is_featured: true,
    is_hot_deal: false
  }
];

async function seed() {
  console.log('Cleaning old products...');
  await supabase.from('products').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  
  console.log('Inserting new products...');
  const { data, error } = await supabase.from('products').insert(products).select();
  
  if (error) {
    console.error('Error seeding products:', error);
  } else {
    console.log('Successfully seeded ' + (data ? data.length : 0) + ' products!');
  }
}

seed();