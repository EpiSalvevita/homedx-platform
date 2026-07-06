class LegalPage {
  final String type;
  final String title;
  final String content;
  final String language;

  LegalPage({
    required this.type,
    required this.title,
    required this.content,
    required this.language,
  });

  factory LegalPage.fromJson(Map<String, dynamic> json) {
    return LegalPage(
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      language: json['language'] as String? ?? 'de',
    );
  }
}
