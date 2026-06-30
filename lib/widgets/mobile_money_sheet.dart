import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:beipoa_mobile/models/checkout.dart';
import 'package:beipoa_mobile/theme/app_theme.dart';
import 'package:beipoa_mobile/utils/formatters.dart';

class MobileMoneySheet extends StatefulWidget {
  const MobileMoneySheet({
    super.key,
    required this.method,
    required this.paymentPhone,
    required this.total,
  });

  final MobileMoneyMethod method;
  final String paymentPhone;
  final int total;

  @override
  State<MobileMoneySheet> createState() => _MobileMoneySheetState();
}

class _MobileMoneySheetState extends State<MobileMoneySheet> {
  var _phase = 0;
  final _pinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submitPin() async {
    if (_pinController.text.length < 4) {
      setState(() => _error = 'Enter your 4-digit PIN.');
      return;
    }
    setState(() {
      _phase = 2;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    setState(() => _phase = 3);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.appCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  Image.asset(widget.method.logoAsset, height: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.method.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Secure demo payment', style: TextStyle(fontSize: 12, color: context.appTextMuted)),
                      ],
                    ),
                  ),
                  if (_phase < 2)
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: switch (_phase) {
                0 => _prompt(),
                1 => _pin(),
                2 => _processing(),
                _ => _success(),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _prompt() {
    return Column(
      children: [
        Text('A payment request will be sent to', style: TextStyle(color: context.appTextMuted)),
        const SizedBox(height: 4),
        Text(formatPhoneDisplay(widget.paymentPhone), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(formatPrice('${widget.total}'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.purpleSoft.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Demo mode — no real money is charged. Use any 4-digit PIN on the next step.',
            style: TextStyle(fontSize: 12, color: context.appTextMuted, height: 1.4),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => setState(() => _phase = 1),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _pin() {
    return Column(
      children: [
        Text('Enter your ${widget.method.label} PIN', style: TextStyle(color: context.appTextMuted)),
        const SizedBox(height: 12),
        TextField(
          controller: _pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8),
          decoration: const InputDecoration(hintText: '••••'),
          autofocus: true,
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _submitPin,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text('Confirm payment'),
        ),
      ],
    );
  }

  Widget _processing() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          CircularProgressIndicator(color: AppColors.purple),
          SizedBox(height: 16),
          Text('Processing payment…'),
        ],
      ),
    );
  }

  Widget _success() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: AppColors.greenAccent, size: 56),
          SizedBox(height: 12),
          Text('Payment successful', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}

String formatPhoneDisplay(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('255') && digits.length >= 12) {
    return '+${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
  }
  if (digits.startsWith('0') && digits.length >= 10) {
    return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
  }
  return phone;
}
