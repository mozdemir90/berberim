import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/shop_repository.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ShopRepository(dio);
});

// Arama metni state'i
final searchQueryProvider = StateProvider<String>((ref) => '');

// Berberleri getiren future provider
final shopsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(shopRepositoryProvider);
  final query = ref.watch(searchQueryProvider);
  return repository.getShops(search: query);
});

// Berberin kendi dükkanı
final myShopProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(shopRepositoryProvider);
  return repository.getMyShop();
});
