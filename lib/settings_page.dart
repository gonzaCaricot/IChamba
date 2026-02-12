import 'package:flutter/material.dart';
import 'services/supabase_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loading = false;
  String _role = 'usuario';
  String? _roleRequest;

  final _pwFormKey = GlobalKey<FormState>();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final row = await SupabaseService.fetchUserProfile();
      if (row != null) {
        setState(() {
          _role = row['role'] ?? 'usuario';
          _roleRequest = row['role_request'];
        });
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestRole(String requestedRole) async {
    setState(() => _loading = true);
    try {
      await SupabaseService.upsertUser({'role_request': requestedRole});
      setState(() => _roleRequest = requestedRole);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud enviada para ser "$requestedRole"')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_pwFormKey.currentState!.validate()) return;
    final newPw = _newPwController.text.trim();
    setState(() => _loading = true);
    try {
      await SupabaseService.changePassword(newPw);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña actualizada')));
      _newPwController.clear();
      _confirmPwController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
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
      appBar: AppBar(title: const Text('Ajustes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Rol: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(roleDisplay, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            if (_roleRequest != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Solicitud pendiente para ser "${_roleRequest!}"', style: const TextStyle(color: Colors.orange)),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_loading || _role == 'autenticado' || _roleRequest == 'autenticado') ? null : () => _requestRole('autenticado'),
                    child: const Text('Solicitar ser Autenticado'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_loading || _role == 'ofrecedor' || _roleRequest == 'ofrecedor') ? null : () => _requestRole('ofrecedor'),
                    child: const Text('Solicitar ser Ofrecedor'),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('Cambiar contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Form(
              key: _pwFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _newPwController,
                    decoration: const InputDecoration(labelText: 'Nueva contraseña'),
                    obscureText: true,
                    validator: (v) => v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPwController,
                    decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
                    obscureText: true,
                    validator: (v) => v == _newPwController.text ? null : 'Las contraseñas no coinciden',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loading ? null : _changePassword,
                          child: const Text('Actualizar contraseña'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
