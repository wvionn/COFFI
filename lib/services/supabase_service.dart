import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/supabase_config.dart';
import '../models/category_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/payment_model.dart';
import '../models/product_model.dart';
import '../models/stock_movement_model.dart';
import '../models/table_model.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  SupabaseClient? _client;
  bool _isInitialized = false;

  // Stream controllers for Realtime updates
  final _ordersStreamController = StreamController<List<OrderModel>>.broadcast();
  final _tablesStreamController = StreamController<List<TableModel>>.broadcast();
  final _productsStreamController = StreamController<List<ProductModel>>.broadcast();
  final _newOrderAlertController = StreamController<OrderModel>.broadcast();

  Stream<List<OrderModel>> get ordersStream => _ordersStreamController.stream;
  Stream<List<TableModel>> get tablesStream => _tablesStreamController.stream;
  Stream<List<ProductModel>> get productsStream => _productsStreamController.stream;
  Stream<OrderModel> get newOrderAlertStream => _newOrderAlertController.stream;

  // In-memory demo data store (Active fallback and cache)
  final List<CategoryModel> _demoCategories = [];
  final List<TableModel> _demoTables = [];
  final List<ProductModel> _demoProducts = [];
  final List<OrderModel> _demoOrders = [];
  final List<StockMovementModel> _demoStockMovements = [];

  bool get isConnected => _isInitialized && _client != null && SupabaseConfig.isConfigured();

  SupabaseClient get client {
    if (_client == null) {
      throw StateError('Supabase client not initialized yet.');
    }
    return _client!;
  }

  /// Initialize Supabase
  Future<void> initialize() async {
    _initDemoData();

    if (SupabaseConfig.isConfigured()) {
      try {
        await Supabase.initialize(
          url: SupabaseConfig.supabaseUrl,
          anonKey: SupabaseConfig.supabaseAnonKey,
        );
        _client = Supabase.instance.client;
        _isInitialized = true;
        _setupRealtimeSubscriptions();
        debugPrint('Supabase initialized successfully.');
      } catch (e) {
        debugPrint('Supabase initialization error: $e. Operating in Demo/Fallback mode.');
      }
    } else {
      debugPrint('Supabase credentials not configured. Operating in Demo/Fallback mode.');
    }
  }

  void _setupRealtimeSubscriptions() {
    if (_client == null) return;

    try {
      _client!
          .channel('public:orders')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'orders',
            callback: (payload) {
              fetchOrders();
              if (payload.eventType == PostgresChangeEvent.insert) {
                final newRecord = payload.newRecord;
                final newOrder = OrderModel.fromMap(newRecord);
                _newOrderAlertController.add(newOrder);
              }
            },
          )
          .subscribe();

      _client!
          .channel('public:cafe_tables')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'cafe_tables',
            callback: (payload) {
              fetchTables();
            },
          )
          .subscribe();

      _client!
          .channel('public:products')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'products',
            callback: (payload) {
              fetchProducts();
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Realtime channel subscription error: $e');
    }
  }

  // =========================================================================
  // CATEGORIES
  // =========================================================================

  Future<List<CategoryModel>> fetchCategories() async {
    if (isConnected) {
      try {
        final data = await client
            .from('categories')
            .select()
            .order('sort_order', ascending: true);
        final list = (data as List).map((e) => CategoryModel.fromMap(e)).toList();
        return list;
      } catch (e) {
        debugPrint('Error fetchCategories: $e');
      }
    }
    return List.from(_demoCategories);
  }

  // =========================================================================
  // CAFE TABLES
  // =========================================================================

  Future<List<TableModel>> fetchTables() async {
    if (isConnected) {
      try {
        final data = await client
            .from('cafe_tables')
            .select()
            .order('table_number', ascending: true);
        final list = (data as List).map((e) => TableModel.fromMap(e)).toList();
        _tablesStreamController.add(list);
        return list;
      } catch (e) {
        debugPrint('Error fetchTables: $e');
      }
    }
    _tablesStreamController.add(List.from(_demoTables));
    return List.from(_demoTables);
  }

  Future<bool> addTable({
    required String tableNumber,
    String area = 'Indoor',
    int capacity = 4,
  }) async {
    final newTable = TableModel(
      id: const Uuid().v4(),
      tableNumber: tableNumber,
      area: area,
      capacity: capacity,
      status: 'available',
    );

    if (isConnected) {
      try {
        await client.from('cafe_tables').insert(newTable.toMap());
        await fetchTables();
        return true;
      } catch (e) {
        debugPrint('Error addTable: $e');
      }
    }

    _demoTables.add(newTable);
    _tablesStreamController.add(List.from(_demoTables));
    return true;
  }

  Future<int> autoGenerateTables({
    required String prefix,
    required int startNumber,
    required int endNumber,
    String area = 'Indoor',
    int capacity = 4,
  }) async {
    int count = 0;
    final List<TableModel> batch = [];

    for (int i = startNumber; i <= endNumber; i++) {
      final numStr = i < 10 ? '0$i' : '$i';
      final tableNumber = '$prefix $numStr'.trim();

      // Check if already exists in demo
      if (!_demoTables.any((t) => t.tableNumber.toLowerCase() == tableNumber.toLowerCase())) {
        final t = TableModel(
          id: const Uuid().v4(),
          tableNumber: tableNumber,
          area: area,
          capacity: capacity,
          status: 'available',
        );
        batch.add(t);
        count++;
      }
    }

    if (isConnected && batch.isNotEmpty) {
      try {
        await client.from('cafe_tables').insert(batch.map((e) => e.toMap()).toList());
        await fetchTables();
        return count;
      } catch (e) {
        debugPrint('Error autoGenerateTables: $e');
      }
    }

    _demoTables.addAll(batch);
    _tablesStreamController.add(List.from(_demoTables));
    return count;
  }

  Future<bool> updateTableStatus(String tableId, String status, {String? orderId}) async {
    if (isConnected) {
      try {
        await client.from('cafe_tables').update({
          'status': status,
          'current_order_id': orderId,
        }).eq('id', tableId);
        await fetchTables();
        return true;
      } catch (e) {
        debugPrint('Error updateTableStatus: $e');
      }
    }

    final index = _demoTables.indexWhere((t) => t.id == tableId);
    if (index != -1) {
      _demoTables[index] = _demoTables[index].copyWith(
        status: status,
        currentOrderId: orderId,
        clearCurrentOrderId: orderId == null,
      );
      _tablesStreamController.add(List.from(_demoTables));
      return true;
    }
    return false;
  }

  Future<bool> forceFreeTable(String tableId) async {
    return updateTableStatus(tableId, 'available', orderId: null);
  }

  // =========================================================================
  // PRODUCTS & MENU
  // =========================================================================

  Future<List<ProductModel>> fetchProducts() async {
    if (isConnected) {
      try {
        final data = await client
            .from('products')
            .select()
            .order('name', ascending: true);
        final list = (data as List).map((e) => ProductModel.fromMap(e)).toList();
        _productsStreamController.add(list);
        return list;
      } catch (e) {
        debugPrint('Error fetchProducts: $e');
      }
    }
    _productsStreamController.add(List.from(_demoProducts));
    return List.from(_demoProducts);
  }

  Future<bool> saveProduct(ProductModel product) async {
    if (isConnected) {
      try {
        await client.from('products').upsert(product.toMap());
        await fetchProducts();
        return true;
      } catch (e) {
        debugPrint('Error saveProduct: $e');
      }
    }

    final index = _demoProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _demoProducts[index] = product;
    } else {
      _demoProducts.add(product);
    }
    _productsStreamController.add(List.from(_demoProducts));
    return true;
  }

  Future<bool> toggleProductSoldOut(String productId, bool isSoldOut) async {
    // Mode 86: if soldOut -> isActive = false or stock = 0
    if (isConnected) {
      try {
        await client.from('products').update({
          'is_active': !isSoldOut,
        }).eq('id', productId);
        await fetchProducts();
        return true;
      } catch (e) {
        debugPrint('Error toggleProductSoldOut: $e');
      }
    }

    final index = _demoProducts.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _demoProducts[index] = _demoProducts[index].copyWith(isActive: !isSoldOut);
      _productsStreamController.add(List.from(_demoProducts));
      return true;
    }
    return false;
  }

  // =========================================================================
  // STOCK MANAGEMENT & OPNAME
  // =========================================================================

  Future<List<StockMovementModel>> fetchStockMovements() async {
    if (isConnected) {
      try {
        final data = await client
            .from('stock_movements')
            .select()
            .order('created_at', ascending: false)
            .limit(100);
        return (data as List).map((e) => StockMovementModel.fromMap(e)).toList();
      } catch (e) {
        debugPrint('Error fetchStockMovements: $e');
      }
    }
    return List.from(_demoStockMovements);
  }

  Future<bool> restockProduct({
    required String productId,
    required int addQuantity,
    required double buyCost,
    String? notes,
  }) async {
    final product = _demoProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => ProductModel(id: productId, name: 'Produk', price: 0),
    );

    final before = product.stock;
    final after = before + addQuantity;

    final movement = StockMovementModel(
      id: const Uuid().v4(),
      productId: productId,
      productName: product.name,
      type: 'in',
      quantity: addQuantity,
      stockBefore: before,
      stockAfter: after,
      notes: notes ?? 'Restock masuk',
      createdAt: DateTime.now(),
    );

    if (isConnected) {
      try {
        await client.from('products').update({'stock': after}).eq('id', productId);
        await client.from('stock_movements').insert(movement.toMap());
        await fetchProducts();
        return true;
      } catch (e) {
        debugPrint('Error restockProduct: $e');
      }
    }

    final pIndex = _demoProducts.indexWhere((p) => p.id == productId);
    if (pIndex != -1) {
      _demoProducts[pIndex] = _demoProducts[pIndex].copyWith(stock: after);
    }
    _demoStockMovements.insert(0, movement);
    _productsStreamController.add(List.from(_demoProducts));
    return true;
  }

  Future<bool> stockOpname({
    required String productId,
    required int actualPhysicalStock,
    required String reason,
  }) async {
    final product = _demoProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => ProductModel(id: productId, name: 'Produk', price: 0),
    );

    final before = product.stock;
    final diff = actualPhysicalStock - before;

    final movement = StockMovementModel(
      id: const Uuid().v4(),
      productId: productId,
      productName: product.name,
      type: 'adjustment',
      quantity: diff,
      stockBefore: before,
      stockAfter: actualPhysicalStock,
      notes: 'Opname: $reason',
      createdAt: DateTime.now(),
    );

    if (isConnected) {
      try {
        await client.from('products').update({'stock': actualPhysicalStock}).eq('id', productId);
        await client.from('stock_movements').insert(movement.toMap());
        await fetchProducts();
        return true;
      } catch (e) {
        debugPrint('Error stockOpname: $e');
      }
    }

    final pIndex = _demoProducts.indexWhere((p) => p.id == productId);
    if (pIndex != -1) {
      _demoProducts[pIndex] = _demoProducts[pIndex].copyWith(stock: actualPhysicalStock);
    }
    _demoStockMovements.insert(0, movement);
    _productsStreamController.add(List.from(_demoProducts));
    return true;
  }

  // =========================================================================
  // ORDERS & POS TRANSACTIONS
  // =========================================================================

  Future<List<OrderModel>> fetchOrders() async {
    if (isConnected) {
      try {
        final ordersData = await client
            .from('orders')
            .select()
            .order('created_at', ascending: false)
            .limit(100);

        final List<OrderModel> fullOrders = [];
        for (final o in ordersData) {
          final itemsData = await client
              .from('order_items')
              .select()
              .eq('order_id', o['id']);
          final items = (itemsData as List).map((i) => OrderItemModel.fromMap(i)).toList();
          fullOrders.add(OrderModel.fromMap(o, items: items));
        }

        _ordersStreamController.add(fullOrders);
        return fullOrders;
      } catch (e) {
        debugPrint('Error fetchOrders: $e');
      }
    }

    _ordersStreamController.add(List.from(_demoOrders));
    return List.from(_demoOrders);
  }

  Future<OrderModel?> createOrder({
    required String orderType, // 'dine_in' or 'takeaway'
    String? tableId,
    String? tableNumber,
    String? customerName,
    String? cashierId,
    String? cashierName,
    required List<OrderItemModel> items,
    required String paymentMethod, // 'cash', 'qris', 'transfer'
    required double amountPaid,
    required double changeAmount,
    String? generalNotes,
  }) async {
    final orderId = const Uuid().v4();
    final now = DateTime.now();
    final dateCode = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final count = _demoOrders.length + 1;
    final invoiceNumber = "INV/$dateCode/${count.toString().padLeft(4, '0')}";

    double subtotal = 0.0;
    double totalHpp = 0.0;

    final List<OrderItemModel> mappedItems = [];
    for (final item in items) {
      subtotal += item.subtotal;
      totalHpp += (item.hpp * item.quantity);
      mappedItems.add(item.copyWith(
        id: const Uuid().v4(),
        orderId: orderId,
      ));
    }

    final taxAmount = (subtotal * 0.10); // PB1 10%
    final totalAmount = subtotal + taxAmount;

    final order = OrderModel(
      id: orderId,
      invoiceNumber: invoiceNumber,
      orderType: orderType,
      tableId: tableId,
      tableNumber: tableNumber,
      customerName: customerName,
      cashierId: cashierId,
      cashierName: cashierName,
      status: 'pending', // Starts at pending for Kitchen KDS
      subtotalAmount: subtotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      totalHpp: totalHpp,
      notes: generalNotes,
      createdAt: now,
      items: mappedItems,
    );

    final payment = PaymentModel(
      id: const Uuid().v4(),
      orderId: orderId,
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
      changeAmount: changeAmount,
      paymentStatus: 'paid',
      paidAt: now,
    );

    if (isConnected) {
      try {
        await client.from('orders').insert(order.toMap());
        await client.from('order_items').insert(mappedItems.map((e) => e.toMap()).toList());
        await client.from('payments').insert(payment.toMap());

        if (orderType == 'dine_in' && tableId != null) {
          await updateTableStatus(tableId, 'occupied', orderId: orderId);
        }

        await fetchOrders();
        _newOrderAlertController.add(order);
        return order;
      } catch (e) {
        debugPrint('Error createOrder Supabase: $e');
      }
    }

    // In-memory demo execution
    _demoOrders.insert(0, order);

    // Deduct demo product stock
    for (final item in items) {
      if (item.productId != null) {
        final pIdx = _demoProducts.indexWhere((p) => p.id == item.productId);
        if (pIdx != -1) {
          final p = _demoProducts[pIdx];
          if (p.trackStock) {
            final newStock = (p.stock - item.quantity).clamp(0, 9999);
            _demoProducts[pIdx] = p.copyWith(stock: newStock);
            _demoStockMovements.insert(0, StockMovementModel(
              id: const Uuid().v4(),
              productId: p.id,
              productName: p.name,
              type: 'out',
              quantity: item.quantity,
              stockBefore: p.stock,
              stockAfter: newStock,
              referenceId: orderId,
              notes: 'Pesanan Kasir $invoiceNumber',
              createdAt: now,
            ));
          }
        }
      }
    }

    // Update table status if Dine-In
    if (orderType == 'dine_in' && tableId != null) {
      await updateTableStatus(tableId, 'occupied', orderId: orderId);
    }

    _ordersStreamController.add(List.from(_demoOrders));
    _productsStreamController.add(List.from(_demoProducts));
    _newOrderAlertController.add(order);

    return order;
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    if (isConnected) {
      try {
        await client.from('orders').update({
          'status': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', orderId);

        // If completed or cancelled, free table
        if (newStatus == 'selesai' || newStatus == 'dibatalkan') {
          final order = _demoOrders.firstWhere((o) => o.id == orderId, orElse: () => _demoOrders.first);
          if (order.tableId != null) {
            await updateTableStatus(order.tableId!, 'available', orderId: null);
          }
        }

        await fetchOrders();
        return true;
      } catch (e) {
        debugPrint('Error updateOrderStatus: $e');
      }
    }

    final index = _demoOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final current = _demoOrders[index];
      _demoOrders[index] = current.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      // If completed or cancelled, free table
      if ((newStatus == 'selesai' || newStatus == 'dibatalkan') && current.tableId != null) {
        await updateTableStatus(current.tableId!, 'available', orderId: null);
      }

      _ordersStreamController.add(List.from(_demoOrders));
      return true;
    }
    return false;
  }

  Future<bool> toggleOrderItemCompleted(String orderId, String itemId, bool completed) async {
    if (isConnected) {
      try {
        await client.from('order_items').update({
          'is_completed': completed,
        }).eq('id', itemId);
        await fetchOrders();
        return true;
      } catch (e) {
        debugPrint('Error toggleOrderItemCompleted: $e');
      }
    }

    final oIdx = _demoOrders.indexWhere((o) => o.id == orderId);
    if (oIdx != -1) {
      final order = _demoOrders[oIdx];
      final itemIdx = order.items.indexWhere((i) => i.id == itemId);
      if (itemIdx != -1) {
        final updatedItems = List<OrderItemModel>.from(order.items);
        updatedItems[itemIdx] = updatedItems[itemIdx].copyWith(isCompleted: completed);
        _demoOrders[oIdx] = order.copyWith(items: updatedItems);
        _ordersStreamController.add(List.from(_demoOrders));
        return true;
      }
    }
    return false;
  }

  // =========================================================================
  // INITIAL DEMO DATA GENERATOR
  // =========================================================================

  void _initDemoData() {
    if (_demoCategories.isNotEmpty) return;

    _demoCategories.addAll([
      CategoryModel(id: 'c1', name: 'Coffee', icon: 'coffee', sortOrder: 1),
      CategoryModel(id: 'c2', name: 'Non-Coffee', icon: 'local_drink', sortOrder: 2),
      CategoryModel(id: 'c3', name: 'Food & Meal', icon: 'restaurant', sortOrder: 3),
      CategoryModel(id: 'c4', name: 'Snacks', icon: 'fastfood', sortOrder: 4),
      CategoryModel(id: 'c5', name: 'Pastry', icon: 'cake', sortOrder: 5),
    ]);

    _demoTables.addAll([
      TableModel(id: 't1', tableNumber: 'Meja 01', area: 'Indoor', capacity: 4, status: 'available'),
      TableModel(id: 't2', tableNumber: 'Meja 02', area: 'Indoor', capacity: 2, status: 'available'),
      TableModel(id: 't3', tableNumber: 'Meja 03', area: 'Indoor', capacity: 4, status: 'available'),
      TableModel(id: 't4', tableNumber: 'Meja 04', area: 'Indoor', capacity: 4, status: 'available'),
      TableModel(id: 't5', tableNumber: 'Meja 05', area: 'Indoor', capacity: 6, status: 'available'),
      TableModel(id: 't6', tableNumber: 'Outdoor 01', area: 'Outdoor', capacity: 4, status: 'available'),
      TableModel(id: 't7', tableNumber: 'Outdoor 02', area: 'Outdoor', capacity: 4, status: 'available'),
      TableModel(id: 't8', tableNumber: 'VIP Lounge', area: 'VIP', capacity: 8, status: 'available'),
    ]);

    _demoProducts.addAll([
      ProductModel(
        id: 'p1',
        categoryId: 'c1',
        name: 'Kopi Susu Aren',
        description: 'Signature espresso dengan susu segar & gula aren murni',
        price: 22000,
        costPrice: 8500,
        stock: 35,
        minStock: 10,
        trackStock: true,
        isActive: true,
        imageUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500&auto=format&fit=crop&q=60',
      ),
      ProductModel(
        id: 'p2',
        categoryId: 'c1',
        name: 'Americano Iced',
        description: 'Double shot robusta blend dingin segar',
        price: 18000,
        costPrice: 4200,
        stock: 50,
        minStock: 10,
        trackStock: true,
        isActive: true,
        imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&auto=format&fit=crop&q=60',
      ),
      ProductModel(
        id: 'p3',
        categoryId: 'c1',
        name: 'Caramel Macchiato',
        description: 'Espresso creamy dengan sirup vanilla dan saus karamel',
        price: 28000,
        costPrice: 11000,
        stock: 24,
        minStock: 5,
        trackStock: true,
        isActive: true,
        imageUrl: 'https://images.unsplash.com/photo-1485808191679-5f86510681a2?w=500&auto=format&fit=crop&q=60',
      ),
      ProductModel(
        id: 'p4',
        categoryId: 'c2',
        name: 'Matcha Latte',
        description: 'Green tea matcha premium Jepang dengan fresh milk',
        price: 24000,
        costPrice: 9500,
        stock: 20,
        minStock: 5,
        trackStock: true,
        isActive: true,
        imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=500&auto=format&fit=crop&q=60',
      ),
      ProductModel(
        id: 'p5',
        categoryId: 'c2',
        name: 'Chocolate Signature',
        description: 'Cokelat Belgia leleh kental dan harum',
        price: 23000,
        costPrice: 9000,
        stock: 30,
        minStock: 5,
        trackStock: true,
        isActive: true,
        imageUrl: 'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed?w=500&auto=format&fit=crop&q=60',
      ),
      ProductModel(
        id: 'p6',
        categoryId: 'c3',
        name: 'Nasi Goreng Spesial',
        description: 'Nasi goreng harum bumbu rempah dengan telur mata sapi',
        price: 32000,
        costPrice: 14000,
        stock: 15,
        minStock: 5,
        trackStock: true,
        isActive: true,
        imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500&auto=format&fit=crop&q=60',
      ),
      ProductModel(
        id: 'p7',
        categoryId: 'c4',
        name: 'French Fries BBQ',
        description: 'Kentang goreng renyah dengan bumbu tabur BBQ',
        price: 18000,
        costPrice: 7000,
        stock: 4, // Low stock demo!
        minStock: 5,
        trackStock: true,
        isActive: true,
        imageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=500&auto=format&fit=crop&q=60',
      ),
      ProductModel(
        id: 'p8',
        categoryId: 'c4',
        name: 'Roti Bakar Coklat Keju',
        description: 'Roti panggang mentega dengan meses dan keju melimpah',
        price: 20000,
        costPrice: 8000,
        stock: 12,
        minStock: 4,
        trackStock: true,
        isActive: true,
        imageUrl: 'https://images.unsplash.com/photo-1584776296944-ab6fb57b0bdd?w=500&auto=format&fit=crop&q=60',
      ),
      ProductModel(
        id: 'p9',
        categoryId: 'c5',
        name: 'Croissant Butter',
        description: 'Roti Prancis renyah lembut dengan aroma mentega',
        price: 25000,
        costPrice: 11500,
        stock: 0, // Sold out demo!
        minStock: 3,
        trackStock: true,
        isActive: false,
        imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500&auto=format&fit=crop&q=60',
      ),
    ]);

    // Initial demo order for Kitchen Display demonstration
    final demoOrderId = 'ord_demo_01';
    final demoItems = [
      OrderItemModel(
        id: 'item_1',
        orderId: demoOrderId,
        productId: 'p1',
        productName: 'Kopi Susu Aren',
        quantity: 2,
        unitPrice: 22000,
        hpp: 8500,
        subtotal: 44000,
        notes: 'Dingin (Iced), Less Sugar, Es Sedikit',
      ),
      OrderItemModel(
        id: 'item_2',
        orderId: demoOrderId,
        productId: 'p7',
        productName: 'French Fries BBQ',
        quantity: 1,
        unitPrice: 18000,
        hpp: 7000,
        subtotal: 18000,
        notes: 'Saus sambal dipisah',
      ),
    ];

    _demoOrders.add(OrderModel(
      id: demoOrderId,
      invoiceNumber: 'INV/20261005/0001',
      orderType: 'dine_in',
      tableId: 't3',
      tableNumber: 'Meja 03',
      cashierId: 'kasir_1',
      cashierName: 'Siti Rahma',
      status: 'pending',
      subtotalAmount: 62000,
      taxAmount: 6200,
      totalAmount: 68200,
      totalHpp: 24000,
      notes: 'Makanan tolong dikeluarkan bersamaan',
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      items: demoItems,
    ));

    // Mark Meja 03 as occupied
    final m3Index = _demoTables.indexWhere((t) => t.id == 't3');
    if (m3Index != -1) {
      _demoTables[m3Index] = _demoTables[m3Index].copyWith(
        status: 'occupied',
        currentOrderId: demoOrderId,
      );
    }
  }
}
