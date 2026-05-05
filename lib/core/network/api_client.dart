import 'package:dio/dio.dart';
import '../auth/token_manager.dart';
import 'api_exceptions.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  
  final Dio _dio;

  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Do not attach token for public routes (e.g., /auth/request-otp, /auth/verify-otp, /health)
          if (!options.path.contains('/auth/') && !options.path.contains('/health')) {
            final token = await TokenManager.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Transform DioException into custom ApiException
          final exception = _handleDioError(e);
          
          // Here we could potentially handle token refresh if implemented in backend
          if (exception is UnauthorizedException) {
            // E.g. emit an event to trigger a log out and redirect to login screen
            TokenManager.deleteToken();
          }
          
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: exception,
              response: e.response,
              type: e.type,
            )
          );
        },
      ),
    );
  }

  ApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.unknown) {
      return NetworkException('Network connection error');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;
      
      String message = 'Unknown error occurred';
      if (data is Map<String, dynamic> && data['message'] != null) {
        message = data['message'];
      }

      switch (statusCode) {
        case 400:
          return BadRequestException(message, data);
        case 401:
          return UnauthorizedException(message);
        case 403:
          return ForbiddenException(message);
        case 404:
          return NotFoundException(message);
        case 500:
          return ServerException(message);
        default:
          return ApiException(message, statusCode, data);
      }
    }

    return ApiException('An unexpected error occurred');
  }

  // HTTP Methods wrapper
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }
  
  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.patch(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.delete(path, data: data, queryParameters: queryParameters);
  }
}
