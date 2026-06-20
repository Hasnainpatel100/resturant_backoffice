import 'package:back_office/imports/imports.dart';
import 'package:back_office/ui/settings/settings/cubit_theme.dart';
import 'package:flutter/material.dart';
import 'package:back_office/imports/core_imports.dart';

class ScreenSettings extends StatelessWidget {
  const ScreenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
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
                  title: const Text('Language'),
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
                        title: const Text('Select Language'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text('English'),
                              onTap: () {
                                context.setLocale(const Locale('en'));
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('हिन्दी'),
                              onTap: () {
                                context.setLocale(const Locale('hi'));
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('اردو'),
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
          Text('Account', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Change PIN'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
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
