import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/imports/packages_imports.dart';
import 'package:back_office/data/repositories/auth_repository_impl.dart';
import 'package:back_office/ui/auth/login/cubit_session.dart';

class StateWrapper extends StatelessWidget {
  final Widget child;

  const StateWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitSession(repository: AuthRepositoryImpl()),
      child: child,
    );
  }
}