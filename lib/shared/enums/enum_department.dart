/// Department for users.
/// Maps to Ktor EnumDepartment.
/// Values sent to API as exact enum names.
enum EnumDepartment {
  management('management'),
  kitchen('kitchen'),
  service('service'),
  bar('bar'),
  housekeeping('housekeeping'),
  delivery('delivery'),
  accounting('accounting'),
  inventory('inventory');

  final String value;
  const EnumDepartment(this.value);
}