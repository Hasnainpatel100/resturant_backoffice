/// Device type for POS devices.
/// Maps to Ktor EnumDeviceType.
/// Values sent to API as exact enum names.
enum EnumDeviceType {
  masterPos('MASTER_POS'),
  terminal('TERMINAL'),
  kitchenDisplay('KITCHEN_DISPLAY');

  final String value;
  const EnumDeviceType(this.value);
}