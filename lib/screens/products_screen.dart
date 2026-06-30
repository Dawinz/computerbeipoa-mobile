import 'package:flutter/material.dart';

import 'package:beipoa_mobile/models/product.dart';
import 'package:beipoa_mobile/services/api_client.dart';
import 'package:beipoa_mobile/screens/product_detail_screen.dart';
import 'package:beipoa_mobile/theme/app_theme.dart';
import 'package:beipoa_mobile/widgets/async_state.dart';
import 'package:beipoa_mobile/widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    super.key,
    this.initialCategory,
    this.initialSearch,
    this.initialCondition,
  });

  final String? initialCategory;
  final String? initialSearch;
  final String? initialCondition;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _api = ApiClient();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<Product> _items = [];
  String? _error;
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  int _totalPages = 1;
  String? _category;
  String? _condition;
  String _search = '';
  Map<String, String> _categoryNames = {};

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _condition = widget.initialCondition;
    _search = widget.initialSearch ?? '';
    _searchController.text = _search;
    _scrollController.addListener(_onScroll);
    _loadCategories();
    _load(reset: true);
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _api.getCategories();
      if (!mounted) return;
      setState(() {
        _categoryNames = {for (final c in cats) c.slug: c.name};
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    }
    try {
      final result = await _api.getProducts(
        page: _page,
        limit: 20,
        category: _category,
        search: _search.isEmpty ? null : _search,
        condition: _condition,
      );
      if (!mounted) return;
      setState(() {
        if (reset || _page == 1) {
          _items = result.items;
        } else {
          _items = [..._items, ...result.items];
        }
        _totalPages = result.meta.totalPages;
        _loading = false;
        _loadingMore = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _loading || _page >= _totalPages) return;
    setState(() => _loadingMore = true);
    _page += 1;
    await _load();
  }

  void _applySearch() {
    _search = _searchController.text.trim();
    _load(reset: true);
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _applySearch(),
                  decoration: InputDecoration(
                    hintText: 'Search products…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _search = '';
                              _load(reset: true);
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_category != null || _condition != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                if (_category != null)
                  InputChip(
                    label: Text(_categoryNames[_category!] ?? _category!.replaceAll('-', ' ')),
                    onDeleted: () {
                      setState(() => _category = null);
                      _load(reset: true);
                    },
                  ),
                if (_condition != null)
                  InputChip(
                    label: const Text('Refurbished'),
                    onDeleted: () {
                      setState(() => _condition = null);
                      _load(reset: true);
                    },
                  ),
              ],
            ),
          ),
        Expanded(
          child: _loading
              ? const LoadingView(message: 'Loading products…')
              : _error != null
                  ? ErrorView(message: _error!, onRetry: () => _load(reset: true))
                  : _items.isEmpty
                      ? const EmptyView(
                          title: 'No products found',
                          subtitle: 'Try a different search or category.',
                        )
                      : RefreshIndicator(
                          onRefresh: () => _load(reset: true),
                          color: AppColors.purple,
                          child: GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.62,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _items.length + (_loadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= _items.length) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              return ProductCard(
                                product: _items[index],
                                onTap: () => _openProduct(_items[index]),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}
