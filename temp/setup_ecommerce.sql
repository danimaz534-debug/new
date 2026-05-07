-- ============================================================
-- E-COMMERCE SCHEMA SETUP
-- Run this in the Supabase SQL Editor for project hqszihvjqscrwdzrwbyg
-- ============================================================

create extension if not exists "uuid-ossp";

-- 1. PROFILES (extends auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text,
  role text not null default 'retail',
  is_blocked boolean not null default false,
  preferred_language text not null default 'en',
  last_seen_at timestamptz not null default now(),
  avatar_url text,
  created_at timestamptz not null default now()
);

-- 2. PRODUCTS
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique,
  description text,
  category text not null,
  brand text not null,
  price numeric(10,2) not null,
  discount_percent integer not null default 0,
  stock integer not null default 0,
  tags text[] default '{}',
  image_url text,
  is_best_seller boolean not null default false,
  is_featured boolean not null default false,
  is_hot_deal boolean not null default false,
  created_at timestamptz not null default now()
);

-- 3. CART ITEMS
create table if not exists public.cart_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  quantity integer not null default 1 check (quantity > 0),
  created_at timestamptz not null default now(),
  unique(user_id, product_id)
);

-- 4. FAVORITES
create table if not exists public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(user_id, product_id)
);

-- 5. WATCH HISTORY
create table if not exists public.watch_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  viewed_at timestamptz not null default now()
);

-- 6. ORDERS
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  payment_method text not null default 'Cash on Delivery',
  status text not null default 'Preparing' check (status in ('Preparing', 'Shipped', 'On the way', 'Delivered')),
  tracking_code text unique not null default 'TRK-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12)),
  subtotal numeric(10,2) not null default 0,
  wholesale_discount numeric(10,2) not null default 0,
  loyalty_discount numeric(10,2) not null default 0,
  total_amount numeric(10,2) not null default 0,
  shipping_address jsonb,
  created_at timestamptz not null default now()
);

-- 7. ORDER ITEMS
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid not null references public.products(id),
  quantity integer not null check (quantity > 0),
  unit_price numeric(10,2) not null,
  discount_percent integer not null default 0
);

-- 8. REVIEWS (used by the schema's reviews table)
create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now()
);

-- 9. PRODUCT COMMENTS (used by Reviews page in the web app)
create table if not exists public.product_comments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  rating integer not null default 5 check (rating between 1 and 5),
  title text,
  comment text,
  is_verified_purchase boolean not null default false,
  created_at timestamptz not null default now()
);

-- 10. PRODUCT RATINGS (aggregate ratings per product)
create table if not exists public.product_ratings (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade unique,
  average_rating numeric(3,2) not null default 0,
  total_ratings integer not null default 0,
  updated_at timestamptz not null default now()
);

-- 11. NOTIFICATIONS
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null,
  type text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

-- 12. CHAT THREADS
create table if not exists public.chat_threads (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  assigned_sales_id uuid references public.profiles(id),
  last_sales_reply_at timestamptz,
  created_at timestamptz not null default now(),
  unique(user_id)
);

-- 13. CHAT MESSAGES
create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null references public.chat_threads(id) on delete cascade,
  sender_id uuid references public.profiles(id),
  sender_type text not null check (sender_type in ('user', 'sales', 'ai')),
  message text not null,
  created_at timestamptz not null default now()
);

-- 14. WHOLESALE CODES
create table if not exists public.wholesale_codes (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  created_by uuid references public.profiles(id),
  redeemed_by uuid references public.profiles(id),
  redeemed_at timestamptz,
  is_used boolean not null default false,
  created_at timestamptz not null default now()
);

-- ============================================================
-- FUNCTIONS
-- ============================================================

create or replace function public.current_role()
returns text
language sql
stable
as $$
  select coalesce((select role from public.profiles where id = auth.uid()), 'guest');
$$;

create or replace function public.ensure_profile(
  p_full_name text default null,
  p_role text default 'retail',
  p_language text default 'en'
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile public.profiles;
begin
  insert into public.profiles (id, email, full_name, role, preferred_language, last_seen_at)
  values (
    auth.uid(),
    coalesce(auth.jwt() ->> 'email', ''),
    coalesce(p_full_name, auth.jwt() -> 'user_metadata' ->> 'full_name', auth.jwt() -> 'user_metadata' ->> 'name'),
    coalesce(p_role, 'retail'),
    coalesce(p_language, 'en'),
    now()
  )
  on conflict (id) do update
    set email = excluded.email,
        full_name = coalesce(excluded.full_name, public.profiles.full_name),
        preferred_language = coalesce(excluded.preferred_language, public.profiles.preferred_language),
        last_seen_at = now()
  returning * into v_profile;

  return v_profile;
end;
$$;

create or replace function public.generate_wholesale_code()
returns public.wholesale_codes
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code text;
  v_row public.wholesale_codes;
begin
  if public.current_role() not in ('admin', 'sales') then
    raise exception 'Insufficient permissions';
  end if;

  v_code := 'WHOLE-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10));

  insert into public.wholesale_codes (code, created_by)
  values (v_code, auth.uid())
  returning * into v_row;

  return v_row;
end;
$$;

-- ============================================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================================

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.cart_items enable row level security;
alter table public.favorites enable row level security;
alter table public.watch_history enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.reviews enable row level security;
alter table public.product_comments enable row level security;
alter table public.product_ratings enable row level security;
alter table public.notifications enable row level security;
alter table public.chat_threads enable row level security;
alter table public.chat_messages enable row level security;
alter table public.wholesale_codes enable row level security;

-- ============================================================
-- RLS POLICIES
-- ============================================================

-- PROFILES
drop policy if exists "profiles self read" on public.profiles;
create policy "profiles self read" on public.profiles for select using (id = auth.uid() or public.current_role() in ('admin', 'sales'));
drop policy if exists "profiles self update" on public.profiles;
create policy "profiles self update" on public.profiles for update using (id = auth.uid() or public.current_role() = 'admin') with check (id = auth.uid() or public.current_role() = 'admin');
drop policy if exists "profiles self insert" on public.profiles;
create policy "profiles self insert" on public.profiles for insert with check (id = auth.uid());
drop policy if exists "admin delete profiles" on public.profiles;
create policy "admin delete profiles" on public.profiles for delete using (public.current_role() = 'admin');

-- PRODUCTS (public read, staff manage)
drop policy if exists "products are public readable" on public.products;
create policy "products are public readable" on public.products for select using (true);
drop policy if exists "staff manage products" on public.products;
create policy "staff manage products" on public.products for all using (public.current_role() in ('admin', 'marketing')) with check (public.current_role() in ('admin', 'marketing'));

-- CART
drop policy if exists "users manage own cart" on public.cart_items;
create policy "users manage own cart" on public.cart_items for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- FAVORITES (users manage own, admin/staff can read all)
drop policy if exists "users manage favorites" on public.favorites;
create policy "users manage favorites" on public.favorites for all using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "admin read all favorites" on public.favorites;
create policy "admin read all favorites" on public.favorites for select using (public.current_role() in ('admin', 'sales', 'marketing'));

-- WATCH HISTORY
drop policy if exists "users manage history" on public.watch_history;
create policy "users manage history" on public.watch_history for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ORDERS
drop policy if exists "users read own orders" on public.orders;
create policy "users read own orders" on public.orders for select using (user_id = auth.uid() or public.current_role() in ('admin', 'sales'));
drop policy if exists "sales update orders" on public.orders;
create policy "sales update orders" on public.orders for update using (public.current_role() in ('admin', 'sales')) with check (public.current_role() in ('admin', 'sales'));
drop policy if exists "users create orders" on public.orders;
create policy "users create orders" on public.orders for insert with check (user_id = auth.uid());

-- ORDER ITEMS
drop policy if exists "order items readable by participants" on public.order_items;
create policy "order items readable by participants" on public.order_items for select using (
  order_id in (
    select o.id from public.orders o
    where o.user_id = auth.uid() or public.current_role() in ('admin', 'sales')
  )
);
drop policy if exists "order items insert by participants" on public.order_items;
create policy "order items insert by participants" on public.order_items for insert with check (
  order_id in (
    select o.id from public.orders o
    where o.user_id = auth.uid() or public.current_role() in ('admin', 'sales')
  )
);

-- REVIEWS
drop policy if exists "reviews are public readable" on public.reviews;
create policy "reviews are public readable" on public.reviews for select using (true);
drop policy if exists "users write own reviews" on public.reviews;
create policy "users write own reviews" on public.reviews for insert with check (user_id = auth.uid());

-- PRODUCT COMMENTS (public read, users write, admin delete)
drop policy if exists "product_comments readable" on public.product_comments;
create policy "product_comments readable" on public.product_comments for select using (true);
drop policy if exists "product_comments writable" on public.product_comments;
create policy "product_comments writable" on public.product_comments for insert with check (user_id = auth.uid());
drop policy if exists "product_comments admin delete" on public.product_comments;
create policy "product_comments admin delete" on public.product_comments for delete using (user_id = auth.uid() or public.current_role() = 'admin');

-- PRODUCT RATINGS (public readable)
drop policy if exists "product_ratings readable" on public.product_ratings;
create policy "product_ratings readable" on public.product_ratings for select using (true);

-- NOTIFICATIONS
drop policy if exists "users read own notifications" on public.notifications;
create policy "users read own notifications" on public.notifications for select using (user_id = auth.uid() or public.current_role() in ('admin', 'sales'));
drop policy if exists "staff insert notifications" on public.notifications;
create policy "staff insert notifications" on public.notifications for insert with check (user_id = auth.uid() or public.current_role() in ('admin', 'sales'));
drop policy if exists "users update notifications" on public.notifications;
create policy "users update notifications" on public.notifications for update using (user_id = auth.uid()) with check (user_id = auth.uid());

-- CHAT
drop policy if exists "chat thread access" on public.chat_threads;
create policy "chat thread access" on public.chat_threads for select using (user_id = auth.uid() or assigned_sales_id = auth.uid() or public.current_role() in ('admin', 'sales'));
drop policy if exists "chat thread create" on public.chat_threads;
create policy "chat thread create" on public.chat_threads for insert with check (user_id = auth.uid() or public.current_role() in ('admin', 'sales'));
drop policy if exists "chat thread update" on public.chat_threads;
create policy "chat thread update" on public.chat_threads for update using (user_id = auth.uid() or assigned_sales_id = auth.uid() or public.current_role() in ('admin', 'sales'));
drop policy if exists "chat message access" on public.chat_messages;
create policy "chat message access" on public.chat_messages for select using (
  thread_id in (
    select t.id from public.chat_threads t
    where t.user_id = auth.uid() or t.assigned_sales_id = auth.uid() or public.current_role() in ('admin', 'sales')
  )
);
drop policy if exists "chat message create" on public.chat_messages;
create policy "chat message create" on public.chat_messages for insert with check (
  thread_id in (
    select t.id from public.chat_threads t
    where t.user_id = auth.uid() or t.assigned_sales_id = auth.uid() or public.current_role() in ('admin', 'sales')
  )
);

-- WHOLESALE CODES
drop policy if exists "sales read wholesale codes" on public.wholesale_codes;
create policy "sales read wholesale codes" on public.wholesale_codes for select using (public.current_role() in ('admin', 'sales'));
drop policy if exists "sales create wholesale codes" on public.wholesale_codes;
create policy "sales create wholesale codes" on public.wholesale_codes for insert with check (public.current_role() in ('admin', 'sales'));
