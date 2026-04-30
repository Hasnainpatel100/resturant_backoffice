/// Device status for POS devices.
/// Maps to Ktor EnumDeviceStatus.
/// Values sent to API as exact enum names.
enum EnumDeviceStatus {
  pending('pending'),
  active('active'),
  inactive('inactive'),
  suspended('suspended'),
  maintenance('maintenance'),
  decommissioned('decommissioned'),
  blocked('blocked');

  final String value;
  const EnumDeviceStatus(this.value);
}