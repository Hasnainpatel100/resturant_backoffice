/// Table status.
/// Maps to Ktor EnumTableStatus.
/// Values sent to API as exact enum names.
enum EnumTableStatus {
  available('available'),
  occupied('occupied'),
  reserved('reserved'),
  dirty('dirty'),
  outOfOrder('outOfOrder'),
  vipReserved('vipReserved'),
  maintenance('maintenance');

  final String value;
  const EnumTableStatus(this.value);
}