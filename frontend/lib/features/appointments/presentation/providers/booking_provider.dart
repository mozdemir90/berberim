import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingState {
  final List<Map<String, dynamic>> selectedServices;
  final DateTime? selectedDate;
  final String? selectedTime;
  final double totalAmount;

  BookingState({
    this.selectedServices = const [],
    this.selectedDate,
    this.selectedTime,
    this.totalAmount = 0.0,
  });

  BookingState copyWith({
    List<Map<String, dynamic>>? selectedServices,
    DateTime? selectedDate,
    String? selectedTime,
    double? totalAmount,
  }) {
    return BookingState(
      selectedServices: selectedServices ?? this.selectedServices,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(BookingState());

  void toggleService(Map<String, dynamic> service) {
    final currentServices = List<Map<String, dynamic>>.from(state.selectedServices);
    final index = currentServices.indexWhere((s) => s['id'] == service['id']);

    if (index >= 0) {
      currentServices.removeAt(index);
    } else {
      currentServices.add(service);
    }

    double total = 0;
    for (var s in currentServices) {
      total += (s['price'] as num).toDouble();
    }

    state = state.copyWith(
      selectedServices: currentServices,
      totalAmount: total,
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date, selectedTime: null);
  }

  void selectTime(String time) {
    state = state.copyWith(selectedTime: time);
  }

  void reset() {
    state = BookingState();
  }
}

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier();
});
