/// Small helpers for storing simple string lists in SQLite text columns.
///
/// This is enough for the MVP and keeps the database easy to inspect.
/// Later, these can be replaced with join tables or JSON if needed.
List<String> splitCsv(String? value) {
  if (value == null || value.trim().isEmpty) return [];

  return value
      .split(',')
      .map((item) => item.trim().toLowerCase())
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList();
}

String joinCsv(Iterable<String> values) {
  return values
      .map((item) => item.trim().toLowerCase())
      .where((item) => item.isNotEmpty)
      .toSet()
      .join(',');
}
