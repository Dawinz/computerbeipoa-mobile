import 'package:intl/intl.dart';
import 'package:beipoa_mobile/config/app_config.dart';

final _currency = NumberFormat.currency(
  locale: 'en_TZ',
  symbol: 'TZS ',
  decimalDigits: 0,
);

String formatPrice(String amount) {
  final value = double.tryParse(amount);
  if (value == null) return amount;
  return _currency.format(value).trim();
}

String resolveImageUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  if (url.startsWith('/')) {
    return '${AppConfig.webBaseUrl}$url';
  }
  return '${AppConfig.webBaseUrl}/$url';
}
