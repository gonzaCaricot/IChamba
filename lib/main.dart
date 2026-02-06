import 'package:flutter/material.dart';
import 'register_page.dart';
import 'supabase_config.dart';
import 'services/supabase_service.dart';
import 'login_page.dart';
import 'main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('URL: $supabaseUrl');
  print('KEY: $supabaseAnonKey');
  await SupabaseService.init(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(IchambaApp());
}

class IchambaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ichamba',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
      routes: {'/register': (context) => RegisterPage()},
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ichamba')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Ir a Registro'),
          onPressed: () => Navigator.pushNamed(context, '/register'),
        ),
      ),
    );
  }
}
