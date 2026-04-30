/// Employment status for users.
/// Maps to Ktor EnumEmploymentStatus.
/// Values sent to API as exact enum names.
enum EnumEmploymentStatus {
  probation('probation'),
  permanent('permanent'),
  noticePeriod('noticePeriod'),
  resigned('resigned'),
  terminated('terminated'),
  intern('intern');

  final String value;
  const EnumEmploymentStatus(this.value);
}