/// Runtime config via `--dart-define=API_URL=...` and `--dart-define=WEB_URL=...`
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api-production-32f72.up.railway.app/api/v1',
  );

  static const String webBaseUrl = String.fromEnvironment(
    'WEB_URL',
    defaultValue: 'https://computerbeipoa.co.tz',
  );

  static const String supportPhone = '+255718314193';
  static const String supportPhoneDisplay = '+255 718 314 193';
  static const String whatsappNumber = '255718314193';
  static const String supportEmail = 'info@computerbeipoa.co.tz';
}
