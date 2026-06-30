import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:beipoa_mobile/config/category_assets.dart';
import 'package:beipoa_mobile/models/category.dart';
import 'package:beipoa_mobile/models/product.dart';
import 'package:beipoa_mobile/services/api_client.dart';
import 'package:beipoa_mobile/screens/product_detail_screen.dart';
import 'package:beipoa_mobile/theme/app_theme.dart';
import 'package:beipoa_mobile/widgets/async_state.dart';
import 'package:beipoa_mobile/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onBrowseAll,
    required this.onOpenCategory,
    required this.onOpenCondition,
  });

  final VoidCallback onBrowseAll;
  final void Function(String categorySlug) onOpenCategory;
  final void Function(String condition) onOpenCondition;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiClient();
  List<Category> _categories = [];
  List<Product> _featured = [];
  String? _error;
  bool _loading = true;

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
      final results = await Future.wait([
        _api.getCategories(),
        _api.getFeaturedProducts(),
      ]);
      if (!mounted) return;
      setState(() {
        _categories = results[0] as List<Category>;
        _featured = results[1] as List<Product>;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(slug: product.slug),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingView(message: 'Loading store…');
    }
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.purple,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _HeroBanner(onShop: widget.onBrowseAll),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shop by category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.appText,
                      ),
                ),
                TextButton(onPressed: widget.onBrowseAll, child: const Text('See all')),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.92,
              ),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return _CategoryCard(
                  category: cat,
                  onTap: () => widget.onOpenCategory(cat.slug),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: promoBanners.map((promo) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PromoCard(
                    promo: promo,
                    onTap: () {
                      if (promo.condition != null) {
                        widget.onOpenCondition(promo.condition!);
                      } else if (promo.categorySlug != null) {
                        widget.onOpenCategory(promo.categorySlug!);
                      } else {
                        widget.onBrowseAll();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          if (_featured.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Featured products',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.appText,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _featured.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 168,
                    child: ProductCard(
                      product: _featured[index],
                      onTap: () => _openProduct(_featured[index]),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.emoji_events_outlined, color: AppColors.orange),
                title: Text('Award-winning store', style: TextStyle(color: context.appText, fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Best Online Store — Kariakoo Business Awards 2026',
                  style: TextStyle(color: context.appTextMuted),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: widget.onBrowseAll,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/banners/hero-laptops.png', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.purple.withValues(alpha: 0.88),
                  AppColors.purple.withValues(alpha: 0.45),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 48),
                const SizedBox(height: 10),
                const Text(
                  'Laptops, desktops\n& office gear',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onShop,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    minimumSize: const Size(0, 38),
                  ),
                  child: const Text('Browse products'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = categoryImageUrl(category.slug, apiImageUrl: category.imageUrl);

    return Material(
      color: context.appCard,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: AppColors.purpleSoft.withValues(alpha: 0.4),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.purple)),
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.purpleSoft.withValues(alpha: 0.4),
                  child: const Icon(Icons.category_outlined, color: AppColors.purple, size: 36),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.appText),
                  ),
                  if (category.productCount != null)
                    Text(
                      '${category.productCount} items',
                      style: TextStyle(fontSize: 11, color: context.appTextMuted),
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

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo, required this.onTap});

  final PromoBanner promo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appCard,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 120,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        promo.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: context.appText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promo.subtitle,
                        style: TextStyle(fontSize: 12, color: context.appTextMuted),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Shop now →',
                        style: TextStyle(
                          color: AppColors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: Image.asset(promo.asset, fit: BoxFit.cover, height: 120),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
