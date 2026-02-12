// ignore_for_file: avoid_print
/// Backfill users from auth.users into public.users table.
/// 
/// This script requires SUPABASE_SERVICE_ROLE_KEY environment variable set.
/// You can get your service role key from Supabase Settings > API.
/// 
/// Usage:
///   dart run tools/backfill_users.dart
/// 
/// Or with service key:
///   SUPABASE_SERVICE_ROLE_KEY=your_key dart run tools/backfill_users.dart

import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://qfrwfsinwfnufnxtixsf.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFmcndmc2lud2ZudWZueHRpeHNmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAzOTUxNDUsImV4cCI6MjA4NTk3MTE0NX0.F2ZIBxO_x9CqXpcYHtAuMigicaeXk_DE5tMd7CgPmrs';

Future<void> main() async {
  print('🔄 Backfill: Synchronizing users from auth.users to public.users...\n');

  // Initialize Supabase with anon key
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  final client = Supabase.instance.client;

  try {
    // Step 1: Check current users in public.users
    print('📊 Step 1: Checking current users in public.users...');
    final currentUsers =
        await client.from('users').select('id, auth_id, email, first_name');
    print('   Found ${currentUsers.length} users in public.users\n');
    for (final u in currentUsers) {
      print('   - ${u['email']} (auth_id: ${u['auth_id']})');
    }
    print('');

    // Step 2: Try to fetch auth users (this may fail due to RLS)
    print('📋 Step 2: Attempting to fetch auth.users...');
    try {
      // Note: This typically fails because auth.users is protected by RLS
      // Use service_role key if you need to access it from a script
      final authUsers = await client.from('auth.users').select('id, email');
      print('   ⚠️  Fetched ${authUsers.length} from auth.users');
    } catch (e) {
      print('   ⚠️  Cannot access auth.users directly (expected due to RLS)');
      print('   → To run this script with auth.users access, you need the');
      print('     SERVICE_ROLE_KEY from Supabase Settings > API');
      print('');
      print('🔗 Alternative: Use the SQL in tools/backfill_users.sql');
      print('   1. Go to Supabase Dashboard > SQL Editor');
      print('   2. Create new query');
      print('   3. Copy & paste the SQL from tools/backfill_users.sql');
      print('   4. Click "Run"');
      print('   5. Verify results with the SELECT queries at the end\n');
      return;
    }

    // Step 3: If we get here, attempt the backfill via raw SQL
    print('✅ Step 3: Running backfill SQL...');
    await client.rpc('exec', params: {
      'sql': '''
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
      '''
    });
    print('   ✓ Backfill completed\n');

    // Step 4: Verify
    print('📊 Step 4: Verifying backfill...');
    final newUsers =
        await client.from('users').select('id, auth_id, email, first_name');
    print('   Now ${newUsers.length} users in public.users');
    print('   Added: ${newUsers.length - currentUsers.length} new users\n');
    print('✓ Backfill complete!');
  } catch (e) {
    print('❌ Error: $e\n');
    print('💡 Recommended solution:');
    print('   Execute the SQL from tools/backfill_users.sql in Supabase SQL Editor:');
    print('   1. Dashboard > SQL Editor > New Query');
    print('   2. Copy SQL from tools/backfill_users.sql');
    print('   3. Click "Run"');
  }
}
