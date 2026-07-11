import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/routing/global_navigator.dart';
import 'package:back_office/routing/app_routes.dart';
import 'package:back_office/config/app_config.dart';
import 'package:back_office/ui/auth/login/cubit_session.dart';

import 'package:back_office/ui/auth/login/screen_login.dart';
import 'package:back_office/ui/auth/forgot_password/screen_forgot_password.dart';

import 'package:back_office/ui/shell/app_shell.dart';
import 'package:back_office/ui/home/screen_home.dart';
import 'package:back_office/ui/onboarding/screen_onboarding.dart';

import 'package:back_office/ui/brand/brand_list/screen_brand_list.dart';
import 'package:back_office/ui/brand/brand_detail/screen_brand_detail.dart';
import 'package:back_office/ui/brand/brand_form/screen_brand_form.dart';

import 'package:back_office/ui/branch/branch_list/screen_branch_list.dart';
import 'package:back_office/ui/branch/branch_detail/screen_branch_detail.dart';
import 'package:back_office/ui/branch/branch_form/screen_branch_form.dart';

import 'package:back_office/ui/users/user_list/screen_user_list.dart';
import 'package:back_office/ui/users/user_form/screen_user_form.dart';
import 'package:back_office/ui/users/user_detail/screen_user_detail.dart';

import 'package:back_office/ui/menu/menu_dashboard/screen_menu_dashboard.dart';

import 'package:back_office/ui/tables/table_layout/screen_table_layout.dart';

import 'package:back_office/ui/pos_devices/pos_device_list/screen_pos_device_list.dart';

import 'package:back_office/ui/settings/settings/screen_settings.dart';
import 'package:back_office/ui/profile/screen_profile.dart';
import 'package:back_office/ui/shell/placeholder_screens.dart';
import '../data/models/feedback_configuration_model.dart';

import '../ui/feedback/feedback_configuration/feedback_list_screen.dart';
import '../ui/feedback/feedback_configuration/feedback_configuration_screen.dart';
import '../ui/feedback/feedback_question_builder_screen.dart';
import '../ui/feedback/screen_customer_response.dart';
import '../ui/room_types/screen_room_type_dashboard.dart';
import '../ui/branch/branch_plan/screen_branch_plan_history.dart';
import '../ui/branch/branch_plan/screen_branch_plan_form.dart';
import '../ui/bills/bill_list/screen_bill_list.dart';
import '../ui/bills/bill_detail/screen_bill_detail.dart';

import '../ui/inventory/screen_inventory_dashboard.dart';
import '../ui/inventory/categories/screen_category_list.dart';
import '../ui/inventory/categories/screen_category_form.dart';
import '../ui/inventory/suppliers/screen_supplier_ledger.dart';
import '../ui/inventory/purchases/screen_purchase_list.dart';
import '../ui/inventory/purchases/screen_purchase_form.dart';
import '../ui/inventory/purchases/screen_purchase_detail.dart';
import '../ui/inventory/reports/screen_inventory_reports.dart';

import '../ui/restaurant_inventory/views/screen_unit_list.dart' as ri_unit_list;
import '../ui/restaurant_inventory/views/screen_unit_form.dart' as ri_unit_form;
import '../ui/restaurant_inventory/views/screen_location_list.dart' as ri_location_list;
import '../ui/restaurant_inventory/views/screen_location_form.dart' as ri_location_form;
import '../ui/restaurant_inventory/views/screen_group_list.dart' as ri_group_list;
import '../ui/restaurant_inventory/views/screen_group_form.dart' as ri_group_form;
import '../ui/restaurant_inventory/views/screen_tax_list.dart' as ri_tax_list;
import '../ui/restaurant_inventory/views/screen_tax_form.dart' as ri_tax_form;
import '../ui/restaurant_inventory/views/screen_material_list.dart' as ri_material_list;
import '../ui/restaurant_inventory/views/screen_material_form.dart' as ri_material_form;
import '../ui/restaurant_inventory/views/screen_vendor_list.dart' as ri_vendor_list;
import '../ui/restaurant_inventory/views/screen_vendor_form.dart' as ri_vendor_form;
import '../ui/restaurant_inventory/views/screen_bill_type_list.dart' as ri_bill_type_list;
import '../ui/restaurant_inventory/views/screen_bill_type_form.dart' as ri_bill_type_form;
import '../ui/restaurant_inventory/views/screen_stock_reason_list.dart' as ri_reason_list;
import '../ui/restaurant_inventory/views/screen_stock_reason_form.dart' as ri_reason_form;
import '../ui/restaurant_inventory/views/screen_adjustment_dashboard.dart' as ri_adj_dashboard;
import '../ui/restaurant_inventory/views/screen_stock_entry_form.dart' as ri_entry_form;
import '../ui/restaurant_inventory/views/screen_stock_out_form.dart' as ri_out_form;
import '../ui/restaurant_inventory/views/screen_po_list.dart' as ri_po_list;
import '../ui/restaurant_inventory/views/screen_po_form.dart' as ri_po_form;
import '../ui/restaurant_inventory/views/screen_grn_list.dart' as ri_grn_list;
import '../ui/restaurant_inventory/views/screen_grn_form.dart' as ri_grn_form;
import '../ui/restaurant_inventory/views/screen_invoice_list.dart' as ri_invoice_list;
import '../ui/restaurant_inventory/views/screen_invoice_form.dart' as ri_invoice_form;
import '../ui/restaurant_inventory/views/screen_indent_list.dart' as ri_indent_list;
import '../ui/restaurant_inventory/views/screen_indent_form.dart' as ri_indent_form;
import '../ui/restaurant_inventory/views/screen_transfer_list.dart' as ri_transfer_list;
import '../ui/restaurant_inventory/views/screen_transfer_form.dart' as ri_transfer_form;

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.login,
  redirect: (context, state) {
    final isLoggedIn = AppConfig.accessToken.isNotEmpty;
    final isOnAuthPage = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.onboarding;

    if (!isLoggedIn && !isOnAuthPage) {
      return AppRoutes.login;
    }

    if (isLoggedIn && isOnAuthPage) {
      return AppRoutes.home;
    }

    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const ScreenOnboarding(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const ScreenLogin(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ScreenForgotPassword(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        final sessionCubit = context.watch<CubitSession>();
        final user = sessionCubit.state.user;
        return AppShell(
          currentLocation: state.matchedLocation,
          user: user,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const ScreenHome(),
        ),
        GoRoute(
          path: AppRoutes.brandList,
          name: 'brandList',
          builder: (context, state) => const ScreenBrandList(),
        ),
        GoRoute(
          path: AppRoutes.brandCreate,
          name: 'brandCreate',
          builder: (context, state) => const ScreenBrandForm(),
        ),
        GoRoute(
          path: AppRoutes.brandDetail,
          name: 'brandDetail',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            return ScreenBrandDetail(brandId: brandId);
          },
        ),
        GoRoute(
          path: AppRoutes.brandEdit,
          name: 'brandEdit',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            return ScreenBrandForm(brandId: brandId);
          },
        ),
        GoRoute(
          path: AppRoutes.branchList,
          name: 'branchList',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            return ScreenBranchList(brandId: brandId);
          },
        ),
        GoRoute(
          path: AppRoutes.branchCreate,
          name: 'branchCreate',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            return ScreenBranchForm(brandId: brandId);
          },
        ),
        GoRoute(
          path: AppRoutes.branchDetail,
          name: 'branchDetail',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            final branchId = state.pathParameters['branchId']!;
            return ScreenBranchDetail(brandId: brandId, branchId: branchId);
          },
        ),
        GoRoute(
          path: AppRoutes.branchEdit,
          name: 'branchEdit',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            final branchId = state.pathParameters['branchId']!;
            return ScreenBranchForm(brandId: brandId, branchId: branchId);
          },
        ),
        GoRoute(
          path: AppRoutes.userList,
          name: 'userList',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            return ScreenUserList(brandId: brandId);
          },
          routes: [
            GoRoute(
              path: 'create',
              name: 'userCreate',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ScreenUserForm(brandId: brandId);
              },
            ),
            GoRoute(
              path: ':userId',
              name: 'userDetail',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                final userId = state.pathParameters['userId']!;
                return ScreenUserDetail(brandId: brandId, userId: userId);
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  name: 'userEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final userId = state.pathParameters['userId']!;
                    return ScreenUserForm(brandId: brandId, userId: userId);
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.menuDashboard,
          name: 'menuDashboard',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            return ScreenMenuDashboard(brandId: brandId);
          },
        ),
        GoRoute(
          path: AppRoutes.tableLayout,
          name: 'tableLayout',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            return ScreenTableLayout(brandId: brandId);
          },
        ),
        GoRoute(
          path: AppRoutes.roomTypes,
          name: 'roomTypes',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            return ScreenRoomTypeDashboard(brandId: brandId);
          },
        ),
        GoRoute(
          path: AppRoutes.posDevices,
          name: 'posDevices',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            return ScreenPosDeviceList(brandId: brandId);
          },
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const ScreenSettings(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ScreenProfile(),
        ),
        GoRoute(
          path: AppRoutes.branchPlanHistory,
          name: 'branchPlanHistory',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            final branchId = state.pathParameters['branchId']!;
            return ScreenBranchPlanHistory(
                brandId: brandId, branchId: branchId);
          },
        ),
        GoRoute(
          path: AppRoutes.branchPlanForm,
          name: 'branchPlanForm',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            final branchId = state.pathParameters['branchId']!;
            return ScreenBranchPlanForm(
                brandId: brandId, branchId: branchId);
          },
        ),
        GoRoute(
          path: AppRoutes.billList,
          name: 'billList',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            return ScreenBillList(brandId: brandId);
          },
          routes: [
            GoRoute(
              path: ':billId',
              name: 'billDetail',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                final billId = state.pathParameters['billId']!;
                return ScreenBillDetail(brandId: brandId, billId: billId);
              },
            ),
          ],
        ),
        // ── Inventory ──────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.inventoryDashboard,
          name: 'inventoryDashboard',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            return ScreenInventoryDashboard(brandId: brandId);
          },
          routes: [
            // Items (Raw Materials)
            GoRoute(
              path: 'items',
              name: 'itemList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ri_material_list.ScreenMaterialList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'itemCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_material_form.ScreenMaterialForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':itemId',
                  name: 'itemDetail',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final itemId = state.pathParameters['itemId']!;
                    return ri_material_form.ScreenMaterialForm(brandId: brandId, itemId: itemId);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      name: 'itemEdit',
                      builder: (context, state) {
                        final brandId = state.pathParameters['brandId']!;
                        final itemId = state.pathParameters['itemId']!;
                        return ri_material_form.ScreenMaterialForm(brandId: brandId, itemId: itemId);
                      },
                    ),
                  ],
                ),
              ],
            ),
            // Categories
            GoRoute(
              path: 'categories',
              name: 'invCategoryList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ScreenCategoryList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'invCategoryCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ScreenCategoryForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':categoryId/edit',
                  name: 'invCategoryEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final categoryId = state.pathParameters['categoryId']!;
                    return ScreenCategoryForm(
                        brandId: brandId, categoryId: categoryId);
                  },
                ),
              ],
            ),
            // Units
            GoRoute(
              path: 'units',
              name: 'unitList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ri_unit_list.ScreenUnitList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'unitCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_unit_form.ScreenUnitForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':unitId/edit',
                  name: 'unitEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final unitId = state.pathParameters['unitId']!;
                    return ri_unit_form.ScreenUnitForm(brandId: brandId, unitId: unitId);
                  },
                ),
              ],
            ),
            // Warehouses (Locations)
            GoRoute(
              path: 'warehouses',
              name: 'warehouseList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ri_location_list.ScreenLocationList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'warehouseCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_location_form.ScreenLocationForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':warehouseId/edit',
                  name: 'warehouseEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final warehouseId = state.pathParameters['warehouseId']!;
                    return ri_location_form.ScreenLocationForm(
                        brandId: brandId, locationId: warehouseId);
                  },
                ),
              ],
            ),
            // Suppliers (Vendors)
            GoRoute(
              path: 'suppliers',
              name: 'supplierList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ri_vendor_list.ScreenVendorList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'supplierCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_vendor_form.ScreenVendorForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':supplierId/edit',
                  name: 'supplierEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final supplierId = state.pathParameters['supplierId']!;
                    return ri_vendor_form.ScreenVendorForm(brandId: brandId, supplierId: supplierId);
                  },
                ),
                GoRoute(
                  path: ':supplierId/ledger',
                  name: 'supplierLedger',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final supplierId = state.pathParameters['supplierId']!;
                    return ScreenSupplierLedger(brandId: brandId, supplierId: supplierId);
                  },
                ),
              ],
            ),
            // Raw Material Groups
            GoRoute(
              path: 'groups',
              name: 'groupList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ri_group_list.ScreenGroupList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'groupCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_group_form.ScreenGroupForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':groupId/edit',
                  name: 'groupEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final groupId = state.pathParameters['groupId']!;
                    return ri_group_form.ScreenGroupForm(brandId: brandId, groupId: groupId);
                  },
                ),
              ],
            ),
            // Raw Material Taxes
            GoRoute(
              path: 'taxes',
              name: 'taxList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ri_tax_list.ScreenTaxList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'taxCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_tax_form.ScreenTaxForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':taxId/edit',
                  name: 'taxEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final taxId = state.pathParameters['taxId']!;
                    return ri_tax_form.ScreenTaxForm(brandId: brandId, taxId: taxId);
                  },
                ),
              ],
            ),
            // Bill Types
            GoRoute(
              path: 'bill-types',
              name: 'billTypeList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ri_bill_type_list.ScreenBillTypeList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'billTypeCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_bill_type_form.ScreenBillTypeForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':billTypeId/edit',
                  name: 'billTypeEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final billTypeId = state.pathParameters['billTypeId']!;
                    return ri_bill_type_form.ScreenBillTypeForm(brandId: brandId, billTypeId: billTypeId);
                  },
                ),
              ],
            ),
            // Stock Reasons
            GoRoute(
              path: 'reasons',
              name: 'reasonList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ri_reason_list.ScreenStockReasonList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'reasonCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_reason_form.ScreenStockReasonForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':reasonId/edit',
                  name: 'reasonEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final reasonId = state.pathParameters['reasonId']!;
                    return ri_reason_form.ScreenStockReasonForm(brandId: brandId, reasonId: reasonId);
                  },
                ),
              ],
            ),
            // Purchases
            GoRoute(
              path: 'purchases',
              name: 'purchaseList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ScreenPurchaseList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'purchaseCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ScreenPurchaseForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':purchaseId',
                  name: 'purchaseDetail',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final purchaseId = state.pathParameters['purchaseId']!;
                    return ScreenPurchaseDetail(brandId: brandId, purchaseId: purchaseId);
                  },
                ),
              ],
            ),
            // Purchase Orders (PO)
            GoRoute(
              path: 'purchase-orders',
              name: 'purchaseOrderList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ri_po_list.ScreenPOList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'purchaseOrderCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_po_form.ScreenPOForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':poId/edit',
                  name: 'purchaseOrderEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final poId = state.pathParameters['poId']!;
                    return ri_po_form.ScreenPOForm(brandId: brandId, poId: poId);
                  },
                ),
              ],
            ),
            // Goods Receipts (GRN)
            GoRoute(
              path: 'goods-receipts',
              name: 'goodsReceiptList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ri_grn_list.ScreenGRNList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'goodsReceiptCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_grn_form.ScreenGRNForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':grnId/edit',
                  name: 'goodsReceiptEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final grnId = state.pathParameters['grnId']!;
                    return ri_grn_form.ScreenGRNForm(brandId: brandId, grnId: grnId);
                  },
                ),
              ],
            ),
            // Supplier Invoices
            GoRoute(
              path: 'supplier-invoices',
              name: 'supplierInvoiceList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ri_invoice_list.ScreenInvoiceList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'supplierInvoiceCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_invoice_form.ScreenInvoiceForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':invoiceId/edit',
                  name: 'supplierInvoiceEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final invoiceId = state.pathParameters['invoiceId']!;
                    return ri_invoice_form.ScreenInvoiceForm(brandId: brandId, invoiceId: invoiceId);
                  },
                ),
              ],
            ),
            // Adjustments
            GoRoute(
              path: 'adjustments',
              name: 'adjustmentList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ri_adj_dashboard.ScreenAdjustmentDashboard(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'adjustmentCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_adj_dashboard.ScreenAdjustmentDashboard(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: 'entries/create',
                  name: 'manualStockEntryCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_entry_form.ScreenStockEntryForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: 'entries/:entryId/edit',
                  name: 'manualStockEntryEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final entryId = state.pathParameters['entryId']!;
                    return ri_entry_form.ScreenStockEntryForm(brandId: brandId, entryId: entryId);
                  },
                ),
                GoRoute(
                  path: 'outs/create',
                  name: 'manualStockOutCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_out_form.ScreenStockOutForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: 'outs/:outId/edit',
                  name: 'manualStockOutEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final outId = state.pathParameters['outId']!;
                    return ri_out_form.ScreenStockOutForm(brandId: brandId, outId: outId);
                  },
                ),
              ],
            ),
            // Transfers
            GoRoute(
              path: 'transfers',
              name: 'transferList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ri_transfer_list.ScreenTransferList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'transferCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_transfer_form.ScreenTransferForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':transferId/edit',
                  name: 'transferEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final transferId = state.pathParameters['transferId']!;
                    return ri_transfer_form.ScreenTransferForm(brandId: brandId, transferId: transferId);
                  },
                ),
              ],
            ),
            // Indents
            GoRoute(
              path: 'indents',
              name: 'indentList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ri_indent_list.ScreenIndentList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'indentCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ri_indent_form.ScreenIndentForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':indentId/edit',
                  name: 'indentEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final indentId = state.pathParameters['indentId']!;
                    return ri_indent_form.ScreenIndentForm(brandId: brandId, indentId: indentId);
                  },
                ),
              ],
            ),
            // Reports
            GoRoute(
              path: 'reports',
              name: 'inventoryReports',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ScreenInventoryReports(brandId: brandId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/users',
          name: 'users',
          builder: (context, state) => const UsersScreen(),
        ),
        GoRoute(
          path: '/tables',
          name: 'tables',
          builder: (context, state) => const TablesScreen(),
        ),
        GoRoute(
          path: '/all-pos-devices',
          name: 'standalonePosDevices',
          builder: (context, state) => const StandalonePosDevicesScreen(),
        ),
        GoRoute(
          path: '/menu',
          name: 'menu',
          builder: (context, state) => const MenuScreen(),
        ),
        GoRoute(
          path: AppRoutes.feedbackList,
          name: 'feedbackListScreen',
          builder: (context, state) => const FeedbackListScreen(),
        ),

        GoRoute(
          path: AppRoutes.feedbackCreate,
          name: 'feedbackCreate',
          builder: (context, state) => const FeedbackConfigurationScreen(),
        ),
        GoRoute(
          path: '/feedback/:feedbackId/edit',
          name: 'feedbackEdit',
          builder: (context, state) {
            final config = state.extra as FeedbackConfigurationModel? ??
                FeedbackConfigurationScreen.getDummyConfigById(state.pathParameters['feedbackId'] ?? '');
            return FeedbackConfigurationScreen(config: config);
          },
        ),
        GoRoute(
          path: AppRoutes.feedbackQuestionBuilder,
          name: 'feedbackQuestionBuilder',
          builder: (context, state) => const FeedbackQuestionBuilderScreen(),
        ),
        GoRoute(
          path: AppRoutes.customerResponses,
          name: 'customerResponses',
          builder: (context, state) => const ScreenCustomerResponse(),
        ),
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),

      ],
    ),
  ],
);