import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_constants.dart';

class AppointmentRepository {
  final Dio _dio;
  final String _baseUrl = '${ApiConstants.baseUrl}/appointments';

  AppointmentRepository(this._dio);

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<Map<String, dynamic>> bookAppointment(Map<String, dynamic> data) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post('$_baseUrl/book', data: data, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Randevu alınırken bir hata oluştu');
    }
  }

  Exception _handleError(DioException e, String defaultMessage) {
    if (e.response != null && e.response!.data is Map) {
      final detail = e.response!.data['detail'];
      if (detail is String) return Exception(detail);
      if (detail is List && detail.isNotEmpty) return Exception(detail.first['msg'] ?? 'Hata');
    }
    return Exception('$defaultMessage: ${e.message}');
  }

  Future<List<dynamic>> getMyAppointments() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('$_baseUrl/me', options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Randevular getirilirken bir hata oluştu');
    }
  }

  Future<List<dynamic>> getShopAppointments(String shopId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('$_baseUrl/shop/$shopId', options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Dükkan randevuları getirilirken bir hata oluştu');
    }
  }

  Future<Map<String, dynamic>> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.put('$_baseUrl/$appointmentId/status', data: {'status': status}, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Randevu durumu güncellenirken bir hata oluştu');
    }
  }
}
