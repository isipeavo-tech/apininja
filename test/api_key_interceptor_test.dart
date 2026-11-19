import 'package:api_ninjas_explorer/core/network/api_key_interceptor.dart';
import 'package:api_ninjas_explorer/core/storage/local_storage.dart';
import 'package:api_ninjas_explorer/state/auth_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorage storage;
  late AuthStore authStore;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    storage = LocalStorage(preferences);
    authStore = AuthStore(storage);
  });

  test('adds the token from AuthStore', () async {
    await authStore.saveApiKey('  main-key  ');
    final interceptor = ApiKeyInterceptor(authStore);
    final options = RequestOptions(path: '/v1/jokes');

    interceptor.onRequest(options, RequestInterceptorHandler());

    expect(options.headers['X-Api-Key'], 'main-key');
  });

  test('uses the request override without mutating the stored key', () async {
    await authStore.saveApiKey('stored-key');
    final interceptor = ApiKeyInterceptor(authStore);
    final options = RequestOptions(
      path: '/v1/jokes',
      extra: <String, dynamic>{
        ApiKeyInterceptor.overrideKeyExtra: 'override-key',
      },
    );

    interceptor.onRequest(options, RequestInterceptorHandler());

    expect(options.headers['X-Api-Key'], 'override-key');
    expect(authStore.apiKey, 'stored-key');
  });
}
