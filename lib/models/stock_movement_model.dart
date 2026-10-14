class StockMovementModel {
  final String id;
  final String productId;
  final String productName;
  final String type; // 'in', 'out', 'adjustment'
  final int quantity;
  final int stockBefore;
  final int stockAfter;
  final String? referenceId;
  final String? notes;
  final DateTime createdAt;

  StockMovementModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    this.referenceId,
    this.notes,
    required this.createdAt,
  });

  bool get isIn => type == 'in';
  bool get isOut => type == 'out';
  bool get isAdjustment => type == 'adjustment';

  factory StockMovementModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return StockMovementModel(
      id: map['id']?.toString() ?? '',
      productId: map['product_id']?.toString() ?? '',
      productName: map['product_name']?.toString() ?? 'Produk',
      type: map['type']?.toString().toLowerCase() ?? 'adjustment',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      stockBefore: (map['stock_before'] as num?)?.toInt() ?? 0,
      stockAfter: (map['stock_after'] as num?)?.toInt() ?? 0,
      referenceId: map['reference_id']?.toString(),
      notes: map['notes']?.toString(),
      createdAt: parseDate(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'type': type,
      'quantity': quantity,
      'stock_before': stockBefore,
      'stock_after': stockAfter,
      'reference_id': referenceId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
