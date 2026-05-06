import 'package:flutter/material.dart';
import 'barber_home_screen.dart';
import 'barber_dashboard_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../appointments/presentation/screens/appointments_screen.dart';

class BarberMainNavigationScreen extends StatefulWidget {
  const BarberMainNavigationScreen({super.key});

  @override
  State<BarberMainNavigationScreen> createState() => _BarberMainNavigationScreenState();
}

class _BarberMainNavigationScreenState extends State<BarberMainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const BarberHomeScreen(),
    const BarberDashboardScreen(),
    const AppointmentsScreen(), // Randevular ekranı hem müşteri hem berber için uyarlanabilir.
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1D8B96),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'İşletme'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Randevular'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
