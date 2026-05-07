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
class _CustomerAppointmentsView extends ConsumerWidget {
  const _CustomerAppointmentsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAppointments = ref.watch(barberAppointmentsProvider);
    
    // Geçici çözüm: Müşteri kendi randevularını görebilsin diye 'Müşteri (Siz)' ismine göre filtrelenir
    final customerAppointments = allAppointments
        .where((app) => app.clientName == 'Müşteri (Siz)')
        .toList();

    // Yaklaşan ve geçmiş olarak ikiye ayır
    final now = DateTime.now();
    final upcoming = customerAppointments.where((app) => 
        (app.status == 'Bekliyor' || app.status == 'Onaylandı') && 
        app.date.isAfter(now.subtract(const Duration(days: 1)))
    ).toList();
    
    final past = customerAppointments.where((app) => 
        app.status == 'Tamamlandı' || 
        app.status == 'Reddedildi' || 
        app.date.isBefore(now.subtract(const Duration(days: 1)))
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevularım'),
      ),
      body: customerAppointments.isEmpty
          ? const Center(child: Text('Randevu bulunmuyor.', style: TextStyle(color: Colors.grey)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (upcoming.isNotEmpty) ...[
                  const Text('Yaklaşan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                  const SizedBox(height: 12),
                  ...upcoming.map((app) => _buildAppointmentCard(app)),
                  const SizedBox(height: 24),
                ],
                if (past.isNotEmpty) ...[
                  const Text('Geçmiş', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                  const SizedBox(height: 12),
                  ...past.map((app) => _buildAppointmentCard(app)),
                ],
              ],
            ),
    );
  }

  Widget _buildAppointmentCard(Appointment item) {
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
                Text(item.shopName ?? 'Berberim', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
            if (item.barberName != null && item.barberName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('Usta: ${item.barberName}', style: const TextStyle(color: Color(0xFF1D8B96), fontSize: 13, fontWeight: FontWeight.w600)),
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
                    Text('${DateFormat('d MMM', 'tr_TR').format(item.date)} • ${item.time}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(item.price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A5F))),
              ],
            ),
          ],
        ),
      ),
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
                      if (appointment.barberName != null && appointment.barberName!.isNotEmpty)
                        Text('Usta: ${appointment.barberName}', style: TextStyle(color: const Color(0xFF1D8B96), fontSize: isCompact ? 11 : 13, fontWeight: FontWeight.w600)),
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

