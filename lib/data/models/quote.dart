class Quote {
  const Quote({
    required this.text,
    required this.author,
    this.work = '',
    this.categories = const <String>[],
  });

  final String text;
  final String author;
  final String work;
  final List<String> categories;

  String get id => '$text|$author';

  factory Quote.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];
    return Quote(
      text: (json['quote'] ?? json['text'] ?? '').toString(),
      author: (json['author'] ?? 'Неизвестный автор').toString(),
      work: (json['work'] ?? '').toString(),
      categories: rawCategories is List
          ? rawCategories.map((item) => item.toString()).toList()
          : const <String>[],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'quote': text,
    'author': author,
    'work': work,
    'categories': categories,
  };
}
