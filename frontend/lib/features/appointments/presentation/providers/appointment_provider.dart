import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Appointment {
  final String id;
  final String clientName;
  final String? barberName;
  final String? shopName;
  final String services;
  final String time;
  final String price;
  final String status; // 'Bekliyor', 'Onaylandı', 'Tamamlandı', 'Reddedildi'
  final Color statusColor;
  final DateTime date;

  Appointment({
    required this.id,
    required this.clientName,
    this.barberName,
    this.shopName,
    required this.services,
    required this.time,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.date,
  });

  Appointment copyWith({String? status, Color? statusColor}) {
    return Appointment(
      id: id,
      clientName: clientName,
      barberName: barberName,
      shopName: shopName,
      services: services,
      time: time,
      price: price,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      date: date,
    );
  }
}

class BarberAppointmentsNotifier extends StateNotifier<List<Appointment>> {
  final Ref ref;
  BarberAppointmentsNotifier(this.ref) : super(_generateInitialAppointments());

  static List<Appointment> _generateInitialAppointments() {
    final now = DateTime.now();
    return [
      Appointment(
        id: '1',
        clientName: 'Fırat Yılmaz',
        time: '10:30',
        services: 'Saç Kesimi, Yıkama',
        price: '₺180',
        status: 'Bekliyor',
        statusColor: Colors.orange,
        date: now,
      ),
      Appointment(
        id: '2',
        clientName: 'Ahmet Can',
        time: '11:45',
        services: 'Sakal Traşı',
        price: '₺80',
        status: 'Onaylandı',
        statusColor: Colors.teal,
        date: now,
      ),
      Appointment(
        id: '3',
        clientName: 'Mehmet Demir',
        time: '14:00',
        services: 'Premium Bakım',
        price: '₺350',
        status: 'Tamamlandı',
        statusColor: Colors.grey,
        date: now,
      ),
      Appointment(
        id: '4',
        clientName: 'Caner Öz',
        time: '09:00',
        services: 'Saç Kesimi',
        price: '₺120',
        status: 'Bekliyor',
        statusColor: Colors.orange,
        date: now.add(const Duration(days: 1)),
      ),
    ];
  }

  void addAppointment(Appointment appointment) {
    state = [...state, appointment];
  }

  void updateStatus(String id, String newStatus) {
    state = [
      for (final app in state)
        if (app.id == id)
          _updateAndHandleStats(app, newStatus)
        else
          app,
    ];
  }

  Appointment _updateAndHandleStats(Appointment app, String newStatus) {
    if (newStatus == 'Tamamlandı' && app.status != 'Tamamlandı') {
      final priceNum = double.tryParse(app.price.replaceAll('₺', '')) ?? 0.0;
      ref.read(barberStatsProvider.notifier).addEarnings(priceNum);
    }
    return app.copyWith(
      status: newStatus,
      statusColor: _getColorForStatus(newStatus),
    );
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'Onaylandı':
        return Colors.teal;
      case 'Tamamlandı':
        return Colors.grey;
      case 'Reddedildi':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

final barberAppointmentsProvider =
    StateNotifierProvider<BarberAppointmentsNotifier, List<Appointment>>((ref) {
  return BarberAppointmentsNotifier(ref);
});

class BarberStats {
  final double totalEarnings;
  final int totalAppointments;
  final double averageRating;

  BarberStats({
    this.totalEarnings = 12450.0,
    this.totalAppointments = 142,
    this.averageRating = 4.9,
  });

  BarberStats copyWith({
    double? totalEarnings,
    int? totalAppointments,
    double? averageRating,
  }) {
    return BarberStats(
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalAppointments: totalAppointments ?? this.totalAppointments,
      averageRating: averageRating ?? this.averageRating,
    );
  }
}

class BarberStatsNotifier extends StateNotifier<BarberStats> {
  BarberStatsNotifier() : super(BarberStats());

  void addEarnings(double amount) {
    state = state.copyWith(
      totalEarnings: state.totalEarnings + amount,
      totalAppointments: state.totalAppointments + 1,
    );
  }
}

final barberStatsProvider = StateNotifierProvider<BarberStatsNotifier, BarberStats>((ref) {
  return BarberStatsNotifier();
});
