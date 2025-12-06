import 'package:dio/dio.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';

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
      final responseData = error.response!.data;
      
      // Log detailed error information
      Logger.error('API Error - Status: $statusCode');
      Logger.error('API Error - Response Data: $responseData');
      Logger.error('API Error - Response Type: ${responseData.runtimeType}');
      
      // Extract error message from various possible formats
      String message = 'An error occurred';
      if (responseData is Map) {
        // Handle ElevenLabs error format: {detail: {message: "...", status: "..."}}
        if (responseData.containsKey('detail')) {
          final detail = responseData['detail'];
          if (detail is Map) {
            // Handle nested detail object: {detail: {message: "...", status: "..."}}
            message = detail['message'] ?? 
                     detail['msg'] ?? 
                     detail['error'] ??
                     detail.toString();
          } else if (detail is List && detail.isNotEmpty) {
            // Handle detail array: {detail: [{msg: "...", ...}]}
            if (detail[0] is Map) {
              message = detail[0]['msg'] ?? 
                       detail[0]['message'] ?? 
                       detail[0].toString();
            } else {
              message = detail[0].toString();
            }
          } else {
            message = detail.toString();
          }
        } else {
          message = responseData['message'] ?? 
                    responseData['error'] ?? 
                    responseData.toString();
        }
      } else if (responseData is String) {
        message = responseData;
      }
      
      Logger.error('API Error - Extracted Message: $message');
      
      switch (statusCode) {
        case 400:
          return ValidationException('Bad Request: $message');
        case 401:
          // Check if it's a quota error (common with free tier)
          if (message.toLowerCase().contains('quota') || 
              message.toLowerCase().contains('credits')) {
            return ServerException(message); // Show the actual quota error message
          }
          return ServerException('Unauthorized: $message');
        case 403:
          return ServerException('Access forbidden: $message');
        case 404:
          return ServerException('Resource not found: $message');
        case 429:
          return const ServerException('Rate limit exceeded. Please try again later.');
        case 500:
        case 502:
        case 503:
          return ServerException('Server error ($statusCode): $message');
        default:
          return ServerException('HTTP $statusCode: $message');
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
      // The error from interceptor should be an AppException
      // If it's not, wrap it in a ServerException
      if (e.error is AppException) {
        throw e.error as AppException;
      } else {
        // If error is not an AppException, create one from the DioException
        throw _handleError(e);
      }
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
      // The error from interceptor should be an AppException
      // If it's not, wrap it in a ServerException
      if (e.error is AppException) {
        throw e.error as AppException;
      } else {
        // If error is not an AppException, create one from the DioException
        throw _handleError(e);
      }
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

