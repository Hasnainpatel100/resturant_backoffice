/// Service types for branches.
/// Maps to Ktor EnumServiceType.
/// These values are sent directly to API — use exact enum names.
enum EnumServiceType {
  quickBill('QUICK_BILL'),
  dineIn('DINE_IN'),
  takeaway('TAKEAWAY'),
  delivery('DELIVERY'),
  driveThru('DRIVE_THRU'),
  roomService('ROOM_SERVICE'),
  buffet('BUFFET'),
  catering('CATERING');

  final String value;
  const EnumServiceType(this.value);
}