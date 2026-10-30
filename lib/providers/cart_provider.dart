import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/order_item_model.dart';
import '../models/product_model.dart';
import '../models/table_model.dart';

class CartProvider extends ChangeNotifier {
  String _orderType = 'dine_in'; // 'dine_in', 'takeaway', 'delivery'
  TableModel? _selectedTable;
  String _customerName = '';
  String _generalNotes = '';
  String _deliveryAddress = '';
  String _customerPhone = '';

  final List<OrderItemModel> _items = [];

  String get orderType => _orderType;
  bool get isDineIn => _orderType == 'dine_in';
  bool get isTakeaway => _orderType == 'takeaway';
  bool get isDelivery => _orderType == 'delivery';

  TableModel? get selectedTable => _selectedTable;
  String get customerName => _customerName;
  String get generalNotes => _generalNotes;
  String get deliveryAddress => _deliveryAddress;
  String get customerPhone => _customerPhone;

  List<OrderItemModel> get items => List.unmodifiable(_items);

  int get totalItemsCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotalAmount => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get taxAmount => subtotalAmount * 0.10; // PB1 Tax 10%

  double get totalAmount => subtotalAmount + taxAmount;

  void setOrderType(String type) {
    _orderType = type;
    if (_orderType != 'dine_in') {
      _selectedTable = null;
    }
    notifyListeners();
  }

  void setSelectedTable(TableModel? table) {
    _selectedTable = table;
    notifyListeners();
  }

  void setCustomerName(String name) {
    _customerName = name;
    notifyListeners();
  }

  void setGeneralNotes(String notes) {
    _generalNotes = notes;
    notifyListeners();
  }

  void setDeliveryAddress(String address) {
    _deliveryAddress = address;
    notifyListeners();
  }

  void setCustomerPhone(String phone) {
    _customerPhone = phone;
    notifyListeners();
  }

  void addItem({
    required ProductModel product,
    int quantity = 1,
    String? notes,
  }) {
    // Check if identical item with exact same notes already exists
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.id && (item.notes ?? '') == (notes ?? ''),
    );

    if (existingIndex != -1) {
      final current = _items[existingIndex];
      final newQty = current.quantity + quantity;
      _items[existingIndex] = current.copyWith(
        quantity: newQty,
        subtotal: current.unitPrice * newQty,
      );
    } else {
      final newItem = OrderItemModel(
        id: const Uuid().v4(),
        orderId: '',
        productId: product.id,
        productName: product.name,
        quantity: quantity,
        unitPrice: product.price,
        hpp: product.costPrice,
        subtotal: product.price * quantity,
        notes: notes,
      );
      _items.add(newItem);
    }
    notifyListeners();
  }

  void incrementItem(String itemId) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      updateQuantity(itemId, _items[index].quantity + 1);
    }
  }

  void decrementItem(String itemId) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      updateQuantity(itemId, _items[index].quantity - 1);
    }
  }

  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      final current = _items[index];
      _items[index] = current.copyWith(
        quantity: newQuantity,
        subtotal: current.unitPrice * newQuantity,
      );
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((i) => i.id == itemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _customerName = '';
    _generalNotes = '';
    _deliveryAddress = '';
    _customerPhone = '';
    notifyListeners();
  }

  void resetAll() {
    _items.clear();
    _selectedTable = null;
    _customerName = '';
    _generalNotes = '';
    _deliveryAddress = '';
    _customerPhone = '';
    _orderType = 'dine_in';
    notifyListeners();
  }
}
