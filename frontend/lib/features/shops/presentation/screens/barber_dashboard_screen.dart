import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shop_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class BarberDashboardScreen extends ConsumerWidget {
  const BarberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myShopAsync = ref.watch(myShopProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Berber Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          )
        ],
      ),
      body: myShopAsync.when(
        data: (shop) {
          if (shop.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Henüz işletme profilinizi oluşturmadınız.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showCreateShopDialog(context, ref),
                    child: const Text('İşletme Oluştur'),
                  )
                ],
              ),
            );
          }

          final services = shop['services'] as List<dynamic>? ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dükkan: ${shop['name']}', style: Theme.of(context).textTheme.titleLarge),
                Text('Adres: ${shop['address']}'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hizmetlerim', style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddServiceDialog(context, ref, shop['id']),
                    )
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return ListTile(
                        title: Text(service['translation_key']),
                        subtitle: Text('${service['duration_minutes']} dk'),
                        trailing: Text('${service['price']} ${service['currency']}'),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Hata: $e')),
      ),
    );
  }

  void _showCreateShopDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni İşletme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Dükkan Adı'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Adres'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(shopRepositoryProvider);
                try {
                  await repo.createShop({
                    'name': nameController.text,
                    'address': addressController.text,
                    'latitude': 0.0,
                    'longitude': 0.0,
                  });
                  Navigator.pop(context);
                  ref.invalidate(myShopProvider);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text('Oluştur'),
            ),
          ],
        );
      },
    );
  }

  void _showAddServiceDialog(BuildContext context, WidgetRef ref, String shopId) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Hizmet Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Hizmet Adı (Örn: Saç Kesimi)'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Fiyat (TL)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Süre (Dakika)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(shopRepositoryProvider);
                try {
                  await repo.addService(shopId, {
                    'translation_key': nameController.text,
                    'price': double.parse(priceController.text),
                    'duration_minutes': int.parse(durationController.text),
                    'currency': 'TRY',
                  });
                  Navigator.pop(context);
                  ref.invalidate(myShopProvider);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }
}
