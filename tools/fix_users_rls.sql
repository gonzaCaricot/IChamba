-- ============================================================================
-- FIX: Allow authenticated users to view all users in public.users
-- ============================================================================
-- Problem: RLS only allows users to see their own row
-- Solution: Add a SELECT policy that allows reading all users

-- Step 1: Check if RLS is enabled (should return true)
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'users';

-- Step 2: Drop any existing overly restrictive SELECT policies
-- (adjust policy names if yours are different)
DROP POLICY IF EXISTS "Users can view their own data" ON public.users;
DROP POLICY IF EXISTS "Enable read access for authenticated users only" ON public.users;

-- Step 3: Create the correct SELECT policy
-- This allows any authenticated user to SELECT all rows from public.users
CREATE POLICY "Allow authenticated users to view all users"
ON public.users
FOR SELECT
TO authenticated
USING (true);

-- Step 4: Keep existing policies for INSERT/UPDATE/DELETE restrictive
-- Example: Users can only update their own row
DROP POLICY IF EXISTS "Users can update their own data" ON public.users;
CREATE POLICY "Users can update their own data"
ON public.users
FOR UPDATE
TO authenticated
USING (auth_id = auth.uid())
WITH CHECK (auth_id = auth.uid());

-- Example: Users can insert their own row (during registration)
DROP POLICY IF EXISTS "Users can insert their own data" ON public.users;
CREATE POLICY "Users can insert their own data"
ON public.users
FOR INSERT
TO authenticated
WITH CHECK (auth_id = auth.uid());

-- Step 5: Verify policies are correct
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'users'
ORDER BY policyname;

-- Step 6: Test query (run as authenticated user via Supabase client)
-- This should now return ALL users
SELECT id, auth_id, email, first_name
FROM public.users
ORDER BY first_name ASC;
