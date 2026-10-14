class OrderItemModel {
  final String id;
  final String orderId;
  final String? productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double hpp;
  final double subtotal;
  final String? notes; // e.g. "Dingin, Less Sugar, Es Sedikit"
  final bool isCompleted;

  OrderItemModel({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.hpp = 0.0,
    required this.subtotal,
    this.notes,
    this.isCompleted = false,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id']?.toString() ?? '',
      orderId: map['order_id']?.toString() ?? '',
      productId: map['product_id']?.toString(),
      productName: map['product_name']?.toString() ?? 'Item',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      hpp: (map['hpp'] as num?)?.toDouble() ?? 0.0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes']?.toString(),
      isCompleted: map['is_completed'] == null ? false : (map['is_completed'] as bool),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'hpp': hpp,
      'subtotal': subtotal,
      'notes': notes,
      'is_completed': isCompleted,
    };
  }

  OrderItemModel copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? hpp,
    double? subtotal,
    String? notes,
    bool? isCompleted,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      hpp: hpp ?? this.hpp,
      subtotal: subtotal ?? this.subtotal,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
