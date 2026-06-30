import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:beipoa_mobile/models/product.dart';
import 'package:beipoa_mobile/services/cart_service.dart';
import 'package:beipoa_mobile/theme/app_theme.dart';
import 'package:beipoa_mobile/utils/formatters.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final image = product.primaryImage;
    final discount = product.discountPercent;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    color: AppColors.purpleSoft.withValues(alpha: 0.4),
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    child: image != null
                        ? CachedNetworkImage(
                            imageUrl: resolveImageUrl(image.url),
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported_outlined),
                          )
                        : const Icon(Icons.devices, size: 48, color: AppColors.textMuted),
                  ),
                  if (discount != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-$discount%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (product.condition == 'REFURBISHED')
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Refurb',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.appText,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatPrice(product.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.purple,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Material(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () {
                            context.read<CartService>().addItem(
                                  productId: product.id,
                                  slug: product.slug,
                                  name: product.name,
                                  price: product.price,
                                  imageUrl: image != null ? resolveImageUrl(image.url) : null,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.add_shopping_cart, color: Colors.white, size: 18),
                          ),
                        ),
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
  }
}
