enum MobileMoneyMethod { mpesa, tigoPesa, airtelMoney }

extension MobileMoneyMethodApi on MobileMoneyMethod {
  String get apiValue => switch (this) {
        MobileMoneyMethod.mpesa => 'MPESA',
        MobileMoneyMethod.tigoPesa => 'TIGO_PESA',
        MobileMoneyMethod.airtelMoney => 'AIRTEL_MONEY',
      };

  String get label => switch (this) {
        MobileMoneyMethod.mpesa => 'M-Pesa',
        MobileMoneyMethod.tigoPesa => 'Tigo Pesa',
        MobileMoneyMethod.airtelMoney => 'Airtel Money',
      };

  String get logoAsset => switch (this) {
        MobileMoneyMethod.mpesa => 'assets/payments/mpesa.png',
        MobileMoneyMethod.tigoPesa => 'assets/payments/tigo-pesa.png',
        MobileMoneyMethod.airtelMoney => 'assets/payments/airtel-money.png',
      };
}

class CheckoutFormData {
  CheckoutFormData({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.city = 'Dar es Salaam',
    this.region = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.notes = '',
    this.paymentMethod = MobileMoneyMethod.mpesa,
    this.paymentPhone = '',
  });

  final String fullName;
  final String email;
  final String phone;
  final String city;
  final String region;
  final String addressLine1;
  final String addressLine2;
  final String notes;
  final MobileMoneyMethod paymentMethod;
  final String paymentPhone;

  CheckoutFormData copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? city,
    String? region,
    String? addressLine1,
    String? addressLine2,
    String? notes,
    MobileMoneyMethod? paymentMethod,
    String? paymentPhone,
  }) {
    return CheckoutFormData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      region: region ?? this.region,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentPhone: paymentPhone ?? this.paymentPhone,
    );
  }
}

class CompletedOrder {
  CompletedOrder({
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.total,
    required this.currency,
    required this.paymentMethod,
    required this.paymentLabel,
    required this.paymentReference,
    required this.paymentPhone,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.city,
    required this.addressLine1,
    required this.items,
    required this.createdAt,
  });

  final String orderNumber;
  final String status;
  final String paymentStatus;
  final String subtotal;
  final String shippingCost;
  final String tax;
  final String total;
  final String currency;
  final String paymentMethod;
  final String paymentLabel;
  final String paymentReference;
  final String paymentPhone;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String city;
  final String addressLine1;
  final List<Map<String, dynamic>> items;
  final String createdAt;

  factory CompletedOrder.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>? ?? {};
    return CompletedOrder(
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String? ?? 'CONFIRMED',
      paymentStatus: json['paymentStatus'] as String? ?? 'PAID',
      subtotal: '${json['subtotal']}',
      shippingCost: '${json['shippingCost']}',
      tax: '${json['tax']}',
      total: '${json['total']}',
      currency: json['currency'] as String? ?? 'TZS',
      paymentMethod: json['paymentMethod'] as String? ?? 'MPESA',
      paymentLabel: json['paymentLabel'] as String? ?? 'Mobile money',
      paymentReference: json['paymentReference'] as String? ?? '',
      paymentPhone: json['paymentPhone'] as String? ?? '',
      customerName: customer['fullName'] as String? ?? '',
      customerEmail: customer['email'] as String? ?? '',
      customerPhone: customer['phone'] as String? ?? '',
      city: customer['city'] as String? ?? '',
      addressLine1: customer['addressLine1'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

const freeShippingThreshold = 500000;
const standardShipping = 15000;

int calculateShipping(int subtotal) =>
    subtotal >= freeShippingThreshold ? 0 : standardShipping;

int calculateOrderTotal(int subtotal) => subtotal + calculateShipping(subtotal);

const paymentProviders = MobileMoneyMethod.values;
