class DictionaryEntry {
  const DictionaryEntry({
    required this.word,
    required this.definition,
    required this.valid,
  });

  final String word;
  final String definition;
  final bool valid;

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      word: (json['word'] ?? '').toString(),
      definition: (json['definition'] ?? '').toString(),
      valid: json['valid'] == true,
    );
  }
}
