import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/booking_provider.dart';
import '../providers/appointment_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> shop;

  const BookingScreen({super.key, required this.shop});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.shop['name'] ?? 'Randevu Al'),
        leading: IconButton(
          icon: Icon(_currentStep > 0 ? Icons.arrow_back : Icons.close),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
              _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Step Indicator
              _buildStepIndicator(),
              
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildServiceSelection(bookingState),
                    _buildStaffSelection(bookingState),
                    _buildDateTimeSelection(bookingState),
                  ],
                ),
              ),
              
              // Bottom Action Bar
              _buildBottomActionBar(bookingState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepCircle(0, 'Hizmetler', _currentStep >= 0),
          _stepLine(_currentStep >= 1),
          _stepCircle(1, 'Usta Seçimi', _currentStep >= 1),
          _stepLine(_currentStep >= 2),
          _stepCircle(2, 'Tarih & Saat', _currentStep >= 2),
        ],
      ),
    );
  }

  Widget _stepCircle(int index, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (index < _currentStep) {
          setState(() => _currentStep = index);
          _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF1D8B96) : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? const Color(0xFF1E3A5F) : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepLine(bool isActive) {
    return Container(
      width: 60,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
      color: isActive ? const Color(0xFF1D8B96) : Colors.grey[300],
    );
  }

  Widget _buildServiceSelection(BookingState state) {
    final services = widget.shop['services'] as List<dynamic>? ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final isSelected = state.selectedServices.any((s) => s['id'] == service['id']);

        return GestureDetector(
          onTap: () => ref.read(bookingProvider.notifier).toggleService(service),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF1D8B96) : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['translation_key'] ?? 'Hizmet',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${service['duration_minutes']} dk',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₺${service['price']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D8B96),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? const Color(0xFF1D8B96) : Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaffSelection(BookingState state) {
    final staffList = widget.shop['staff'] as List<dynamic>? ?? [];

    if (staffList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Bu dükkanda henüz usta tanımlanmamış.\nLütfen "Herhangi biri" seçeneği ile devam edin.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: staffList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          final isSelected = state.selectedStaff == null;
          return _buildStaffItem(
            name: 'Fark Etmez (Herhangi Biri)',
            isSelected: isSelected,
            onTap: () => ref.read(bookingProvider.notifier).selectStaff(null),
          );
        }

        final staff = staffList[index - 1];
        final isSelected = state.selectedStaff?['id'] == staff['id'];

        return _buildStaffItem(
          name: staff['name'],
          isSelected: isSelected,
          onTap: () => ref.read(bookingProvider.notifier).selectStaff(staff),
        );
      },
    );
  }

  Widget _buildStaffItem({required String name, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1D8B96) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFF1F5F9),
              child: Icon(Icons.person, color: Color(0xFF1D8B96)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFF1D8B96) : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelection(BookingState state) {
    final now = DateTime.now();
    final dates = List.generate(14, (index) => now.add(Duration(days: index)));
    
    final times = [
      '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
      '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
      '16:00', '16:30', '17:00', '17:30', '18:00', '18:30'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tarih Seçin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = state.selectedDate?.day == date.day && 
                                  state.selectedDate?.month == date.month;
                
                return GestureDetector(
                  onTap: () => ref.read(bookingProvider.notifier).selectDate(date),
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1D8B96) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE', 'tr_TR').format(date).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white70 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF1E3A5F),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          const Text('Saat Seçin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: times.length,
            itemBuilder: (context, index) {
              final time = times[index];
              final isSelected = state.selectedTime == time;
              final allAppointmentsAsync = ref.watch(shopAppointmentsProvider(widget.shop['id']));
              final allAppointments = allAppointmentsAsync.value ?? [];
              final selectedStaffName = state.selectedStaff?['name'] ?? 'Herhangi Biri';
              final selectedDate = state.selectedDate ?? now;
              
              final activeAppointmentsAtTime = allAppointments.where((app) => 
                app.date.year == selectedDate.year &&
                app.date.month == selectedDate.month &&
                app.date.day == selectedDate.day &&
                app.time == time &&
                app.status != 'Reddedildi' && 
                app.status != 'İptal'
              ).toList();

              bool isBooked = false;
              if (selectedStaffName == 'Herhangi Biri') {
                final staffCount = (widget.shop['staff'] as List<dynamic>? ?? []).length;
                final totalCapacity = staffCount > 0 ? staffCount : 1;
                isBooked = activeAppointmentsAtTime.length >= totalCapacity;
              } else {
                isBooked = activeAppointmentsAtTime.any((app) => app.barberName == selectedStaffName);
              }

              return GestureDetector(
                onTap: isBooked ? null : () => ref.read(bookingProvider.notifier).selectTime(time),
                child: Container(
                  decoration: BoxDecoration(
                    color: isBooked 
                        ? Colors.grey[200] 
                        : (isSelected ? const Color(0xFF1D8B96) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1D8B96) : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      time,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isBooked 
                            ? Colors.grey[400] 
                            : (isSelected ? Colors.white : const Color(0xFF1E3A5F)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BookingState state) {
    final canGoNext = _currentStep == 0 
        ? state.selectedServices.isNotEmpty 
        : (_currentStep == 1 ? true : state.selectedTime != null);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep == 0)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Toplam Tutar', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text(
                    '₺${state.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                  ),
                ],
              ),
            ),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canGoNext ? _handleNext : null,
              child: Text(
                _currentStep == 0 
                    ? 'Usta Seçimine İlerle' 
                    : (_currentStep == 1 ? 'Tarih Seçimine İlerle' : 'Randevuyu Onayla')
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      final state = ref.read(bookingProvider);
      
      try {
        final shopId = widget.shop['id'];
        final serviceIds = state.selectedServices.map((s) => s['id'].toString()).toList();
        final staffId = state.selectedStaff?['id']?.toString();
        
        String? scheduledTimeIso;
        if (state.selectedDate != null && state.selectedTime != null) {
          final timeParts = state.selectedTime!.split(':');
          final scheduledTime = DateTime(
            state.selectedDate!.year, 
            state.selectedDate!.month, 
            state.selectedDate!.day, 
            int.parse(timeParts[0]), 
            int.parse(timeParts[1])
          );
          scheduledTimeIso = scheduledTime.toUtc().toIso8601String();
        }

        await ref.read(barberAppointmentsProvider.notifier).bookAppointment({
          'shop_id': shopId,
          'service_ids': serviceIds,
          'staff_id': staffId,
          'type': 'SCHEDULED', // Assuming scheduled for now
          'scheduled_time': scheduledTimeIso,
        });

        ref.invalidate(shopAppointmentsProvider(shopId));

        _showSuccessDialog();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF1D8B96), size: 80),
            const SizedBox(height: 16),
            const Text(
              'Randevunuz Alındı!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Randevunuz berberin onayına gönderildi. Statüsünü "Randevularım" sayfasından takip edebilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(bookingProvider.notifier).reset();
                Navigator.of(context).pop(); // Dialog
                Navigator.of(context).pop(); // Booking Screen
              },
              child: const Text('Tamam'),
            ),
          ],
        ),
      ),
    );
  }
}
