import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String invoiceNumber;
  final String orderType; // 'dine_in', 'takeaway'
  final String? tableId;
  final String? tableNumber;
  final String? customerName;
  final String? cashierId;
  final String? cashierName;
  final String status; // 'pending', 'diproses', 'siap', 'selesai', 'dibatalkan'
  final double subtotalAmount;
  final double taxAmount; // PB1 10%
  final double totalAmount;
  final double totalHpp;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.invoiceNumber,
    this.orderType = 'dine_in',
    this.tableId,
    this.tableNumber,
    this.customerName,
    this.cashierId,
    this.cashierName,
    this.status = 'pending',
    required this.subtotalAmount,
    this.taxAmount = 0.0,
    required this.totalAmount,
    this.totalHpp = 0.0,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  bool get isDineIn => orderType == 'dine_in';
  bool get isTakeaway => orderType == 'takeaway';

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'diproses';
  bool get isReady => status == 'siap';
  bool get isCompleted => status == 'selesai';
  bool get isCancelled => status == 'dibatalkan';

  int get elapsedMinutes => DateTime.now().difference(createdAt).inMinutes;

  String get elapsedTimeString {
    final diff = DateTime.now().difference(createdAt);
    final minutes = diff.inMinutes.toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, {List<OrderItemModel>? items}) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return OrderModel(
      id: map['id']?.toString() ?? '',
      invoiceNumber: map['invoice_number']?.toString() ?? '',
      orderType: map['order_type']?.toString().toLowerCase() ?? 'dine_in',
      tableId: map['table_id']?.toString(),
      tableNumber: map['table_number']?.toString(),
      customerName: map['customer_name']?.toString(),
      cashierId: map['cashier_id']?.toString(),
      cashierName: map['cashier_name']?.toString(),
      status: map['status']?.toString().toLowerCase() ?? 'pending',
      subtotalAmount: (map['subtotal_amount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['tax_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      totalHpp: (map['total_hpp'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes']?.toString(),
      createdAt: parseDate(map['created_at']),
      updatedAt: map['updated_at'] != null ? parseDate(map['updated_at']) : null,
      items: items ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'order_type': orderType,
      'table_id': tableId,
      'table_number': tableNumber,
      'customer_name': customerName,
      'cashier_id': cashierId,
      'cashier_name': cashierName,
      'status': status,
      'subtotal_amount': subtotalAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'total_hpp': totalHpp,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? invoiceNumber,
    String? orderType,
    String? tableId,
    String? tableNumber,
    String? customerName,
    String? cashierId,
    String? cashierName,
    String? status,
    double? subtotalAmount,
    double? taxAmount,
    double? totalAmount,
    double? totalHpp,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      orderType: orderType ?? this.orderType,
      tableId: tableId ?? this.tableId,
      tableNumber: tableNumber ?? this.tableNumber,
      customerName: customerName ?? this.customerName,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      status: status ?? this.status,
      subtotalAmount: subtotalAmount ?? this.subtotalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      totalHpp: totalHpp ?? this.totalHpp,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}
