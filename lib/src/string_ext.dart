extension StringX on String {
  String convertName() {
    final rep = filterHyphen().filterSpaces();
    final parts = rep.split('_');

    if (parts.length == 1) {
      return rep;
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

  String filterHyphen() {
    final parts = split('-');
    final f = parts.reduce((value, element) => value + element.firstUpper());
    return f;
  }

  String filterSpaces() {
    final f = split('(');
    final parts = f.removeAt(0).split(' ');
    final converted =
        parts.reduce((value, element) => value + element.firstUpper());

    if (f.isEmpty) {
      return converted;
    }

    return converted + '(' + f.join();
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
