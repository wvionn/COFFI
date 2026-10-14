class TableModel {
  final String id;
  final String tableNumber;
  final String area; // 'Indoor', 'Outdoor', 'VIP'
  final int capacity;
  final String status; // 'available', 'occupied', 'reserved'
  final String? currentOrderId;

  TableModel({
    required this.id,
    required this.tableNumber,
    this.area = 'Indoor',
    this.capacity = 4,
    this.status = 'available',
    this.currentOrderId,
  });

  bool get isAvailable => status == 'available';
  bool get isOccupied => status == 'occupied';
  bool get isReserved => status == 'reserved';

  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
      id: map['id']?.toString() ?? '',
      tableNumber: map['table_number']?.toString() ?? '',
      area: map['area']?.toString() ?? 'Indoor',
      capacity: (map['capacity'] as num?)?.toInt() ?? 4,
      status: map['status']?.toString() ?? 'available',
      currentOrderId: map['current_order_id']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'table_number': tableNumber,
      'area': area,
      'capacity': capacity,
      'status': status,
      'current_order_id': currentOrderId,
    };
  }

  TableModel copyWith({
    String? id,
    String? tableNumber,
    String? area,
    int? capacity,
    String? status,
    String? currentOrderId,
    bool clearCurrentOrderId = false,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      area: area ?? this.area,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      currentOrderId: clearCurrentOrderId ? null : (currentOrderId ?? this.currentOrderId),
    );
  }
}
