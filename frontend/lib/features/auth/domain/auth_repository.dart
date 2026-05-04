import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio;

  // baseUrl, .env veya Config'den alınmalıdır.
  // Android Emulator için 10.0.2.2 kullanılır.
  final String _baseUrl = 'http://10.0.2.2:8000/api/v1/auth';

  AuthRepository(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/login',
        data: {
          'username': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final detail = e.response!.data['detail'];
        if (detail is String) {
          throw Exception(detail);
        } else if (detail is List && detail.isNotEmpty) {
           throw Exception(detail.first['msg'] ?? 'Doğrulama hatası');
        }
      }
      throw Exception('Giriş başarısız oldu: ${e.message}');
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu: $e');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, {String role = 'CUSTOMER'}) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/register',
        data: {
          'email': email,
          'password': password,
          'role': role,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final detail = e.response!.data['detail'];
        if (detail is String) {
          throw Exception(detail);
        } else if (detail is List && detail.isNotEmpty) {
           throw Exception(detail.first['msg'] ?? 'Doğrulama hatası');
        }
      }
      throw Exception('Kayıt başarısız oldu: ${e.message}');
    } catch (e) {
       throw Exception('Beklenmeyen bir hata oluştu: $e');
    }
  }
}
