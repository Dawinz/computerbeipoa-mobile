import 'package:flutter/material.dart';

import 'package:beipoa_mobile/config/app_config.dart';
import 'package:beipoa_mobile/models/checkout.dart';
import 'package:beipoa_mobile/services/cart_service.dart';
import 'package:beipoa_mobile/services/whatsapp_checkout.dart';
import 'package:beipoa_mobile/theme/app_theme.dart';
import 'package:beipoa_mobile/utils/formatters.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.cart});

  final CartService cart;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  var _step = 0;
  var _submitting = false;
  CheckoutFormData _form = CheckoutFormData();

  int get _subtotal => widget.cart.subtotal.round();
  int get _shipping => calculateShipping(_subtotal);
  int get _total => calculateOrderTotal(_subtotal);

  void _continueToReview() {
    if (_formKey.currentState?.validate() != true) return;
    _formKey.currentState!.save();
    setState(() => _step = 1);
  }

  Future<void> _sendViaWhatsApp() async {
    _formKey.currentState?.save();

    setState(() => _submitting = true);
    try {
      final message = WhatsAppCheckout.buildOrderMessage(
        customer: _form,
        items: widget.cart.items,
        subtotal: _subtotal,
        shipping: _shipping,
        total: _total,
      );

      final launched = await WhatsAppCheckout.launchOrder(message);
      if (!mounted) return;

      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp. Install WhatsApp or contact us by phone.'),
          ),
        );
        return;
      }

      widget.cart.clear();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => WhatsAppCheckoutSuccessScreen(
            customerName: _form.fullName.trim(),
            total: _total,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 0 ? 'Delivery details' : 'Review order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step == 1) {
              setState(() => _step = 0);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          _CheckoutSteps(current: _step),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_step == 0) ...[
                    _SectionTitle('Contact'),
                    _field('Full name', (v) => _form = _form.copyWith(fullName: v ?? ''), initial: _form.fullName, required: true),
                    _field('Email', (v) => _form = _form.copyWith(email: v ?? ''), initial: _form.email, keyboard: TextInputType.emailAddress, required: true),
                    _field('Phone', (v) => _form = _form.copyWith(phone: v ?? ''), initial: _form.phone, keyboard: TextInputType.phone, required: true),
                    const SizedBox(height: 8),
                    _SectionTitle('Delivery address'),
                    _field('City', (v) => _form = _form.copyWith(city: v ?? ''), initial: _form.city, required: true),
                    _field('Region (optional)', (v) => _form = _form.copyWith(region: v ?? ''), initial: _form.region),
                    _field('Street address', (v) => _form = _form.copyWith(addressLine1: v ?? ''), initial: _form.addressLine1, required: true, minLength: 5),
                    _field('Apartment, floor (optional)', (v) => _form = _form.copyWith(addressLine2: v ?? ''), initial: _form.addressLine2),
                    _field('Order notes (optional)', (v) => _form = _form.copyWith(notes: v ?? ''), initial: _form.notes, maxLines: 3),
                  ] else ...[
                    Card(
                      color: AppColors.purpleSoft.withValues(alpha: 0.35),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.chat, color: Color(0xFF25D366), size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Complete your order on WhatsApp',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: context.appText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'We will receive your cart and delivery details in WhatsApp. Our team will confirm stock, delivery, and payment with you.',
                                    style: TextStyle(fontSize: 13, color: context.appTextMuted, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _OrderItemsCard(items: widget.cart.items),
                    const SizedBox(height: 16),
                    _OrderSummaryCard(subtotal: _subtotal, shipping: _shipping, total: _total),
                    const SizedBox(height: 12),
                    Text(
                      'WhatsApp: ${AppConfig.supportPhoneDisplay}',
                      style: TextStyle(fontSize: 13, color: context.appTextMuted),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
            decoration: BoxDecoration(
              color: context.appCard,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
              ],
            ),
            child: FilledButton.icon(
              onPressed: _submitting
                  ? null
                  : _step == 0
                      ? _continueToReview
                      : _sendViaWhatsApp,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: _step == 1 ? const Color(0xFF25D366) : null,
              ),
              icon: _submitting
                  ? const SizedBox.shrink()
                  : Icon(_step == 0 ? Icons.arrow_forward : Icons.chat),
              label: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_step == 0 ? 'Review order' : 'Send order via WhatsApp'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    void Function(String?) onSaved, {
    String initial = '',
    TextInputType? keyboard,
    bool required = false,
    int minLength = 2,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initial,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        onSaved: onSaved,
        validator: required
            ? (v) {
                final value = v?.trim() ?? '';
                if (value.length < minLength) return 'Please enter $label';
                if (label.toLowerCase().contains('email') && !value.contains('@')) {
                  return 'Enter a valid email';
                }
                if (label.toLowerCase().contains('phone')) {
                  final digits = value.replaceAll(RegExp(r'\D'), '');
                  if (digits.length < 9) return 'Enter a valid phone number';
                }
                return null;
              }
            : null,
      ),
    );
  }
}

class WhatsAppCheckoutSuccessScreen extends StatelessWidget {
  const WhatsAppCheckoutSuccessScreen({
    super.key,
    required this.customerName,
    required this.total,
  });

  final String customerName;
  final int total;

  @override
  Widget build(BuildContext context) {
    final firstName = customerName.split(' ').first;

    return Scaffold(
      appBar: AppBar(title: const Text('Order sent')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.chat, size: 72, color: Color(0xFF25D366)),
          const SizedBox(height: 16),
          Text(
            'Thank you, $firstName!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order details were sent to Computer Beipoa on WhatsApp.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appTextMuted, height: 1.4),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Estimated total', formatPrice('$total'), bold: true),
                  _row('Next step', 'Our team will confirm your order on WhatsApp'),
                  _row('Support', AppConfig.supportPhoneDisplay),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: const Text('Continue shopping'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: AppColors.textMuted))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutSteps extends StatelessWidget {
  const _CheckoutSteps({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _dot(context, 'Details', active: current == 0, done: current > 0),
          Expanded(child: Container(height: 2, color: current > 0 ? AppColors.purple : context.appBorder)),
          _dot(context, 'WhatsApp', active: current == 1, done: false),
        ],
      ),
    );
  }

  Widget _dot(BuildContext context, String label, {required bool active, required bool done}) {
    final color = done || active ? AppColors.purple : context.appBorder;
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: done
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  label == 'Details' ? '1' : '2',
                  style: TextStyle(color: active ? Colors.white : context.appTextMuted, fontSize: 12),
                ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: context.appTextMuted)),
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
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: context.appText),
      ),
    );
  }
}

class _OrderItemsCard extends StatelessWidget {
  const _OrderItemsCard({required this.items});

  final List<CartLine> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items (${items.length})', style: TextStyle(fontWeight: FontWeight.bold, color: context.appText)),
            const SizedBox(height: 10),
            ...items.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${line.name} x${line.quantity}',
                        style: TextStyle(color: context.appText),
                      ),
                    ),
                    Text(formatPrice('${line.lineTotal.round()}'), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.subtotal, required this.shipping, required this.total});

  final int subtotal;
  final int shipping;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _line('Subtotal', formatPrice('$subtotal')),
            _line('Shipping', shipping == 0 ? 'Free' : formatPrice('$shipping')),
            const Divider(),
            _line('Total', formatPrice('$total'), bold: true),
          ],
        ),
      ),
    );
  }

  Widget _line(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: bold ? null : AppColors.textMuted, fontWeight: bold ? FontWeight.bold : null)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }
}
