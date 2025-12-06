import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

// Export Options, FormData, and MultipartFile for convenience
export 'package:dio/dio.dart' show Options, Response, FormData, MultipartFile;

/// Base API client with error handling
class ApiClient {
  final Dio _dio;
  
  ApiClient(this._dio) {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    );
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final exception = _handleError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: exception,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }
  
  /// Handle Dio errors and convert to app exceptions
  AppException _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkException('Connection timeout. Please check your internet connection.');
    }
    
    if (error.type == DioExceptionType.connectionError) {
      return const NetworkException('No internet connection. Please check your network settings.');
    }
    
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data?['message'] ?? 
                     error.response!.data?['error'] ?? 
                     'An error occurred';
      
      switch (statusCode) {
        case 400:
          return ValidationException(message);
        case 401:
          return const ServerException('Unauthorized. Please check your API key.');
        case 403:
          return const ServerException('Access forbidden.');
        case 404:
          return const ServerException('Resource not found.');
        case 429:
          return const ServerException('Rate limit exceeded. Please try again later.');
        case 500:
        case 502:
        case 503:
          return const ServerException('Server error. Please try again later.');
        default:
          return ServerException(message);
      }
    }
    
    return ServerException(error.message ?? 'An unexpected error occurred');
  }
  
  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }
  
  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }
  
  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }
  
  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }
}

