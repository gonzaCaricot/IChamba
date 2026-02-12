-- SQL to enable safe Row Level Security for public.posts
-- Run these statements in the Supabase SQL editor (requires project admin)

-- Enable RLS if not already enabled
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to SELECT posts (adjust if you prefer public read)
CREATE POLICY allow_select_authenticated_posts
  ON public.posts
  FOR SELECT
  TO authenticated
  USING (true);

-- Allow authenticated users to insert posts only when the new.user_id equals their auth.uid()
CREATE POLICY allow_insert_authenticated_posts
  ON public.posts
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Allow authenticated users to update only their own posts
CREATE POLICY allow_update_own_posts
  ON public.posts
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Allow authenticated users to delete only their own posts
CREATE POLICY allow_delete_own_posts
  ON public.posts
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Optional: If you want anon/public read access, create a SELECT policy for "public" role
-- CREATE POLICY allow_select_public_posts ON public.posts FOR SELECT TO public USING (true);

-- Note: Ensure the posts table has a `user_id` column of text type that stores auth.uid().