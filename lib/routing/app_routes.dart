/// Centralized route path constants for GoRouter.
abstract final class AppRoutes {
  AppRoutes._();

  // Auth routes
  static const String splash = '/splash';
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  
  static const String forgotPassword = '/forgot-password';

  // Brand routes (Admin/Support)
  static const String brandList = '/brands';
  static const String brandDetail = '/brands/:brandId';
  static const String brandCreate = '/brands/create';
  static const String brandEdit = '/brands/:brandId/edit';

  // Branch routes
  static const String branchList = '/brands/:brandId/branches';
  static const String branchDetail = '/brands/:brandId/branches/:branchId';
  static const String branchCreate = '/brands/:brandId/branches/create';
  static const String branchEdit = '/brands/:brandId/branches/:branchId/edit';

  // User routes
  static const String userList = '/brands/:brandId/users';
  static const String userDetail = '/brands/:brandId/users/:userId';
  static const String userCreate = '/brands/:brandId/users/create';
  static const String userEdit = '/brands/:brandId/users/:userId/edit';

  // Menu routes
  static const String menuDashboard = '/brands/:brandId/menu';
  static const String menuCategories = '/brands/:brandId/menu/categories';
  static const String categoryCreate =
      '/brands/:brandId/menu/categories/create';
  static const String categoryEdit =
      '/brands/:brandId/menu/categories/:categoryId/edit';
  static const String menuItems = '/brands/:brandId/menu/items';
  static const String menuItemCreate = '/brands/:brandId/menu/items/create';
  static const String menuItemEdit = '/brands/:brandId/menu/items/:itemId/edit';

  // Table routes
  static const String tableLayout = '/brands/:brandId/tables';
  static const String tableCreate = '/brands/:brandId/tables/create';
  static const String tableEdit = '/brands/:brandId/tables/:tableId/edit';
  static const String roomTypes = '/brands/:brandId/room-types';

  // POS Device routes
  static const String posDevices = '/brands/:brandId/pos-devices';
  static const String deviceRegistration =
      '/brands/:brandId/pos-devices/register';

  // Branch Plan routes
  static const String branchPlanHistory =
      '/brands/:brandId/branches/:branchId/plan-history';
  static const String branchPlanForm =
      '/brands/:brandId/branches/:branchId/plan';

  // Bills routes
  static const String billList = '/brands/:brandId/bills';
  static const String billDetail = '/brands/:brandId/bills/:billId';

  // Inventory routes
  static const String inventoryDashboard = '/brands/:brandId/inventory';

  // Items
  static const String itemList   = '/brands/:brandId/inventory/items';
  static const String itemCreate = '/brands/:brandId/inventory/items/create';
  static const String itemDetail = '/brands/:brandId/inventory/items/:itemId';
  static const String itemEdit   = '/brands/:brandId/inventory/items/:itemId/edit';

  // Categories
  static const String invCategoryList   = '/brands/:brandId/inventory/categories';
  static const String invCategoryCreate = '/brands/:brandId/inventory/categories/create';
  static const String invCategoryEdit   = '/brands/:brandId/inventory/categories/:categoryId/edit';

  // Units
  static const String unitList   = '/brands/:brandId/inventory/units';
  static const String unitCreate = '/brands/:brandId/inventory/units/create';
  static const String unitEdit   = '/brands/:brandId/inventory/units/:unitId/edit';

  // Warehouses
  static const String warehouseList   = '/brands/:brandId/inventory/warehouses';
  static const String warehouseCreate = '/brands/:brandId/inventory/warehouses/create';
  static const String warehouseEdit   = '/brands/:brandId/inventory/warehouses/:warehouseId/edit';

  // Suppliers
  static const String supplierList   = '/brands/:brandId/inventory/suppliers';
  static const String supplierCreate = '/brands/:brandId/inventory/suppliers/create';
  static const String supplierEdit   = '/brands/:brandId/inventory/suppliers/:supplierId/edit';
  static const String supplierLedger = '/brands/:brandId/inventory/suppliers/:supplierId/ledger';

  // Raw Material Groups
  static const String groupList   = '/brands/:brandId/inventory/groups';
  static const String groupCreate = '/brands/:brandId/inventory/groups/create';
  static const String groupEdit   = '/brands/:brandId/inventory/groups/:groupId/edit';

  // Raw Material Taxes
  static const String taxList   = '/brands/:brandId/inventory/taxes';
  static const String taxCreate = '/brands/:brandId/inventory/taxes/create';
  static const String taxEdit   = '/brands/:brandId/inventory/taxes/:taxId/edit';

  // Bill Types
  static const String billTypeList   = '/brands/:brandId/inventory/bill-types';
  static const String billTypeCreate = '/brands/:brandId/inventory/bill-types/create';
  static const String billTypeEdit   = '/brands/:brandId/inventory/bill-types/:billTypeId/edit';

  // Stock Reasons
  static const String reasonList   = '/brands/:brandId/inventory/reasons';
  static const String reasonCreate = '/brands/:brandId/inventory/reasons/create';
  static const String reasonEdit   = '/brands/:brandId/inventory/reasons/:reasonId/edit';

  // Purchases
  static const String purchaseList   = '/brands/:brandId/inventory/purchases';
  static const String purchaseCreate = '/brands/:brandId/inventory/purchases/create';
  static const String purchaseDetail = '/brands/:brandId/inventory/purchases/:purchaseId';

  // Procurement (PO, GRN, Invoices)
  static const String purchaseOrderList   = '/brands/:brandId/inventory/purchase-orders';
  static const String purchaseOrderCreate = '/brands/:brandId/inventory/purchase-orders/create';
  static const String purchaseOrderEdit   = '/brands/:brandId/inventory/purchase-orders/:poId/edit';

  static const String goodsReceiptList   = '/brands/:brandId/inventory/goods-receipts';
  static const String goodsReceiptCreate = '/brands/:brandId/inventory/goods-receipts/create';
  static const String goodsReceiptEdit   = '/brands/:brandId/inventory/goods-receipts/:grnId/edit';

  static const String supplierInvoiceList   = '/brands/:brandId/inventory/supplier-invoices';
  static const String supplierInvoiceCreate = '/brands/:brandId/inventory/supplier-invoices/create';
  static const String supplierInvoiceEdit   = '/brands/:brandId/inventory/supplier-invoices/:invoiceId/edit';

  // Adjustments
  static const String adjustmentList   = '/brands/:brandId/inventory/adjustments';
  static const String adjustmentCreate = '/brands/:brandId/inventory/adjustments/create';
  static const String manualStockEntryCreate = '/brands/:brandId/inventory/adjustments/entries/create';
  static const String manualStockEntryEdit   = '/brands/:brandId/inventory/adjustments/entries/:entryId/edit';
  static const String manualStockOutCreate = '/brands/:brandId/inventory/adjustments/outs/create';
  static const String manualStockOutEdit   = '/brands/:brandId/inventory/adjustments/outs/:outId/edit';

  // Transfers
  static const String transferList   = '/brands/:brandId/inventory/transfers';
  static const String transferCreate = '/brands/:brandId/inventory/transfers/create';
  static const String transferEdit   = '/brands/:brandId/inventory/transfers/:transferId/edit';

  // Indents
  static const String indentList   = '/brands/:brandId/inventory/indents';
  static const String indentCreate = '/brands/:brandId/inventory/indents/create';
  static const String indentEdit   = '/brands/:brandId/inventory/indents/:indentId/edit';

  // Reports
  static const String inventoryReports = '/brands/:brandId/inventory/reports';

  // Settings
  static const String settings = '/settings';
  static const String profile = '/profile';
}
