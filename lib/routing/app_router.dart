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

import 'package:back_office/ui/users/user_list/screen_user_list.dart';
import 'package:back_office/ui/users/user_form/screen_user_form.dart';

import 'package:back_office/ui/menu/menu_dashboard/screen_menu_dashboard.dart';

import 'package:back_office/ui/tables/table_layout/screen_table_layout.dart';

import 'package:back_office/ui/pos_devices/pos_device_list/screen_pos_device_list.dart';

import 'package:back_office/ui/settings/settings/screen_settings.dart';
import 'package:back_office/ui/profile/screen_profile.dart';
import 'package:back_office/ui/shell/placeholder_screens.dart';

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
          path: AppRoutes.branchDetail,
          name: 'branchDetail',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            final branchId = state.pathParameters['branchId']!;
            return ScreenBranchDetail(brandId: brandId, branchId: branchId);
          },
        ),
        GoRoute(
          path: AppRoutes.userList,
          name: 'userList',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            return ScreenUserList(brandId: brandId);
          },
        ),
        GoRoute(
          path: AppRoutes.userCreate,
          name: 'userCreate',
          builder: (context, state) {
            final brandId = state.pathParameters['brandId']!;
            return ScreenUserForm(brandId: brandId);
          },
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
        // Placeholder routes
        GoRoute(
          path: '/inventory',
          name: 'inventory',
          builder: (context, state) => const InventoryScreen(),
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