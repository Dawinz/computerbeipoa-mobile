class Category {
  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    this.children,
    this.productCount,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final List<Category>? children;
  final int? productCount;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      productCount: (json['_count'] as Map<String, dynamic>?)?['products'] as int?,
    );
  }
}
