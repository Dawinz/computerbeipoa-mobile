import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:beipoa_mobile/models/checkout.dart';
import 'package:beipoa_mobile/screens/checkout_screen.dart';
import 'package:beipoa_mobile/screens/product_detail_screen.dart';
import 'package:beipoa_mobile/services/cart_service.dart';
import 'package:beipoa_mobile/theme/app_theme.dart';
import 'package:beipoa_mobile/utils/formatters.dart';
import 'package:beipoa_mobile/widgets/async_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cart, _) {
        if (!cart.isLoaded) {
          return const LoadingView();
        }

        if (cart.items.isEmpty) {
          return EmptyView(
            title: 'Your cart is empty',
            subtitle: 'Browse products and tap the cart icon to add items.',
          );
        }

        final subtotal = cart.subtotal.round();
        final shipping = calculateShipping(subtotal);
        final total = calculateOrderTotal(subtotal);

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final line = cart.items[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ProductDetailScreen(slug: line.slug),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 72,
                                height: 72,
                                color: AppColors.purpleSoft.withValues(alpha: 0.35),
                                child: line.imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: line.imageUrl!,
                                        fit: BoxFit.contain,
                                      )
                                    : Icon(Icons.devices, color: context.appTextMuted),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.w600, color: context.appText),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatPrice(line.price),
                                  style: const TextStyle(
                                    color: AppColors.purple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton.outlined(
                                      iconSize: 18,
                                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                      onPressed: () => cart.updateQuantity(line.productId, line.quantity - 1),
                                      icon: const Icon(Icons.remove),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        '${line.quantity}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    IconButton.outlined(
                                      iconSize: 18,
                                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                      onPressed: () => cart.updateQuantity(line.productId, line.quantity + 1),
                                      icon: const Icon(Icons.add),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () => cart.removeItem(line.productId),
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
              decoration: BoxDecoration(
                color: context.appCard,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _summaryRow('Subtotal', formatPrice('$subtotal')),
                  _summaryRow(
                    'Shipping',
                    shipping == 0 ? 'Free' : formatPrice('$shipping'),
                  ),
                  const Divider(height: 20),
                  _summaryRow('Total', formatPrice('$total'), bold: true),
                  if (shipping > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Free delivery on orders over ${formatPrice('$freeShippingThreshold')}',
                      style: TextStyle(fontSize: 12, color: context.appTextMuted),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CheckoutScreen(cart: cart),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    child: const Text('Proceed to checkout'),
                  ),
                  TextButton(
                    onPressed: cart.clear,
                    child: const Text('Clear cart', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: bold ? null : AppColors.textMuted, fontWeight: bold ? FontWeight.bold : null)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600, fontSize: bold ? 18 : null)),
        ],
      ),
    );
  }
}
