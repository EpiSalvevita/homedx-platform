class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String imageUrl;
  final ProductType type;
  final ProductCategory category;
  final int? stock;
  final Map<String, dynamic>? metadata;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'EUR',
    this.imageUrl = '',
    required this.type,
    required this.category,
    this.stock,
    this.metadata,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EUR',
      imageUrl: json['imageUrl'] as String? ?? '',
      type: ProductType.fromWireValue(json['type'] as String?),
      category: ProductCategory.fromWireValue(json['category'] as String?),
      stock: json['stock'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'imageUrl': imageUrl,
      'type': type.wireValue,
      'category': category.wireValue,
      'stock': stock,
      'metadata': metadata,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? currency,
    String? imageUrl,
    ProductType? type,
    ProductCategory? category,
    int? stock,
    Map<String, dynamic>? metadata,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Categorizes a [Product] by fulfillment type.
///
/// Each value carries an explicit [wireValue] that mirrors the matching
/// Prisma enum member on the NestJS backend. Dart-side names follow Dart
/// style (lowerCamelCase); wire values follow Prisma style (SCREAMING_SNAKE_CASE).
enum ProductType {
  physical('PHYSICAL'),
  digital('DIGITAL'),
  service('SERVICE');

  const ProductType(this.wireValue);

  /// Backend wire-format string. Sent in `Product.toJson` and matched in
  /// `fromWireValue`. Do not refactor this away without coordinating with
  /// the backend Prisma schema.
  final String wireValue;

  /// Resolves a backend wire value to its Dart enum member.
  ///
  /// Returns [ProductType.physical] for null or unknown values so a
  /// malformed/expanded backend payload doesn't crash the app — same
  /// behaviour as the previous `toString()`-based parser.
  static ProductType fromWireValue(String? value) {
    if (value == null) return ProductType.physical;
    for (final t in ProductType.values) {
      if (t.wireValue == value) return t;
    }
    return ProductType.physical;
  }
}

/// Sub-categorizes a [Product] for the shop UI.
///
/// See [ProductType] for the wire-value rationale.
enum ProductCategory {
  testStrip('TEST_STRIP'),
  testDevice('TEST_DEVICE'),
  accessory('ACCESSORY'),
  other('OTHER');

  const ProductCategory(this.wireValue);

  final String wireValue;

  static ProductCategory fromWireValue(String? value) {
    if (value == null) return ProductCategory.testStrip;
    for (final t in ProductCategory.values) {
      if (t.wireValue == value) return t;
    }
    return ProductCategory.testStrip;
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}




