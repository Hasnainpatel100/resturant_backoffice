import 'package:get/get.dart';
import 'package:back_office/data/models/branch_model.dart';
import 'package:back_office/data/models/user_model.dart';
import 'package:back_office/data/models/restaurant_inventory/vendor_model.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_model.dart';
import 'package:back_office/data/models/restaurant_inventory/unit_model.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_tax_model.dart';
import 'package:back_office/data/models/restaurant_inventory/bill_type_model.dart';
import 'package:back_office/data/models/restaurant_inventory/stock_reason_model.dart';

import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';

class InventoryLookupController extends GetxController {
  final MongoBranchRepository branchRepository = MongoBranchRepositoryImpl();
  final VendorRepository vendorRepository = VendorRepositoryImpl();
  final RawMaterialRepository materialRepository = RawMaterialRepositoryImpl();
  final UnitRepository unitRepository = UnitRepositoryImpl();
  final RawMaterialTaxRepository taxRepository = RawMaterialTaxRepositoryImpl();
  final BillTypeRepository billTypeRepository = BillTypeRepositoryImpl();
  final StockReasonRepository reasonRepository = StockReasonRepositoryImpl();
  final MongoUserRepository userRepository = MongoUserRepositoryImpl();

  final branches = <BranchModel>[].obs;
  final vendors = <VendorModel>[].obs;
  final rawMaterials = <RawMaterialModel>[].obs;
  final units = <UnitModel>[].obs;
  final taxes = <RawMaterialTaxModel>[].obs;
  final billTypes = <BillTypeModel>[].obs;
  final reasons = <StockReasonModel>[].obs;
  final users = <AppUser>[].obs;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadAllLookups() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final List<Future<dynamic>> futures = [
        branchRepository.getAllBranches(),
        vendorRepository.getAllVendors(),
        materialRepository.getAllMaterials(),
        unitRepository.getAllUnits(),
        taxRepository.getAllTaxes(),
        billTypeRepository.getAllBillTypes(),
        reasonRepository.getAllStockReasons(),
        userRepository.getAllUsers(),
      ];
      final results = await Future.wait(futures);

      branches.assignAll(results[0] as List<BranchModel>);
      vendors.assignAll(results[1] as List<VendorModel>);
      rawMaterials.assignAll(results[2] as List<RawMaterialModel>);
      units.assignAll(results[3] as List<UnitModel>);
      taxes.assignAll(results[4] as List<RawMaterialTaxModel>);
      billTypes.assignAll(results[5] as List<BillTypeModel>);
      reasons.assignAll(results[6] as List<StockReasonModel>);
      users.assignAll(results[7] as List<AppUser>);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
