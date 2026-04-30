/// Kitchen station for menu items.
/// Maps to Ktor EnumKitchenStation.
/// Values sent to API as exact enum names.
enum EnumKitchenStation {
  mainKitchen('mainKitchen'),
  southIndian('southIndian'),
  chinese('chinese'),
  barbecue('barbecue'),
  bakery('bakery'),
  dessert('dessert'),
  beverage('beverage'),
  tandoor('tandoor'),
  grill('grill'),
  continental('continental'),
  italian('italian'),
  thai('thai'),
  japanese('japanese'),
  snacks('snacks');

  final String value;
  const EnumKitchenStation(this.value);
}