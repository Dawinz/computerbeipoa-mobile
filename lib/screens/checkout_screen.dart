import 'package:flutter/material.dart';

import 'package:beipoa_mobile/models/checkout.dart';
import 'package:beipoa_mobile/services/api_client.dart';
import 'package:beipoa_mobile/services/cart_service.dart';
import 'package:beipoa_mobile/theme/app_theme.dart';
import 'package:beipoa_mobile/utils/formatters.dart';
import 'package:beipoa_mobile/widgets/mobile_money_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.cart});

  final CartService cart;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _api = ApiClient();
  final _formKey = GlobalKey<FormState>();
  var _step = 0;
  var _submitting = false;
  CheckoutFormData _form = CheckoutFormData();

  int get _subtotal => widget.cart.subtotal.round();
  int get _shipping => calculateShipping(_subtotal);
  int get _total => calculateOrderTotal(_subtotal);

  String _normalizePhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('255')) return '+$digits';
    if (digits.startsWith('0')) return '+255${digits.substring(1)}';
    if (digits.startsWith('7') || digits.startsWith('6')) return '+255$digits';
    return value.trim();
  }

  void _continueToPayment() {
    if (_formKey.currentState?.validate() != true) return;
    _formKey.currentState!.save();
    setState(() => _step = 1);
  }

  Future<void> _pay() async {
    _formKey.currentState?.save();
    final paymentPhoneRaw =
        _form.paymentPhone.trim().isEmpty ? _form.phone : _form.paymentPhone;
    final normalizedPaymentPhone = _normalizePhone(paymentPhoneRaw);
    if (normalizedPaymentPhone.replaceAll(RegExp(r'\D'), '').length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid mobile money number.')),
      );
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MobileMoneySheet(
        method: _form.paymentMethod,
        paymentPhone: normalizedPaymentPhone,
        total: _total,
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    try {
      final result = await _api.submitCheckout({
        'fullName': _form.fullName.trim(),
        'email': _form.email.trim(),
        'phone': _normalizePhone(_form.phone),
        'city': _form.city.trim(),
        'region': _form.region.trim().isEmpty ? null : _form.region.trim(),
        'addressLine1': _form.addressLine1.trim(),
        'addressLine2': _form.addressLine2.trim().isEmpty ? null : _form.addressLine2.trim(),
        'notes': _form.notes.trim().isEmpty ? null : _form.notes.trim(),
        'paymentMethod': _form.paymentMethod.apiValue,
        'paymentPhone': normalizedPaymentPhone,
        'items': widget.cart.items
            .map((line) => {'productId': line.productId, 'quantity': line.quantity})
            .toList(),
      });

      widget.cart.clear();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => CheckoutSuccessScreen(order: CompletedOrder.fromJson(result)),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 0 ? 'Delivery details' : 'Payment'),
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
                    Text(
                      'Pay with mobile money',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Demo checkout — no real funds are transferred.',
                      style: TextStyle(fontSize: 13, color: context.appTextMuted),
                    ),
                    const SizedBox(height: 16),
                    ...paymentProviders.map((method) {
                      final selected = _form.paymentMethod == method;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: context.appCard,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => setState(() => _form = _form.copyWith(paymentMethod: method)),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected ? AppColors.purple : context.appBorder,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(method.logoAsset, height: 36),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      method.label,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: context.appText,
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    const Icon(Icons.check_circle, color: AppColors.purple),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    _field(
                      'Mobile money number',
                      (v) => _form = _form.copyWith(paymentPhone: v ?? ''),
                      initial: _form.paymentPhone.isEmpty ? _form.phone : _form.paymentPhone,
                      keyboard: TextInputType.phone,
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    _OrderSummaryCard(subtotal: _subtotal, shipping: _shipping, total: _total),
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
            child: FilledButton(
              onPressed: _submitting
                  ? null
                  : _step == 0
                      ? _continueToPayment
                      : _pay,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_step == 0 ? 'Continue to payment' : 'Pay ${formatPrice('$_total')}'),
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

class CheckoutSuccessScreen extends StatelessWidget {
  const CheckoutSuccessScreen({super.key, required this.order});

  final CompletedOrder order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order confirmed')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.check_circle, size: 72, color: AppColors.greenAccent.withValues(alpha: 0.9)),
          const SizedBox(height: 16),
          Text(
            'Thank you, ${order.customerName.split(' ').first}!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Order ${order.orderNumber}',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appTextMuted),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Total paid', formatPrice(order.total), bold: true),
                  _row('Payment', order.paymentLabel),
                  _row('Reference', order.paymentReference),
                  _row('Deliver to', '${order.addressLine1}, ${order.city}'),
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
          _dot(context, 'Delivery', active: current == 0, done: current > 0),
          Expanded(child: Container(height: 2, color: current > 0 ? AppColors.purple : context.appBorder)),
          _dot(context, 'Payment', active: current == 1, done: false),
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
                  label == 'Delivery' ? '1' : '2',
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
