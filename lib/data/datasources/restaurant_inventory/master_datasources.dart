import 'base_hive_datasource.dart';

class LocationMongoDataSource extends BaseHiveDataSource {
  LocationMongoDataSource() : super('locations');
}

class UnitMongoDataSource extends BaseHiveDataSource {
  UnitMongoDataSource() : super('units');
}

class RawMaterialGroupMongoDataSource extends BaseHiveDataSource {
  RawMaterialGroupMongoDataSource() : super('raw_material_groups');
}

class RawMaterialTaxMongoDataSource extends BaseHiveDataSource {
  RawMaterialTaxMongoDataSource() : super('raw_material_taxes');
}

class RawMaterialMongoDataSource extends BaseHiveDataSource {
  RawMaterialMongoDataSource() : super('raw_materials');
}

class VendorMongoDataSource extends BaseHiveDataSource {
  VendorMongoDataSource() : super('vendors');
}

class BillTypeMongoDataSource extends BaseHiveDataSource {
  BillTypeMongoDataSource() : super('bill_types');
}

class StockReasonMongoDataSource extends BaseHiveDataSource {
  StockReasonMongoDataSource() : super('stock_reasons');
}

class BranchMongoDataSource extends BaseHiveDataSource {
  BranchMongoDataSource() : super('branches');
}

class UserMongoDataSource extends BaseHiveDataSource {
  UserMongoDataSource() : super('users');
}
