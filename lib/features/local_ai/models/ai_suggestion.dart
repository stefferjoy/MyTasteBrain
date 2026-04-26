class AiSuggestion {
  final String title;
  final String body;
  final List<String> tags;
  final bool generatedOnDevice;

  const AiSuggestion({
    required this.title,
    required this.body,
    this.tags = const [],
    this.generatedOnDevice = false,
  });
}
