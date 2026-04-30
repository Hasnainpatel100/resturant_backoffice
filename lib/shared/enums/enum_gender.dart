/// Gender for user details.
/// Maps to Ktor EnumGender.
/// Values sent to API as exact enum names.
enum EnumGender {
  male('male'),
  female('female'),
  other('other'),
  preferNotToSay('preferNotToSay');

  final String value;
  const EnumGender(this.value);
}