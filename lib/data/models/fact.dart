class Fact {
  const Fact({required this.text});

  final String text;

  factory Fact.fromJson(Map<String, dynamic> json) =>
      Fact(text: (json['fact'] ?? '').toString());
}
