/// Order status.
/// Maps to Ktor EnumOrderStatus.
/// Values sent to API as exact enum names.
enum EnumOrderStatus {
  pending('pending'),
  accepted('accepted'),
  preparing('preparing'),
  ready('ready'),
  served('served'),
  completed('completed'),
  cancelled('cancelled'),
  refunded('refunded'),
  kotPending('kotPending'),
  kotFired('kotFired');

  final String value;
  const EnumOrderStatus(this.value);
}