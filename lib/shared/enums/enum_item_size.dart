/// Item size for menu item pricing.
/// Maps to Ktor EnumItemSize.
/// Values sent to API as exact enum names.
enum EnumItemSize {
  small('small'),
  half('half'),
  regular('regular'),
  medium('medium'),
  large('large'),
  full('full'),
  xlarge('xlarge');

  final String value;
  const EnumItemSize(this.value);
}