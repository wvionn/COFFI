class AddonModel {
  final String id;
  final String name;
  final String group; // e.g., 'TOPPING', 'SUSU SUBSTITUSI', 'FLAVOR', 'SUHU', 'GULA'
  final double price;
  final String? imageUrl;
  final bool isActive;

  const AddonModel({
    required this.id,
    required this.name,
    required this.group,
    this.price = 0.0,
    this.imageUrl,
    this.isActive = true,
  });

  factory AddonModel.fromMap(Map<String, dynamic> map) {
    return AddonModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      group: map['group']?.toString().toUpperCase() ?? 'TOPPING',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url']?.toString(),
      isActive: map['is_active'] == null ? true : (map['is_active'] as bool),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'group': group,
      'price': price,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }

  AddonModel copyWith({
    String? id,
    String? name,
    String? group,
    double? price,
    String? imageUrl,
    bool? isActive,
  }) {
    return AddonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      group: group ?? this.group,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
