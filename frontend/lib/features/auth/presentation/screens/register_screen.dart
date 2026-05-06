import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'CUSTOMER';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    ref.read(authProvider.notifier).register(
      _emailController.text.trim(),
      _passwordController.text,
      role: _selectedRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Kayıt Hatası'),
            content: Text(next.errorMessage!.replaceAll('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tamam'),
              )
            ],
          ),
        );
      } else if (next.status == AuthStatus.authenticated) {
        if (next.role == 'BARBER') {
          context.go('/barber');
        } else {
          context.go('/customer');
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(labelText: 'Kayıt Tipi'),
              items: const [
                DropdownMenuItem(value: 'CUSTOMER', child: Text('Müşteri')),
                DropdownMenuItem(value: 'BARBER', child: Text('Berber/İşletme')),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedRole = val ?? 'CUSTOMER';
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Şifre'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (authState.status == AuthStatus.loading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _onRegister,
                child: const Text('Kayıt Ol'),
              ),
          ],
        ),
      ),
    );
  }
}
