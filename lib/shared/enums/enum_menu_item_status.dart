/// Menu item status.
/// Maps to Ktor EnumMenuItemStatus.
/// Values sent to API as exact enum names.
enum EnumMenuItemStatus {
  active('active'),
  inactive('inactive'),
  outOfStock('outOfStock'),
  seasonal('seasonal'),
  limited('limited'),
  discontinued('discontinued');

  final String value;
  const EnumMenuItemStatus(this.value);
}