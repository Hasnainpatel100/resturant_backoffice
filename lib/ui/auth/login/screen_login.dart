import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/imports/packages_imports.dart';
import 'package:back_office/ui/auth/login/cubit_auth.dart';

class ScreenLogin extends HookWidget {
  const ScreenLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = useMemoized(() => GlobalKey<FormState>());
    final usernameController = useTextEditingController();
    final pinController = useTextEditingController();
    final obscurePin = useState(true);
    final rememberMe = useState(false);

    final isLoading = context.select((CubitAuth cubit) => cubit.state.isLoading);

    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    Future<void> handleLogin() async {
      if (!(formKey.currentState?.validate() ?? false)) {
        return;
      }

      context.read<CubitAuth>().login(
        context: context,
        email: usernameController.text,
        password: pinController.text,
        rememberMe: rememberMe.value,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.xl),
                Text('common.auth_welcome_back'.tr().tr(),
                  style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.sm),
                Text('common.auth_sign_in_subtitle'.tr().tr(),
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(height: AppSpacing.xxxl),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: usernameController,
                        enabled: !isLoading,
                        label: 'common.auth_username'.tr().tr(),
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (v) {
                          if (AppUtils.isBlank(v)) {
                            return 'auth.username_required'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: pinController,
                        enabled: !isLoading,
                        label: 'common.auth_pin'.tr().tr(),
                        obscureText: obscurePin.value,
                        prefixIcon: const Icon(Icons.lock_outline),
                        keyboardType: TextInputType.number,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePin.value ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => obscurePin.value = !obscurePin.value,
                        ),
                        validator: (v) {
                          if (AppUtils.isBlank(v)) {
                            return 'auth.pin_required'.tr();
                          }
                          if (v!.length < 4) {
                            return 'auth.pin_min_length'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 5,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: rememberMe.value,
                                  onChanged: (value) => rememberMe.value = value ?? false,
                                ),
                              ),
                              Text('common.auth_remember_me'.tr().tr(),
                                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'common.auth_sign_in'.tr().tr(),
                        isLoading: isLoading,
                        onPressed: isLoading ? null : handleLogin,
                        width: ButtonSize.large,
                        isFullWidth: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
