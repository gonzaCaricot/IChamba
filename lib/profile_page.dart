import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'services/credentials_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  bool _loading = false;

  String _role = 'usuario';
  String? _roleRequest;

  @override
  void initState() {
    super.initState();
    SupabaseService.fetchUserProfile().then((row) {
      if (!mounted) return;
      if (row != null) {
        _nameController.text = row['first_name'] ?? '';
        _lastNameController.text = row['last_name'] ?? '';
        _emailController.text = row['email'] ?? '';
        _phoneController.text = row['phone'] ?? '';
        _cityController.text = row['city'] ?? '';
        _neighborhoodController.text = row['neighborhood'] ?? '';
        setState(() {
          _role = row['role'] ?? 'usuario';
          _roleRequest = row['role_request'];
        });
      } else {
        final user = SupabaseService.currentUser();
        if (user != null) {
          _nameController.text = user.userMetadata?['first_name'] ?? '';
          _lastNameController.text = user.userMetadata?['last_name'] ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = user.userMetadata?['phone'] ?? '';
          _cityController.text = user.userMetadata?['city'] ?? '';
          _neighborhoodController.text =
              user.userMetadata?['neighborhood'] ?? '';
          setState(() {
            _role = user.userMetadata?['role'] ?? 'usuario';
            _roleRequest = user.userMetadata?['role_request'];
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final current = SupabaseService.currentUser();
      final data = <String, dynamic>{
        'first_name': _nameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
        'neighborhood': _neighborhoodController.text.trim(),
      };
      if (current?.id != null) data['auth_id'] = current!.id;

      await SupabaseService.upsertUser(data);
      if (current?.email != null) {
        await CredentialsStore.saveLastEmail(current!.email!);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil guardado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestRole(String requestedRole) async {
    setState(() => _loading = true);
    try {
      final current = SupabaseService.currentUser();
      final data = <String, dynamic>{
        'role_request': requestedRole,
      };
      if (current?.id != null) data['auth_id'] = current!.id;
      await SupabaseService.upsertUser(data);
      setState(() {
        _roleRequest = requestedRole;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Solicitud enviada para ser "$requestedRole"')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleDisplay = {
      'usuario': 'Usuario',
      'autenticado': 'Autenticado',
      'ofrecedor': 'Ofrecedor',
      'admin': 'Administrador',
    }[_role] ?? _role;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    v != null && v.trim().isNotEmpty ? null : 'Ingrese nombre',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (v) =>
                    v != null && v.trim().isNotEmpty ? null : 'Ingrese apellido',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Mail'),
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Email inválido',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Celular'),
                validator: (v) =>
                    v != null && v.trim().isNotEmpty ? null : 'Ingrese celular',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Ciudad'),
                validator: (v) =>
                    v != null && v.trim().isNotEmpty ? null : 'Ingrese ciudad',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _neighborhoodController,
                decoration: const InputDecoration(labelText: 'Barrio'),
                validator: (v) =>
                    v != null && v.trim().isNotEmpty ? null : 'Ingrese barrio',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Rol: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(roleDisplay, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              if (_roleRequest != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Solicitud pendiente para ser "${_roleRequest!}"',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_loading || _role == 'autenticado' || _roleRequest == 'autenticado')
                          ? null
                          : () => _requestRole('autenticado'),
                      child: const Text('Solicitar ser Autenticado'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_loading || _role == 'ofrecedor' || _roleRequest == 'ofrecedor')
                          ? null
                          : () => _requestRole('ofrecedor'),
                      child: const Text('Solicitar ser Ofrecedor'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}