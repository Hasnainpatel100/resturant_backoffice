/// User roles.
/// Maps to Ktor EnumUserRole.
/// Values sent to API as exact enum names.
enum EnumUserRole {
  admin('admin'),
  superAdmin('superAdmin'),
  supportTeam('supportTeam'),
  owner('owner'),
  manager('manager'),
  executiveChef('executiveChef'),
  sousChef('sousChef'),
  captain('captain'),
  waiter('waiter'),
  cashier('cashier'),
  barmen('barmen'),
  kitchenDisplay('kitchenDisplay'),
  inventoryController('inventoryController'),
  deliveryRider('deliveryRider'),
  masterPos('masterPos'),
  terminal('terminal');

  final String value;
  const EnumUserRole(this.value);
}