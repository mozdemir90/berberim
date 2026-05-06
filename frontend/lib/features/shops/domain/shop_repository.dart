import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_constants.dart';

class ShopRepository {
  final Dio _dio;
  final String _baseUrl = '${ApiConstants.baseUrl}/shops';

  ShopRepository(this._dio);

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<dynamic>> getShops({String? search}) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '$_baseUrl/',
        queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
        options: options,
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e, 'Berberler yüklenirken hata oluştu.');
    }
  }

  Future<Map<String, dynamic>> getMyShop() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('$_baseUrl/my', options: options);
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {}; // Dükkan yok
      }
      throw _handleError(e, 'İşletme bilgileriniz alınamadı.');
    }
  }

  Future<Map<String, dynamic>> createShop(Map<String, dynamic> shopData) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post('$_baseUrl/', data: shopData, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'İşletme oluşturulamadı.');
    }
  }

  Future<Map<String, dynamic>> addService(String shopId, Map<String, dynamic> serviceData) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post('$_baseUrl/$shopId/services', data: serviceData, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Hizmet eklenemedi.');
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
}
