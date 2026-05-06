import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/appointment_provider.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isBarber = authState.role == 'BARBER';

    return isBarber ? const _BarberScheduleView() : const _CustomerAppointmentsView();
  }
}

// --- Müşteri Görünümü ---
class _CustomerAppointmentsView extends StatelessWidget {
  const _CustomerAppointmentsView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Randevularım'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Yaklaşan'),
              Tab(text: 'Geçmiş'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAppointmentList([
              _AppointmentData(
                shopName: 'Asil Erkek Kuaförü',
                services: 'Saç Kesimi, Sakal Traşı',
                date: '15 Mayıs',
                time: '14:30',
                status: 'Onaylandı',
                statusColor: Colors.teal,
                price: '₺150',
              ),
            ]),
            _buildAppointmentList([]),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<_AppointmentData> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Randevu bulunmuyor.', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(item.status, style: TextStyle(color: item.statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.services, style: const TextStyle(color: Colors.grey)),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF1D8B96)),
                        const SizedBox(width: 8),
                        Text('${item.date} • ${item.time}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(item.price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A5F))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- Berber Görünümü ---
class _BarberScheduleView extends ConsumerStatefulWidget {
  const _BarberScheduleView();

  @override
  ConsumerState<_BarberScheduleView> createState() => _BarberScheduleViewState();
}

class _BarberScheduleViewState extends ConsumerState<_BarberScheduleView> {
  DateTime selectedDate = DateTime.now();
  bool isTimelineView = false;

  @override
  Widget build(BuildContext context) {
    final allAppointments = ref.watch(barberAppointmentsProvider);
    final appointments = allAppointments.where((app) => 
      app.date.year == selectedDate.year &&
      app.date.month == selectedDate.month &&
      app.date.day == selectedDate.day
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Takvim'),
        actions: [
          IconButton(
            icon: Icon(isTimelineView ? Icons.view_list : Icons.view_agenda_outlined),
            onPressed: () => setState(() => isTimelineView = !isTimelineView),
            tooltip: isTimelineView ? 'Liste Görünümü' : 'Zaman Çizelgesi',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHorizontalCalendar(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Color(0xFF1D8B96)),
                SizedBox(width: 8),
                Text('Randevu Akışı', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: isTimelineView 
                ? _buildTimelineView(appointments)
                : _buildListView(appointments),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: appointments.length,
      itemBuilder: (context, index) => _buildBarberActionCard(appointments[index]),
    );
  }

  Widget _buildTimelineView(List<Appointment> appointments) {
    final hours = List.generate(17, (index) => 8 + index); // 08:00 - 24:00

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: hours.length,
      itemBuilder: (context, index) {
        final hour = hours[index];
        final timeStr = '${hour.toString().padLeft(2, '0')}:00';
        final hourAppointments = appointments.where((a) => a.time.startsWith('${hour.toString().padLeft(2, '0')}:')).toList();

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 50,
                child: Column(
                  children: [
                    Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    Expanded(child: Container(width: 1, color: Colors.grey[300])),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    if (hourAppointments.isEmpty)
                      const SizedBox(height: 40)
                    else
                      ...hourAppointments.map((app) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildBarberActionCard(app, isCompact: true),
                      )).toList(),
                    const Divider(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Bu tarih için randevu bulunmuyor.', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildHorizontalCalendar() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          
          return GestureDetector(
            onTap: () => setState(() => selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1D8B96) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey[200]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'tr_TR').format(date).toUpperCase(),
                    style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF1E3A5F)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBarberActionCard(Appointment appointment, {bool isCompact = false}) {
    return Card(
      margin: EdgeInsets.only(bottom: isCompact ? 4 : 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isCompact ? 12 : 16)),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 8 : 16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: isCompact ? 15 : 20,
                  backgroundColor: const Color(0xFFF1F5F9), 
                  child: Icon(Icons.person, color: const Color(0xFF1E3A5F), size: isCompact ? 18 : 24)
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.clientName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isCompact ? 14 : 16)),
                      Text(appointment.services, style: TextStyle(color: Colors.grey, fontSize: isCompact ? 11 : 13)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(appointment.time, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isCompact ? 14 : 16, color: const Color(0xFF1D8B96))),
                    if (!isCompact) Text(appointment.price, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            if (!isCompact) ...[
              const Divider(height: 24),
              if (appointment.status == 'Bekliyor')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showCancelDialog(appointment.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Reddet'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(barberAppointmentsProvider.notifier).updateStatus(appointment.id, 'Onaylandı');
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Randevu onaylandı!')));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D8B96)),
                        child: const Text('Onayla'),
                      ),
                    ),
                  ],
                )
              else if (appointment.status == 'Onaylandı')
                ElevatedButton(
                  onPressed: () {
                    ref.read(barberAppointmentsProvider.notifier).updateStatus(appointment.id, 'Tamamlandı');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Randevu tamamlandı olarak işaretlendi!')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], minimumSize: const Size(double.infinity, 45)),
                  child: const Text('Tamamlandı İşaretle'),
                )
              else
                _buildStatusChip(appointment),
            ],
            if (isCompact && appointment.status != 'Bekliyor') 
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: _buildStatusChip(appointment),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(Appointment appointment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: appointment.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          appointment.status,
          style: TextStyle(color: appointment.statusColor, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  void _showCancelDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Randevuyu İptal Et'),
        content: const Text('Bu randevuyu iptal etmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () {
              ref.read(barberAppointmentsProvider.notifier).updateStatus(id, 'Reddedildi');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Randevu reddedildi.')));
            },
            child: const Text('Evet, İptal Et', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AppointmentData {
  final String shopName;
  final String services;
  final String date;
  final String time;
  final String status;
  final Color statusColor;
  final String price;

  _AppointmentData({
    required this.shopName,
    required this.services,
    required this.date,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.price,
  });
}
