import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../shops/presentation/providers/shop_provider.dart';
import '../../domain/appointment_repository.dart';

// Repository Provider
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AppointmentRepository(dio);
});

final shopAppointmentsProvider = FutureProvider.family<List<Appointment>, String>((ref, shopId) async {
  final repo = ref.watch(appointmentRepositoryProvider);
  final data = await repo.getShopAppointments(shopId);
  return data.map((e) => Appointment.fromJson(e)).toList();
});

class Appointment {
  final String id;
  final String clientName;
  final String? barberName;
  final String? shopName;
  final String services;
  final String time;
  final String price;
  final String status;
  final Color statusColor;
  final DateTime date;
  
  final String? customerId;
  final String? shopId;
  final String? staffId;
  final int? queueNumber;
  final String? type;

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
    this.customerId,
    this.shopId,
    this.staffId,
    this.queueNumber,
    this.type,
  });

  factory Appointment.fromJson(Map<String, dynamic> json, {String? userName}) {
    String uiStatus = 'Bekliyor';
    Color uiColor = Colors.orange;
    switch(json['status']) {
      case 'PENDING': uiStatus = 'Bekliyor'; uiColor = Colors.orange; break;
      case 'APPROVED': uiStatus = 'Onaylandı'; uiColor = Colors.teal; break;
      case 'COMPLETED': uiStatus = 'Tamamlandı'; uiColor = Colors.grey; break;
      case 'REJECTED': uiStatus = 'Reddedildi'; uiColor = Colors.red; break;
      case 'CANCELLED': uiStatus = 'İptal'; uiColor = Colors.red; break;
    }

    final servicesList = json['services'] as List<dynamic>? ?? [];
    final servicesText = servicesList.map((s) => s['translation_key']).join(', ');
    
    double totalPrice = 0;
    for (var s in servicesList) {
       totalPrice += (s['price'] as num).toDouble();
    }
    
    DateTime date = DateTime.now();
    if (json['scheduled_time'] != null) {
      String timeStr = json['scheduled_time'];
      if (!timeStr.endsWith('Z')) timeStr += 'Z';
      date = DateTime.parse(timeStr).toLocal();
    } else if (json['created_at'] != null) {
      String timeStr = json['created_at'];
      if (!timeStr.endsWith('Z')) timeStr += 'Z';
      date = DateTime.parse(timeStr).toLocal();
    }
    
    String timeText = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

    return Appointment(
      id: json['id'],
      clientName: json['customer']?['email']?.split('@')[0] ?? userName ?? 'Müşteri',
      barberName: json['staff']?['name'], 
      shopName: json['shop']?['name'] ?? 'Berberim',
      services: servicesText.isEmpty ? 'Hizmet' : servicesText,
      time: timeText,
      price: '₺$totalPrice',
      status: uiStatus,
      statusColor: uiColor,
      date: date,
      customerId: json['customer_id'],
      shopId: json['shop_id'],
      staffId: json['staff_id'],
      queueNumber: json['queue_number'],
      type: json['type'],
    );
  }

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
      customerId: customerId,
      shopId: shopId,
      staffId: staffId,
      queueNumber: queueNumber,
      type: type,
    );
  }
}

class AppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  WebSocketChannel? _channel;

  @override
  Future<List<Appointment>> build() async {
    return _fetchAppointments();
  }

  Future<List<Appointment>> _fetchAppointments() async {
    final authState = ref.read(authProvider);
    final repo = ref.read(appointmentRepositoryProvider);
    
    if (authState.status != AuthStatus.authenticated) return [];

    List<dynamic> data = [];
    if (authState.role == 'BARBER') {
      try {
        final myShop = await ref.read(myShopProvider.future);
        if (myShop != null && myShop['id'] != null) {
          data = await repo.getShopAppointments(myShop['id']);
        }
      } catch (e) {
        // Shop not found or error
        data = [];
      }
    } else {
      data = await repo.getMyAppointments();
    }

    final userName = 'Müşteri (Siz)';
    final list = data.map((e) => Appointment.fromJson(e, userName: userName)).toList();
    
    // Auto-connect to websocket if there's a shopId in the first appointment
    if (list.isNotEmpty && list.first.shopId != null && _channel == null) {
      _connectWebSocket(list.first.shopId!);
    }
    
    return list;
  }

  void _connectWebSocket(String shopId) {
    final token = ref.read(authProvider).token;
    if (token == null) return;

    final wsUrl = Uri.parse('ws://127.0.0.1:8000/api/v1/ws/queue/$shopId?token=$token');
    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message);
          if (data['event'] == 'appointment_status_changed' || data['event'] == 'appointment_booked') {
            ref.invalidateSelf(); // Refresh list on new events
          }
        } catch (e) {
          debugPrint('WebSocket message error: $e');
        }
      },
      onError: (error) => debugPrint('WebSocket error: $error'),
      onDone: () => debugPrint('WebSocket disconnected'),
    );
  }

  Future<void> bookAppointment(Map<String, dynamic> data) async {
    final repo = ref.read(appointmentRepositoryProvider);
    await repo.bookAppointment(data);
    ref.invalidateSelf();
  }

  Future<void> updateStatus(String id, String newStatus) async {
    final repo = ref.read(appointmentRepositoryProvider);
    
    String backendStatus = 'PENDING';
    switch(newStatus) {
      case 'Bekliyor': backendStatus = 'PENDING'; break;
      case 'Onaylandı': backendStatus = 'APPROVED'; break;
      case 'Tamamlandı': backendStatus = 'COMPLETED'; break;
      case 'Reddedildi': backendStatus = 'REJECTED'; break;
      case 'İptal': backendStatus = 'CANCELLED'; break;
    }

    await repo.updateAppointmentStatus(id, backendStatus);
    
    if (newStatus == 'Tamamlandı') {
       // Mock earnings update
       final app = state.value?.firstWhere((a) => a.id == id);
       if (app != null) {
          final priceNum = double.tryParse(app.price.replaceAll('₺', '')) ?? 0.0;
          ref.read(barberStatsProvider.notifier).addEarnings(priceNum);
       }
    }
    ref.invalidateSelf();
  }

  @override
  void dispose() {
    _channel?.sink.close();
  }
}

final barberAppointmentsProvider = AsyncNotifierProvider<AppointmentsNotifier, List<Appointment>>(() {
  return AppointmentsNotifier();
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

