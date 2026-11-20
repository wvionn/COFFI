import '../core/constants/supabase_config.dart';

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
  final String? unit; // In-app display unit: 'cup', 'pcs', 'botol', 'pack', 'porsi', 'kg', 'liter'

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
    this.unit = 'cup',
  });

  String get displayUnit => (unit != null && unit!.isNotEmpty) ? unit! : 'cup';

  double get marginPercentage {
    if (price <= 0) return 0.0;
    return ((price - costPrice) / price) * 100;
  }

  bool get isOutOfStock => trackStock && stock <= 0;
  bool get isLowStock => trackStock && stock > 0 && stock <= minStock;
  bool get canBeSold => isActive && (!trackStock || stock > 0);

  static const Set<String> _supabaseBucketPngs = {
    'butter_croissant.png',
    'cafe_latte.png',
    'coffi_aren.png',
    'dark_choco.png',
    'iced_americano.png',
    'matcha_latte.png',
    'royal_thai_tea.png',
  };

  static String? _resolveImageUrl(dynamic rawVal) {
    final raw = rawVal?.toString().trim();
    if (raw == null || raw.isEmpty) return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    final lower = raw.toLowerCase();
    if (lower.contains('french_fries')) {
      return 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=500&auto=format&fit=crop&q=60';
    }

    // Normalize asset paths (including legacy .jpg entries in Supabase) to live Supabase Storage or valid local .png
    if (raw.startsWith('assets/images/products/')) {
      final fileName = raw.split('/').last;
      final normalizedFile = fileName.toLowerCase().endsWith('.jpg')
          ? '${fileName.substring(0, fileName.length - 4)}.png'
          : fileName;
      final base = SupabaseConfig.supabaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
      if (base.isNotEmpty && _supabaseBucketPngs.contains(normalizedFile)) {
        return '$base/storage/v1/object/public/Products/$normalizedFile';
      }
      return 'assets/images/products/$normalizedFile';
    }

    final base = SupabaseConfig.supabaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (base.isNotEmpty && !raw.startsWith('assets/')) {
      final cleanPath = raw.replaceFirst(RegExp(r'^/+'), '');
      return cleanPath.startsWith('storage/v1/')
          ? '$base/$cleanPath'
          : '$base/storage/v1/object/public/$cleanPath';
    }

    return raw;
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString() ?? '',
      categoryId: map['category_id']?.toString(),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      price: ((map['price'] ?? map['selling_price']) as num?)?.toDouble() ?? 0.0,
      costPrice: ((map['cost_price'] ?? map['purchase_price']) as num?)?.toDouble() ?? 0.0,
      stock: ((map['stock'] ?? map['current_stock']) as num?)?.toInt() ?? 0,
      minStock: (map['min_stock'] as num?)?.toInt() ?? 5,
      trackStock: map['track_stock'] == null ? true : (map['track_stock'] as bool),
      isActive: map['is_active'] == null ? true : (map['is_active'] as bool),
      imageUrl: _resolveImageUrl(map['image_url']),
      unit: map['unit']?.toString() ?? 'cup',
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
    String? unit,
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
      unit: unit ?? this.unit,
    );
  }
}
