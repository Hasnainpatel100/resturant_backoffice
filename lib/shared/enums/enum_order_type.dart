/// Order type for orders.
/// Maps to Ktor EnumOrderType.
/// Values sent to API as exact enum names.
enum EnumOrderType {
  dineIn('dineIn'),
  takeaway('takeaway'),
  delivery('delivery'),
  driveThru('driveThru'),
  roomService('roomService');

  final String value;
  const EnumOrderType(this.value);
}