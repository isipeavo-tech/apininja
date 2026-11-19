class ThesaurusEntry {
  const ThesaurusEntry({
    required this.word,
    this.synonyms = const <String>[],
    this.antonyms = const <String>[],
  });

  final String word;
  final List<String> synonyms;
  final List<String> antonyms;

  bool get isEmpty => synonyms.isEmpty && antonyms.isEmpty;

  factory ThesaurusEntry.fromJson(Map<String, dynamic> json) {
    return ThesaurusEntry(
      word: (json['word'] ?? '').toString(),
      synonyms: _stringList(json['synonyms']),
      antonyms: _stringList(json['antonyms']),
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      return value.split(',').map((item) => item.trim()).toList();
    }
    return const <String>[];
  }
}
