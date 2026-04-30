/// Food type for menu items.
/// Maps to Ktor EnumFoodType.
/// Values sent to API as exact enum names.
enum EnumFoodType {
  veg('veg'),
  nonVeg('nonVeg'),
  egg('egg'),
  jain('jain');

  final String value;
  const EnumFoodType(this.value);
}