import 'package:back_office/data/repositories/auth_repository_impl.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/imports/packages_imports.dart';
import 'package:back_office/shared/wrappers/skeleton_wrapper.dart';
import 'package:back_office/ui/auth/login/cubit_auth.dart';
import 'package:back_office/ui/auth/login/cubit_session.dart';
import 'package:back_office/ui/auth/login/state_session.dart';
import 'package:back_office/ui/settings/settings/cubit_theme.dart';
import 'package:flutter/scheduler.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    WebSecurity.enableInspectProtection();
    final authRepository = AuthRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CubitAuth(repository: authRepository)),
        BlocProvider(create: (_) => CubitSession(repository: authRepository)),
        BlocProvider(create: (_) => CubitTheme()),
      ],
      child: Builder(builder: (context) => _buildApp(context)),
    );
  }

  Widget _buildApp(BuildContext context) {
    return CupertinoApp.router(
      title: 'BackOffice',
      debugShowCheckedModeBanner: false,
      theme: buildCupertinoTheme(primaryColorHex: '#007ea8'),
      routerConfig: appRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        Widget current = child ?? const SizedBox.shrink();
        current = SkeletonWrapper(child: current);
        current = _SessionListenerWrapper(child: current);

        final content = current;

        current = BlocBuilder<CubitTheme, bool>(
          builder: (context, isDark) {
            return Theme(
              data: isDark
                  ? buildDarkTheme(primaryColorHex: '#007ea8')
                  : buildLightTheme(primaryColorHex: '#007ea8'),
              child: content,
            );
          },
        );
        return current;
      },
    );
  }
}

class _SessionListenerWrapper extends StatefulWidget {
  const _SessionListenerWrapper({required this.child});

  final Widget child;

  @override
  State<_SessionListenerWrapper> createState() =>
      _SessionListenerWrapperState();
}

class _SessionListenerWrapperState extends State<_SessionListenerWrapper> {
  bool _sessionHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sessionHandled) return;
    _sessionHandled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sessionCubit = context.read<CubitSession>();
      final status = sessionCubit.state.status;
      if (status != SessionStatus.unknown) {
        FlutterNativeSplash.remove();
        if (status == SessionStatus.authenticated) {
          rootNavigatorKey.currentContext?.go(AppRoutes.home);
        } else if (status == SessionStatus.unauthenticated) {
          rootNavigatorKey.currentContext?.go(AppRoutes.onboarding);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CubitSession, StateSession>(
      listenWhen: (prev, next) => prev.status != next.status,
      listener: (context, state) {
        if (state.status != SessionStatus.unknown) {
          FlutterNativeSplash.remove();
          if (state.status == SessionStatus.authenticated) {
            rootNavigatorKey.currentContext?.go(AppRoutes.home);
          } else if (state.status == SessionStatus.unauthenticated) {
            rootNavigatorKey.currentContext?.go(AppRoutes.onboarding);
          }
        }
      },
      child: widget.child,
    );
  }
}
