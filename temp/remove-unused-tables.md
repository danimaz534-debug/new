# Unused Database Tables Cleanup

This document identifies verified unused tables in the "final project dani" database schema (mobile + web) and provides SQL commands to safely remove them. Tables still in use by either platform are retained.

---

## Verified Unused Tables

### 1. `public.app_users`
- **Status**: UNUSED
- **Reason**: Complete duplicate of `public.profiles` table
- **Evidence**: No references in mobile (`lib/`) or web (`src/`) app code. Only present in `clean_schema.sql` (legacy schema definition). All app functionality uses `public.profiles` (linked to `auth.users`).
- **Dependencies**: Only referenced by unused `cart` table.

### 2. `public.cart`
- **Status**: UNUSED
- **Reason**: Redundant with `public.cart_items`
- **Evidence**: No references in app code. All cart functionality uses `public.cart_items` (properly links to `profiles` + `products` with validation). The `cart` table incorrectly references unused `app_users`.
- **Dependencies**: Depends on `app_users`.

---

## Retained Tables (In Use)

### `public.reviews`
- **Status**: KEEP (used by mobile app)
- **Reason**: Mobile app's `review_service.dart` directly queries this table (`client.from('reviews')`)
- **Note**: Web app uses `product_comments` for reviews, creating duplicate functionality. Consolidation is recommended but out of scope for this cleanup.

---

## SQL Cleanup Commands

Drop tables in the order below to avoid foreign key constraint errors:

```sql
-- 1. Drop cart first (depends on app_users)
DROP TABLE IF EXISTS public.cart;

-- 2. Drop redundant app_users table
DROP TABLE IF EXISTS public.app_users;
```

---

## Warning
1. Always take a full database backup before running destructive SQL commands
2. Verify no stale code references these tables in your app before executing
3. The `reviews` table is intentionally retained as it is used by the mobile app
