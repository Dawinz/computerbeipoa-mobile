import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:beipoa_mobile/screens/account_screen.dart';
import 'package:beipoa_mobile/screens/cart_screen.dart';
import 'package:beipoa_mobile/screens/home_screen.dart';
import 'package:beipoa_mobile/screens/products_screen.dart';
import 'package:beipoa_mobile/services/cart_service.dart';
import 'package:beipoa_mobile/widgets/shell_scope.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;
  String? _productsCategory;
  String? _productsSearch;
  String? _productsCondition;
  int _productsKey = 0;

  void _goToTab(int index) {
    setState(() => _index = index);
  }

  void _openProducts({String? category, String? search, String? condition}) {
    setState(() {
      _productsCategory = category;
      _productsSearch = search;
      _productsCondition = condition;
      _productsKey++;
      _index = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartService>().itemCount;

    return ShellScope(
      goToTab: _goToTab,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/logo.png', height: 32),
              const SizedBox(width: 10),
              const Text('Computer Beipoa'),
            ],
          ),
          actions: [
            if (_index != 2)
              IconButton(
                icon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text(cartCount > 99 ? '99+' : '$cartCount'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                onPressed: () => _goToTab(2),
              ),
          ],
        ),
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(
              onBrowseAll: () => _openProducts(),
              onOpenCategory: (slug) => _openProducts(category: slug),
              onOpenCondition: (condition) => _openProducts(condition: condition),
            ),
            ProductsScreen(
              key: ValueKey('products-$_productsKey'),
              initialCategory: _productsCategory,
              initialSearch: _productsSearch,
              initialCondition: _productsCondition,
            ),
            const CartScreen(),
            const AccountScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _goToTab,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Shop',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text(cartCount > 99 ? '99+' : '$cartCount'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text(cartCount > 99 ? '99+' : '$cartCount'),
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
