import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
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
            title: const Text('Giriş Hatası'),
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
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                onPressed: _onLogin,
                child: const Text('Giriş Yap'),
              ),
            const SizedBox(height: 16),
            const Text('Veya', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Google login entegrasyonu
              },
              icon: const Icon(Icons.login),
              label: const Text('Google ile Giriş Yap'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Apple login entegrasyonu
              },
              icon: const Icon(Icons.apple),
              label: const Text('Apple ile Giriş Yap'),
            ),
            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text('Hesabın yok mu? Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}
