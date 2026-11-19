import 'package:dio/dio.dart';

import '../../state/auth_store.dart';
import '../config/app_config.dart';

class ApiKeyInterceptor extends Interceptor {
  ApiKeyInterceptor(this._authStore);

  static const String overrideKeyExtra = 'apiKeyOverride';

  final AuthStore _authStore;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final overrideKey = options.extra[overrideKeyExtra];
    final token = (overrideKey is String ? overrideKey : _authStore.apiKey)
        .trim();
    if (token.isNotEmpty) {
      options.headers[AppConfig.apiKeyHeader] = token;
    }
    options.headers.putIfAbsent('Accept', () => 'application/json');
    handler.next(options);
  }
}
