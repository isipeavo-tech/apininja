import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.isAuthError = false,
    this.isNetworkError = false,
  });

  final String message;
  final int? statusCode;
  final bool isAuthError;
  final bool isNetworkError;

  factory ApiException.fromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return ApiException(
        'API-ключ не принят. Проверьте ключ в настройках.',
        statusCode: statusCode,
        isAuthError: true,
      );
    }
    if (statusCode == 429) {
      return ApiException(
        'Превышен лимит запросов. Попробуйте позже.',
        statusCode: statusCode,
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return ApiException(
        'Сервер API временно недоступен. Попробуйте ещё раз.',
        statusCode: statusCode,
      );
    }

    final serverMessage = _extractServerMessage(error.response?.data);
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return ApiException(serverMessage, statusCode: statusCode);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          'Истекло время ожидания ответа. Проверьте подключение к сети.',
          isNetworkError: true,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const ApiException(
          'Не удалось подключиться к API. Проверьте интернет и повторите попытку.',
          isNetworkError: true,
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          'Не удалось проверить сертификат сервера.',
          isNetworkError: true,
        );
      case DioExceptionType.cancel:
        return const ApiException('Запрос был отменён.');
      case DioExceptionType.badResponse:
        return ApiException(
          'API вернул ошибку${statusCode == null ? '' : ' $statusCode'}.',
          statusCode: statusCode,
        );
    }
  }

  static String? _extractServerMessage(Object? data) {
    if (data is String) {
      final trimmed = data.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (data is Map) {
      final value = data['error'] ?? data['message'] ?? data['detail'];
      return value?.toString();
    }
    return null;
  }

  @override
  String toString() => message;
}
