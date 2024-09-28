import '../i18n.dart';

///
/// Quantity category resolver for russian.
///
/// See:
///
/// https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html#en
///
///
QuantityCategory quantityResolver(int count, QuantityType type) {
  if (type == QuantityType.ordinal) return _resolveOrdinal(count);
  return _resolveCardinal(count);
}

QuantityCategory _resolveCardinal(int count) {
  switch (count) {
    case 1:
      return QuantityCategory.one;
  }
  return QuantityCategory.other;
}

QuantityCategory _resolveOrdinal(int count) {
  final mod10 = count % 10;
  // final mod100 = count % 100;

  if (count >= 5 && count <= 20) return QuantityCategory.many;
  if (mod10 == 1) return QuantityCategory.one;
  if (mod10 >= 2 && mod10 <= 4) return QuantityCategory.few;
  if (mod10 >= 5 || mod10 == 0) return QuantityCategory.many;

  return QuantityCategory.other;
}
