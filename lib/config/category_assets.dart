import 'package:beipoa_mobile/config/app_config.dart';

/// Category hero images aligned with the web store banners.
String categoryImageUrl(String slug, {String? apiImageUrl}) {
  if (apiImageUrl != null && apiImageUrl.isNotEmpty) {
    if (apiImageUrl.startsWith('http')) return apiImageUrl;
    return '${AppConfig.webBaseUrl}${apiImageUrl.startsWith('/') ? '' : '/'}$apiImageUrl';
  }

  const slugImages = <String, String>{
    'laptops': '/banners/hero-laptops.png',
    'desktop-computers': '/banners/hero-laptops.png',
    'monitors': '/banners/hero-laptops.png',
    'printers': '/banners/hero-laptops.png',
    'networking-equipment': '/banners/hero-gaming.png',
    'storage-devices': '/banners/hero-gaming.png',
    'gaming-computers': '/banners/hero-gaming.png',
    'office-essentials': '/banners/hero-laptops.png',
  };

  final path = slugImages[slug] ?? '/banners/hero-laptops.png';
  return '${AppConfig.webBaseUrl}$path';
}

class PromoBanner {
  const PromoBanner({
    required this.title,
    required this.subtitle,
    required this.asset,
    this.categorySlug,
    this.condition,
  });

  final String title;
  final String subtitle;
  final String asset;
  final String? categorySlug;
  final String? condition;
}

const promoBanners = [
  PromoBanner(
    title: 'Office Essentials',
    subtitle: 'Desktops, printers & monitors for your team',
    categorySlug: 'desktop-computers',
    asset: 'assets/banners/hero-laptops.png',
  ),
  PromoBanner(
    title: 'Refurbished Deals',
    subtitle: 'Save up to 40% on certified devices',
    condition: 'REFURBISHED',
    asset: 'assets/banners/promo-refurbished.png',
  ),
];
