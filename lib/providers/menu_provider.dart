import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/addon_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/stock_movement_model.dart';
import '../services/supabase_service.dart';

class MenuProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService.instance;

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  List<StockMovementModel> _stockMovements = [];
  List<AddonModel>? _addons;

  List<AddonModel> get _addonStore => _addons ??= [
        const AddonModel(
          id: 'addon_1',
          name: 'Extra Shot',
          group: 'TOPPING',
          price: 5000,
          imageUrl: 'assets/images/products/coffi_aren.png',
          isActive: true,
        ),
        const AddonModel(
          id: 'addon_2',
          name: 'Oat Milk',
          group: 'SUSU SUBSTITUSI',
          price: 10000,
          imageUrl: 'assets/images/products/matcha_latte.png',
          isActive: true,
        ),
        const AddonModel(
          id: 'addon_3',
          name: 'Syrup Caramel',
          group: 'FLAVOR',
          price: 5000,
          imageUrl: 'assets/images/products/cafe_latte.png',
          isActive: true,
        ),
        const AddonModel(
          id: 'addon_4',
          name: 'Almond Milk',
          group: 'SUSU SUBSTITUSI',
          price: 10000,
          imageUrl: 'assets/images/products/royal_thai_tea.png',
          isActive: true,
        ),
        const AddonModel(
          id: 'addon_5',
          name: 'Syrup Vanilla',
          group: 'FLAVOR',
          price: 5000,
          imageUrl: 'assets/images/products/cafe_latte.png',
          isActive: true,
        ),
        const AddonModel(
          id: 'addon_6',
          name: 'Whipped Cream',
          group: 'TOPPING',
          price: 6000,
          imageUrl: 'assets/images/products/dark_choco.png',
          isActive: true,
        ),
        const AddonModel(
          id: 'addon_7',
          name: 'Ice / Hot',
          group: 'TEMPERATURE',
          price: 0,
          imageUrl: 'assets/images/products/iced_americano.png',
          isActive: true,
        ),
        const AddonModel(
          id: 'addon_8',
          name: 'Less / No Sugar',
          group: 'SUGAR LEVEL',
          price: 0,
          imageUrl: 'assets/images/products/coffi_aren.png',
          isActive: true,
        ),
      ];

  bool _isLoading = false;

  String? _selectedCategoryId; // null = Semua
  String _searchQuery = '';
  StreamSubscription? _productsSubscription;

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  List<StockMovementModel> get stockMovements => _stockMovements;
  List<AddonModel> get addons => List.unmodifiable(_addonStore);
  List<AddonModel> get activeAddons =>
      _addonStore.where((a) => a.isActive).toList();
  Set<String> get addonGroups => _addonStore.map((a) => a.group).toSet();
  bool get isLoading => _isLoading;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  List<ProductModel> get lowStockProducts =>
      _products.where((p) => p.isLowStock || p.isOutOfStock).toList();

  List<ProductModel> get filteredProducts {
    return _products.where((product) {
      final matchesCategory =
          _selectedCategoryId == null || product.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
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
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      _products[idx] = product;
    } else {
      _products.add(product);
    }
    notifyListeners();

    final success = await _service.saveProduct(product);
    if (success && !_service.isConnected) {
      await refreshProducts();
    }
    return success;
  }

  Future<bool> deleteProduct(String productId) async {
    final success = await _service.deleteProduct(productId);
    if (success) {
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
    }
    return success;
  }

  Future<bool> saveCategory(CategoryModel category) async {
    final success = await _service.saveCategory(category);
    if (success) {
      final idx = _categories.indexWhere((c) => c.id == category.id);
      if (idx != -1) {
        _categories[idx] = category;
      } else {
        _categories.add(category);
      }
      _categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      notifyListeners();
    }
    return success;
  }

  Future<bool> deleteCategory(String categoryId) async {
    final success = await _service.deleteCategory(categoryId);
    if (success) {
      _categories.removeWhere((c) => c.id == categoryId);
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = null;
      }
      notifyListeners();
    }
    return success;
  }

  void saveAddon(AddonModel addon) {
    final store = _addonStore;
    final idx = store.indexWhere((a) => a.id == addon.id);
    if (idx != -1) {
      store[idx] = addon;
    } else {
      store.insert(0, addon);
    }
    notifyListeners();
  }

  void deleteAddon(String addonId) {
    _addonStore.removeWhere((a) => a.id == addonId);
    notifyListeners();
  }

  void toggleAddonActive(String addonId, bool isActive) {
    final store = _addonStore;
    final idx = store.indexWhere((a) => a.id == addonId);
    if (idx != -1) {
      store[idx] = store[idx].copyWith(isActive: isActive);
      notifyListeners();
    }
  }

  Future<bool> toggleSoldOut(String productId, bool isSoldOut) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      _products[idx] = _products[idx].copyWith(isActive: !isSoldOut);
      notifyListeners();
    }
    final success = await _service.toggleProductSoldOut(productId, isSoldOut);
    return success;
  }

  Future<bool> restockProduct({
    required String productId,
    required int quantity,
    required double buyCost,
    String? notes,
  }) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    final currentProduct = idx != -1 ? _products[idx] : null;
    final currentStock = currentProduct?.stock;
    final productName = currentProduct?.name;

    // Optimistic local update so Stok, Produk, and Dashboard update immediately
    if (idx != -1) {
      _products[idx] = _products[idx].copyWith(
        stock: _products[idx].stock + quantity,
        isActive: true,
      );
      notifyListeners();
    }

    final success = await _service.restockProduct(
      productId: productId,
      addQuantity: quantity,
      buyCost: buyCost,
      notes: notes,
      currentStock: currentStock,
      productName: productName,
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
    final idx = _products.indexWhere((p) => p.id == productId);
    final currentProduct = idx != -1 ? _products[idx] : null;
    final currentStock = currentProduct?.stock;
    final productName = currentProduct?.name;

    // Optimistic local update so Stok, Produk, and Dashboard update immediately
    if (idx != -1) {
      _products[idx] = _products[idx].copyWith(
        stock: actualPhysicalStock,
        isActive: actualPhysicalStock > 0,
      );
      notifyListeners();
    }

    final success = await _service.stockOpname(
      productId: productId,
      actualPhysicalStock: actualPhysicalStock,
      reason: reason,
      currentStock: currentStock,
      productName: productName,
    );
    if (success) {
      _stockMovements = await _service.fetchStockMovements();
      notifyListeners();
    }
    return success;
  }

  Future<void> refreshProducts() async {
    _categories = await _service.fetchCategories();
    _products = await _service.fetchProducts();
    _stockMovements = await _service.fetchStockMovements();
    notifyListeners();
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }
}
