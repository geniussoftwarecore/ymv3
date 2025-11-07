import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../generated/l10n.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/constants/app_constants.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).settings),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أحمد محمد',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ahmed.mohammed@workshop.com',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'مدير الورشة',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        _showEditProfileDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Settings Section
            Text(
              'إعدادات التطبيق',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(S.of(context).language),
                    subtitle: Text(
                      locale.languageCode == 'ar'
                          ? S.of(context).arabic
                          : S.of(context).english,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showLanguageDialog(context, ref);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: Text(S.of(context).theme),
                    subtitle: Text(S.of(context).light),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showThemeDialog(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: Text(S.of(context).notifications),
                    subtitle: const Text('مفعل'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // Handle notification toggle
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Settings Section
            Text(
              'إعدادات الحساب',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(S.of(context).changePassword),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showChangePasswordDialog(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.security_outlined),
                    title: const Text('الأمان والخصوصية'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to security settings
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text('النسخ الاحتياطي'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to backup settings
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Support Section
            Text(
              'الدعم والمساعدة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('مركز المساعدة'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to help center
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.contact_support_outlined),
                    title: Text(S.of(context).contactUs),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to contact us
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.bug_report_outlined),
                    title: const Text('الإبلاغ عن مشكلة'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to bug report
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About Section
            Text(
              'حول التطبيق',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(S.of(context).about),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: Text(S.of(context).termsOfService),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to terms of service
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(S.of(context).privacyPolicy),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to privacy policy
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: const Icon(Icons.logout_outlined),
                label: Text(S.of(context).logout),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Version Info
            Center(
              child: Text(
                '${S.of(context).version} ${AppConstants.appVersion}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    var selectedLanguage = locale.languageCode;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(S.of(context).language),
            content: RadioGroup<String>(
              groupValue: selectedLanguage,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  selectedLanguage = value;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text(S.of(context).arabic),
                    value: 'ar',
                  ),
                  RadioListTile<String>(
                    title: Text(S.of(context).english),
                    value: 'en',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  localeNotifier.setLocale(Locale(selectedLanguage));
                  Navigator.pop(context);
                },
                child: Text(S.of(context).ok),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    var selectedTheme = 'light';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(S.of(context).theme),
            content: RadioGroup<String>(
              groupValue: selectedTheme,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  selectedTheme = value;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text(S.of(context).light),
                    value: 'light',
                  ),
                  RadioListTile<String>(
                    title: Text(S.of(context).dark),
                    value: 'dark',
                  ),
                  RadioListTile<String>(
                    title: Text(S.of(context).system),
                    value: 'system',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle theme change here
                  Navigator.pop(context);
                },
                child: Text(S.of(context).ok),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).updateProfile),
        content: const Text('سيتم إضافة نموذج تحديث الملف الشخصي هنا'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).changePassword),
        content: const Text('سيتم إضافة نموذج تغيير كلمة المرور هنا'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.build_circle,
          size: 32,
          color: Colors.white,
        ),
      ),
      children: [
        const Text('نظام إدارة الورش الهجين'),
        const SizedBox(height: 8),
        const Text('تطبيق شامل لإدارة ورش السيارات مع دعم الذكاء الاصطناعي'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).logout),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(S.of(context).logout),
          ),
        ],
      ),
    );
  }
}
