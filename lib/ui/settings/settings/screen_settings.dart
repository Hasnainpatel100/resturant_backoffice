import 'package:back_office/imports/imports.dart';
import 'package:back_office/ui/settings/settings/cubit_theme.dart';

class ScreenSettings extends StatelessWidget {
  const ScreenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('common.settings'.tr())),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          Text('common.preferences'.tr(), style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: Text('common.dark_mode'.tr()),
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (value) {
                      context.read<CubitTheme>().setDarkMode(value);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text('common.language'.tr()),
                  subtitle: Text(
                    context.locale.languageCode == 'hi'
                        ? 'Hindi'
                        : 'English',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('common.select_language'.tr()),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text('common.english'.tr()),
                              onTap: () {
                                context.setLocale(const Locale('en'));
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: Text('common.empty_key'.tr()),
                              onTap: () {
                                context.setLocale(const Locale('hi'));
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: Text('common.empty_key'.tr()),
                              onTap: () {
                                context.setLocale(const Locale('ur'));
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text('common.account'.tr(), style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.security),
                  title: Text('common.change_pin'.tr()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text('common.notifications'.tr()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text('common.about'.tr(), style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text('common.app_version'.tr()),
                  subtitle: Text('common.1_0_0'.tr()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: Text('common.terms_of_service'.tr()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: Text('common.privacy_policy'.tr()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
