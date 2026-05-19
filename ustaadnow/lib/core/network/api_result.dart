import 'package:dio/dio.dart';

sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

final class ApiError<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  final ApiErrorType type;

  const ApiError({
    required this.message,
    this.statusCode,
    required this.type,
  });
}

enum ApiErrorType {
  network,
  server,
  timeout,
  unauthorized,
  notFound,
  unknown,
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorType type;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.type = ApiErrorType.unknown,
  });

  factory NetworkException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Request timed out. Please try again.',
          type: ApiErrorType.timeout,
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection.',
          type: ApiErrorType.network,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return NetworkException(
            message: 'Unauthorized access.',
            statusCode: statusCode,
            type: ApiErrorType.unauthorized,
          );
        } else if (statusCode == 404) {
          return NetworkException(
            message: 'Resource not found.',
            statusCode: statusCode,
            type: ApiErrorType.notFound,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return NetworkException(
            message: 'Server error. Please try again.',
            statusCode: statusCode,
            type: ApiErrorType.server,
          );
        }
        return NetworkException(
          message: e.response?.data?['message'] ?? 'Something went wrong.',
          statusCode: statusCode,
          type: ApiErrorType.unknown,
        );
      default:
        return NetworkException(
          message: e.message ?? 'Something went wrong.',
          type: ApiErrorType.unknown,
        );
    }
  }

  @override
  String toString() => 'NetworkException: $message (code: $statusCode)';
}
