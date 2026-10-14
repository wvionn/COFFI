import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/stock_movement_model.dart';
import '../services/supabase_service.dart';

class MenuProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService.instance;

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  List<StockMovementModel> _stockMovements = [];
  bool _isLoading = false;

  String? _selectedCategoryId; // null = Semua
  String _searchQuery = '';
  StreamSubscription? _productsSubscription;

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  List<StockMovementModel> get stockMovements => _stockMovements;
  bool get isLoading => _isLoading;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  List<ProductModel> get lowStockProducts => _products.where((p) => p.isLowStock || p.isOutOfStock).toList();

  List<ProductModel> get filteredProducts {
    return _products.where((product) {
      final matchesCategory = _selectedCategoryId == null || product.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  MenuProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _categories = await _service.fetchCategories();
    _products = await _service.fetchProducts();
    _stockMovements = await _service.fetchStockMovements();

    _isLoading = false;
    notifyListeners();

    _productsSubscription?.cancel();
    _productsSubscription = _service.productsStream.listen((updatedList) {
      _products = updatedList;
      notifyListeners();
    });
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> saveProduct(ProductModel product) async {
    final success = await _service.saveProduct(product);
    if (success) {
      await refreshProducts();
    }
    return success;
  }

  Future<bool> toggleSoldOut(String productId, bool isSoldOut) async {
    final success = await _service.toggleProductSoldOut(productId, isSoldOut);
    return success;
  }

  Future<bool> restockProduct({
    required String productId,
    required int quantity,
    required double buyCost,
    String? notes,
  }) async {
    final success = await _service.restockProduct(
      productId: productId,
      addQuantity: quantity,
      buyCost: buyCost,
      notes: notes,
    );
    if (success) {
      _stockMovements = await _service.fetchStockMovements();
      notifyListeners();
    }
    return success;
  }

  Future<bool> stockOpname({
    required String productId,
    required int actualPhysicalStock,
    required String reason,
  }) async {
    final success = await _service.stockOpname(
      productId: productId,
      actualPhysicalStock: actualPhysicalStock,
      reason: reason,
    );
    if (success) {
      _stockMovements = await _service.fetchStockMovements();
      notifyListeners();
    }
    return success;
  }

  Future<void> refreshProducts() async {
    _products = await _service.fetchProducts();
    notifyListeners();
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }
}
