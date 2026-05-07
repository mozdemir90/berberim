import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingState {
  final List<Map<String, dynamic>> selectedServices;
  final DateTime? selectedDate;
  final String? selectedTime;
  final Map<String, dynamic>? selectedStaff;
  final double totalAmount;

  BookingState({
    this.selectedServices = const [],
    DateTime? selectedDate,
    this.selectedTime,
    this.selectedStaff,
    this.totalAmount = 0.0,
  }) : selectedDate = selectedDate ?? DateTime.now();

  BookingState copyWith({
    List<Map<String, dynamic>>? selectedServices,
    DateTime? selectedDate,
    String? selectedTime,
    Map<String, dynamic>? selectedStaff,
    double? totalAmount,
  }) {
    return BookingState(
      selectedServices: selectedServices ?? this.selectedServices,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedStaff: selectedStaff ?? this.selectedStaff,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(BookingState(selectedDate: DateTime.now()));

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

  void selectStaff(Map<String, dynamic>? staff) {
    state = BookingState(
      selectedServices: state.selectedServices,
      selectedDate: state.selectedDate,
      selectedTime: state.selectedTime,
      selectedStaff: staff,
      totalAmount: state.totalAmount,
    );
  }

  void reset() {
    state = BookingState(selectedDate: DateTime.now());
  }
}

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier();
});
