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
                Text(
                  'Welcome Back',
                  style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Sign in to your account',
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
                        label: 'Username',
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (v) {
                          if (AppUtils.isBlank(v)) {
                            return 'Username is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: pinController,
                        enabled: !isLoading,
                        label: 'PIN',
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
                            return 'PIN is required';
                          }
                          if (v!.length < 4) {
                            return 'PIN must be at least 4 digits';
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
                              Text(
                                'Remember me',
                                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'Sign In',
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
