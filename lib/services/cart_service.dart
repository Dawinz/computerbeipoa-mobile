import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartLine {
  CartLine({
    required this.productId,
    required this.slug,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  final String productId;
  final String slug;
  final String name;
  final String price;
  final int quantity;
  final String? imageUrl;

  double get lineTotal => (double.tryParse(price) ?? 0) * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'slug': slug,
        'name': name,
        'price': price,
        'quantity': quantity,
        'imageUrl': imageUrl,
      };

  factory CartLine.fromJson(Map<String, dynamic> json) {
    return CartLine(
      productId: json['productId'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      price: json['price'] as String,
      quantity: json['quantity'] as int,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class CartService extends ChangeNotifier {
  static const _storageKey = 'beipoa-cart';

  final List<CartLine> _items = [];
  bool _loaded = false;

  List<CartLine> get items => List.unmodifiable(_items);
  bool get isLoaded => _loaded;

  int get itemCount => _items.fold(0, (sum, line) => sum + line.quantity);

  double get subtotal => _items.fold(0, (sum, line) => sum + line.lineTotal);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    _items.clear();
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final entry in list) {
          _items.add(CartLine.fromJson(entry as Map<String, dynamic>));
        }
      } catch (_) {
        // ignore corrupt cart
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_items.map((e) => e.toJson()).toList()),
    );
  }

  void addItem({
    required String productId,
    required String slug,
    required String name,
    required String price,
    String? imageUrl,
    int quantity = 1,
  }) {
    final existing = _items.indexWhere((l) => l.productId == productId);
    if (existing >= 0) {
      final line = _items[existing];
      _items[existing] = CartLine(
        productId: line.productId,
        slug: line.slug,
        name: line.name,
        price: line.price,
        quantity: line.quantity + quantity,
        imageUrl: line.imageUrl ?? imageUrl,
      );
    } else {
      _items.add(CartLine(
        productId: productId,
        slug: slug,
        name: name,
        price: price,
        quantity: quantity,
        imageUrl: imageUrl,
      ));
    }
    _persist();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity < 1) {
      removeItem(productId);
      return;
    }
    final index = _items.indexWhere((l) => l.productId == productId);
    if (index < 0) return;
    final line = _items[index];
    _items[index] = CartLine(
      productId: line.productId,
      slug: line.slug,
      name: line.name,
      price: line.price,
      quantity: quantity,
      imageUrl: line.imageUrl,
    );
    _persist();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((l) => l.productId == productId);
    _persist();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _persist();
    notifyListeners();
  }
}
