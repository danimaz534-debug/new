// Deno Edge Function: Permanently delete user from auth and profiles
// Uses service role key to bypass RLS policies
// Only admin users can call this function

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Create Supabase client with service role key (bypasses RLS)
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Get the authorization header to verify the calling user
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing authorization header" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Verify the calling user is authenticated
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser(authHeader.replace("Bearer ", ""));

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Get the calling user's profile to check role
    const { data: callerProfile, error: profileError } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();

    if (profileError || !callerProfile) {
      return new Response(
        JSON.stringify({ error: "Failed to verify user role" }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Only allow admin
    if (callerProfile.role !== "admin") {
      return new Response(
        JSON.stringify({ error: "Insufficient permissions - admin required" }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Parse request body
    const { user_id } = await req.json();

    if (!user_id) {
      return new Response(
        JSON.stringify({ error: "user_id is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 1. Delete from auth.users (this also removes from auth)
    const { error: authDeleteError } = await supabase.auth.admin.deleteUser(user_id);
    if (authDeleteError) {
      console.error('Auth delete error:', authDeleteError);
      return new Response(
        JSON.stringify({ error: "Failed to delete user from auth: " + authDeleteError.message }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 2. Delete from profiles (in case not cascaded)
    const { error: profileDeleteError } = await supabase
      .from("profiles")
      .delete()
      .eq("id", user_id);

    if (profileDeleteError) {
      console.error('Profile delete error:', profileDeleteError);
      // Auth user already deleted, but profile might remain
      return new Response(
        JSON.stringify({ error: "User deleted from auth but profile cleanup failed: " + profileDeleteError.message }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 3. Clean up related data (chat threads, messages, etc.)
    await supabase.from("chat_threads").delete().eq("user_id", user_id);
    await supabase.from("chat_messages").delete().eq("sender_id", user_id);
    await supabase.from("chat_summaries").delete().eq("user_id", user_id);
    await supabase.from("orders").delete().eq("user_id", user_id);
    await supabase.from("cart_items").delete().eq("user_id", user_id);
    await supabase.from("favorites").delete().eq("user_id", user_id);
    await supabase.from("reviews").delete().eq("user_id", user_id);
    await supabase.from("product_comments").delete().eq("user_id", user_id);
    await supabase.from("notifications").delete().eq("user_id", user_id);
    await supabase.from("user_addresses").delete().eq("user_id", user_id);

    return new Response(
      JSON.stringify({ success: true, message: "User permanently deleted from auth and all related data" }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});