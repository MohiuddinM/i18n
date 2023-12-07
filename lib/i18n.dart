import 'src/cs.dart' as cs;
import 'src/en.dart' as en;
import 'src/ru.dart' as ru;

///
/// Language specific function, which is provided with a number and should return one of possible categories.
/// count is never null.
///
typedef CategoryResolver = QuantityCategory Function(
  int count,
  QuantityType type,
);

enum QuantityCategory { zero, one, two, few, many, other }

enum QuantityType { cardinal, ordinal }

void registerResolver(String languageCode, CategoryResolver resolver) {
  _resolverRegistry[languageCode] = resolver;
}

///
/// Same as ordinal.
///
String plural(
  int count,
  String languageCode, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) {
  return _resolvePlural(
    count,
    languageCode,
    QuantityType.cardinal,
    zero: zero,
    one: one,
    two: two,
    few: few,
    many: many,
    other: other,
  );
}

///
/// See: http://cldr.unicode.org/index/cldr-spec/plural-rules
///
String cardinal(
  int count,
  String languageCode, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) {
  return _resolvePlural(
    count,
    languageCode,
    QuantityType.cardinal,
    zero: zero,
    one: one,
    two: two,
    few: few,
    many: many,
    other: other,
  );
}

///
/// See: http://cldr.unicode.org/index/cldr-spec/plural-rules
///
String ordinal(
  int count,
  String languageCode, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) {
  return _resolvePlural(
    count,
    languageCode,
    QuantityType.ordinal,
    zero: zero,
    one: one,
    two: two,
    few: few,
    many: many,
    other: other,
  );
}

///
/// Selects one of the cases based on the key.
///
String select(
  String key,
  Map<String, String> cases, {
  String? other,
}) {
  return _firstNotNull(cases[key], other);
}

Map<String, CategoryResolver> _resolverRegistry = {
  'en': en.quantityResolver,
  'cs': cs.quantityResolver,
  'ru': ru.quantityResolver,
};

String _resolvePlural(
  int count,
  String languageCode,
  QuantityType type, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) {
  final c = _resolveCategory(languageCode, count, type);
  many ??= other;
  return switch (c) {
    QuantityCategory.zero => _firstNotNull(zero, many),
    QuantityCategory.one => _firstNotNull(one, many),
    QuantityCategory.two => _firstNotNull(two, many),
    QuantityCategory.few => _firstNotNull(few, many),
    QuantityCategory.many => _firstNotNull(many, other),
    QuantityCategory.other => _firstNotNull(other, many),
  };
}

QuantityCategory _defaultResolver(int count, QuantityType type) {
  return switch (count) {
    0 => QuantityCategory.zero,
    1 => QuantityCategory.one,
    2 => QuantityCategory.two,
    3 || 4 => QuantityCategory.few,
    _ => QuantityCategory.other,
  };
}

QuantityCategory _resolveCategory(
  String languageCode,
  int count,
  QuantityType type,
) {
  final resolver = _resolverRegistry[languageCode] ?? _defaultResolver;
  return resolver(count, type);
}

String _firstNotNull(String? a, String? b) {
  return a ?? b ?? '???';
}
