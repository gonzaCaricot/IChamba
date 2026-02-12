# 🔧 FIX: Users Not Loading in Messaging

## 🐛 Problem
Your Flutter app only sees **1 user** (yourself) when querying `public.users`, even though many users exist in the database.

**Root Cause:** Row Level Security (RLS) is blocking SELECT queries.

---

## ✅ Solution: Fix RLS Policy

### Step 1: Open Supabase Dashboard
1. Go to https://app.supabase.com
2. Select your **IChamba** project
3. Navigate to **SQL Editor** (left sidebar)
4. Click **New Query**

### Step 2: Run the Fix SQL
Copy and paste ALL contents from `tools/fix_users_rls.sql` and click **RUN**.

Or copy this directly:

```sql
-- Allow authenticated users to view all users
CREATE POLICY "Allow authenticated users to view all users"
ON public.users
FOR SELECT
TO authenticated
USING (true);
```

### Step 3: Verify the Policy
Run this query to check:

```sql
SELECT policyname, cmd, qual
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'users';
```

You should see:
- Policy name: `"Allow authenticated users to view all users"`
- Command: `SELECT`
- Using: `true`

---

## 🧪 Test the Fix

### In Supabase SQL Editor:
```sql
SELECT id, auth_id, email, first_name
FROM public.users
ORDER BY first_name ASC;
```

You should see **ALL** users (not just yours).

### In Flutter App:
1. **Hot restart** the app (not just hot reload)
2. Login
3. Go to **Mensajes** → Click **New Message** icon
4. You should now see other users in the picker

---

## 📋 What Changed

### Before (Broken):
- RLS only allowed users to see their own row
- Query: `SELECT * FROM public.users` → Returns 1 row
- Message picker: Shows 0 other users

### After (Fixed):
- RLS allows authenticated users to see all rows
- Query: `SELECT * FROM public.users` → Returns ALL rows
- Message picker: Shows all other users
- Security: Each user can still only UPDATE/DELETE their own data

---

## 🔒 Security Notes

**This is SAFE because:**
- ✅ Users need basic profile info (name, email) to send messages
- ✅ Only SELECT is opened to all authenticated users
- ✅ UPDATE/DELETE/INSERT remain restricted to own records
- ✅ Similar to Facebook, WhatsApp, etc. (you can see who exists to message them)

**Your data is protected:**
- Users can't modify other users' data
- Users can't delete other users
- Only authenticated users can view (not public)

---

## 🚨 Troubleshooting

### Still seeing only 1 user?

**Check 1:** Verify RLS policy exists
```sql
SELECT * FROM pg_policies WHERE tablename = 'users';
```

**Check 2:** Confirm you have multiple users in table
```sql
SELECT COUNT(*) FROM public.users;
```

**Check 3:** Check Flutter logs for errors
Look for: `[fetchOtherUsers]` in your console

**Check 4:** Make sure you're authenticated
The policy only works for logged-in users.

### Error: "new row violates row-level security"

This means INSERT/UPDATE policies are too restrictive. Keep SELECT open, but restrict other operations:

```sql
-- Allow updates only to own record
CREATE POLICY "Users can update their own data"
ON public.users FOR UPDATE
TO authenticated
USING (auth_id = auth.uid())
WITH CHECK (auth_id = auth.uid());
```

---

## 📞 Next Steps

1. ✅ Run the SQL from `tools/fix_users_rls.sql`
2. ✅ Hot restart your Flutter app
3. ✅ Test messaging → new message
4. ✅ Verify you see other users

If issues persist, check the Flutter console for detailed error logs from `[fetchOtherUsers]`.
