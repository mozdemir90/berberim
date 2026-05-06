import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shop_provider.dart';

class BarberHomeScreen extends ConsumerWidget {
  const BarberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myShopAsync = ref.watch(myShopProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 60,
            backgroundColor: const Color(0xFF1E3A5F),
            title: const Text(
              'İşletme Özeti',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hoş Geldiniz, Berberim!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Bugünkü dükkan performansınız burada.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  
                  // Stats Cards
                  Row(
                    children: [
                      _buildStatCard('Bugün', '12', Icons.calendar_today, Colors.blue),
                      const SizedBox(width: 12),
                      _buildStatCard('Kazanç', '₺1,450', Icons.payments_outlined, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatCard('Bekleyen', '3', Icons.hourglass_empty, Colors.orange),
                      const SizedBox(width: 12),
                      _buildStatCard('Puan', '4.9', Icons.star_border, Colors.purple),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'Sıradaki Randevular',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildNextAppointment('Ahmet Yılmaz', '14:30', 'Saç Kesimi'),
                  _buildNextAppointment('Mehmet Can', '15:15', 'Sakal Traşı'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildNextAppointment(String name, String time, String service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFF1F5F9),
          child: Icon(Icons.person, color: Color(0xFF1E3A5F)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(service),
        trailing: Text(time, style: const TextStyle(color: Color(0xFF1D8B96), fontWeight: FontWeight.bold)),
      ),
    );
  }
}
