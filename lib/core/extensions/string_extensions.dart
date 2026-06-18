extension StringExtensions on String {
  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(this);

  bool get isValidNigerianPhone =>
      RegExp(r'^(\+?234|0)[789]\d{9}$')
          .hasMatch(replaceAll(RegExp(r'\s|-'), ''));

  bool get isValidPassword => length >= 8;

  String get initials {
    final parts = trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String get toTitleCase =>
      split(' ').map((w) => w.capitalized).join(' ');

  String truncate(int max, {String ellipsis = '...'}) {
    if (length <= max) return this;
    return '${substring(0, max - ellipsis.length)}$ellipsis';
  }

  String? get nullIfEmpty => isEmpty ? null : this;
}

extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  String get orEmpty => this ?? '';
}
