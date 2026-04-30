import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/imports/packages_imports.dart';


class ScreenOnboarding extends HookWidget {
  const ScreenOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final pageController = usePageController();
    final currentIndex = useState(0);

    final List<Map<String, dynamic>> onboardingData = useMemoized(() => [
      {
        'title': 'onboarding.onboarding_title_1'.tr(),
        'subtitle':
            'onboarding.onboarding_subtitle_1'.tr(),
        'pageWidget': const FlutterLogo(size: 200),
      },
      {
        'title': 'onboarding.onboarding_title_2'.tr(),
        'subtitle':
            'onboarding.onboarding_subtitle_2'.tr(),
        'pageWidget': const FlutterLogo(size: 200),
      },
      {
        'title': 'onboarding.onboarding_title_3'.tr(),
        'subtitle':
            'onboarding.onboarding_subtitle_3'.tr(),
        'pageWidget': const FlutterLogo(size: 200),
      },
    ]);

    void onGetStarted() {
      // Navigate back or to home. For template purpose:
      context.go(AppRoutes.login);
    }

    return _OnboardingView(
      theme: theme,
      colorScheme: colorScheme,
      textTheme: textTheme,
      pageController: pageController,
      currentIndex: currentIndex.value,
      onboardingData: onboardingData,
      onPageChanged: (index) => currentIndex.value = index,
      onGetStarted: onGetStarted,
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView({
    required this.theme,
    required this.colorScheme,
    required this.textTheme,
    required this.pageController,
    required this.currentIndex,
    required this.onboardingData,
    required this.onPageChanged,
    required this.onGetStarted,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final PageController pageController;
  final int currentIndex;
  final List<Map<String, dynamic>> onboardingData;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top branding
            Padding(
              padding: EdgeInsets.only(
                top: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              child: Text(
                'FlutterInit.',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  fontSize: 22,
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: onboardingData.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      // Dynamic Illustration Section
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: onboardingData[index]['pageWidget'] as Widget,
                          ),
                        ),
                      ),
                      
                      // Text Section
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: Column(
                          children: [
                            Text(
                              onboardingData[index]['title'] as String,
                              textAlign: TextAlign.center,
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                height: 1.2,
                                fontSize: 24,
                              ),
                            ),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              onboardingData[index]['subtitle'] as String,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),

            // Bottom Section: Dots and Button
            Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                   SizedBox(height: AppSpacing.xl),
                  // Get Started Button
                  AppButton(
                    label: 'shared.get_started'.tr(),
                    onPressed: onGetStarted,
                    variant: ButtonVariant.primary,
                    width: ButtonSize.medium,
                  ),
                  SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
