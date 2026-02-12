-- Backfill users table from auth.users
-- This script synchronizes the public.users table with auth.users,
-- creating missing user rows for authenticated accounts that don't yet exist in the app.
--
-- Execute this in Supabase SQL Editor to populate users from auth accounts.

INSERT INTO public.users (auth_id, email, first_name, last_name, role, created_at)
SELECT
  au.id AS auth_id,
  au.email,
  COALESCE(au.user_metadata->>'first_name', '') AS first_name,
  COALESCE(au.user_metadata->>'last_name', '') AS last_name,
  'usuario' AS role,
  now() AS created_at
FROM auth.users au
WHERE au.id NOT IN (
  SELECT auth_id FROM public.users WHERE auth_id IS NOT NULL
)
ON CONFLICT (auth_id) DO NOTHING;

-- Verify: count users in public.users
SELECT COUNT(*) as total_users FROM public.users;

-- Verify: list all users with their auth info
SELECT id, auth_id, email, first_name, last_name, role FROM public.users ORDER BY created_at DESC;
