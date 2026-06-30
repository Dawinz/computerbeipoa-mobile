import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:beipoa_mobile/screens/shell_screen.dart';
import 'package:beipoa_mobile/screens/splash_screen.dart';
import 'package:beipoa_mobile/services/cart_service.dart';
import 'package:beipoa_mobile/services/theme_service.dart';
import 'package:beipoa_mobile/theme/app_theme.dart';

class BeipoaApp extends StatefulWidget {
  const BeipoaApp({super.key});

  @override
  State<BeipoaApp> createState() => _BeipoaAppState();
}

class _BeipoaAppState extends State<BeipoaApp> {
  final _cart = CartService();
  final _theme = ThemeService();

  @override
  void initState() {
    super.initState();
    _cart.load();
    _theme.load();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartService>.value(value: _cart),
        ChangeNotifierProvider<ThemeService>.value(value: _theme),
      ],
      child: Consumer<ThemeService>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Computer Beipoa',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.mode,
            home: SplashScreen(
              onReady: () => const ShellScreen(),
            ),
          );
        },
      ),
    );
  }
}
