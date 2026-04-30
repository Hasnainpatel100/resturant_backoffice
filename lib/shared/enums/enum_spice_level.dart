/// Spice level for menu items.
/// Maps to Ktor EnumSpiceLevel.
/// Values sent to API as exact enum names.
enum EnumSpiceLevel {
  mild('mild'),
  medium('medium'),
  spicy('spicy'),
  extraSpicy('extraSpicy'),
  nonSpicy('nonSpicy');

  final String value;
  const EnumSpiceLevel(this.value);
}