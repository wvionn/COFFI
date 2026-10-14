class ProductModel {
  final String id;
  final String? categoryId;
  final String name;
  final String? description;
  final double price;
  final double costPrice; // HPP
  final int stock;
  final int minStock;
  final bool trackStock;
  final bool isActive;
  final String? imageUrl;

  ProductModel({
    required this.id,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.costPrice = 0.0,
    this.stock = 0,
    this.minStock = 5,
    this.trackStock = true,
    this.isActive = true,
    this.imageUrl,
  });

  double get marginPercentage {
    if (price <= 0) return 0.0;
    return ((price - costPrice) / price) * 100;
  }

  bool get isOutOfStock => trackStock && stock <= 0;
  bool get isLowStock => trackStock && stock > 0 && stock <= minStock;
  bool get canBeSold => isActive && (!trackStock || stock > 0);

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString() ?? '',
      categoryId: map['category_id']?.toString(),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      minStock: (map['min_stock'] as num?)?.toInt() ?? 5,
      trackStock: map['track_stock'] == null ? true : (map['track_stock'] as bool),
      isActive: map['is_active'] == null ? true : (map['is_active'] as bool),
      imageUrl: map['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'cost_price': costPrice,
      'stock': stock,
      'min_stock': minStock,
      'track_stock': trackStock,
      'is_active': isActive,
      'image_url': imageUrl,
    };
  }

  ProductModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    double? costPrice,
    int? stock,
    int? minStock,
    bool? trackStock,
    bool? isActive,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      trackStock: trackStock ?? this.trackStock,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
