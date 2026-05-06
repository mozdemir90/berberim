import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/shop_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsAsyncValue = ref.watch(shopsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Berber Keşfet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Berber Ara...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: shopsAsyncValue.when(
              data: (shops) {
                if (shops.isEmpty) {
                  return const Center(child: Text('Berber bulunamadı.'));
                }
                return ListView.builder(
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    final shop = shops[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.store)),
                        title: Text(shop['name'] ?? ''),
                        subtitle: Text('${shop['address'] ?? ''}\n1.2 km yakınınızda'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            Text('${shop['average_rating'] ?? 0.0}'),
                          ],
                        ),
                        onTap: () {
                           context.push('/shop/${shop['id']}', extra: shop);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Hata: $e')),
            ),
          )
        ],
      ),
    );
  }
}
