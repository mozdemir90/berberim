import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/shops/presentation/screens/customer_home_screen.dart';
import '../../features/shops/presentation/screens/barber_dashboard_screen.dart';
import '../../features/shops/presentation/screens/shop_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final role = prefs.getString('user_role');
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (token == null) {
        return isAuthRoute ? null : '/login';
      }

      if (isAuthRoute) {
        return role == 'BARBER' ? '/barber' : '/customer';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/customer',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '/barber',
        builder: (context, state) => const BarberDashboardScreen(),
      ),
      GoRoute(
        path: '/shop/:id',
        builder: (context, state) {
          final shop = state.extra as Map<String, dynamic>? ?? {};
          return ShopDetailScreen(shop: shop);
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
});
