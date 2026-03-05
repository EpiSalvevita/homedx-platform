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
      type: ProductType.values.firstWhere(
        (e) => e.toString() == 'ProductType.${json['type']}',
        orElse: () => ProductType.PHYSICAL,
      ),
      category: ProductCategory.values.firstWhere(
        (e) => e.toString() == 'ProductCategory.${json['category']}',
        orElse: () => ProductCategory.TEST_STRIP,
      ),
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
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
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

enum ProductType {
  PHYSICAL,
  DIGITAL,
  SERVICE,
}

enum ProductCategory {
  TEST_STRIP,
  TEST_DEVICE,
  ACCESSORY,
  OTHER,
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




