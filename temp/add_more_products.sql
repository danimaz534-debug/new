-- Insert additional electronic products into the database
INSERT INTO public.products (
  id, name, slug, description, category, brand, price, discount_percent, stock, tags, image_url, is_best_seller, is_featured, is_hot_deal
) VALUES
(gen_random_uuid(), 'Sony WH-1000XM5', 'sony-wh-1000xm5', 'Industry-leading noise canceling with two processors and eight microphones for pristine audio quality.', 'Audio', 'Sony', 399.99, 10, 45, ARRAY['headphones', 'wireless', 'noise-canceling'], 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&q=80&w=800', true, true, false),

(gen_random_uuid(), 'Apple MacBook Pro 16" (M3 Max)', 'macbook-pro-16-m3', 'The ultimate pro laptop. With the M3 Max chip, advanced display, and all-day battery life.', 'Laptops', 'Apple', 3499.00, 0, 15, ARRAY['laptop', 'apple', 'macbook', 'pro'], 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&q=80&w=800', true, true, false),

(gen_random_uuid(), 'Samsung Galaxy Watch 6 Classic', 'galaxy-watch-6-classic', 'A premium smartwatch with a rotating bezel, advanced health tracking, and seamless integration with your Galaxy device.', 'Wearables', 'Samsung', 399.00, 15, 60, ARRAY['smartwatch', 'wearable', 'samsung'], 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?auto=format&fit=crop&q=80&w=800', false, true, true),

(gen_random_uuid(), 'Dell XPS 15', 'dell-xps-15', '15.6-inch OLED InfinityEdge display laptop crafted with premium materials and powerful performance.', 'Laptops', 'Dell', 1999.99, 5, 25, ARRAY['laptop', 'windows', 'dell'], 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?auto=format&fit=crop&q=80&w=800', false, false, false),

(gen_random_uuid(), 'Logitech MX Master 3S', 'logitech-mx-master-3s', 'Advanced wireless mouse with ultra-fast scrolling, ergonomic design, and customizable buttons.', 'Accessories', 'Logitech', 99.99, 0, 120, ARRAY['mouse', 'wireless', 'accessory'], 'https://images.unsplash.com/photo-1527814050087-379381547926?auto=format&fit=crop&q=80&w=800', true, false, false),

(gen_random_uuid(), 'iPad Air (M1)', 'ipad-air-m1', 'Light. Bright. Full of might. The iPad Air features a stunning Liquid Retina display and the M1 chip.', 'Tablets', 'Apple', 599.00, 12, 80, ARRAY['tablet', 'apple', 'ipad'], 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&q=80&w=800', true, true, true),

(gen_random_uuid(), 'LG UltraGear 27" Gaming Monitor', 'lg-ultragear-27', '27-inch QHD Nano IPS display with 1ms response time and 144Hz refresh rate for ultimate gaming.', 'Monitors', 'LG', 349.99, 20, 35, ARRAY['monitor', 'gaming', 'display'], 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&q=80&w=800', false, false, true),

(gen_random_uuid(), 'Keychron K2 Wireless Mechanical Keyboard', 'keychron-k2', 'A versatile wireless mechanical keyboard with Mac layout and tactile switches.', 'Accessories', 'Keychron', 89.99, 0, 50, ARRAY['keyboard', 'mechanical', 'wireless'], 'https://images.unsplash.com/photo-1595225476474-87563907a212?auto=format&fit=crop&q=80&w=800', false, true, false);
