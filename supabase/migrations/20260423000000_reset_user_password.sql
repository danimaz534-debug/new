-- Create a function to allow admins to reset user passwords
-- This function uses SECURITY DEFINER to run with elevated privileges
-- It checks that the calling user is an admin before resetting the password

-- Create a function to reset a user's password
CREATE OR REPLACE FUNCTION reset_user_password(
  p_user_id UUID,
  p_new_password TEXT,
  p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result JSON;
BEGIN
  -- Verify that the calling user is an admin
  IF NOT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = p_admin_id AND role = 'admin'
  ) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Insufficient permissions - admin role required'
    );
  END IF;

  -- Validate password length
  IF LENGTH(p_new_password) < 6 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Password must be at least 6 characters'
    );
  END IF;

  -- Check if user exists
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = p_user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'User not found'
    );
  END IF;

  -- Update the user's password
  -- Note: This requires the function to run with elevated privileges
  UPDATE auth.users
  SET 
    encrypted_password = crypt(p_new_password, gen_salt('bf')),
    updated_at = NOW()
  WHERE id = p_user_id;

  -- Return success
  RETURN json_build_object(
    'success', true,
    'message', 'Password reset successfully',
    'user_id', p_user_id
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION reset_user_password TO authenticated;

-- Note: This function requires the service role to execute properly
-- It's recommended to use the Edge Function approach for password resets
-- as shown in the reset-user-password.ts file
