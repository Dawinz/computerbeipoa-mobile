import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:beipoa_mobile/config/app_config.dart';
import 'package:beipoa_mobile/services/theme_service.dart';
import 'package:beipoa_mobile/theme/app_theme.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Image.asset('assets/logo.png', height: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Computer Beipoa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.appText,
                    ),
                  ),
                  Text(
                    'house of computer',
                    style: TextStyle(color: context.appTextMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Best Online Store — Kariakoo Business Awards 2026',
          style: TextStyle(
            color: context.appTextMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _SectionTitle('Appearance'),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: context.appBorder),
              bottom: BorderSide(color: context.appBorder),
            ),
          ),
          child: SwitchListTile(
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: AppColors.orange),
              title: Text('Dark mode', style: TextStyle(color: context.appText)),
              subtitle: Text(
                isDark ? 'Easier on the eyes in low light' : 'Switch to a darker theme',
                style: TextStyle(color: context.appTextMuted),
              ),
              value: isDark,
              onChanged: theme.toggleDark,
            ),
        ),
        const SizedBox(height: 16),
        _SectionTitle('Support'),
        _Tile(
          icon: Icons.phone,
          title: 'Call us',
          subtitle: AppConfig.supportPhoneDisplay,
          onTap: () => _launch(Uri.parse('tel:${AppConfig.supportPhone}')),
        ),
        _Tile(
          icon: Icons.chat_outlined,
          title: 'WhatsApp',
          subtitle: 'Chat with our team',
          onTap: () => _launch(Uri.parse('https://wa.me/${AppConfig.whatsappNumber}')),
        ),
        _Tile(
          icon: Icons.email_outlined,
          title: 'Email',
          subtitle: AppConfig.supportEmail,
          onTap: () => _launch(Uri.parse('mailto:${AppConfig.supportEmail}')),
        ),
        _Tile(
          icon: Icons.language,
          title: 'Visit website',
          subtitle: 'computerbeipoa.co.tz',
          onTap: () => _launch(Uri.parse(AppConfig.webBaseUrl)),
        ),
        const SizedBox(height: 16),
        _SectionTitle('About'),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: context.appBorder),
              bottom: BorderSide(color: context.appBorder),
            ),
          ),
          child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.local_shipping_outlined, color: AppColors.orange),
                  title: Text('Free delivery', style: TextStyle(color: context.appText)),
                  subtitle: Text(
                    'On orders over TZS 500,000',
                    style: TextStyle(color: context.appTextMuted),
                  ),
                ),
                Divider(height: 1, color: context.appBorder),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined, color: AppColors.orange),
                  title: Text('Warranty included', style: TextStyle(color: context.appText)),
                  subtitle: Text(
                    'New and certified refurbished devices',
                    style: TextStyle(color: context.appTextMuted),
                  ),
                ),
                Divider(height: 1, color: context.appBorder),
                ListTile(
                  leading: const Icon(Icons.payments_outlined, color: AppColors.orange),
                  title: Text('Mobile money checkout', style: TextStyle(color: context.appText)),
                  subtitle: Text(
                    'M-Pesa, Tigo Pesa & Airtel Money',
                    style: TextStyle(color: context.appTextMuted),
                  ),
                ),
              ],
            ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Version 1.0.0',
            style: TextStyle(fontSize: 12, color: context.appTextMuted),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.purple,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.appBorder),
          bottom: BorderSide(color: context.appBorder),
        ),
      ),
      child: ListTile(
          leading: Icon(icon, color: AppColors.orange),
          title: Text(title, style: TextStyle(color: context.appText)),
          subtitle: Text(subtitle, style: TextStyle(color: context.appTextMuted)),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
    );
  }
}
