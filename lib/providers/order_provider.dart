import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/utils/sound_service.dart';
import '../models/order_model.dart';
import '../services/supabase_service.dart';

class OrderProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService.instance;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  OrderModel? _incomingAlertOrder;
  bool _soundEnabled = true;

  StreamSubscription? _ordersSubscription;
  StreamSubscription? _alertSubscription;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  OrderModel? get incomingAlertOrder => _incomingAlertOrder;
  bool get soundEnabled => _soundEnabled;

  // Kitchen KDS & Cashier categorizations
  List<OrderModel> get waitingValidationOrders => _orders.where((o) => o.isWaitingValidation).toList();
  List<OrderModel> get newKitchenOrders => _orders.where((o) => o.isPending).toList();
  List<OrderModel> get inProgressKitchenOrders => _orders.where((o) => o.isProcessing).toList();
  List<OrderModel> get readyKitchenOrders => _orders.where((o) => o.isReady).toList();
  List<OrderModel> get deliveringOrders => _orders.where((o) => o.isDelivering).toList();
  List<OrderModel> get completedOrders => _orders.where((o) => o.isCompleted).toList();

  int get activeTicketsCount => newKitchenOrders.length + inProgressKitchenOrders.length;

  OrderProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _orders = await _service.fetchOrders();
    _isLoading = false;
    notifyListeners();

    _ordersSubscription?.cancel();
    _ordersSubscription = _service.ordersStream.listen((updatedList) {
      _orders = updatedList;
      notifyListeners();
    });

    _alertSubscription?.cancel();
    _alertSubscription = _service.newOrderAlertStream.listen((newOrder) {
      _incomingAlertOrder = newOrder;
      if (_soundEnabled) {
        SoundService.playOrderChime();
      }
      notifyListeners();
    });
  }

  void toggleSoundAlert() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  void dismissAlert() {
    _incomingAlertOrder = null;
    notifyListeners();
  }

  Future<bool> updateStatus(String orderId, String newStatus) async {
    final success = await _service.updateOrderStatus(orderId, newStatus);
    if (success) {
      SoundService.playSuccessChime();
    }
    return success;
  }

  Future<bool> toggleItemChecklist(String orderId, String itemId, bool currentVal) async {
    return await _service.toggleOrderItemCompleted(orderId, itemId, !currentVal);
  }

  List<OrderModel> getCustomerOrders({String? customerId, String? customerName}) {
    return _orders.where((o) {
      if (customerId != null && o.customerId == customerId) return true;
      if (customerName != null &&
          customerName.isNotEmpty &&
          o.customerName?.toLowerCase().trim() == customerName.toLowerCase().trim()) {
        return true;
      }
      return false;
    }).toList();
  }

  Future<OrderModel?> checkout({
    required String orderType,
    String? tableId,
    String? tableNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    String? cashierId,
    String? cashierName,
    required List<dynamic> items,
    required String paymentMethod,
    required double amountPaid,
    required double changeAmount,
    String? generalNotes,
    String initialStatus = 'pending',
  }) async {
    _isLoading = true;
    notifyListeners();

    final order = await _service.createOrder(
      orderType: orderType,
      tableId: tableId,
      tableNumber: tableNumber,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
      cashierId: cashierId,
      cashierName: cashierName,
      items: items.cast(),
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
      changeAmount: changeAmount,
      generalNotes: generalNotes,
      initialStatus: initialStatus,
    );

    _isLoading = false;
    notifyListeners();
    return order;
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _alertSubscription?.cancel();
    super.dispose();
  }
}
