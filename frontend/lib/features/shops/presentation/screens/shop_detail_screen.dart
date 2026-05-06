import 'package:flutter/material.dart';

class ShopDetailScreen extends StatelessWidget {
  final Map<String, dynamic> shop;

  const ShopDetailScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final services = shop['services'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(shop['name'] ?? 'Berber Detayı'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.store, size: 80, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop['name'] ?? '',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    shop['address'] ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  if (shop['description'] != null)
                    Text(shop['description']),
                  const SizedBox(height: 24),
                  Text(
                    'Hizmetler',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  if (services.isEmpty)
                    const Text('Henüz hizmet eklenmemiş.')
                  else
                    ...services.map((service) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(service['translation_key'] ?? 'Hizmet'),
                        subtitle: Text('${service['duration_minutes']} dk'),
                        trailing: Text('${service['price']} ${service['currency']}'),
                      );
                    }).toList(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Randevu / Sıra alma ekranına git
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sıra alma yakında eklenecek!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Sıraya Gir / Randevu Al'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
