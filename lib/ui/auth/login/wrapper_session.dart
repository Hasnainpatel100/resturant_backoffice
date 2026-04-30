import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/imports/packages_imports.dart';
import 'package:back_office/ui/auth/login/cubit_session.dart';
import 'package:back_office/ui/auth/login/state_session.dart';

class WrapperSession extends StatelessWidget {
  final Widget child;
  const WrapperSession({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CubitSession, StateSession>(
      listenWhen: (prev, next) => prev.status != next.status,
      listener: (context, state) {
        if (state.status != SessionStatus.unknown) {
          FlutterNativeSplash.remove();
          if (state.status == SessionStatus.authenticated) {
            context.go(AppRoutes.home);
          } else if (state.status == SessionStatus.unauthenticated) {
            context.go(AppRoutes.onboarding);
          }
        }
      },
      child: child,
    );
  }
}