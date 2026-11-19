import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import 'api_key_interceptor.dart';

Dio createDio(ApiKeyInterceptor apiKeyInterceptor, PrettyDioLogger logger) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      responseType: ResponseType.json,
    ),
  )..interceptors.addAll(<Interceptor>[apiKeyInterceptor, logger]);
  return dio;
}

PrettyDioLogger createDioLogger() {
  return PrettyDioLogger(
    request: true,
    requestHeader: false,
    requestBody: true,
    responseHeader: false,
    responseBody: true,
    error: true,
    compact: true,
    maxWidth: 110,
    logPrint: (Object object) => debugPrint(object.toString()),
  );
}
