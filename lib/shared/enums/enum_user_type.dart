/// User type classification.
/// Maps to Ktor EnumUserType.
/// Values sent to API as exact enum names.
enum EnumUserType {
  platform('PLATFORM'),
  brand('BRAND');

  final String value;
  const EnumUserType(this.value);
}