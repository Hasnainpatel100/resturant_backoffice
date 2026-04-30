/// Account status for brands and branches.
/// Maps to Ktor EnumAccountStatus.
/// Values sent to API as exact enum names.
enum EnumAccountStatus {
  active('active'),
  inactive('inactive'),
  suspended('suspended'),
  pendingVerification('pendingVerification'),
  expired('expired'),
  locked('locked');

  final String value;
  const EnumAccountStatus(this.value);
}