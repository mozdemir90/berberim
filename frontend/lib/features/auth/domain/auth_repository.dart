import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio;

  // baseUrl, .env veya Config'den alınmalıdır.
  final String _baseUrl = 'http://localhost:8000/api/v1/auth';

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
      throw Exception((e.response?.data as Map?)?['detail'] ?? 'Giriş başarısız oldu.');
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
      throw Exception((e.response?.data as Map?)?['detail'] ?? 'Kayıt başarısız oldu.');
    }
  }
}
