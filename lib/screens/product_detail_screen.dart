import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:beipoa_mobile/models/product.dart';
import 'package:beipoa_mobile/services/api_client.dart';
import 'package:beipoa_mobile/services/cart_service.dart';
import 'package:beipoa_mobile/theme/app_theme.dart';
import 'package:beipoa_mobile/utils/formatters.dart';
import 'package:beipoa_mobile/widgets/async_state.dart';
import 'package:beipoa_mobile/widgets/product_gallery.dart';
import 'package:beipoa_mobile/widgets/shell_scope.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _api = ApiClient();
  Product? _product;
  List<Product> _similar = [];
  String? _error;
  bool _loading = true;
  bool _loadingSimilar = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final product = await _api.getProduct(widget.slug);
      if (!mounted) return;
      setState(() {
        _product = product;
        _loading = false;
      });
      _loadSimilar(product);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _loadSimilar(Product product) async {
    final category = product.category?.slug;
    if (category == null || category.isEmpty) return;
    setState(() => _loadingSimilar = true);
    try {
      final res = await _api.getProducts(
        page: 1,
        limit: 8,
        category: category,
      );
      if (!mounted) return;
      setState(() {
        _similar = res.items.where((p) => p.id != product.id).take(6).toList();
        _loadingSimilar = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSimilar = false);
    }
  }

  void _addToCart() {
    final product = _product!;
    final image = product.primaryImage;
    context.read<CartService>().addItem(
          productId: product.id,
          slug: product.slug,
          name: product.name,
          price: product.price,
          imageUrl: image != null ? resolveImageUrl(image.url) : null,
          quantity: _quantity,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity × ${product.name} to cart'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View cart',
          onPressed: () {
            ShellScope.maybeOf(context)?.goToTab(2);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.name ?? 'Product'),
      ),
      body: _loading
          ? const LoadingView(message: 'Loading product…')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _buildContent(_product!),
      bottomNavigationBar: _product != null ? _buildBottomBar(_product!) : null,
    );
  }

  Widget _buildContent(Product product) {
    final discount = product.discountPercent;
    final specs = product.specifications ?? [];
    final isRefurb = product.condition == 'REFURBISHED';
    final hasStock = product.condition != 'OUT_OF_STOCK';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProductGallery(
          images: product.images ?? [],
          productName: product.name,
        ),
        const SizedBox(height: 20),
        if (product.brand != null)
          Text(
            product.brand!.name.toUpperCase(),
            style: const TextStyle(
              color: AppColors.purple,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        const SizedBox(height: 6),
        Text(
          product.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.appText,
              ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatPrice(product.price),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.purple,
              ),
            ),
            if (product.compareAtPrice != null) ...[
              const SizedBox(width: 10),
              Text(
                formatPrice(product.compareAtPrice!),
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: context.appTextMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
            if (discount != null) ...[
              const SizedBox(width: 8),
              Text(
                '-$discount%',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              isRefurb ? 'Condition: Refurbished' : 'Condition: New',
              style: TextStyle(color: context.appTextMuted, fontSize: 13),
            ),
            const Spacer(),
            Text(
              hasStock ? 'In stock' : 'Out of stock',
              style: TextStyle(
                color: hasStock ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        if (product.category != null) ...[
          const SizedBox(height: 4),
          Text(
            'Category: ${product.category!.name}',
            style: TextStyle(color: context.appTextMuted, fontSize: 13),
          ),
        ],
        const SizedBox(height: 12),
        Divider(color: context.appBorder),
        if (product.shortDescription != null) ...[
          const SizedBox(height: 10),
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.appText,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            product.shortDescription!,
            style: TextStyle(
              color: context.appTextMuted,
              height: 1.6,
              fontSize: 15,
            ),
          ),
        ],
        if (specs.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            'Specifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.appText,
                ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < specs.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      specs[i].name,
                      style: TextStyle(
                        color: context.appTextMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: Text(
                      specs[i].value,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.appText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 22),
        Divider(color: context.appBorder),
        const SizedBox(height: 10),
        _buildSimilarSection(product),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSimilarSection(Product product) {
    if (_loadingSimilar) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: AppColors.purple),
        ),
      );
    }
    if (_similar.isEmpty) {
      return Text(
        'No similar items available right now.',
        style: TextStyle(color: context.appTextMuted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Similar items',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.appText,
              ),
        ),
        const SizedBox(height: 12),
        ..._similar.map((item) {
          final image = item.primaryImage;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 56,
                height: 56,
                color: AppColors.purpleSoft.withValues(alpha: 0.3),
                child: image == null
                    ? const Icon(Icons.devices_outlined)
                    : CachedNetworkImage(
                        imageUrl: resolveImageUrl(image.url),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            title: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.appText,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              formatPrice(item.price),
              style: const TextStyle(
                color: AppColors.purple,
                fontWeight: FontWeight.w700,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProductDetailScreen(slug: item.slug),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildBottomBar(Product product) {
    final hasStock = product.condition != 'OUT_OF_STOCK';
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: context.appBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: context.appText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: hasStock ? _addToCart : null,
                icon: Icon(hasStock ? Icons.shopping_cart_outlined : Icons.remove_shopping_cart_outlined),
                label: Text(
                  hasStock
                      ? 'Add to cart · ${formatPrice(product.price)}'
                      : 'Out of stock',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.orange,
                  disabledBackgroundColor: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
