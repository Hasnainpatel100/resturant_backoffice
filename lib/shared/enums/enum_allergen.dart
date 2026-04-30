/// Allergen information for menu items.
/// Maps to Ktor EnumAllergen.
/// Values sent to API as exact enum names.
enum EnumAllergen {
  gluten('gluten'),
  dairy('dairy'),
  eggs('eggs'),
  fish('fish'),
  shellfish('shellfish'),
  treeNuts('treeNuts'),
  peanuts('peanuts'),
  soy('soy'),
  sesame('sesame'),
  mustard('mustard'),
  celery('celery'),
  molluscs('molluscs'),
  sulphites('sulphites'),
  lupin('lupin'),
  crustaceans('crustaceans');

  final String value;
  const EnumAllergen(this.value);
}