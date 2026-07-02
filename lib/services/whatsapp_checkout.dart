import 'package:url_launcher/url_launcher.dart';

import 'package:beipoa_mobile/config/app_config.dart';
import 'package:beipoa_mobile/models/checkout.dart';
import 'package:beipoa_mobile/services/cart_service.dart';
import 'package:beipoa_mobile/utils/formatters.dart';

/// Builds and opens a WhatsApp order message for manual checkout.
class WhatsAppCheckout {
  static String buildOrderMessage({
    required CheckoutFormData customer,
    required List<CartLine> items,
    required int subtotal,
    required int shipping,
    required int total,
  }) {
    final buffer = StringBuffer()
      ..writeln('Hello Computer Beipoa, I would like to place an order from the mobile app.')
      ..writeln()
      ..writeln('*Customer*')
      ..writeln('Name: ${customer.fullName.trim()}')
      ..writeln('Phone: ${customer.phone.trim()}')
      ..writeln('Email: ${customer.email.trim()}')
      ..writeln()
      ..writeln('*Delivery*')
      ..writeln('Address: ${customer.addressLine1.trim()}')
      ..writeln('City: ${customer.city.trim()}');

    if (customer.addressLine2.trim().isNotEmpty) {
      buffer.writeln('Extra: ${customer.addressLine2.trim()}');
    }
    if (customer.region.trim().isNotEmpty) {
      buffer.writeln('Region: ${customer.region.trim()}');
    }

    buffer
      ..writeln()
      ..writeln('*Order items*');

    for (var i = 0; i < items.length; i++) {
      final line = items[i];
      buffer.writeln(
        '${i + 1}. ${line.name} x${line.quantity} — ${formatPrice(line.price)} each',
      );
    }

    buffer
      ..writeln()
      ..writeln('*Totals*')
      ..writeln('Subtotal: ${formatPrice('$subtotal')}')
      ..writeln('Shipping: ${shipping == 0 ? 'Free' : formatPrice('$shipping')}')
      ..writeln('*Total: ${formatPrice('$total')}*');

    if (customer.notes.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('*Notes*')
        ..writeln(customer.notes.trim());
    }

    buffer
      ..writeln()
      ..writeln('Please confirm availability, delivery time, and payment details. Thank you!');

    return buffer.toString();
  }

  static Uri orderUri(String message) {
    return Uri.parse(
      'https://wa.me/${AppConfig.whatsappNumber}?text=${Uri.encodeComponent(message)}',
    );
  }

  static Future<bool> launchOrder(String message) async {
    final uri = orderUri(message);
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
