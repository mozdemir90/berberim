import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(context),
                  const SizedBox(height: 24),
                  _buildCampaignsCarousel(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Popüler Kategoriler'),
                  const SizedBox(height: 12),
                  _buildCategoriesGrid(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Sizin İçin Mağaza Seçkisi'),
                  const SizedBox(height: 12),
                  _buildStoreCarousel(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Berberlerden İlanlar'),
                  const SizedBox(height: 12),
                  _buildAdsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF1E3A5F),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 30,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.multiply),
              child: Image.asset(
                'assets/images/logo.png',
                color: Colors.white,
                colorBlendMode: BlendMode.lighten,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Berberim',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
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
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Merhaba, Fırat!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E3A5F),
              ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Bugün kendini şımartmaya ne dersin?',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Tümünü Gör', style: TextStyle(color: Color(0xFF1D8B96))),
        ),
      ],
    );
  }

  Widget _buildCampaignsCarousel() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          final colors = [const Color(0xFF1D8B96), const Color(0xFF1E3A5F), Colors.orange[800]!];
          final texts = ['İlk Randevuya %20 İndirim!', 'Premium Bakım Setleri', 'Arkadaşını Getir Puan Kazan'];
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors[index], colors[index].withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(Icons.percent, size: 100, color: Colors.white.withOpacity(0.1)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('KAMPANYA', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        texts[index],
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: colors[index],
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Kuponu Al', style: TextStyle(fontSize: 13)),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      {'name': 'Saç Kesimi', 'icon': Icons.content_cut},
      {'name': 'Sakal Traşı', 'icon': Icons.face},
      {'name': 'Cilt Bakımı', 'icon': Icons.spa},
      {'name': 'Çocuk', 'icon': Icons.child_care},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((cat) {
        return Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Icon(cat['icon'] as IconData, color: const Color(0xFF1D8B96), size: 30),
            ),
            const SizedBox(height: 8),
            Text(cat['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStoreCarousel() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Center(child: Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mat Wax 100ml', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1),
                      const SizedBox(height: 4),
                      const Text('120.00 TL', style: TextStyle(color: Color(0xFF1D8B96), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.orange, size: 12),
                          Text(' 4.8', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdsSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.campaign, color: Colors.orange),
            ),
            title: const Text('Devren Satılık Berber Salonu', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Çankaya bölgesinde müşteri potansiyeli yüksek...'),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}
