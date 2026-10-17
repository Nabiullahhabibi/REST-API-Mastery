import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          // Android emulator: 10.0.2.2. Physical phone: use your computer's LAN IP.
          baseUrl:
              baseUrl ??
              const String.fromEnvironment(
                'API_BASE_URL',
                // defaultValue: 'http://10.0.2.2:3000/api/v1',
                defaultValue: 'http://192.168.0.100:3000/api/v1',
              ),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add Authorization here when the project later gains authentication.
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return _unwrap(response);
  }

  Future<dynamic> post(String path, {Object? data}) async {
    final response = await _dio.post(path, data: data);
    return _unwrap(response);
  }

  Future<dynamic> put(String path, {Object? data}) async {
    final response = await _dio.put(path, data: data);
    return _unwrap(response);
  }

  Future<dynamic> patch(String path, {Object? data}) async {
    final response = await _dio.patch(path, data: data);
    return _unwrap(response);
  }

  Future<void> delete(String path) async {
    final response = await _dio.delete(path);
    if (response.statusCode == 204) return; // 204 has no JSON body.
    _unwrap(response);
  }

  dynamic _unwrap(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) return response.data;

    final body = response.data;
    final message = body is Map<String, dynamic>
        ? (body['message']?.toString() ?? 'Request failed ($status)')
        : 'Request failed ($status)';
    throw ApiException(statusCode: status, message: message, body: body);
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.body,
  });
  final int statusCode;
  final String message;
  final dynamic body;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
