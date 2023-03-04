extension StringX on String {
  String convertName() {
    final parts = split('_');

    if (parts.length == 1) {
      return this;
    }

    final buffer = StringBuffer(parts.first)
      ..writeAll(parts.sublist(1).map((e) => e.firstUpper()));
    return buffer.toString();
  }

  String firstUpper() {
    return this[0].toUpperCase() + substring(1);
  }

  String firstLower() {
    return this[0].toLowerCase() + substring(1);
  }

  bool get containsReference {
    final parts = split('\$');

    if (parts.length == 1) {
      return false;
    }

    if (parts.length == 2) {
      return !parts.first.endsWith(r'\');
    }

    throw ArgumentError('can not contain multiple \$ signs');
  }
}
