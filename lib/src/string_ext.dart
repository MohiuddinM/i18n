extension StringX on String {
  String convertName() {
    final parts = split('_');

    if (parts.length == 1) {
      return this;
    } else if (parts.length == 2) {
      return parts.first + parts.last.firstUpper();
    } else if (parts.length == 3) {
      return parts.first + parts[1].firstUpper() + parts.last.firstUpper();
    } else {
      throw ArgumentError();
    }
  }

  String firstUpper() {
    return substring(0, 1).toUpperCase() + substring(1);
  }

  String firstLower() {
    return substring(0, 1).toLowerCase() + substring(1);
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
