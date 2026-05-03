class SummaryResult {
  const SummaryResult({required this.title, required this.summary});

  final String title;
  final String summary;

  // Minimal strict schema: only two string fields are allowed.
  static const Map<String, dynamic> schema = {
    'type': 'object',
    'additionalProperties': false,
    'required': ['title', 'summary'],
    'properties': {
      'title': {'type': 'string'},
      'summary': {'type': 'string'},
    },
  };

  static SummaryResult fromJson(Map<String, dynamic> json) {
    final allowedKeys = {'title', 'summary'};
    if (json.keys.any((key) => !allowedKeys.contains(key))) {
      throw const FormatException('JSON has unexpected fields.');
    }

    final titleValue = json['title'];
    final summaryValue = json['summary'];
    if (titleValue is! String || titleValue.trim().isEmpty) {
      throw const FormatException('Field "title" must be a non-empty string.');
    }
    if (summaryValue is! String || summaryValue.trim().isEmpty) {
      throw const FormatException(
        'Field "summary" must be a non-empty string.',
      );
    }

    return SummaryResult(
      title: titleValue.trim(),
      summary: summaryValue.trim(),
    );
  }
}
