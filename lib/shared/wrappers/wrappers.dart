// Flutter SDK
export 'package:flutter/material.dart';
export 'package:flutter/cupertino.dart' hide RefreshCallback;
export 'package:flutter/foundation.dart';
export 'package:flutter/services.dart';
export 'package:flutter_native_splash/flutter_native_splash.dart';

export 'package:easy_localization/easy_localization.dart' hide TextDirection, MapExtension;
export 'package:fpdart/fpdart.dart' hide State;

// Project Core - everything exported through shared.dart (theme, extensions,
// utils, widgets, enums) plus routing and services.
export '../../config/app_config.dart';
export '../../routing/app_router.dart';
export '../../routing/app_routes.dart';
export '../../routing/global_navigator.dart';
export '../../services/services.dart';
export '../shared.dart';
export '../../data/models/user_model.dart';

export '../../ui/auth/login/screen_login.dart';
export '../../ui/auth/forgot_password/screen_forgot_password.dart';
export '../../ui/home/screen_home.dart';
export '../../ui/onboarding/screen_onboarding.dart';