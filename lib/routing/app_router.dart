import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/routing/global_navigator.dart';
import 'package:back_office/routing/app_routes.dart';
import 'package:back_office/config/app_config.dart';
import 'package:back_office/theme/theme_constants.dart';
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

import '../ui/room_types/screen_room_type_dashboard.dart';
import '../ui/branch/branch_plan/screen_branch_plan_history.dart';
import '../ui/branch/branch_plan/screen_branch_plan_form.dart';
import '../ui/bills/bill_list/screen_bill_list.dart';
import '../ui/bills/bill_detail/screen_bill_detail.dart';

import '../ui/inventory/screen_inventory_dashboard.dart';
import '../ui/inventory/categories/screen_category_list.dart';
import '../ui/inventory/categories/screen_category_form.dart';
import '../ui/inventory/units/screen_unit_list.dart';
import '../ui/inventory/units/screen_unit_form.dart';
import '../ui/inventory/warehouses/screen_warehouse_list.dart';
import '../ui/inventory/warehouses/screen_warehouse_form.dart';
import '../ui/inventory/items/screen_item_list.dart';
import '../ui/inventory/items/screen_item_form.dart';
import '../ui/inventory/items/screen_item_detail.dart';
import '../ui/inventory/suppliers/screen_supplier_list.dart';
import '../ui/inventory/suppliers/screen_supplier_form.dart';
import '../ui/inventory/suppliers/screen_supplier_ledger.dart';
import '../ui/inventory/purchases/screen_purchase_list.dart';
import '../ui/inventory/purchases/screen_purchase_form.dart';
import '../ui/inventory/purchases/screen_purchase_detail.dart';
import '../ui/inventory/adjustments/screen_adjustment_list.dart';
import '../ui/inventory/adjustments/screen_adjustment_form.dart';
import '../ui/inventory/transfers/screen_transfer_list.dart';
import '../ui/inventory/transfers/screen_transfer_form.dart';
import '../ui/inventory/reports/screen_inventory_reports.dart';

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
            // Items
            GoRoute(
              path: 'items',
              name: 'itemList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ScreenItemList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'itemCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ScreenItemForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':itemId',
                  name: 'itemDetail',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final itemId = state.pathParameters['itemId']!;
                    return ScreenItemDetail(brandId: brandId, itemId: itemId);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      name: 'itemEdit',
                      builder: (context, state) {
                        final brandId = state.pathParameters['brandId']!;
                        final itemId = state.pathParameters['itemId']!;
                        return ScreenItemForm(brandId: brandId, itemId: itemId);
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
                return ScreenUnitList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'unitCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ScreenUnitForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':unitId/edit',
                  name: 'unitEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final unitId = state.pathParameters['unitId']!;
                    return ScreenUnitForm(brandId: brandId, unitId: unitId);
                  },
                ),
              ],
            ),
            // Warehouses
            GoRoute(
              path: 'warehouses',
              name: 'warehouseList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ScreenWarehouseList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'warehouseCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ScreenWarehouseForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':warehouseId/edit',
                  name: 'warehouseEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final warehouseId = state.pathParameters['warehouseId']!;
                    return ScreenWarehouseForm(
                        brandId: brandId, warehouseId: warehouseId);
                  },
                ),
              ],
            ),
            // Suppliers
            GoRoute(
              path: 'suppliers',
              name: 'supplierList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ScreenSupplierList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'supplierCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ScreenSupplierForm(brandId: brandId);
                  },
                ),
                GoRoute(
                  path: ':supplierId/edit',
                  name: 'supplierEdit',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    final supplierId = state.pathParameters['supplierId']!;
                    return ScreenSupplierForm(brandId: brandId, supplierId: supplierId);
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
            // Adjustments
            GoRoute(
              path: 'adjustments',
              name: 'adjustmentList',
              builder: (context, state) {
                final brandId = state.pathParameters['brandId']!;
                return ScreenAdjustmentList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'adjustmentCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ScreenAdjustmentForm(brandId: brandId);
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
                return ScreenTransferList(brandId: brandId);
              },
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'transferCreate',
                  builder: (context, state) {
                    final brandId = state.pathParameters['brandId']!;
                    return ScreenTransferForm(brandId: brandId);
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
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
    ),
  ],
);