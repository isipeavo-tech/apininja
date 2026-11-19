import 'package:api_ninjas_explorer/app.dart';
import 'package:api_ninjas_explorer/core/di/injection.dart';
import 'package:api_ninjas_explorer/core/storage/local_storage.dart';
import 'package:api_ninjas_explorer/core/theme/app_theme.dart';
import 'package:api_ninjas_explorer/data/models/dictionary_entry.dart';
import 'package:api_ninjas_explorer/data/models/fact.dart';
import 'package:api_ninjas_explorer/data/models/joke.dart';
import 'package:api_ninjas_explorer/data/models/quote.dart';
import 'package:api_ninjas_explorer/data/models/thesaurus_entry.dart';
import 'package:api_ninjas_explorer/data/repositories/api_ninjas_repository.dart';
import 'package:api_ninjas_explorer/features/onboarding/api_key_screen.dart';
import 'package:api_ninjas_explorer/features/shell/main_shell.dart';
import 'package:api_ninjas_explorer/state/auth_store.dart';
import 'package:api_ninjas_explorer/state/favorites_store.dart';
import 'package:api_ninjas_explorer/state/settings_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepository extends ApiNinjasRepository {
  _FakeRepository() : super(Dio());

  String? lastValidatedKey;

  @override
  Future<void> validateApiKey(String key) async {
    lastValidatedKey = key;
  }

  @override
  Future<Quote> getRandomQuote({String? category}) async =>
      const Quote(text: 'Knowledge is power.', author: 'Francis Bacon');

  @override
  Future<Quote> getQuoteOfTheDay() async => const Quote(
    text: 'Well done is better than well said.',
    author: 'Benjamin Franklin',
  );

  @override
  Future<Joke> getRandomJoke() async => const Joke(
    text: 'Why did the developer go broke? Because he used up all his cache.',
  );

  @override
  Future<Fact> getRandomFact() async => const Fact(text: 'Honey never spoils.');

  @override
  Future<Fact> getFactOfTheDay() async =>
      const Fact(text: 'Octopuses have three hearts.');

  @override
  Future<DictionaryEntry> getDefinition(String word) async =>
      const DictionaryEntry(
        word: 'serendipity',
        definition: 'The occurrence of events by chance in a happy way.',
        valid: true,
      );

  @override
  Future<ThesaurusEntry> getThesaurus(String word) async =>
      const ThesaurusEntry(
        word: 'serendipity',
        synonyms: <String>['luck', 'chance'],
        antonyms: <String>['misfortune'],
      );
}

void main() {
  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    configureDependencies(preferences);
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('shows the API key onboarding screen', (tester) async {
    await tester.pumpWidget(const ApiNinjasApp());
    await tester.pumpAndSettle();

    expect(find.text('API Ninjas Explorer'), findsOneWidget);
    expect(find.text('Подключиться'), findsOneWidget);
  });

  testWidgets('validates and saves an API key', (tester) async {
    final authStore = getIt<AuthStore>();
    final repository = _FakeRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: ApiKeyScreen(authStore: authStore, repository: repository),
      ),
    );
    await tester.enterText(find.byType(TextField), 'valid-key');
    await tester.tap(find.text('Подключиться'));
    await tester.pumpAndSettle();

    expect(repository.lastValidatedKey, 'valid-key');
    expect(authStore.apiKey, 'valid-key');
  });

  testWidgets('renders all main tabs on a phone-sized screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MainShell(
          authStore: getIt<AuthStore>(),
          favoritesStore: getIt<FavoritesStore>(),
          settingsController: getIt<SettingsController>(),
          storage: getIt<LocalStorage>(),
          repository: _FakeRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Цитата дня'), findsWidgets);

    await tester.tap(find.text('Шутки'));
    await tester.pumpAndSettle();
    expect(find.text('Лента шуток'), findsOneWidget);

    await tester.tap(find.text('Факты'));
    await tester.pumpAndSettle();
    expect(find.text('Случайные факты'), findsOneWidget);

    await tester.tap(find.text('Словарь'));
    await tester.pumpAndSettle();
    expect(find.text('Английский словарь'), findsOneWidget);

    await tester.tap(find.text('Настройки'));
    await tester.pumpAndSettle();
    expect(find.text('API-ключ'), findsOneWidget);
  });
}
