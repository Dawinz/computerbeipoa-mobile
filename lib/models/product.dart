class ProductImage {
  ProductImage({
    required this.url,
    this.altText,
    this.isPrimary = false,
  });

  final String url;
  final String? altText;
  final bool isPrimary;

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      url: json['url'] as String,
      altText: json['altText'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

class ProductBrand {
  ProductBrand({required this.name, required this.slug});

  final String name;
  final String slug;

  factory ProductBrand.fromJson(Map<String, dynamic> json) {
    return ProductBrand(
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }
}

class ProductCategory {
  ProductCategory({required this.name, required this.slug});

  final String name;
  final String slug;

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }
}

class ProductSpec {
  ProductSpec({required this.name, required this.value, this.group});

  final String name;
  final String value;
  final String? group;

  factory ProductSpec.fromJson(Map<String, dynamic> json) {
    return ProductSpec(
      name: json['name'] as String,
      value: json['value'] as String,
      group: json['group'] as String?,
    );
  }
}

class Product {
  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.condition,
    required this.isFeatured,
    this.shortDescription,
    this.description,
    this.compareAtPrice,
    this.brand,
    this.category,
    this.images,
    this.specifications,
  });

  final String id;
  final String name;
  final String slug;
  final String price;
  final String? compareAtPrice;
  final String condition;
  final bool isFeatured;
  final String? shortDescription;
  final String? description;
  final ProductBrand? brand;
  final ProductCategory? category;
  final List<ProductImage>? images;
  final List<ProductSpec>? specifications;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      price: json['price'].toString(),
      compareAtPrice: json['compareAtPrice']?.toString(),
      condition: json['condition'] as String? ?? 'NEW',
      isFeatured: json['isFeatured'] as bool? ?? false,
      shortDescription: json['shortDescription'] as String?,
      description: json['description'] as String?,
      brand: json['brand'] != null
          ? ProductBrand.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      category: json['category'] != null
          ? ProductCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      specifications: (json['specifications'] as List<dynamic>?)
          ?.map((e) => ProductSpec.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ProductImage? get primaryImage {
    final imgs = images;
    if (imgs == null || imgs.isEmpty) return null;
    for (final img in imgs) {
      if (img.isPrimary) return img;
    }
    return imgs.first;
  }

  int? get discountPercent {
    if (compareAtPrice == null) return null;
    final p = double.tryParse(price);
    final c = double.tryParse(compareAtPrice!);
    if (p == null || c == null || c <= p) return null;
    return (((c - p) / c) * 100).round();
  }
}

class PaginatedProducts {
  PaginatedProducts({required this.items, required this.meta});

  final List<Product> items;
  final PaginationMeta meta;

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    return PaginatedProducts(
      items: (json['items'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class PaginationMeta {
  PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final int total;
  final int page;
  final int limit;
  final int totalPages;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
