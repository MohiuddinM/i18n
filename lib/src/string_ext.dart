extension StringX on String {
  String convertName() {
    final parts = split('_');

    if (parts.length == 1) {
      return this;
    }

    final buffer = StringBuffer(parts.first)
      ..writeAll(parts.sublist(1).map((e) {
        if (e.length != 2) {
          throw ArgumentError('$e is not a valid language or country code');
        }
        return e.firstUpper();
      }));
    return buffer.toString();
  }

  String firstUpper() {
    return this[0].toUpperCase() + substring(1);
  }

  String firstLower() {
    return this[0].toLowerCase() + substring(1);
  }

  bool get containsReference {
    final refs = split('\$')..removeLast();

    if (refs.isEmpty) {
      return false;
    }

    final escapedRefs = refs.where((e) => e.endsWith(r'\'));

    if (escapedRefs.isEmpty) {
      return true;
    }

    if (escapedRefs.length == refs.length) {
      return false;
    }

    if (escapedRefs.isNotEmpty && escapedRefs.length < refs.length) {
      throw ArgumentError(
        'A string can not mix both escaped and non-escaped \$ signs',
      );
    }

    return true;
  }
}
