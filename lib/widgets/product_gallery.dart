import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:beipoa_mobile/models/product.dart';
import 'package:beipoa_mobile/theme/app_theme.dart';
import 'package:beipoa_mobile/utils/formatters.dart';

class ProductGallery extends StatefulWidget {
  const ProductGallery({super.key, required this.images, required this.productName});

  final List<ProductImage> images;
  final String productName;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  late int _index;
  late List<ProductImage> _sorted;

  @override
  void initState() {
    super.initState();
    _sorted = List<ProductImage>.from(widget.images)
      ..sort((a, b) {
        if (a.isPrimary && !b.isPrimary) return -1;
        if (!a.isPrimary && b.isPrimary) return 1;
        return 0;
      });
    _index = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_sorted.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Card(
          child: Center(
            child: Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.grey.shade400),
          ),
        ),
      );
    }

    final current = _sorted[_index];

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: AppColors.purpleSoft.withValues(alpha: 0.3),
                  padding: const EdgeInsets.all(16),
                  child: CachedNetworkImage(
                    imageUrl: resolveImageUrl(current.url),
                    fit: BoxFit.contain,
                  ),
                ),
                if (_sorted.length > 1) ...[
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _NavButton(
                        icon: Icons.chevron_left,
                        onTap: () => setState(() {
                          _index = (_index - 1 + _sorted.length) % _sorted.length;
                        }),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _NavButton(
                        icon: Icons.chevron_right,
                        onTap: () => setState(() {
                          _index = (_index + 1) % _sorted.length;
                        }),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_index + 1} / ${_sorted.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_sorted.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _sorted.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final img = _sorted[i];
                final selected = i == _index;
                return GestureDetector(
                  onTap: () => setState(() => _index = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppColors.purple : AppColors.border,
                        width: selected ? 2.5 : 1,
                      ),
                      color: AppColors.purpleSoft.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: CachedNetworkImage(
                      imageUrl: resolveImageUrl(img.url),
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}
