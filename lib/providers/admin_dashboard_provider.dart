import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class CategorySalesStat {
  final String categoryId;
  final String categoryName;
  final int itemCount;
  final double revenue;

  const CategorySalesStat({
    required this.categoryId,
    required this.categoryName,
    required this.itemCount,
    required this.revenue,
  });
}

class ShiftReportSummary {
  final String key;
  final String cashierName;
  final DateTime date;
  final String shiftLabel; // 'Shift Pagi' | 'Shift Sore'
  final double systemTotal;
  final double cashTotal;
  final double qrisTotal;
  final int orderCount;
  final double physicalTotal;
  final bool isReconciled;

  const ShiftReportSummary({
    required this.key,
    required this.cashierName,
    required this.date,
    required this.shiftLabel,
    required this.systemTotal,
    required this.cashTotal,
    required this.qrisTotal,
    required this.orderCount,
    required this.physicalTotal,
    required this.isReconciled,
  });

  double get variance => physicalTotal - systemTotal;
  bool get isBalanced => variance.abs() < 1;
}

class AdminDashboardProvider extends ChangeNotifier {
  static const String _reconciliationPrefsKey = 'admin_shift_reconciliations_v1';

  String _selectedPeriod = 'Hari Ini';
  DateTimeRange? _customDateRange;
  Map<String, double>? _reconciledPhysicalTotals;
  bool _prefsLoaded = false;

  String get selectedPeriod => _selectedPeriod;
  DateTimeRange? get customDateRange => _customDateRange;

  Map<String, double> get _reconciliations {
    _reconciledPhysicalTotals ??= {};
    return _reconciledPhysicalTotals!;
  }

  AdminDashboardProvider() {
    _loadReconciliations();
  }

  Future<void> _loadReconciliations() async {
    if (_prefsLoaded) return;
    _prefsLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_reconciliationPrefsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _reconciledPhysicalTotals = decoded.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        );
        notifyListeners();
      }
    } catch (_) {
      // Ignore SharedPreferences failures in test/web environments
    }
  }

  Future<void> recordShiftReconciliation(
    String shiftKey,
    double physicalTotal,
  ) async {
    _reconciliations[shiftKey] = physicalTotal;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _reconciliationPrefsKey,
        jsonEncode(_reconciliations),
      );
    } catch (_) {
      // Ignore persistence failures
    }
  }

  Future<void> resetShiftReconciliation(String shiftKey) async {
    _reconciliations.remove(shiftKey);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _reconciliationPrefsKey,
        jsonEncode(_reconciliations),
      );
    } catch (_) {
      // Ignore persistence failures
    }
  }

  void setPeriod(String period) {
    _selectedPeriod = period;
    if (period != 'Kustom') {
      _customDateRange = null;
    }
    notifyListeners();
  }

  void setCustomDateRange(DateTimeRange range) {
    _customDateRange = DateTimeRange(
      start: DateTime(range.start.year, range.start.month, range.start.day),
      end: DateTime(
        range.end.year,
        range.end.month,
        range.end.day,
        23,
        59,
        59,
      ),
    );
    _selectedPeriod = 'Kustom';
    notifyListeners();
  }

  DateTimeRange getEffectiveDateRange() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_selectedPeriod == 'Kustom' && _customDateRange != null) {
      return _customDateRange!;
    }
    if (_selectedPeriod == 'Kemarin') {
      final y = startOfToday.subtract(const Duration(days: 1));
      return DateTimeRange(
        start: y,
        end: DateTime(y.year, y.month, y.day, 23, 59, 59),
      );
    }
    if (_selectedPeriod == '7 Hari Terakhir') {
      return DateTimeRange(
        start: startOfToday.subtract(const Duration(days: 6)),
        end: endOfToday,
      );
    }
    if (_selectedPeriod == 'Bulan Ini') {
      final firstOfMonth = DateTime(now.year, now.month, 1);
      final lastOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      return DateTimeRange(start: firstOfMonth, end: lastOfMonth);
    }
    if (_selectedPeriod == 'Semua') {
      return DateTimeRange(
        start: DateTime(now.year, 1, 1),
        end: endOfToday,
      );
    }
    return DateTimeRange(start: startOfToday, end: endOfToday);
  }

  bool _matchesSelectedPeriod(DateTime dt) {
    final now = DateTime.now();
    if (_selectedPeriod == 'Semua') return true;
    if (_selectedPeriod == 'Kustom' && _customDateRange != null) {
      return !dt.isBefore(_customDateRange!.start) &&
          !dt.isAfter(_customDateRange!.end);
    }
    if (_selectedPeriod == 'Hari Ini') {
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    }
    if (_selectedPeriod == 'Kemarin') {
      final yesterday = now.subtract(const Duration(days: 1));
      return dt.year == yesterday.year &&
          dt.month == yesterday.month &&
          dt.day == yesterday.day;
    }
    if (_selectedPeriod == '7 Hari Terakhir') {
      final diff = now.difference(dt);
      return diff.inDays <= 7 && !dt.isAfter(now.add(const Duration(days: 1)));
    }
    if (_selectedPeriod == 'Bulan Ini') {
      return dt.year == now.year && dt.month == now.month;
    }
    return true;
  }

  /// Filter valid (paid/active/completed, non-cancelled) orders based on selected period.
  List<OrderModel> getFilteredOrders(List<OrderModel> allOrders) {
    return allOrders.where((order) {
      if (order.isCancelled || order.isWaitingValidation) return false;
      return _matchesSelectedPeriod(order.createdAt);
    }).toList();
  }

  /// Filter ALL orders (including cancelled) for Riwayat Transaksi.
  List<OrderModel> getFilteredOrdersIncludingCancelled(
    List<OrderModel> allOrders,
  ) {
    final list = allOrders
        .where((order) => _matchesSelectedPeriod(order.createdAt))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  double calculateTotalOmset(List<OrderModel> orders) {
    return orders
        .where((o) => !o.isCancelled && !o.isWaitingValidation)
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double calculateCashTotal(List<OrderModel> orders) {
    return orders
        .where((o) => !o.isCancelled && !o.isWaitingValidation && o.isCashPayment)
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double calculateQrisTotal(List<OrderModel> orders) {
    return orders
        .where((o) =>
            !o.isCancelled &&
            !o.isWaitingValidation &&
            o.isQrisOrDigitalPayment)
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double calculateTotalHpp(List<OrderModel> orders) {
    return orders
        .where((o) => !o.isCancelled && !o.isWaitingValidation)
        .fold(0.0, (sum, o) => sum + o.totalHpp);
  }

  double calculateGrossProfit(List<OrderModel> orders) {
    return calculateTotalOmset(orders) - calculateTotalHpp(orders);
  }

  double calculateAverageMargin(List<OrderModel> orders) {
    final omset = calculateTotalOmset(orders);
    if (omset <= 0) return 0.0;
    return (calculateGrossProfit(orders) / omset) * 100;
  }

  double calculateAverageOrderValue(List<OrderModel> orders) {
    final valid = orders.where((o) => !o.isCancelled).toList();
    if (valid.isEmpty) return 0.0;
    return calculateTotalOmset(valid) / valid.length;
  }

  Map<String, int> getTopSellingItems(List<OrderModel> orders) {
    final Map<String, int> counts = {};
    for (final order in orders) {
      if (order.isCancelled) continue;
      for (final item in order.items) {
        counts[item.productName] =
            (counts[item.productName] ?? 0) + item.quantity;
      }
    }
    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries.take(5));
  }

  /// Groups revenue and sold item counts by product category.
  List<CategorySalesStat> getCategorySalesStats(
    List<OrderModel> orders,
    List<ProductModel> products,
    List<CategoryModel> categories,
  ) {
    final productById = <String, ProductModel>{
      for (final p in products) p.id: p,
    };
    final productByName = <String, ProductModel>{
      for (final p in products) p.name.toLowerCase().trim(): p,
    };
    final categoryById = <String, CategoryModel>{
      for (final c in categories) c.id: c,
    };

    final Map<String, ({String name, int qty, double rev})> acc = {};

    for (final order in orders) {
      if (order.isCancelled) continue;
      for (final item in order.items) {
        ProductModel? matched;
        if (item.productId != null) {
          matched = productById[item.productId!];
        }
        matched ??= productByName[item.productName.toLowerCase().trim()];

        String catId = matched?.categoryId ?? 'other';
        String catName = categoryById[catId]?.name ?? _inferCategoryName(item.productName);
        if (catId == 'other') {
          catId = catName.toLowerCase();
        }

        final prev = acc[catId];
        acc[catId] = (
          name: catName,
          qty: (prev?.qty ?? 0) + item.quantity,
          rev: (prev?.rev ?? 0.0) + item.subtotal,
        );
      }
    }

    final result = acc.entries
        .map(
          (e) => CategorySalesStat(
            categoryId: e.key,
            categoryName: e.value.name,
            itemCount: e.value.qty,
            revenue: e.value.rev,
          ),
        )
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return result;
  }

  String _inferCategoryName(String productName) {
    final lower = productName.toLowerCase();
    if (lower.contains('croissant') ||
        lower.contains('fries') ||
        lower.contains('roti') ||
        lower.contains('nasi') ||
        lower.contains('pastry') ||
        lower.contains('cake') ||
        lower.contains('toast')) {
      return 'Makanan & Pastry';
    }
    if (lower.contains('kopi') ||
        lower.contains('latte') ||
        lower.contains('espresso') ||
        lower.contains('americano') ||
        lower.contains('aren') ||
        lower.contains('tea') ||
        lower.contains('matcha') ||
        lower.contains('choco')) {
      return 'Minuman';
    }
    return 'Lain-lain';
  }

  /// Generates Z-Report shift summaries grouped by (Date + Shift Pagi/Sore + Kasir).
  List<ShiftReportSummary> getShiftSummaries(List<OrderModel> orders) {
    final Map<
        String,
        ({
          String cashier,
          DateTime date,
          String shiftLabel,
          double systemTotal,
          double cashTotal,
          double qrisTotal,
          int orderCount,
        })> grouped = {};

    for (final order in orders) {
      if (order.isCancelled) continue;
      final dt = order.createdAt;
      final dateOnly = DateTime(dt.year, dt.month, dt.day);
      final shiftLabel = dt.hour < 15 ? 'Shift Pagi' : 'Shift Sore';
      final rawCashier = order.cashierName?.trim();
      final cashier =
          (rawCashier == null || rawCashier.isEmpty) ? 'Kasir Outlet' : rawCashier;

      final key =
          '${dateOnly.year}-${dateOnly.month}-${dateOnly.day}|$shiftLabel|$cashier';
      final prev = grouped[key];
      grouped[key] = (
        cashier: cashier,
        date: dateOnly,
        shiftLabel: shiftLabel,
        systemTotal: (prev?.systemTotal ?? 0.0) + order.totalAmount,
        cashTotal:
            (prev?.cashTotal ?? 0.0) + (order.isCashPayment ? order.totalAmount : 0.0),
        qrisTotal: (prev?.qrisTotal ?? 0.0) +
            (order.isQrisOrDigitalPayment ? order.totalAmount : 0.0),
        orderCount: (prev?.orderCount ?? 0) + 1,
      );
    }

    final summaries = grouped.entries.map((entry) {
      final data = entry.value;
      final hasReconciled = _reconciliations.containsKey(entry.key);
      final physical = _reconciliations[entry.key] ?? data.systemTotal;
      return ShiftReportSummary(
        key: entry.key,
        cashierName: data.cashier,
        date: data.date,
        shiftLabel: data.shiftLabel,
        systemTotal: data.systemTotal,
        cashTotal: data.cashTotal,
        qrisTotal: data.qrisTotal,
        orderCount: data.orderCount,
        physicalTotal: physical,
        isReconciled: hasReconciled,
      );
    }).toList();

    summaries.sort((a, b) {
      final cmpDate = b.date.compareTo(a.date);
      if (cmpDate != 0) return cmpDate;
      // Shift Sore appears above Shift Pagi on the same day
      if (a.shiftLabel != b.shiftLabel) {
        return a.shiftLabel == 'Shift Sore' ? -1 : 1;
      }
      return b.systemTotal.compareTo(a.systemTotal);
    });

    return summaries;
  }
}
