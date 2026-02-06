import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SupabaseService {
  static final FlutterSecureStorage _secure = FlutterSecureStorage();
  static SupabaseClient? _client;

  // Provide your Supabase values in a .env or replace here
  static const _envUrlKey = 'SUPABASE_URL';
  static const _envKeyKey = 'SUPABASE_ANON_KEY';

  static Future<void> init({
    required String url,
    required String anonKey,
  }) async {
    if (_client != null) return;
    await Supabase.initialize(url: url, anonKey: anonKey);
    _client = Supabase.instance.client;
  }

  static SupabaseClient get client {
    if (_client != null) return _client!;
    return Supabase.instance.client;
  }

  // Auth helpers
  static Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Session? currentSession() => client.auth.currentSession;

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Simple user table helpers (Postgres)
  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    final resp = await client.from('users').select();
    if (resp == null) {
      throw Exception('No data returned from users table');
    }
    if (resp is List) {
      return List<Map<String, dynamic>>.from(resp);
    } else {
      throw Exception('Unexpected data format from users table');
    }
  }

  static Future<void> createUser(Map<String, dynamic> user) async {
    final resp = await client.from('users').insert(user).select().single();
    if (resp == null) {
      throw Exception('Failed to create user');
    }
  }
}
