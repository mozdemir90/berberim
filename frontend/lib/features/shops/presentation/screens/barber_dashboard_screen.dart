import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shop_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

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
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.cut, size: 80, color: Color(0xFF1D8B96)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: myShopAsync.when(
                data: (shop) {
                  if (shop.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Henüz işletme profilinizi oluşturmadınız.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 24),
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
                        Text(
                          'Dükkan: ${shop['name']}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: const Color(0xFF1E3A5F),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Adres: ${shop['address']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
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
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ustalarım', style: Theme.of(context).textTheme.titleMedium),
                            IconButton(
                              icon: const Icon(Icons.person_add),
                              onPressed: () => _showAddStaffDialog(context, ref, shop['id']),
                            )
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: (shop['staff'] as List<dynamic>? ?? []).isEmpty
                              ? const Center(child: Text('Henüz usta eklenmemiş.'))
                              : ListView.builder(
                                  itemCount: (shop['staff'] as List<dynamic>? ?? []).length,
                                  itemBuilder: (context, index) {
                                    final staff = shop['staff'][index];
                                    return ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: Color(0xFF1D8B96),
                                        child: Icon(Icons.person, color: Colors.white),
                                      ),
                                      title: Text(staff['name']),
                                      subtitle: Text(staff['is_available'] ? 'Müsait' : 'Meşgul'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _confirmDeleteStaff(context, ref, shop['id'], staff['id'], staff['name']),
                                      ),
                                    );
                                  },
                                ),
                        )
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Hata: $e',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(myShopProvider),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
              const SizedBox(height: 16),
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
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Fiyat (TL)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
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

  void _showAddStaffDialog(BuildContext context, WidgetRef ref, String shopId) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Usta Ekle'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Usta Adı Soyadı'),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(shopRepositoryProvider);
                try {
                  await repo.addStaff(shopId, {
                    'name': nameController.text,
                    'is_available': true,
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

  void _confirmDeleteStaff(BuildContext context, WidgetRef ref, String shopId, String staffId, String staffName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ustayı Sil'),
        content: Text('$staffName isimli ustayı silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () async {
              final repo = ref.read(shopRepositoryProvider);
              try {
                await repo.deleteStaff(shopId, staffId);
                Navigator.pop(context);
                ref.invalidate(myShopProvider);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
