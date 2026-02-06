import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase/supabase.dart';

// Usage: set SUPABASE_URL and SUPABASE_KEY environment vars then run:
// dart run tools/migrate_to_supabase.dart C:\path\to\ichamba.db

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run tools/migrate_to_supabase.dart <path_to_db>');
    return;
  }

  final dbPath = args[0];
  final url = Platform.environment['SUPABASE_URL'];
  final key = Platform.environment['SUPABASE_ANON_KEY'];
  if (url == null || key == null) {
    print(
      'Please set SUPABASE_URL and SUPABASE_ANON_KEY environment variables.',
    );
    return;
  }

  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;
  final db = await databaseFactory.openDatabase(dbPath);

  final rows = await db.query('users');
  final client = SupabaseClient(url, key);

  for (final row in rows) {
    final mapped = {
      'id': row['id'],
      'name': row['name'],
      'first_name': row['first_name'],
      'last_name': row['last_name'],
      'address': row['address'],
      'neighborhood': row['neighborhood'],
      'phone': row['phone'],
    };

    final res = await client.from('users').insert(mapped).execute();
    if (res.error != null) {
      print('Failed insert id ${row['id']}: ${res.error!.message}');
    } else {
      print('Inserted id ${row['id']}');
    }
  }

  await db.close();
  print('Done');
}
