# Database Cleanup Guide

After a comprehensive analysis of both the mobile app (`mobile_app`) and web app (`web_app_react`) codebases in your project, we identified the tables that are actively used and those that are redundant. 

### Unused Tables Identified:
1. **`public.cart`**: This table is not used anywhere in the codebase. All shopping cart functionalities in both apps properly utilize `public.cart_items`.
2. **`public.app_users`**: This table is a legacy/redundant table. Both the mobile and web apps rely entirely on `public.profiles` for user data and role management (which is linked to Supabase's `auth.users`).

### Actively Used Tables (DO NOT DELETE):
- `cart_items`, `chat_messages`, `chat_summaries`, `chat_threads`, `favorites`, `notifications`, `order_items`, `orders`, `product_comments`, `product_ratings`, `products`, `profiles`, `reviews`, `user_addresses`, `watch_history`, `wholesale_codes` are all actively referenced in the project across Dart (Mobile) and JavaScript/React (Web) files.

---

### SQL Code to Delete Unneeded Tables

You can safely drop the unneeded tables by running the following SQL commands in your Supabase SQL editor. 

*Note: We drop `cart` first because it has a foreign key dependency on `app_users`.*

```sql
-- Drop the unused cart table
DROP TABLE IF EXISTS public.cart CASCADE;

-- Drop the unused app_users table
DROP TABLE IF EXISTS public.app_users CASCADE;
```
