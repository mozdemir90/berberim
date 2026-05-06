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
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF1E3A5F),
            title: Row(
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.multiply),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 30,
                    color: Colors.white,
                    colorBlendMode: BlendMode.lighten,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Berber Keşfet', style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Berber Ara...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Son Ziyaretlerim',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                ),
                _buildRecentVisits(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Text(
                    'Tüm Berberler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                ),
              ],
            ),
          ),
          shopsAsyncValue.when(
            data: (shops) {
              if (shops.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Henüz kayıtlı berber bulunamadı.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final shop = shops[index];
                    return _buildShopCard(context, shop);
                  },
                  childCount: shops.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Hata: $e'))),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentVisits() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 3,
        itemBuilder: (context, index) {
          final mockData = [
            {'name': 'Asil Berber', 'date': '12 May'},
            {'name': 'Zeki Makas', 'date': '05 May'},
            {'name': 'Trend Salon', 'date': '28 Nis'},
          ];
          return Container(
            width: 100,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1D8B96).withOpacity(0.3), width: 1),
                  ),
                  child: const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFF8FAFC),
                    child: Icon(Icons.person, color: Color(0xFF1E3A5F), size: 30),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  mockData[index]['name']!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  mockData[index]['date']!,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, Map<String, dynamic> shop) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.store, color: Color(0xFF1D8B96)),
        ),
        title: Text(
          shop['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(shop['address'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: const [
                Icon(Icons.location_on, size: 14, color: Color(0xFF1D8B96)),
                SizedBox(width: 4),
                Text('1.2 km yakınınızda', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                '${shop['average_rating'] ?? 0.0}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ],
          ),
        ),
        onTap: () {
          context.push('/shop/${shop['id']}', extra: shop);
        },
      ),
    );
  }
}
