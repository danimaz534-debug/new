# Unused Database Functions Cleanup

After a comprehensive analysis of both the `mobile_app` and `web_app_react` codebases, we identified the database functions and triggers that are actively used and those that are redundant and no longer invoked by the applications.

### ❌ Unused Functions / Triggers (Safe to Delete)
These functions were either part of previous experiments, legacy implementations, or replaced by direct client-side Supabase queries:

1. **`public.can_delete_address`**
2. **`public.create_user`**
3. **`public.create_user_profile`**
4. **`public.get_address_details`**
5. **`public.get_all_user_addresses`**
6. **`public.get_user_default_address_safe`**
7. **`public.get_user_profile_safe`**
8. **`public.handle_new_product`** (trigger function)
9. **`public.handle_order_status_change`** (trigger function)
10. **`public.reset_user_password`**
11. **`public.rls_auto_enable`** (event trigger function)
12. **`public.update_user_address`**

### ✅ Actively Used Functions / Triggers (DO NOT DELETE)
These are actively called from the code via `.rpc()` or are required by active database triggers/policies:

- `public.create_order_from_cart`
- `public.current_role`
- `public.ensure_chat_thread`
- `public.ensure_profile`
- `public.generate_wholesale_code`
- `public.redeem_wholesale_code`
- `public.update_product_ratings` (active trigger)
- `public.update_updated_at` (active trigger)
- `public.update_updated_at_column` (active trigger)

---

### SQL Code to Delete Unneeded Functions

You can safely drop the unneeded functions by running the following SQL commands in your Supabase SQL editor. Using `CASCADE` will automatically drop any triggers associated with these functions.

```sql
-- Drop legacy address management functions
DROP FUNCTION IF EXISTS public.can_delete_address(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.get_address_details(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.get_all_user_addresses() CASCADE;
DROP FUNCTION IF EXISTS public.get_user_default_address_safe() CASCADE;
DROP FUNCTION IF EXISTS public.update_user_address(uuid, text, text, text, text, text, text, text, boolean) CASCADE;

-- Drop legacy user management functions
DROP FUNCTION IF EXISTS public.create_user(text, text, uuid, text, text) CASCADE;
DROP FUNCTION IF EXISTS public.create_user_profile(uuid, text, uuid, text, text) CASCADE;
DROP FUNCTION IF EXISTS public.get_user_profile_safe() CASCADE;
DROP FUNCTION IF EXISTS public.reset_user_password(uuid, text, uuid) CASCADE;

-- Drop legacy/unused trigger functions
DROP FUNCTION IF EXISTS public.handle_new_product() CASCADE;
DROP FUNCTION IF EXISTS public.handle_order_status_change() CASCADE;
DROP FUNCTION IF EXISTS public.rls_auto_enable() CASCADE;
```
