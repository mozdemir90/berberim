import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Isar database ve EasyLocalization başlatmaları burada yapılacak.

  runApp(
    const ProviderScope(
      child: BerberApp(),
    ),
  );
}

class BerberApp extends ConsumerWidget {
  const BerberApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Berber & Müşteri Ağı',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: goRouter,
    );
  }
}

// core/routing/app_router.dart'a taşınacak yapı
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      // Diğer rotalar: /login, /shop/:id, /appointments vb.
    ],
  );
});

// Geçici HomeScreen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Berber Uygulaması Anasayfa')),
      body: const Center(
        child: Text('Uygulama İskeleti Hazır!'),
      ),
    );
  }
}
