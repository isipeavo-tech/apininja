import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/api_key_interceptor.dart';
import '../models/dictionary_entry.dart';
import '../models/fact.dart';
import '../models/joke.dart';
import '../models/quote.dart';
import '../models/thesaurus_entry.dart';

class ApiNinjasRepository {
  ApiNinjasRepository(this._dio);

  final Dio _dio;

  Future<Quote> getRandomQuote({String? category}) async {
    final response = await _get(
      '/v2/randomquotes',
      query: category == null || category == 'all'
          ? null
          : <String, dynamic>{'categories': category},
    );
    final items = _asList(response.data);
    if (items.isEmpty) {
      throw const ApiException('API не вернул ни одной цитаты.');
    }
    return Quote.fromJson(items.first);
  }

  Future<Quote> getQuoteOfTheDay() async {
    final response = await _get('/v2/quoteoftheday');
    final items = _asList(response.data);
    if (items.isEmpty) {
      throw const ApiException('API не вернул цитату дня.');
    }
    return Quote.fromJson(items.first);
  }

  Future<Joke> getRandomJoke() async {
    final response = await _get('/v1/jokes');
    final items = _asList(response.data);
    if (items.isEmpty) {
      throw const ApiException('API не вернул шутку.');
    }
    return Joke.fromJson(items.first);
  }

  Future<Fact> getRandomFact() async {
    final response = await _get('/v1/facts');
    final items = _asList(response.data);
    if (items.isEmpty) {
      throw const ApiException('API не вернул факт.');
    }
    return Fact.fromJson(items.first);
  }

  Future<Fact> getFactOfTheDay() async {
    final response = await _get('/v1/factoftheday');
    final items = _asList(response.data);
    if (items.isEmpty) {
      throw const ApiException('API не вернул факт дня.');
    }
    return Fact.fromJson(items.first);
  }

  Future<DictionaryEntry> getDefinition(String word) async {
    final response = await _get(
      '/v1/dictionary',
      query: <String, dynamic>{'word': word},
    );
    return DictionaryEntry.fromJson(_asMap(response.data));
  }

  Future<ThesaurusEntry> getThesaurus(String word) async {
    final response = await _get(
      '/v1/thesaurus',
      query: <String, dynamic>{'word': word},
    );
    return ThesaurusEntry.fromJson(_asMap(response.data));
  }

  Future<void> validateApiKey(String key) async {
    try {
      await _dio.get<dynamic>(
        '/v1/jokes',
        options: Options(
          extra: <String, dynamic>{
            ApiKeyInterceptor.overrideKeyExtra: key.trim(),
          },
        ),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Response<dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      return await _dio.get<dynamic>(
        path,
        queryParameters: query,
        options: options,
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  List<Map<String, dynamic>> _asList(Object? data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    throw const ApiException('API вернул данные в неизвестном формате.');
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw const ApiException('API вернул данные в неизвестном формате.');
  }
}
