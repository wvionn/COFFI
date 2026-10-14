class PaymentModel {
  final String id;
  final String orderId;
  final String paymentMethod; // 'cash', 'qris', 'transfer'
  final double amountPaid;
  final double changeAmount;
  final String paymentStatus; // 'paid', 'pending', 'refunded'
  final String? referenceNumber;
  final DateTime paidAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.paymentMethod,
    required this.amountPaid,
    this.changeAmount = 0.0,
    this.paymentStatus = 'paid',
    this.referenceNumber,
    required this.paidAt,
  });

  bool get isCash => paymentMethod == 'cash';
  bool get isQris => paymentMethod == 'qris';
  bool get isTransfer => paymentMethod == 'transfer';

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return PaymentModel(
      id: map['id']?.toString() ?? '',
      orderId: map['order_id']?.toString() ?? '',
      paymentMethod: map['payment_method']?.toString().toLowerCase() ?? 'cash',
      amountPaid: (map['amount_paid'] as num?)?.toDouble() ?? 0.0,
      changeAmount: (map['change_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: map['payment_status']?.toString().toLowerCase() ?? 'paid',
      referenceNumber: map['reference_number']?.toString(),
      paidAt: parseDate(map['paid_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'payment_method': paymentMethod,
      'amount_paid': amountPaid,
      'change_amount': changeAmount,
      'payment_status': paymentStatus,
      'reference_number': referenceNumber,
      'paid_at': paidAt.toIso8601String(),
    };
  }
}
