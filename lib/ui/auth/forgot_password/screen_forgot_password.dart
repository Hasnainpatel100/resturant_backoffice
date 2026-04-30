import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/imports/packages_imports.dart';
import 'package:back_office/ui/auth/login/cubit_auth.dart';

class ScreenForgotPassword extends HookWidget {
  const ScreenForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();

    final isLoading = context.select((CubitAuth cubit) => cubit.state.isLoading);

    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    void handleReset() {
      if (!(formKey.currentState?.validate() ?? false)) return;

      context.read<CubitAuth>().forgotPassword(
        context: context,
        email: emailController.text,
      );
    }

    return Scaffold(
      appBar: AppTopBar(
        title: '',
        onPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.xl),
                Icon(
                  Icons.lock_reset,
                  size: 64,
                  color: cs.primary,
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'auth.forgot_password'.tr(),
                  style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'auth.reset_instructions'.tr(),
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(height: AppSpacing.xxxl),
                Form(
                  key: formKey,
                  child: AppTextField(
                    controller: emailController,
                    enabled: !isLoading,
                    label: 'auth.email_label'.tr(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: (v) {
                      if (AppUtils.isBlank(v)) {
                        return 'auth.email_required'.tr();
                      }
                      if (!v!.contains('@')) {
                        return 'auth.invalid_email'.tr();
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => handleReset(),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'auth.send_reset_link'.tr(),
                  isLoading: isLoading,
                  onPressed: isLoading ? null : handleReset,
                  width: ButtonSize.large,
                  isFullWidth: true,
                ),
                SizedBox(height: AppSpacing.xl),
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'auth.back_to_login'.tr(),
                    style: tt.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
