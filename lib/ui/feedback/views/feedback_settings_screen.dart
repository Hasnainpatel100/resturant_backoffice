import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class FeedbackSettingsScreen extends StatelessWidget {
  const FeedbackSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('common.feedback_settings'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('common.configure_your_customer_feedba'.tr(),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: Text('common.enable_auto_replies'.tr()),
            subtitle: Text('common.send_an_automated_sms_email_wh'.tr()),
            value: false,
            onChanged: (bool value) {
               ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('common.feature_coming_soon'.tr())),
                );
            },
          ),
          const Divider(),
          ListTile(
            title: Text('common.feedback_form_questions'.tr()),
            subtitle: Text('common.customize_what_questions_you_a'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('common.form_builder_coming_soon'.tr())),
                );
            },
          ),
        ],
      ),
    );
  }
}
